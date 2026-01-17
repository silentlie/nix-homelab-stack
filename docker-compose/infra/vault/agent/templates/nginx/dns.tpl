{{- with pkiCert
  "pki-int-srv/issue/nginx"
  "common_name=dns"
  "alt_names=dns.home.arpa,dns"
  "ttl=72h" -}}

{{- .Data.Key  | writeToFile "/vault/file/certs/dns.key" "" "" "0644" -}}
{{- .Data.Cert | writeToFile "/vault/file/certs/dns.crt" "" "" "0644" -}}
{{- .Data.CA   | writeToFile "/vault/file/certs/ca-chain.crt" "" "" "0644" -}}

{{- end -}}