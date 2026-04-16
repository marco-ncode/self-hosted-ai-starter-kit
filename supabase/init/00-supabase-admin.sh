#!/bin/sh
set -eu

# Ensure supabase_admin exists before image migrations run.
supabase_admin_password_escaped=$(printf "%s" "${POSTGRES_PASSWORD}" | sed "s/'/''/g")
postgres_db_escaped=$(printf "%s" "${POSTGRES_DB:-postgres}" | sed "s/'/''/g")

psql -v ON_ERROR_STOP=1 \
  --username "${POSTGRES_USER:-postgres}" \
  --dbname "${POSTGRES_DB:-postgres}" <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticator') THEN
    CREATE ROLE authenticator NOINHERIT LOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_auth_admin') THEN
    CREATE ROLE supabase_auth_admin NOINHERIT LOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_storage_admin') THEN
    CREATE ROLE supabase_storage_admin NOINHERIT LOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_admin') THEN
    EXECUTE format(
      'CREATE ROLE supabase_admin WITH LOGIN SUPERUSER PASSWORD %L',
      '${supabase_admin_password_escaped}'
    );
  ELSE
    EXECUTE format(
      'ALTER ROLE supabase_admin WITH LOGIN SUPERUSER PASSWORD %L',
      '${supabase_admin_password_escaped}'
    );
    ALTER ROLE supabase_admin WITH LOGIN SUPERUSER;
  END IF;
END
\$\$;

ALTER ROLE authenticator WITH LOGIN PASSWORD '${supabase_admin_password_escaped}';
ALTER ROLE supabase_auth_admin WITH LOGIN PASSWORD '${supabase_admin_password_escaped}';
ALTER ROLE supabase_storage_admin WITH LOGIN PASSWORD '${supabase_admin_password_escaped}';

CREATE SCHEMA IF NOT EXISTS _realtime;
GRANT USAGE, CREATE ON SCHEMA _realtime TO supabase_admin;
ALTER ROLE supabase_admin IN DATABASE "${postgres_db_escaped}" SET search_path = _realtime;
SQL
