{{- with pkiCert
  "pki-int-srv/issue/nginx"
  "common_name=tplink-ap"
  "alt_names=tplink-ap.home.arpa,tplink-ap"
  "ttl=72h" -}}

{{- .Data.Key  | writeToFile "/vault/file/certs/tplink-ap.key" "" "" "0644" -}}
{{- .Data.Cert | writeToFile "/vault/file/certs/tplink-ap.crt" "" "" "0644" -}}
{{- .Data.CA   | writeToFile "/vault/file/certs/tplink-ap.crt" "" "" "0644" "append,newline" -}}

{{- end -}}
