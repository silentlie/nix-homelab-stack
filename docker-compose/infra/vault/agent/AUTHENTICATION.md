# Vault Agent authentication: RoleID with Docker network binding

**Status:** Accepted on 2026-11-16. **Scope:** the NixOS infra host's Docker Compose `vault-agent`.

## Decision

Use Vault Agent AppRole auto-auth with **RoleID-only authentication**, constrained by the Agent's source IP:

- AppRole: `infra-vault-agent`.
- `bind_secret_id = false`.
- `secret_id_bound_cidrs = ["172.20.0.3/32"]` to restrict the login source address.
- `token_bound_cidrs = ["172.20.0.3/32"]` to restrict subsequent use of tokens issued by this role.
- The RoleID remains at `/vault/file/approle/role_id`; no SecretID file is used.
- Docker Compose pins primary Vault to `172.20.0.2` and Vault Agent to `172.20.0.3` on the dedicated `infra_agent` bridge.
- The `agent` bridge is internal, uses `172.20.0.0/16`, and is attached only to primary Vault and Vault Agent.
- Do not reuse the Transit Vault auto-unseal token for Agent authentication.

This deliberately trades the second AppRole credential for a narrow network-origin constraint. It removes manual SecretID delivery on cold starts. It is acceptable for this single-operator homelab because Docker host/root compromise is already outside the threat model, but it is **not cryptographic machine identity**.

## Why this works

Vault always requires a RoleID. With `bind_secret_id=false`, Vault does not require a SecretID. HashiCorp documents that the AppRole login endpoint still evaluates other configured constraints, including client IP CIDR restrictions.

The name `secret_id_bound_cidrs` is misleading for this configuration: it is the AppRole role-level CIDR list that restricts which client IPs may perform login, even when the SecretID requirement is disabled. `token_bound_cidrs` additionally binds the issued token to the permitted client IP.

The Agent connects to primary Vault at `http://vault:8200` over the dedicated Docker bridge. Vault sees the Agent source address as `172.20.0.3`. The static address makes that source constraint deterministic across container recreation.

## Network trust boundary

| Component | Address on `infra_agent` | Other networks |
| --- | --- | --- |
| Primary Vault | `172.20.0.2` | `homelab`, `transit`, `db` |
| Vault Agent | `172.20.0.3` | None |

The `infra_agent` bridge is configured with:

- Subnet: `172.20.0.0/16`
- Gateway: `172.20.0.1`
- `internal: true`

Only Vault and Vault Agent should be attached to this network. Treat network membership and Docker daemon access as privileged. Do not attach application containers, debugging containers, or unrelated services to it.

The internal bridge prevents the Agent from using this network for external connectivity. Primary Vault remains multi-homed and retains connectivity through its other networks. Docker's host remains able to administer and access bridge networks; `internal: true` does not protect against host root or Docker daemon compromise.

## Security trade-offs

| Scenario | Expected result |
| --- | --- |
| Internet attacker or ordinary LAN device | Cannot directly join the Docker bridge or originate from the permitted Agent address |
| Container on another bridge | Cannot directly use the Agent network identity |
| Container deliberately attached to `infra_agent` | Inside the trusted network boundary; its own IP is still outside the `/32` restriction |
| Vault Agent container compromise | Attacker can read the RoleID and use the Agent's allowed source address; treat as compromise of the Agent's Vault identity |
| Docker daemon or host-root compromise | Attacker can control containers/networking and impersonate the Agent; out of scope |
| Proxmox/VM host compromise | Can ultimately control the guest and its secrets; out of scope |

RoleID-only is weaker than RoleID + SecretID against an attacker who can obtain the RoleID **and** originate traffic from `172.20.0.3`. The CIDR controls reduce exposure to other workloads, but they are network controls, not cryptographic proof of process identity.

Keep the RoleID file within the Agent-only bind mount. Recommended host permissions are owner UID:GID `100:1000`, directory mode `0700`, and file mode `0600`, provided the Vault Agent process continues to run as UID 100/GID 1000. Never commit the RoleID value to Git or expose it in logs.

## Configure the live AppRole

The AppRole is live Vault state, not provisioned by the Compose files. Apply these changes to the **primary Vault**, using an administrative token. Do not use the Transit Vault token.

First inspect the current role and record its existing policies and token settings:

