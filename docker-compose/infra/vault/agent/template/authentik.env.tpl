AUTHENTIK_SECRET_KEY={{ with secret "kv/data/authentik/core" }}{{ .Data.data.secret_key }}{{ end }}

AUTHENTIK_PROXY=true

AUTHENTIK_BOOTSTRAP_PASSWORD={{ with secret "kv/data/authentik/bootstrap" }}{{ .Data.data.password }}{{ end }}
AUTHENTIK_BOOTSTRAP_TOKEN={{ with secret "kv/data/authentik/bootstrap" }}{{ .Data.data.token }}{{ end }}

AUTHENTIK_LOG_LEVEL=info
AUTHENTIK_ERROR_REPORTING_ENABLED=false

AUTHENTIK_POSTGRESQL__HOST=postgres
AUTHENTIK_POSTGRESQL__PORT=5432
AUTHENTIK_POSTGRESQL__NAME=authentik
AUTHENTIK_POSTGRESQL__USER={{ with secret "database/creds/authentik" }}{{ .Data.username }}{{ end }}
AUTHENTIK_POSTGRESQL__PASSWORD={{ with secret "database/creds/authentik" }}{{ .Data.password }}{{ end }}

AUTHENTIK_REDIS__HOST=redis
AUTHENTIK_REDIS__PORT=6379
AUTHENTIK_REDIS__PASSWORD={{ with secret "kv/data/redis/authentik" }}{{ .Data.data.password }}{{ end }}