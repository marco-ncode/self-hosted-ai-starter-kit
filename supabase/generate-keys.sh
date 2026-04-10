#!/bin/sh
# Generate Supabase secrets and API keys for this project.
#
# Usage:
#   sh supabase/generate-keys.sh
#   sh supabase/generate-keys.sh --update-env

set -eu

if ! command -v openssl >/dev/null 2>&1; then
  echo "Error: openssl is required but not found." >&2
  exit 1
fi

gen_hex() {
  openssl rand -hex "$1"
}

gen_base64() {
  openssl rand -base64 "$1"
}

base64_url_encode() {
  openssl enc -base64 -A | tr '+/' '-_' | tr -d '='
}

gen_token() {
  payload=$1
  payload_b64=$(printf %s "$payload" | base64_url_encode)
  header_b64=$(printf %s "$header" | base64_url_encode)
  signed_content="${header_b64}.${payload_b64}"
  signature=$(printf %s "$signed_content" | openssl dgst -binary -sha256 -hmac "$supabase_jwt_secret" | base64_url_encode)
  printf '%s' "${signed_content}.${signature}"
}

update_env_value() {
  key=$1
  value=$2
  file=$3

  tmp_file="${file}.tmp.$$"
  awk -v k="$key" -v v="$value" '
    BEGIN { done = 0 }
    $0 ~ "^" k "=" {
      if (done == 0) {
        print k "=" v
        done = 1
      }
      next
    }
    { print }
    END {
      if (done == 0) {
        print k "=" v
      }
    }
  ' "$file" > "$tmp_file"
  mv "$tmp_file" "$file"
}

supabase_jwt_secret=$(gen_base64 30)
header='{"alg":"HS256","typ":"JWT"}'
iat=$(date +%s)
exp=$((iat + 5 * 3600 * 24 * 365))

anon_payload="{\"role\":\"anon\",\"iss\":\"supabase\",\"iat\":${iat},\"exp\":${exp}}"
service_role_payload="{\"role\":\"service_role\",\"iss\":\"supabase\",\"iat\":${iat},\"exp\":${exp}}"

supabase_anon_key=$(gen_token "$anon_payload")
supabase_service_role_key=$(gen_token "$service_role_payload")
supabase_secret_key_base=$(gen_base64 48)
supabase_postgres_password=$(gen_hex 16)
supabase_dashboard_password=$(gen_hex 16)
supabase_db_enc_key=$(gen_hex 16)

echo ""
echo "SUPABASE_JWT_SECRET=${supabase_jwt_secret}"
echo "SUPABASE_ANON_KEY=${supabase_anon_key}"
echo "SUPABASE_SERVICE_ROLE_KEY=${supabase_service_role_key}"
echo "SUPABASE_SECRET_KEY_BASE=${supabase_secret_key_base}"
echo "SUPABASE_POSTGRES_PASSWORD=${supabase_postgres_password}"
echo "SUPABASE_DASHBOARD_PASSWORD=${supabase_dashboard_password}"
echo "SUPABASE_DB_ENC_KEY=${supabase_db_enc_key}"
echo ""

update_env=false
if [ "${1:-}" = "--update-env" ]; then
  update_env=true
elif test -t 0; then
  printf "Update .env file? (y/N) "
  read -r reply
  case "$reply" in
    [Yy]) update_env=true ;;
    *) update_env=false ;;
  esac
fi

if [ "$update_env" != "true" ]; then
  exit 0
fi

if [ ! -f .env ]; then
  echo "Error: .env not found in current directory." >&2
  exit 1
fi

update_env_value "SUPABASE_JWT_SECRET" "$supabase_jwt_secret" .env
update_env_value "SUPABASE_ANON_KEY" "$supabase_anon_key" .env
update_env_value "SUPABASE_SERVICE_ROLE_KEY" "$supabase_service_role_key" .env
update_env_value "SUPABASE_SECRET_KEY_BASE" "$supabase_secret_key_base" .env
update_env_value "SUPABASE_POSTGRES_PASSWORD" "$supabase_postgres_password" .env
update_env_value "SUPABASE_DASHBOARD_PASSWORD" "$supabase_dashboard_password" .env
update_env_value "SUPABASE_DB_ENC_KEY" "$supabase_db_enc_key" .env

echo "Updated .env with generated Supabase keys."
