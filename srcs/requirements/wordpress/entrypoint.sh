#!/bin/bash
set -e

WP_CONFIG_FILE=/var/www/html/wp-config.php
WP_SOURCE_DIR=/usr/src/wordpress

# --- KROK 1: Kopiowanie plików WP do woluminu (tylko przy pierwszym uruchomieniu) ---
# Sprawdzamy, czy katalog /var/www/html jest pusty.
if [ ! "$(ls -A /var/www/html 2>/dev/null)" ]; then
    echo "ℹ️ Wolumin /var/www/html jest pusty. Kopiowanie plików WP z obrazu na host..."
    
    # Kopiowanie plików, w tym ukrytych (.htaccess, jeśli istnieje)
    cp -r $WP_SOURCE_DIR/. /var/www/html/
    
    # NADAJ UPRAWNIENIA WŁAŚCIWE DLA PHP-FPM (www_data)
    chown -R www_data:www_data /var/www/html
    
    echo "✅ Kopiowanie i ustawianie uprawnień zakończone."
fi

# --- KROK 2: Generowanie lub używanie wp-config.php ---

# Auto-generate wp-config.php if it doesn't exist
if [ ! -f "$WP_CONFIG_FILE" ]; then
    echo "ℹ️ Generowanie wp-config.php..."
    cat > "$WP_CONFIG_FILE" <<EOL
<?php
// ZMIENIONE: Używamy zmiennych MYSQL_* z Twojego .env
define('DB_NAME', '${MYSQL_DATABASE}');
define('DB_USER', '${MYSQL_USER}');
define('DB_PASSWORD', '${cat "${DB_PASSWORD_FILE}}');
define('DB_HOST', 'mariadb'); // Używamy nazwy serwisu Docker Compose
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

\$table_prefix = '${WORDPRESS_TABLE_PREFIX:-wp_}';
define('WP_DEBUG', false);

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOL
    chown www_data:www_data "$WP_CONFIG_FILE"
fi

# --- KROK 3: Start PHP-FPM ---
echo "🚀 Uruchamiam PHP-FPM..."
exec /usr/sbin/php-fpm82 -F