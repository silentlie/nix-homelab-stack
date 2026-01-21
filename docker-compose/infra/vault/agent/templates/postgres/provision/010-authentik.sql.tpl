SELECT 'CREATE DATABASE authentik'
WHERE NOT EXISTS (
  SELECT FROM pg_database WHERE datname = 'authentik'
) \gexec

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'authentik_base'
  ) THEN
    CREATE ROLE authentik_base NOLOGIN;
  END IF;
END
$$;

GRANT CONNECT ON DATABASE authentik TO authentik_base;

\connect authentik

GRANT USAGE ON SCHEMA public TO authentik_base;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO authentik_base;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO authentik_base;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL PRIVILEGES ON TABLES TO authentik_base;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL PRIVILEGES ON SEQUENCES TO authentik_base;

ALTER ROLE authentik_base SET search_path = public;