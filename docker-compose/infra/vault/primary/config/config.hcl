ui = true

log_level  = "info"
log_format = "json"

disable_mlock = false

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

storage "file" {
  path = "/vault/file"
}

api_addr     = "http://vault:8200"

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname = true
}

default_lease_ttl = "24h"
max_lease_ttl     = "168h"