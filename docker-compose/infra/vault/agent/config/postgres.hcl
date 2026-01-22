template {
  source      = "/vault/agent/templates/postgres/999-vault.sql.tpl"
  destination = "/vault/file/postgres/999-vault.sql"
  perms       = 0644
  error_on_missing_key = true
}

template {
  source      = "/vault/agent/templates/postgres/010-authentik.sql.tpl"
  destination = "/vault/file/postgres/010-authentik.sql"
  perms       = 0644
  error_on_missing_key = true
}

template {
  source      = "/vault/agent/templates/postgres/020-vaultwarden.sql.tpl"
  destination = "/vault/file/postgres/020-vaultwarden.sql"
  perms       = 0644
  error_on_missing_key = true
}


template {
  source      = "/vault/agent/templates/postgres/postgres.env.tpl"
  destination = "/vault/file/postgres/postgres.env"
  perms       = 0644
  error_on_missing_key = true
}