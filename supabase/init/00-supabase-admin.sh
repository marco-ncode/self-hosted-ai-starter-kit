#!/bin/sh
set -eu

# Ensure supabase_admin exists before image migrations run.
psql -v ON_ERROR_STOP=1 \
  --username "${POSTGRES_USER:-postgres}" \
  --dbname "${POSTGRES_DB:-postgres}" \
  -v supabase_admin_password="${POSTGRES_PASSWORD}" <<'SQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_admin') THEN
    EXECUTE format(
      'CREATE ROLE supabase_admin WITH LOGIN SUPERUSER PASSWORD %L',
      :'supabase_admin_password'
    );
  ELSE
    EXECUTE format(
      'ALTER ROLE supabase_admin WITH LOGIN SUPERUSER PASSWORD %L',
      :'supabase_admin_password'
    );
    ALTER ROLE supabase_admin WITH LOGIN SUPERUSER;
  END IF;
END
$$;
SQL
