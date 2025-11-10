#!/bin/sh
set -e

DB_DIR="/var/lib/mysql"

# Inicjalizacja bazy danych przy pierwszym uruchomieniu
if [ ! -d "$DB_DIR/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir="$DB_DIR" > /dev/null

    # Uruchomienie tymczasowego serwera bez sieci
    mysqld --user=mysql --skip-networking &
    sleep 5

    echo "Creating database and user..."
    mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    mysql -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
    mysql -e "FLUSH PRIVILEGES;"

    mysqladmin shutdown
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir="$DB_DIR"
