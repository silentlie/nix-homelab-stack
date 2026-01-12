seal "transit" {
  address            = "http://vault-transit:8200"
  token              = "s.xxxxx"
  key_name           = "autounseal-key"
  mount_path         = "transit"
  tls_skip_verify    = true
}