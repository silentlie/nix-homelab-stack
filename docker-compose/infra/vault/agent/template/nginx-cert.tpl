{{ with secret "pki/issue/internal"
  "common_name=nginx.home.arpa"
  "alt_names=*.home.arpa"
  "ttl=24h" }}
{{ .Data.certificate }}
{{ .Data.issuing_ca }}
{{ end }}