user default off

{{- /* Admin user: full access. Keep this tightly controlled. */ -}}
{{- with secret "kv/data/redis/users/admin" -}}
user {{ .Data.data.username }} on >{{ .Data.data.password }} ~* +@all
{{- end -}}

{{- /* Authentik user: restrict keys + commands to what it likely needs. */ -}}
{{- with secret "kv/data/redis/users/authentik" -}}
user {{ .Data.data.username }} on >{{ .Data.data.password }} ~authentik:* +get +set +del +expire +ttl +pttl +exists +ping
{{- end -}}