pid_file = "/tmp/vault-agent.pid"
log_level = "info"
log_format = "json"

vault {
  address = "https://vault.home.arpa:8200"
  ca_cert = "/vault/certs/ca.crt"
}

auto_auth {
  method "approle" {
    mount_path = "auth/approle"
    config = {
      role_id_file_path   = "/vault/agent/role_id"
      secret_id_file_path = "/vault/agent/secret_id"
    }
  }

  sink "file" {
    config = {
      path = "/vault/agent/token"
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
  source      = "/vault/agent/templates/nginx-cert.tpl"
  destination = "/vault/agent/certs/fullchain.pem"
  perms       = 0644
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/nginx-key.tpl"
  destination = "/vault/agent/certs/privkey.pem"
  perms       = 0600
  error_on_missing_key = true
  command = "nginx -s reload"
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/ca.tpl"
  destination = "/vault/agent/certs/ca.crt"
  perms       = 0644
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/postgres-init.sql.tpl"
  destination = "/vault/agent/postgres/001-init.sql"
  perms       = 0400
  error_on_missing_key = true
}

template {
  source      = "/vault/agent/templates/users.acl.tpl"
  destination = "/vault/agent/redis/users.acl"
  perms       = 0600
  error_on_missing_key = true
}

template {
  source      = "/vault/agent/templates/authentik.env.tpl"
  destination = "/vault/agent/authentik/authentik.env"
  perms       = 0600
  error_on_missing_key = true
}

template {
  source      = "/vault/agent/templates/vaultwarden.env.tpl"
  destination = "/vault/agent/vaultwarden/vaultwarden.env"
  perms       = 0600
  error_on_missing_key = true
}