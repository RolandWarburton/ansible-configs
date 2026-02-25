#!/bin/bash
# fetch-token.sh — Authenticates to OpenBao as roland and saves the token to /etc/credentials/
# Usage: sudo ./fetch-bao-token.sh

set -euo pipefail

BAO_ADDR="https://secrets.wirecrop.net"
USERNAME="roland"
CREDENTIALS_DIR="/etc/credentials"
TOKEN_FILE="$CREDENTIALS_DIR/openbao-token"
TMP_RESPONSE=$(mktemp)

# Accept password from environment else prompt interactively
if [ -z "${BAO_PASSWORD:-}" ]; then
  read -rsp "OpenBao password for $USERNAME: " BAO_PASSWORD
  echo
fi
PASSWORD="$BAO_PASSWORD"

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: this script must be run as root (use sudo)"
  exit 1
fi

echo "Authenticating to OpenBao as $USERNAME..."

# Capture the response the first check for errors
HTTP_CODE=$(curl -s -o "$TMP_RESPONSE" -w "%{http_code}" \
  --request POST \
  --data "{\"password\": \"$PASSWORD\"}" \
  "$BAO_ADDR/v1/auth/userpass/login/$USERNAME") || true

RESPONSE=$(cat "$TMP_RESPONSE")
rm -f "$TMP_RESPONSE"

if [ "$HTTP_CODE" -eq 0 ] || [ "$HTTP_CODE" = "000" ]; then
  echo "Error: could not reach OpenBao at $BAO_ADDR — is it down?"
  exit 1
fi

if [ "$HTTP_CODE" -ne 200 ]; then
  echo "Error: OpenBao returned HTTP $HTTP_CODE"
  exit 1
fi

# Extract the token and save it to a file
TOKEN=$(echo "$RESPONSE" | jq -r '.auth.client_token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "Error: failed to extract token from response"
  echo "$RESPONSE"
  exit 1
fi

# Create credentials directory if it doesn't exist
mkdir -p "$CREDENTIALS_DIR"
chmod 700 "$CREDENTIALS_DIR"

# Write token to file
echo "$TOKEN" > "$TOKEN_FILE"
chmod 600 "$TOKEN_FILE"
chown root:root "$TOKEN_FILE"

echo "Token saved to $TOKEN_FILE"
