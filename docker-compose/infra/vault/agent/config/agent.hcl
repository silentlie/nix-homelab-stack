pid_file = "/tmp/vault-agent.pid"
log_level = "info"
log_format = "json"

vault {
  address = "http://vault:8200"
}

# SECURITY DECISION (2026-10-29): intentional manual, one-time AppRole bootstrap.
# See ../AUTHENTICATION.md before changing auto-auth, adding a bootstrap
# service, or introducing reusable credentials. Unattended process restart is
# explicitly NOT guaranteed: after consuming/deleting the SecretID file, a
# new Agent process needs a freshly provisioned SecretID. Its persisted token
# sink below is sensitive output, NOT an AppRole cold-start credential.
auto_auth {
  method "approle" {
    mount_path = "auth/approle"
    config = {
      role_id_file_path   = "/vault/file/approle/role_id"
      secret_id_file_path = "/vault/file/approle/secret_id"
      remove_secret_id_file_after_reading = true
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