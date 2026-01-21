template {
  source      = "/vault/agent/templates/postgres/001-init.sql.tpl"
  destination = "/vault/file/postgres/001-init.sql"
  perms       = 0644
  error_on_missing_key = true
}

template {
  source      = "/vault/agent/templates/postgres/provision/provision_cred.tpl"
  destination = "/vault/file/postgres/provision/.provision_cred.rendered"
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/postgres/provision/010-authentik.sql.tpl"
  destination = "/vault/file/postgres/provision/010-authentik.sql"
  perms       = 0644
  error_on_missing_key = true
}

template {
  source      = "/vault/agent/templates/postgres/provision/020-vaultwarden.sql.tpl"
  destination = "/vault/file/postgres/provision/020-vaultwarden.sql"
  perms       = 0644
  error_on_missing_key = true
}


template {
  source      = "/vault/agent/templates/postgres/postgres.env.tpl"
  destination = "/vault/file/postgres/postgres.env"
  perms       = 0644
  error_on_missing_key = true
}