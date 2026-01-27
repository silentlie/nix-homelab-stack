{{- with secret "database/static-creds/vaultwarden" -}}
DATABASE_URL=postgresql://{{ .Data.username }}:{{ .Data.password }}/vaultwarden?sslmode=disable
{{- end }}

{{- with secret "kv/data/vaultwarden/env" -}}

DOMAIN={{ .Data.data.domain }}
SIGNUPS_ALLOWED={{ .Data.data.signups_allowed }}
INVITATIONS_ALLOWED={{ .Data.data.invitation_allowed }}
SENDS_ALLOWED={{ .Data.data.sends_allowed }}
{{- end -}}
