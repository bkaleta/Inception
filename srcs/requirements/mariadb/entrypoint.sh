#!/bin/sh
set -e

DB_DIR="/var/lib/mysql"
RUN_DIR="/run/mysqld"
CNF_FILE="/etc/my.cnf.d/zz-custom.cnf"
INIT_SQL="/tmp/init.sql"

mkdir -p "$DB_DIR" "$RUN_DIR" /etc/my.cnf.d
chown -R mysql:mysql "$DB_DIR" "$RUN_DIR"
chmod 750 "$DB_DIR"

FIRST_INIT=0
if [ ! -d "$DB_DIR/mysql" ] || [ ! -f "$DB_DIR/ibdata1" ]; then
	FIRST_INIT=1
fi

if [ "$FIRST_INIT" -eq 1 ]; then
	echo "[init] Initializing MariaDB data directory..."
	mariadb-install-db --user=mysql --datadir="$DB_DIR" --rpm >/dev/null

	echo "[init] Creating init.sql..."
	cat > "$INIT_SQL" <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	chmod 600 "$INIT_SQL"
	chown mysql:mysql "$INIT_SQL"

	cat > "$CNF_FILE" <<EOF
[mysqld]
user = mysql
pid-file = /run/mysqld/mysqld.pid
datadir = /var/lib/mysql
socket = /run/mysqld/mysqld.sock
bind-address = 0.0.0.0
port = 3306
skip-networking = 0
init_file = /tmp/init.sql
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
EOF
else
	cat > "$CNF_FILE" <<EOF
[mysqld]
user = mysql
pid-file = /run/mysqld/mysqld.pid
datadir = /var/lib/mysql
socket = /run/mysqld/mysqld.sock
bind-address = 0.0.0.0
port = 3306
skip-networking = 0
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
EOF
fi

echo "[run] Starting MariaDB..."
exec mysqld --user=mysql --datadir="$DB_DIR"