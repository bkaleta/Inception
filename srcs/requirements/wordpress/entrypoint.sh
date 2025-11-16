#!/bin/bash
set -e

WP_CONFIG_FILE=/var/www/html/wp-config.php
WP_DIR=/var/www/html
WP_SOURCE_DIR=/usr/src/wordpress   # jeśli w obrazie masz skopiowane źródła WP
TABLE_PREFIX="${WORDPRESS_TABLE_PREFIX:-wp_}"

# Sekrety/zmienne z compose/secrets
DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASS="$(cat "${DB_PASSWORD_FILE}")"
DB_HOST="${MYSQL_HOSTNAME}"

echo "ℹ️  Sprawdzam zawartość ${WP_DIR}…"
if [ ! "$(ls -A "$WP_DIR" 2>/dev/null)" ]; then
  echo "ℹ️  Wolumin jest pusty."

  if [ -d "${WP_SOURCE_DIR}" ] && [ -f "${WP_SOURCE_DIR}/wp-settings.php" ]; then
    echo "ℹ️  Kopiuję WordPress z obrazu (${WP_SOURCE_DIR} → ${WP_DIR})…"
    cp -r "${WP_SOURCE_DIR}/." "${WP_DIR}/"
  else
    echo "ℹ️  Brak ${WP_SOURCE_DIR}. Pobieram WordPress przez WP-CLI…"
    wp core download --path="${WP_DIR}" --allow-root
  fi
fi

# Własność katalogu dla php-fpm (u Ciebie to nobody:nogroup)
chown -R nobody:nogroup "${WP_DIR}"

# Tworzenie wp-config.php (jeśli nie istnieje)
if [ ! -f "${WP_CONFIG_FILE}" ]; then
  echo "ℹ️  Generuję wp-config.php…"
  cat > "${WP_CONFIG_FILE}" <<EOL
<?php
define('DB_NAME', '${DB_NAME}');
define('DB_USER', '${DB_USER}');
define('DB_PASSWORD', '${DB_PASS}');
define('DB_HOST', '${DB_HOST}');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

define('AUTH_KEY',         '$(openssl rand -base64 32)');
define('SECURE_AUTH_KEY',  '$(openssl rand -base64 32)');
define('LOGGED_IN_KEY',    '$(openssl rand -base64 32)');
define('NONCE_KEY',        '$(openssl rand -base64 32)');
define('AUTH_SALT',        '$(openssl rand -base64 32)');
define('SECURE_AUTH_SALT', '$(openssl rand -base64 32)');
define('LOGGED_IN_SALT',   '$(openssl rand -base64 32)');
define('NONCE_SALT',       '$(openssl rand -base64 32)');

\$table_prefix = '${TABLE_PREFIX}';
define('WP_DEBUG', false);

if ( ! defined('ABSPATH') ) {
    define('ABSPATH', _DIR_ . '/');
}
require_once ABSPATH . 'wp-settings.php';
EOL

  chown nobody:nogroup "${WP_CONFIG_FILE}"
fi

echo "🚀 Uruchamiam PHP-FPM…"
exec /usr/sbin/php-fpm82 -F