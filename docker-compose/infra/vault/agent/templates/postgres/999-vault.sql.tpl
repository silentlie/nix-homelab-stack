{{- with secret "kv/data/postgres/users/vault" -}}

DO
$$
BEGIN
  -- Create role if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '{{ .Data.data.username }}') THEN
    CREATE ROLE "{{ .Data.data.username }}"
      WITH
        LOGIN
        PASSWORD '{{ .Data.data.password }}'
        CREATEROLE;
  ELSE
    -- Privileges are as expected
    ALTER ROLE "{{ .Data.data.username }}"
      WITH
        LOGIN
        PASSWORD '{{ .Data.data.password }}'
        CREATEROLE;
  END IF;
END
$$;

{{- end }}

ALTER ROLE postgres PASSWORD NULL;
