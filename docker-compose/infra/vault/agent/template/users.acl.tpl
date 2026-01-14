user default off

{{- with secret "kv/data/redis/users/redis" }}
user {{ .Data.data.username }} on >{{ .Data.data.password }} {{ .Data.data.permissions }}
{{- end }}

{{- with secret "kv/data/redis/users/vault" }}
user {{ .Data.data.username }} on >{{ .Data.data.password }} {{ .Data.data.permissions }}
{{- end }}