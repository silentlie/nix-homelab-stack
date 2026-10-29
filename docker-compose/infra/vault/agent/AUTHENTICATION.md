# Vault Agent bootstrap authentication: accepted decision

**Status:** Accepted on 2026-10-29. **Scope:** the NixOS infra host's Docker Compose `vault-agent`.
**Revisit only** if the trust model/requirements change or a relevant **official HashiCorp capability** materially changes the options described below. Do not reopen this debate merely to make container restarts automatic.

## Decision

Keep Vault Agent AppRole auto-auth with:

- A separately delivered RoleID and short-lived, ideally single-use SecretID (the live AppRole role determines actual TTL/use restrictions; verify those in Vault, not in this repo).
- `remove_secret_id_file_after_reading = true` in `config/agent.hcl`.
- **Explicit, operator-authorised re-bootstrap** with a *fresh* SecretID when the Agent starts without valid cached credentials (in particular after a container/process recreation).
- **No** long-lived reusable SecretID, persistent bootstrap token, or separate privileged SecretID-minting sidecar/service just to make restarts unattended.
- **No** reuse of the Transit Vault auto-unseal token to authenticate this Agent to the primary Vault.

This deliberately **favours limiting persistent bootstrap trust over unattended recovery**. A restart may require a human; that is an accepted availability cost, not a bug to work around silently. Agent remains the deliberate holder of application-facing Vault privileges, but it is **not** the only security-sensitive component in the deployment.

## Why

Vault Agent authenticates to the primary Vault through AppRole and renews its Vault token while permitted. On startup it reads `/vault/file/approle/role_id` and `/vault/file/approle/secret_id`. The SecretID file is then removed by design. The Agent may cache credential values in its running process; **a new process cannot reconstruct a consumed, absent SecretID**. Renewal of an existing token is not the same as the ability to log in afresh.

A machine cannot authenticate to Vault after losing its current session without *some* independently verifiable credential or identity assertion. A separate bootstrap service would require its own authority and protection. A reusable SecretID, stored token, or filesystem certificate key would preserve another restart-capable credential. Neither eliminates the underlying bootstrap trust issue.

The **Transit Vault** relationship solves a different problem: primary Vault's seal/unseal cryptographic access to a separate Vault, using its own scoped credential. That token is not an Agent AppRole credential and must not be repurposed or granted broader rights.

### Alternatives considered, not adopted

| Alternative | Why not adopted for this trust boundary |
| --- | --- |
| `remove_secret_id_file_after_reading = false` plus reusable SecretID | Allows unattended re-login but leaves a reusable credential accessible on disk. |
| Dedicated bootstrap/provisioning service | Moves the standing privilege to mint SecretIDs into another service; increases the number of things to secure and recover. |
| Persist and reuse a Vault token / token-file auto-auth | Still relies on a persistent bearer credential. The existing Agent token **sink** is not an automatic replacement for AppRole startup credentials. |
| TLS certificate auto-auth with on-disk private key | Useful in other threat models, but the renewable/reusable private key becomes the bootstrap trust anchor. |
| TPM-backed/attested machine identity | Interesting future option, but not assumed to be a built-in, end-to-end solution in this NixOS VM/Proxmox setup; vTPM trust depends on the hypervisor. Must be evaluated explicitly before adoption. |

There is **no claim of zero persistent secrets overall**: the token sink at `/vault/file/token`, rendered application secrets, and TLS private keys remain security-sensitive. Their ownership/permissions are a separate documented trade-off in [readme.md](readme.md). This decision is specifically about *not introducing an additional reusable AppRole bootstrap secret or privileged bootstrap service*. Treat the existing token sink as a secret and never rely on it as a restart mechanism without a separate review.

## Expected failure/recovery behaviour

- Vault Agent running with a valid token can renew it as Vault permits; Vault reachability interruptions do not inherently demand a new SecretID if the session remains usable.
- When Agent restarts without a valid SecretID at its configured location, `no known secret ID` in Agent logs is **expected**. `restart: unless-stopped` may restart the process but cannot invent credentials.
- After Vault is available and unsealed, the operator issues a fresh, appropriately scoped SecretID through the existing authenticated Vault administrative procedure and securely places it at the host's bind-mounted `vault/agent/file/approle/secret_id` (inside the container: `/vault/file/approle/secret_id`). Do not put its value into Git, chat, command-line arguments, logs, shell history, or an insecure helper service.
- Ensure the file is readable by the Vault Agent and restricted (normally `0600`), then start/recreate Agent. Expect the SecretID file to be consumed/removed.
- Confirm `docker compose logs --tail=80 vault-agent` shows authentication succeeding, then check rendered secrets/certificates as needed. Do **not** repeatedly recreate an already running Agent without planning a fresh bootstrap.
- `400 common name ... not allowed by this role` during `pki-int-srv/issue/nginx` is a **PKI certificate role/domain policy** problem, *not* an AppRole bootstrap failure. Diagnose separately.

Useful read-only checks, from `docker-compose/infra`:

```sh
docker compose ps vault vault-agent
docker compose logs --tail=80 vault-agent
# Do not print credentials:
test -s vault/agent/file/approle/secret_id && echo "SecretID file present" || echo "SecretID file absent"
```

## When a future review is justified

Reopen this design **only** with a clear reason and documented comparison of the trust boundary, for example:

1. HashiCorp officially documents/supports a materially different Vault Agent authentication or machine-identity method that provides restart-capable reauthentication without a disk-retrievable, reusable bootstrap secret **and** without an independently privileged bootstrap service. Verify it works for **this Docker/NixOS VM** and assess root/hypervisor compromise.
2. The operator expressly changes the requirements (e.g. unattended cold-start becomes mandatory) or the threat model/environment changes.
3. A security advisory or supported Vault deprecation requires replacement of the current method.

An ordinary Vault version release, persistent-token caching, response wrapping, automatic token renewal, or a different way to store the same permanent credential is **not** by itself a reason to revisit. Compare new official documentation against this decision before proposing a change; preserve single-use, manually controlled recovery until a replacement is approved.

## Primary sources (reviewed 2026-10-29)

- HashiCorp: [Vault Agent AppRole auto-auth](https://developer.hashicorp.com/vault/docs/agent-and-proxy/autoauth/methods/approle) (SecretID file consumption and caching).
- HashiCorp: [Auto-auth overview](https://developer.hashicorp.com/vault/docs/agent-and-proxy/autoauth) (method vs token renewal).
- HashiCorp: [Validated Vault Agent/AppRole pattern](https://developer.hashicorp.com/validated-patterns/vault/vault-agent-approle) (ephemeral vs persistent bootstrapping).
- HashiCorp: [TLS certificate auto-auth](https://developer.hashicorp.com/vault/docs/agent-and-proxy/autoauth/methods/cert) (certificate/key file requirements).
- HashiCorp: [Persistent caching](https://developer.hashicorp.com/vault/docs/agent-and-proxy/agent/caching/persistent-caches) (not a general-purpose credential-free cold-start mechanism).

**Future-maintainer rule:** Do not "fix" `no known secret ID` by turning the SecretID into a reusable credential or adding a secret-minting service without an explicit change to this accepted security decision.
