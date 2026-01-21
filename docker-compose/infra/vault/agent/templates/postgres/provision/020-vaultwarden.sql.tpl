SELECT 'CREATE DATABASE vaultwarden'
WHERE NOT EXISTS (
  SELECT FROM pg_database WHERE datname = 'vaultwarden'
) \gexec

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'vaultwarden_base'
  ) THEN
    CREATE ROLE vaultwarden_base NOLOGIN;
  END IF;
END
$$;

GRANT CONNECT ON DATABASE vaultwarden TO vaultwarden_base;

\connect vaultwarden

GRANT USAGE ON SCHEMA public TO vaultwarden_base;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO vaultwarden_base;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO vaultwarden_base;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL PRIVILEGES ON TABLES TO vaultwarden_base;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL PRIVILEGES ON SEQUENCES TO vaultwarden_base;

ALTER ROLE vaultwarden_base SET search_path = public;