{{- with pkiCert
  "pki-int-srv/issue/nginx"
  "common_name=proxmox"
  "alt_names=proxmox.home.arpa,proxmox"
  "ttl=72h" -}}

{{- .Data.Key  | writeToFile "/vault/file/certs/proxmox.key" "" "" "0644" -}}
{{- .Data.Cert | writeToFile "/vault/file/certs/proxmox.crt" "" "" "0644" -}}
{{- .Data.CA   | writeToFile "/vault/file/certs/proxmox.crt" "" "" "0644" "append,newline" -}}

{{- end -}}