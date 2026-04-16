-- Supabase Postgres image already provisions core roles and grants
-- during /docker-entrypoint-initdb.d/init-scripts.
-- Keep this file idempotent and non-conflicting.
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
