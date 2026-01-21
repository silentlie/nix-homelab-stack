{{ with secret "database/role/postgres_provision" }}
{{- .Data.username  | writeToFile "/vault/file/postgres/provision/provision_user" "" "" "0644" -}}
{{- .Data.password  | writeToFile "/vault/file/postgres/provision/provision_pass" "" "" "0644" -}}
{{ end }}