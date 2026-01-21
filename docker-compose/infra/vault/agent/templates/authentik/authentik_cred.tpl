{{ with secret "database/roles/authentik" }}
{{- .Data.username  | writeToFile "/vault/file/authentik/pg_user" "" "" "0644" -}}
{{- .Data.password  | writeToFile "/vault/file/authentik/pg_pass" "" "" "0644" -}}
{{ end }}