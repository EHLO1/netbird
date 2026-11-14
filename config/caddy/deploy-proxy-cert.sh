#!/bin/sh
set -eu

IDENTIFIER="${1:?Missing certificate identifier}"
CERT_PATH="${2:?Missing certificate path}"
KEY_PATH="${3:?Missing private key path}"

# Target the cert for netbird-proxy
[ "$IDENTIFIER" = "*.$NB_PROXY_DOMAIN" ] || exit 0

SOURCE="/data/caddy"
DEST="/certs/wildcard"

mkdir -p "$DEST"

# Stage files before replacing the existing certificate
TMP_CERT=$(mktemp "$DEST/.cert.XXXXXX")
TMP_KEY=$(mktemp "$DEST/.key.XXXXXX")

trap 'rm -f "$TMP_CERT" "$TMP_KEY"' EXIT

cp "$SOURCE/$CERT_PATH" "$TMP_CERT"
cp "$SOURCE/$KEY_PATH" "$TMP_KEY"

chmod 0644 "$TMP_CERT"
chmod 0600 "$TMP_KEY"
chown 1000:1000 "$TMP_CERT" "$TMP_KEY"

mv -f "$TMP_KEY" "$DEST/$NB_PROXY_DOMAIN.key"
mv -f "$TMP_CERT" "$DEST/$NB_PROXY_DOMAIN.crt"

echo "Deployed wildcard certificate for $IDENTIFIER"