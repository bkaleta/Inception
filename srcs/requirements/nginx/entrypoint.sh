#!/bin/sh
set -e

CN="${DOMAIN_NAME:-localhost}"
mkdir -p /etc/ssl/private /etc/ssl/certs

# Self-signed cert (dev/obrona) – produkcyjnie użyj prawdziwego certu
if [ ! -f /etc/ssl/private/nginx-selfsigned.key ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=PL/O=42/OU=student/CN=${CN}"
fi

# Upewnij się, że katalog istnieje i jest czytelny dla nginx
# mkdir -p /var/www/html
# chmod 755 /var/www /var/www/html

exec "$@"
