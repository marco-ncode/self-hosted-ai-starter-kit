-- Supabase Postgres image already provisions core roles and grants
-- during /docker-entrypoint-initdb.d/init-scripts.
-- Keep this file idempotent and non-conflicting.
SELECT 1;
