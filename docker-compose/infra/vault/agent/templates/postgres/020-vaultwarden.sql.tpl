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

GRANT vaultwarden TO vault WITH ADMIN OPTION;

GRANT CONNECT ON DATABASE vaultwarden TO vaultwarden;

\connect vaultwarden

ALTER SCHEMA public OWNER TO vaultwarden;

ALTER ROLE vaultwarden SET search_path = public;