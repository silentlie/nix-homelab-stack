{{- with pkiCert
  "pki-int-srv/issue/nginx"
  "common_name=authentik"
  "alt_names=authentik.home.arpa,authentik"
  "ttl=72h" -}}

{{- .Data.Key  | writeToFile "/vault/file/certs/authentik.key" "" "" "0644" -}}
{{- .Data.Cert | writeToFile "/vault/file/certs/authentik.crt" "" "" "0644" -}}
{{- .Data.CA   | writeToFile "/vault/file/certs/authentik.crt" "" "" "0644" "append,newline" -}}

{{- end -}}