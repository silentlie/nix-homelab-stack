AUTHENTIK_SECRET_KEY={{ with secret "kv/data/authentik/core" }}{{ .Data.data.secret_key }}{{ end }}

AUTHENTIK_PROXY=true

{{- with secret "kv/data/authentik/users/bootstrap" -}}
AUTHENTIK_BOOTSTRAP_PASSWORD={{ .Data.data.password }}
{{- with index .Data.data "token" }}
AUTHENTIK_BOOTSTRAP_TOKEN={{ index .Data.data "token" }}
{{- end }}
{{- end }}

AUTHENTIK_LOG_LEVEL=info
AUTHENTIK_ERROR_REPORTING_ENABLED=false

AUTHENTIK_POSTGRESQL__HOST=postgres
AUTHENTIK_POSTGRESQL__PORT=5432
AUTHENTIK_POSTGRESQL__NAME=authentik
AUTHENTIK_POSTGRESQL__USER={{ with secret "database/creds/authentik" }}{{ .Data.username }}{{ end }}
AUTHENTIK_POSTGRESQL__PASSWORD={{ with secret "database/creds/authentik" }}{{ .Data.password }}{{ end }}