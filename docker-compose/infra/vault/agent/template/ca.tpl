{{ with secret "pki-root/cert/ca" }}
{{ .Data.certificate }}
{{ end }}