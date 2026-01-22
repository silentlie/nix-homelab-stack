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

GRANT authentik TO vault WITH ADMIN OPTION;

GRANT CONNECT ON DATABASE authentik TO authentik;

\connect authentik

ALTER SCHEMA public OWNER TO authentik;

ALTER ROLE authentik SET search_path = public;