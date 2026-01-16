{{- with pkiCert
  "pki-int-srv/issue/nginx"
  "common_name=vault"
  "alt_names=vault.home.arpa,vault"
  "ttl=72h" -}}

{{- .Data.Key  | writeToFile "/vault/file/certs/vault.key" "0" "0" "0600" -}}
{{- .Data.Cert | writeToFile "/vault/file/certs/vault.crt" "0" "0" "0644" -}}
{{- .Data.CA   | writeToFile "/vault/file/certs/vault.crt" "0" "0" "0644" "append,newline" -}}

{{- end -}}