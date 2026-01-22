DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'authentik'
  ) THEN
    CREATE ROLE authentik LOGIN;
  END IF;
END
$$;

SELECT 'CREATE DATABASE authentik'
WHERE NOT EXISTS (
  SELECT FROM pg_database WHERE datname = 'authentik'
) \gexec

GRANT CONNECT ON DATABASE authentik TO authentik;

\connect authentik

ALTER SCHEMA public OWNER TO authentik;

ALTER DEFAULT PRIVILEGES FOR ROLE authentik IN SCHEMA public
  GRANT SELECT ON TABLES TO authentik_grants WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES FOR ROLE authentik IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO authentik_grants WITH GRANT OPTION;

GRANT authentik_grants TO vault;

ALTER ROLE authentik SET search_path = public;