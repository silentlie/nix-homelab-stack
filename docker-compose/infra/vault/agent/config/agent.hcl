pid_file = "/tmp/vault-agent.pid"
log_level = "info"
log_format = "json"

vault {
  address = "http://vault:8200"
}

# SECURITY DECISION (2026-11-16): RoleID-only AppRole authentication.
# The primary Vault role enforces both login-source and token-use CIDRs at
# 172.20.0.3/32. Docker Compose pins this Agent to that address on the
# dedicated internal "agent" bridge. Network membership is privileged.
# See ../AUTHENTICATION.md before changing either side of this boundary.
auto_auth {
  method "approle" {
    mount_path = "auth/approle"
    config = {
      role_id_file_path = "/vault/file/approle/role_id"
    }
  }

  sink "file" {
    config = {
      path = "/vault/file/token"
      mode = 0600
    }
  }

  exit_after_auth = false
}

cache {
  use_auto_auth_token = true
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = true
}
