pid_file = "/tmp/vault-agent.pid"
log_level = "info"
log_format = "json"

vault {
  address = "http://vault:8200"
}

auto_auth {
  method "approle" {
    mount_path = "auth/approle"
    config = {
      role_id_file_path   = "/vault/file/agent/role_id"
      secret_id_file_path = "/vault/file/agent/secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    config = {
      path = "/vault/file/agent/token"
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

template {
  source      = "/vault/file/agent/templates/nginx/vault.tpl"
  destination = "/vault/file/agent/certs"
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/file/agent/templates/ca.tpl"
  destination = "/vault/file/agent/certs/ca.crt"
  perms       = 0644
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/file/agent/templates/001-init.sql.tpl"
  destination = "/vault/file/agent/postgres/001-init.sql"
  perms       = 0400
  error_on_missing_key = true
}

template {
  source      = "/vault/file/agent/templates/postgres.env.tpl"
  destination = "/vault/file/agent/postgres/postgres.env"
  perms       = 0600
  error_on_missing_key = true
}

# template {
#   source      = "/vault/file/agent/templates/users.acl.tpl"
#   destination = "/vault/file/agent/redis/users.acl"
#   perms       = 0600
#   error_on_missing_key = true
# }

template {
  source      = "/vault/file/agent/templates/authentik.env.tpl"
  destination = "/vault/file/agent/authentik/authentik.env"
  perms       = 0600
  error_on_missing_key = true
}

template {
  source      = "/vault/file/agent/templates/vaultwarden.env.tpl"
  destination = "/vault/file/agent/vaultwarden/vaultwarden.env"
  perms       = 0600
  error_on_missing_key = true
}