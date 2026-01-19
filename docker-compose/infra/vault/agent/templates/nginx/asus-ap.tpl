{{- with pkiCert
  "pki-int-srv/issue/nginx"
  "common_name=asus-ap"
  "alt_names=asus-ap.home.arpa,asus-ap"
  "ttl=72h" -}}

{{- .Data.Key  | writeToFile "/vault/file/certs/asus-ap.key" "" "" "0644" -}}
{{- .Data.Cert | writeToFile "/vault/file/certs/asus-ap.crt" "" "" "0644" -}}
{{- .Data.CA   | writeToFile "/vault/file/certs/asus-ap.crt" "" "" "0644" "append,newline" -}}

{{- end -}}