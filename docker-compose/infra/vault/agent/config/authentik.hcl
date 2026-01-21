template {
  source      = "/vault/agent/templates/authentik/authentik_cred.tpl"
  destination = "/vault/file/authentik/.authentik_cred.rendered"
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/authentik/authentik.env.tpl"
  destination = "/vault/file/authentik/authentik.env"
  perms       = 0644
  error_on_missing_key = true
}

# template {
#   source      = "/vault/agent/templates/users.acl.tpl"
#   destination = "/vault/file/redis/users.acl"
#   perms       = 0644
#   error_on_missing_key = true
# }