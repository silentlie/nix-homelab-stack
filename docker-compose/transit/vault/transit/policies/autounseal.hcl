path "transit/encrypt/autounseal-key" {
  capabilities = ["update"]
}

path "transit/decrypt/autounseal-key" {
  capabilities = ["update"]
}

path "transit/keys/autounseal-key" {
  capabilities = ["read"]
}