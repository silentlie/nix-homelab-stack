template {
  source      = "/vault/agent/templates/nginx/vault.tpl"
  destination = "/vault/file/certs/.vault.rendered"
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/nginx/technitium.tpl"
  destination = "/vault/file/certs/.technitium.rendered"
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/nginx/nginx.tpl"
  destination = "/vault/file/certs/.nginx.rendered"
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/nginx/traefik.tpl"
  destination = "/vault/file/certs/.traefik.rendered"
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/nginx/authentik.tpl"
  destination = "/vault/file/certs/.authentik.rendered"
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/nginx/vaultwarden.tpl"
  destination = "/vault/file/certs/.vaultwarden.rendered"
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/nginx/proxmox.tpl"
  destination = "/vault/file/certs/.proxmox.rendered"
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/nginx/nanokvm.tpl"
  destination = "/vault/file/certs/.nanokvm.rendered"
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/nginx/dns.tpl"
  destination = "/vault/file/certs/.dns.rendered"
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}

template {
  source      = "/vault/agent/templates/nginx/ca.tpl"
  destination = "/vault/file/certs/ca.crt"
  perms       = 0644
  error_on_missing_key = true
  wait {
    min = "5s"
    max = "30s"
  }
}