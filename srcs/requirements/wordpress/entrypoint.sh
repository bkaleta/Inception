#!/bin/sh
set -e

DB_PASS="$(cat "$DB_PASSWORD_FILE")"

mkdir -p /var/www/html
chown -R nobody:nogroup /var/www/html

# Jeżeli brak instalacji – wykonaj idempotentnie
if [ ! -f /var/www/html/wp-config.php ]; then
  wp core download --path=/var/www/html --allow-root

  wp config create \
    --path=/var/www/html \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASS" \
    --dbhost="$DB_HOST" \
    --dbcollate="" \
    --allow-root

  wp core install \
    --path=/var/www/html \
    --url="https://${DOMAIN_NAME}/" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USR" \
    --admin_password="$DB_PASS" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  # opcjonalnie drugi user (możesz usunąć)
  wp user create editor editor@example.com --role=editor \
     --user_pass="$DB_PASS" --path=/var/www/html --allow-root
fi

exec "$@"