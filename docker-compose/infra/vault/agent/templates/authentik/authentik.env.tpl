AUTHENTIK_SECRET_KEY={{ with secret "kv/data/authentik/core" }}{{ .Data.data.secret_key }}{{ end }}

AUTHENTIK_PROXY=true

AUTHENTIK_LOG_LEVEL=debug
AUTHENTIK_ERROR_REPORTING_ENABLED=false

AUTHENTIK_POSTGRESQL__HOST=postgres
AUTHENTIK_POSTGRESQL__PORT=5432
AUTHENTIK_POSTGRESQL__NAME=authentik
AUTHENTIK_POSTGRESQL__USER=file:///authentik/secrets/pg_user
AUTHENTIK_POSTGRESQL__PASSWORD=file:///authentik/secrets/pg_pass
AUTHENTIK_POSTGRESQL__CONN_MAX_AGE=0
AUTHENTIK_POSTGRESQL__CONN_HEALTH_CHECKS=true

{{ with secret "kv/data/authentik/users/bootstrap" }}

AUTHENTIK_BOOTSTRAP_PASSWORD={{ .Data.data.password }}

{{ with index .Data.data "token" }}
AUTHENTIK_BOOTSTRAP_TOKEN={{ index .Data.data "token" }}
{{ end }}
{{ end }}