{{- with pkiCert
  "pki-int-srv/issue/nginx"
  "common_name=nginx"
  "alt_names=nginx.home.arpa,nginx"
  "ttl=72h" -}}

{{- .Data.Key  | writeToFile "/vault/file/certs/nginx.key" "" "" "0644" -}}
{{- .Data.Cert | writeToFile "/vault/file/certs/nginx.crt" "" "" "0644" -}}
{{- .Data.CA   | writeToFile "/vault/file/certs/nginx.crt" "" "" "0644" "append,newline" -}}

{{- end -}}