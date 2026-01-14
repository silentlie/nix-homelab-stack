{{- with pkiCert
  "pki-int-srv/issue/nginx"
  "common_name=vault"
  "alt_names=vault.home.arpa,vault"
  "ttl=168h" -}}
{{ .Key  | writeToFile "/vault/agent/certs/vault.key" "0600" }}
{{ .Cert | writeToFile "/vault/agent/certs/vault.crt" "0644" }}
{{ .CA   | writeToFile "/vault/agent/certs/vault.crt" "0644" "append" }}
{{- end -}}