```sh
vault read auth/approle/role/infra-vault-agent
```

Use the individual property endpoints below so the existing token policies, TTLs, and other role settings are preserved. Apply the CIDR restrictions before disabling SecretID:

```sh
vault write auth/approle/role/infra-vault-agent/secret-id-bound-cidrs \
  secret_id_bound_cidrs="172.20.0.3/32"

vault write auth/approle/role/infra-vault-agent/token-bound-cidrs \
  token_bound_cidrs="172.20.0.3/32"

vault write auth/approle/role/infra-vault-agent/bind-secret-id \
  bind_secret_id=false
```

Verify the resulting role:

```sh
vault read auth/approle/role/infra-vault-agent
vault read auth/approle/role/infra-vault-agent/role-id
```

Expected role values:

- `bind_secret_id: false`
- `secret_id_bound_cidrs: [172.20.0.3/32]`
- `token_bound_cidrs: [172.20.0.3/32]`

Confirm the existing `token_policies`, `token_ttl`, and `token_max_ttl` remain as intended. Do not replace the whole role configuration with a partial `vault write auth/approle/role/infra-vault-agent ...` request: omitted role fields may be reset to defaults.

## Deploy the Docker network and Agent configuration

Run from `docker-compose/infra`. The current live network already uses the same subnet and addresses, but Docker cannot change an existing bridge's `internal` setting in place. Recreate only the two containers attached to `infra_agent` and then recreate that network:

```sh
docker compose rm -sf vault-agent vault
docker network rm infra_agent
docker compose up -d vault vault-agent
```

This removes only the two containers, not the bind-mounted Vault data. Do **not** add `-v` to the removal command. Other application containers are not attached to `infra_agent` and should remain running.

Verify the network and addresses:

```sh
docker network inspect infra_agent
docker inspect vault vault-agent --format \
  '{{.Name}} {{range $name, $net := .NetworkSettings.Networks}}{{$name}}={{$net.IPAddress}} {{end}}'
```

Expected addresses on `infra_agent`:

- `vault=172.20.0.2`
- `vault-agent=172.20.0.3`

Confirm `Internal` is `true` in the network inspection and that only those two containers are attached.

Then inspect Agent authentication and template rendering:

```sh
docker compose ps vault vault-agent
docker compose logs --tail=100 vault-agent
```

The Agent should authenticate without a SecretID file, write a new token to `/vault/file/token`, and render its configured templates. Its existing health check should become healthy when the PostgreSQL template is present.

Tokens issued before the `token_bound_cidrs` change do not retroactively gain that restriction. After confirming the new RoleID-only login works, revoke the old Agent token and let the Agent authenticate again so its token sink contains a token carrying the new CIDR restriction. Treat the token sink as sensitive; do not print or paste its value.

## Recovery and maintenance

- A normal Vault Agent process/container restart can authenticate again using the persisted RoleID and the fixed Docker source IP; no SecretID delivery is required.
- If the RoleID is rotated, update the host's Agent-only RoleID file and restart the Agent.
- If the Agent IP or bridge subnet changes, update the AppRole's `secret_id_bound_cidrs` and `token_bound_cidrs` before restarting the Agent.
- If the Agent's source address changes unexpectedly, login and/or token use should fail closed until the network and AppRole configuration agree.
- Do not add another container to `infra_agent` without reviewing this trust boundary.
- `400 common name ... not allowed by this role` during `pki-int-srv/issue/nginx` is a PKI certificate-role/domain policy problem, not an AppRole authentication failure.

## Primary sources

- HashiCorp: [Vault Agent AppRole auto-auth](https://developer.hashicorp.com/vault/docs/agent-and-proxy/autoauth/methods/approle) — SecretID is optional when `bind_secret_id=false`.
- HashiCorp: [AppRole API](https://developer.hashicorp.com/vault/api-docs/auth/approle) — login evaluates other configured constraints; role-level login and token CIDR fields.
- HashiCorp: [AppRole authentication](https://developer.hashicorp.com/vault/docs/auth/approle) — RoleID and SecretID semantics.
- Docker: [Bridge network driver](https://docs.docker.com/engine/network/drivers/bridge/) — user-defined bridge isolation and internal networks.

**Future-maintainer rule:** Do not remove the static Agent address, either CIDR restriction, or the dedicated internal network without explicitly reviewing the authentication trust boundary.
