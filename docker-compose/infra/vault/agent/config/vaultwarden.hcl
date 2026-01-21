template {
  source      = "/vault/agent/templates/vaultwarden/vaultwarden.env.tpl"
  destination = "/vault/file/vaultwarden/vaultwarden.env"
  perms       = 0644
}