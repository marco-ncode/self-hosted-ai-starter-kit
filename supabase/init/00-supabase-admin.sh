#!/bin/sh
set -eu

# Ensure supabase_admin exists before image migrations run.
supabase_admin_password_escaped=$(printf "%s" "${POSTGRES_PASSWORD}" | sed "s/'/''/g")

psql -v ON_ERROR_STOP=1 \
  --username "${POSTGRES_USER:-postgres}" \
  --dbname "${POSTGRES_DB:-postgres}" <<SQL
DO \$\$
BEGIN
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
SQL
