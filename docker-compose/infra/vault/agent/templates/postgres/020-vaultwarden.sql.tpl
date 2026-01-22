DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'vaultwarden'
  ) THEN
    CREATE ROLE vaultwarden LOGIN;
  END IF;
END
$$;

SELECT 'CREATE DATABASE vaultwarden'
WHERE NOT EXISTS (
  SELECT FROM pg_database WHERE datname = 'vaultwarden'
) \gexec

GRANT CONNECT ON DATABASE vaultwarden TO vaultwarden;

\connect vaultwarden

ALTER SCHEMA public OWNER TO vaultwarden;

ALTER DEFAULT PRIVILEGES FOR ROLE vaultwarden IN SCHEMA public
  GRANT SELECT ON TABLES TO vaultwarden_grants WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES FOR ROLE vaultwarden IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO vaultwarden_grants WITH GRANT OPTION;

GRANT vaultwarden_grants TO vault;

ALTER ROLE vaultwarden SET search_path = public;