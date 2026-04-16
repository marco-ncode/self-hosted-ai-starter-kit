#!/bin/sh
set -eu

# Run after Supabase init-scripts to assign passwords and realtime schema defaults.
supabase_password_escaped=$(printf "%s" "${POSTGRES_PASSWORD}" | sed "s/'/''/g")

psql -v ON_ERROR_STOP=1 \
  --username "${POSTGRES_USER:-postgres}" \
  --dbname "${POSTGRES_DB:-postgres}" <<SQL
ALTER ROLE authenticator WITH LOGIN PASSWORD '${supabase_password_escaped}';
ALTER ROLE supabase_auth_admin WITH LOGIN PASSWORD '${supabase_password_escaped}';
ALTER ROLE supabase_storage_admin WITH LOGIN PASSWORD '${supabase_password_escaped}';

CREATE SCHEMA IF NOT EXISTS _realtime;
GRANT USAGE, CREATE ON SCHEMA _realtime TO supabase_admin;
ALTER ROLE supabase_admin SET search_path = _realtime;
SQL
