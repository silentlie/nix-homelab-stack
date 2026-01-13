{{- with secret "kv/data/vaultwarden" -}}

DATABASE_URL={{ .Data.data.database_url }}
ADMIN_TOKEN={{ .Data.data.admin_token }}
DOMAIN={{ .Data.data.domain }}
SIGNUPS_ALLOWED={{ .Data.data.signups_allowed }}
ROCKET_PORT={{ .Data.data.rocket_port }}
ROCKET_WORKERS={{ .Data.data.rocket_workers }}

{{- end -}}