#!/bin/sh
set -e

DB_DIR="/var/lib/mysql"
DB_NAME="${DB_NAME:-${MYSQL_DATABASE}}"
DB_USER="${DB_USER:-${MYSQL_USER}}"
DB_PASS="$(cat "${DB_PASSWORD_FILE}")"
ROOT_PASS="$(cat "${DB_ROOT_PASSWORD_FILE}")"

# init przy 1. starcie
if [ ! -d "$DB_DIR/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir="$DB_DIR" > /dev/null

    mysqld --user=mysql --skip-networking &
    pid="$!"
    # czekamy aż serwer wstanie
    for i in $(seq 1 20); do
        mysqladmin ping 2>/dev/null && break
        sleep 1
    done

    echo "Configuring database and users..."
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';"
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
    mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%'; FLUSH PRIVILEGES;"

    mysqladmin shutdown -p"${ROOT_PASS}"
    wait "$pid" || true
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir="$DB_DIR"