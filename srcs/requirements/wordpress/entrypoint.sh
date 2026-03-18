#!/bin/bash
set -e

WP_PATH="${WP_PATH:-/var/www/html}"
WP_SOURCE_DIR="/usr/src/wordpress"
DB_PORT="${DB_PORT:-3306}"
WP_USER_ROLE="${WP_USER_ROLE:-author}"

mkdir -p "${WP_PATH}"

if [ ! -f "${WP_PATH}/wp-settings.php" ]; then
	if [ -f "${WP_SOURCE_DIR}/wp-settings.php" ]; then
		cp -r "${WP_SOURCE_DIR}/." "${WP_PATH}/"
	else
		wp core download --path="${WP_PATH}" --allow-root
	fi
fi

chown -R www-data:www-data "${WP_PATH}"

for i in $(seq 1 30); do
	if mariadb --skip-ssl \
		-h"${DB_HOST}" \
		-P"${DB_PORT}" \
		-u"${DB_USER}" \
		-p"${DB_PASSWORD}" \
		--protocol=tcp \
		-e "USE ${DB_NAME};" >/dev/null 2>&1; then
		break
	fi
	sleep 2
	if [ "${i}" -eq 30 ]; then
		echo "Database is not ready"
		exit 1
	fi
done

if [ ! -f "${WP_PATH}/wp-config.php" ]; then
	wp config create \
		--path="${WP_PATH}" \
		--dbname="${DB_NAME}" \
		--dbuser="${DB_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost="${DB_HOST}:${DB_PORT}" \
		--skip-check \
		--allow-root
fi

if ! wp core is-installed --path="${WP_PATH}" --allow-root >/dev/null 2>&1; then
	wp core install \
		--path="${WP_PATH}" \
		--url="https://${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root
fi

wp option update home "https://${DOMAIN_NAME}" --path="${WP_PATH}" --allow-root >/dev/null 2>&1
wp option update siteurl "https://${DOMAIN_NAME}" --path="${WP_PATH}" --allow-root >/dev/null 2>&1

if wp user get "${WP_ADMIN_USER}" --path="${WP_PATH}" --allow-root >/dev/null 2>&1; then
	wp user update "${WP_ADMIN_USER}" \
		--user_email="${WP_ADMIN_EMAIL}" \
		--user_pass="${WP_ADMIN_PASSWORD}" \
		--display_name="${WP_ADMIN_USER}" \
		--path="${WP_PATH}" \
		--allow-root >/dev/null 2>&1
else
	wp user create "${WP_ADMIN_USER}" "${WP_ADMIN_EMAIL}" \
		--role=administrator \
		--user_pass="${WP_ADMIN_PASSWORD}" \
		--path="${WP_PATH}" \
		--allow-root >/dev/null 2>&1
fi

if [ -n "${WP_USER_NAME}" ] && [ -n "${WP_USER_EMAIL}" ] && [ -n "${WP_USER_PASSWORD}" ]; then
	if wp user get "${WP_USER_NAME}" --path="${WP_PATH}" --allow-root >/dev/null 2>&1; then
		wp user update "${WP_USER_NAME}" \
			--user_email="${WP_USER_EMAIL}" \
			--user_pass="${WP_USER_PASSWORD}" \
			--path="${WP_PATH}" \
			--allow-root >/dev/null 2>&1
		wp user set-role "${WP_USER_NAME}" "${WP_USER_ROLE}" \
			--path="${WP_PATH}" \
			--allow-root >/dev/null 2>&1
	else
		wp user create "${WP_USER_NAME}" "${WP_USER_EMAIL}" \
			--role="${WP_USER_ROLE}" \
			--user_pass="${WP_USER_PASSWORD}" \
			--path="${WP_PATH}" \
			--allow-root >/dev/null 2>&1
	fi
fi

exec "$@"