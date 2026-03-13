#!/bin/bash
set -e

WP_PATH="${WP_PATH:-/var/www/html}"
WP_SOURCE_DIR="/usr/src/wordpress"

DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASS="$(cat "${DB_PASSWORD_FILE}")"
DB_HOST="${MYSQL_HOSTNAME}"
DB_PORT="${MYSQL_PORT:-3306}"

WP_URL="https://${DOMAIN_NAME}"
WP_TITLE="${WP_TITLE}"
WP_ADMIN_USER="${WP_ADMIN_USR}"
WP_ADMIN_PASS="${WP_ADMIN_PWD}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL}"
WP_SECONDARY_USER="${WP_USER_USR}"
WP_SECONDARY_EMAIL="${WP_USER_EMAIL}"
WP_SECONDARY_PASS="${WP_USER_PWD}"
WP_SECONDARY_ROLE="${WP_USER_ROLE:-author}"

if [ -z "${DB_HOST}" ] || [ -z "${DB_USER}" ] || [ -z "${DB_PASS}" ] || [ -z "${DB_NAME}" ]; then
	echo "ERROR: Missing DB configuration."
	echo "Required: MYSQL_HOSTNAME, MYSQL_USER, MYSQL_DATABASE, DB_PASSWORD_FILE"
	exit 1
fi

if [ -z "${WP_URL}" ] || [ -z "${WP_TITLE}" ] || [ -z "${WP_ADMIN_USER}" ] || [ -z "${WP_ADMIN_PASS}" ] || [ -z "${WP_ADMIN_EMAIL}" ]; then
	echo "ERROR: Missing WordPress configuration."
	echo "Required: DOMAIN_NAME, WP_TITLE, WP_ADMIN_USR, WP_ADMIN_PWD, WP_ADMIN_EMAIL"
	exit 1
fi

if printf '%s' "${WP_ADMIN_USER}" | grep -qi 'admin'; then
	echo "ERROR: WP_ADMIN_USR must not contain the substring 'admin'."
	exit 1
fi

echo "ℹ️  Sprawdzam zawartość ${WP_PATH}..."
mkdir -p "${WP_PATH}"

if [ ! -f "${WP_PATH}/wp-settings.php" ]; then
	echo "ℹ️  Wolumin nie zawiera jeszcze WordPressa."
	if [ -d "${WP_SOURCE_DIR}" ] && [ -f "${WP_SOURCE_DIR}/wp-settings.php" ]; then
		echo "ℹ️  Kopiuję WordPress z obrazu (${WP_SOURCE_DIR} → ${WP_PATH})..."
		cp -r "${WP_SOURCE_DIR}/." "${WP_PATH}/"
	else
		echo "ℹ️  Brak źródeł w obrazie. Pobieram WordPress przez WP-CLI..."
		wp core download --path="${WP_PATH}" --allow-root
	fi
fi

chown -R www-data:www-data "${WP_PATH}"

echo "ℹ️  DB_HOST=${DB_HOST}"
echo "ℹ️  DB_NAME=${DB_NAME}"
echo "ℹ️  DB_USER=${DB_USER}"

echo "ℹ️  Sprawdzam DNS dla hosta bazy..."
getent hosts "${DB_HOST}" || true

echo "ℹ️  Czekam aż port ${DB_PORT} będzie otwarty..."
for i in $(seq 1 30); do
	if nc -z "${DB_HOST}" "${DB_PORT}"; then
		echo "✅ Port ${DB_PORT} odpowiada"
		break
	fi
	echo "⏳ Port ${DB_PORT} jeszcze nie odpowiada..."
	sleep 2
	if [ "${i}" -eq 30 ]; then
		echo "❌ Port ${DB_PORT} nie odpowiada"
		exit 1
	fi
done

