{{- with pkiCert
  "pki-int-srv/issue/nginx"
  "common_name=technitium"
  "alt_names=technitium.home.arpa,technitium"
  "ttl=72h" -}}

{{- .Data.Key  | writeToFile "/vault/file/certs/technitium.key" "" "" "0644" -}}
{{- .Data.Cert | writeToFile "/vault/file/certs/technitium.crt" "" "" "0644" -}}
{{- .Data.CA   | writeToFile "/vault/file/certs/technitium.crt" "" "" "0644" "append,newline" -}}

{{- end -}}