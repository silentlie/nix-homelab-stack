{{- with secret "kv/data/db/postgres-bootstrap" }}

ALTER ROLE postgres WITH PASSWORD '{{ .Data.data.postgres_password }}';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'vault_db_admin'
  ) THEN
    CREATE ROLE vault_db_admin
      WITH LOGIN PASSWORD '{{ .Data.data.vault_admin_password }}';
  END IF;
END $$;

ALTER ROLE vault_db_admin CREATEROLE;
ALTER ROLE vault_db_admin CREATEDB;

{{- end }}