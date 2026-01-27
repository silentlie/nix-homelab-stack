{{ with secret "kv/data/postgres/users/postgres" }}
POSTGRES_USER={{ .Data.data.username }}
POSTGRES_PASSWORD={{ .Data.data.password }}
{{ end }}