echo "ℹ️  Czekam aż baza i użytkownik będą gotowe..."
for i in $(seq 1 30); do
	if mariadb --skip-ssl \
		-h"${DB_HOST}" \
		-P"${DB_PORT}" \
		-u"${DB_USER}" \
		-p"${DB_PASS}" \
		--protocol=tcp \
		-e "USE ${DB_NAME};" >/dev/null 2>&1; then
		echo "✅ Połączenie z bazą działa"
		break
	fi
	echo "⏳ User lub baza jeszcze niegotowe..."
	sleep 2
	if [ "${i}" -eq 30 ]; then
		echo "❌ Nie udało się połączyć z bazą"
		exit 1
	fi
done

if [ ! -f "${WP_PATH}/wp-config.php" ]; then
	echo "ℹ️  Generuję wp-config.php przez WP-CLI..."
	wp config create \
		--path="${WP_PATH}" \
		--dbname="${DB_NAME}" \
		--dbuser="${DB_USER}" \
		--dbpass="${DB_PASS}" \
		--dbhost="${DB_HOST}:${DB_PORT}" \
		--skip-check \
		--allow-root
fi

if ! wp core is-installed --path="${WP_PATH}" --allow-root >/dev/null 2>&1; then
	echo "⚙️  Instaluję WordPress..."
	wp core install \
		--path="${WP_PATH}" \
		--url="${WP_URL}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASS}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root
fi

echo "ℹ️  Aktualizuję podstawowe ustawienia WordPressa..."
wp option update home "${WP_URL}" --path="${WP_PATH}" --allow-root >/dev/null 2>&1 || true
wp option update siteurl "${WP_URL}" --path="${WP_PATH}" --allow-root >/dev/null 2>&1 || true

echo "ℹ️  Synchronizuję konto administratora..."
if wp user get "${WP_ADMIN_USER}" --path="${WP_PATH}" --allow-root >/dev/null 2>&1; then
	wp user update "${WP_ADMIN_USER}" \
		--user_email="${WP_ADMIN_EMAIL}" \
		--user_pass="${WP_ADMIN_PASS}" \
		--display_name="${WP_ADMIN_USER}" \
		--path="${WP_PATH}" \
		--allow-root >/dev/null 2>&1 || true
	wp user add-role "${WP_ADMIN_USER}" administrator \
		--path="${WP_PATH}" \
		--allow-root >/dev/null 2>&1 || true
else
	wp user create "${WP_ADMIN_USER}" "${WP_ADMIN_EMAIL}" \
		--role=administrator \
		--user_pass="${WP_ADMIN_PASS}" \
		--path="${WP_PATH}" \
		--allow-root >/dev/null 2>&1
fi

if [ -n "${WP_SECONDARY_USER}" ] && [ -n "${WP_SECONDARY_EMAIL}" ] && [ -n "${WP_SECONDARY_PASS}" ]; then
	echo "ℹ️  Synchronizuję dodatkowego użytkownika..."
	if wp user get "${WP_SECONDARY_USER}" --path="${WP_PATH}" --allow-root >/dev/null 2>&1; then
		wp user update "${WP_SECONDARY_USER}" \
			--user_email="${WP_SECONDARY_EMAIL}" \
			--user_pass="${WP_SECONDARY_PASS}" \
			--path="${WP_PATH}" \
			--allow-root >/dev/null 2>&1 || true
		wp user set-role "${WP_SECONDARY_USER}" "${WP_SECONDARY_ROLE}" \
			--path="${WP_PATH}" \
			--allow-root >/dev/null 2>&1 || true
	else
		wp user create "${WP_SECONDARY_USER}" "${WP_SECONDARY_EMAIL}" \
			--role="${WP_SECONDARY_ROLE}" \
			--user_pass="${WP_SECONDARY_PASS}" \
			--path="${WP_PATH}" \
			--allow-root >/dev/null 2>&1
	fi
fi

chown -R www-data:www-data "${WP_PATH}"

echo "🚀 Uruchamiam PHP-FPM..."
exec "$@"