{{- with pkiCert
  "pki-int-srv/issue/nginx"
  "common_name=nanokvm"
  "alt_names=nanokvm.home.arpa,nanokvm"
  "ttl=72h" -}}

{{- .Data.Key  | writeToFile "/vault/file/certs/nanokvm.key" "" "" "0644" -}}
{{- .Data.Cert | writeToFile "/vault/file/certs/nanokvm.crt" "" "" "0644" -}}
{{- .Data.CA   | writeToFile "/vault/file/certs/nanokvm.crt" "" "" "0644" "append,newline" -}}

{{- end -}}