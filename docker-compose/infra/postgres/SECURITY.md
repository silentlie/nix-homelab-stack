# PostgreSQL Authentication Model (Local-Only Admin + Vault)

## Goal

- Keep a **local-only break-glass superuser** (`postgres`)
- **Disable password-based admin login**
- **Block all TCP superuser access**
- Let **Vault manage non-superuser roles** (dynamic/static)
- Avoid lock-out scenarios

---

## Key PostgreSQL Concepts

### Role attributes
- `LOGIN` / `NOLOGIN`
  Controls whether a role can authenticate **at all**.
- `PASSWORD`
  Only affects password-based auth methods (`scram`, `md5`).
- `NOLOGIN` blocks *all* auth methods (including local trust/peer).

### Authentication layers
PostgreSQL authentication is decided by **both**:
1. Role attributes
2. `pg_hba.conf`

> **Role attributes say *whether* you may log in.
> `pg_hba.conf` says *how* and *from where*.**

---

## `trust` vs `peer` (local socket auth)

### `trust`
```conf
local all postgres trust
```

- No authentication at all
- Any local process can claim to be `postgres`
- Convenient, but unsafe if container is compromised

### `peer`
```conf
local all postgres peer
```

- Maps **OS user → DB user**
- To log in as DB `postgres`, the process **must run as OS user `postgres`**
- Requires explicit intent (`docker exec -u postgres`)

**Conclusion:**
`peer` is safer and preferred.

---

## Why NOT `NOLOGIN` for postgres

```sql
ALTER ROLE postgres NOLOGIN;
```

This:
- Blocks **all** login paths
- Includes local socket access
- Can permanently lock you out unless another superuser exists

**Do not use `NOLOGIN` for the break-glass admin role.**

---

## Correct Way to Disable Password Login Only

```sql
ALTER ROLE postgres PASSWORD NULL;
```

Effects:
- Password-based auth always fails
- `peer` / `trust` still work
- Password hashes are removed

---

## Final `pg_hba.conf` (Approved)

```conf
# Local-only break-glass admin
local   all             postgres                                peer

# Block postgres over TCP entirely
host    all             postgres        0.0.0.0/0               reject
host    all             postgres        ::/0                    reject

# All other local connections require password
local   all             all                                     scram-sha-256

# Loopback TCP requires password
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             ::1/128                 scram-sha-256

# Replication (passworded)
local   replication     all                                     scram-sha-256
host    replication     all             127.0.0.1/32            scram-sha-256
host    replication     all             ::1/128                 scram-sha-256

# All other TCP connections require password
host    all             all             all                     scram-sha-256
```

---

## Verified Behaviors (Expected)

### Local admin works (intentional)
```bash
docker exec -u postgres -it postgres psql -U postgres
```

### Local admin as root is blocked
```bash
docker exec -it postgres psql -U postgres
# Peer authentication failed
```

### TCP admin access is blocked
```bash
psql -h postgres -U postgres
# pg_hba.conf rejects connection
```

### App / Vault roles still work
- Use `scram-sha-256`
- Require password
- No superuser privileges

---

## Vault Integration Notes

- Vault **does NOT** have PostgreSQL `SUPERUSER`
- Vault DB connection role has:
  - `CREATEROLE`
  - `ALTER ROLE`
  - `DROP ROLE`
  - ability to `GRANT <base_role>`
- Vault **cannot** escalate to admin
- Vault compromise ≠ Postgres root compromise

---

## Recovery / Break-Glass Policy

- Admin access requires:
```bash
docker exec -u postgres -it postgres psql -U postgres
```
- No password required
- No network exposure
- No Vault dependency

---

## Why This Model Exists (Summary)

- Prevent silent privilege escalation
- Keep Vault powerful but constrained
- Make admin access **explicit and intentional**
- Avoid total lock-out scenarios
- Align with least-privilege principles

---

## References

- PostgreSQL `pg_hba.conf` documentation
  https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
- PostgreSQL authentication methods
  https://www.postgresql.org/docs/current/auth-methods.html
- PostgreSQL role attributes
  https://www.postgresql.org/docs/current/role-attributes.html

---

### TL;DR

- ✅ `peer` for local admin
- ❌ `NOLOGIN` for postgres
- ❌ TCP superuser access
- ❌ Password-based admin
- ✅ Vault manages non-admin roles
- ✅ Explicit break-glass path
