{{- with secret "database/static-creds/vaultwarden" -}}
DATABASE_URL=host=postgres port=5432 user={{ .Data.username }} password={{ .Data.password }} dbname=vaultwarden sslmode=disable
{{- end }}

{{- with secret "kv/data/vaultwarden/env" -}}
DOMAIN={{ .Data.data.domain }}
SIGNUPS_ALLOWED={{ .Data.data.signups_allowed }}
INVITATIONS_ALLOWED={{ .Data.data.invitation_allowed }}
SENDS_ALLOWED={{ .Data.data.sends_allowed }}
{{- end -}}
