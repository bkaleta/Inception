#!/bin/sh
set -e

DB_DIR="/var/lib/mysql"
RUN_DIR="/run/mysqld"

DB_NAME="${DB_NAME:-${MYSQL_DATABASE}}"
DB_USER="${DB_USER:-${MYSQL_USER}}"
DB_PASS="$(cat "${DB_PASSWORD_FILE}")"
ROOT_PASS="$(cat "${DB_ROOT_PASSWORD_FILE}")"
DB_HOST="${MYSQL_HOSTNAME}"

# Katalogi i prawa (po bind-mount trzeba zrobić to TU, nie w Dockerfile)
mkdir -p "$DB_DIR" "$RUN_DIR"
chown -R mysql:mysql "$DB_DIR" "$RUN_DIR"
chmod 750 "$DB_DIR"

# 1) Inicjalizacja przy 1. starcie
if [ ! -d "$DB_DIR/mysql" ] || [ ! -f "$DB_DIR/ibdata1" ]; then
  echo "[init] Initializing MariaDB data directory..."
  mariadb-install-db --user=mysql --datadir="$DB_DIR" --rpm >/dev/null

  echo "[init] Starting temporary server (socket only)..."
  mysqld --user=mysql --datadir="$DB_DIR" --skip-networking --socket="$RUN_DIR/mysqld.sock" &
  pid="$!"

  # Czekamy aż wstanie (socket)
  for i in $(seq 1 30); do
    [ -S "$RUN_DIR/mysqld.sock" ] && mysql --protocol=socket -uroot -e "SELECT 1" && break
    sleep 1
    [ "$i" -eq 30 ] && { echo "[init] MariaDB didn't start for init"; exit 1; }
  done

  echo "[init] Securing root and creating DB/user..."
  mysql --protocol=socket -uroot <<-SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
    FLUSH PRIVILEGES;
SQL

  mysqladmin --protocol=socket -uroot -p"${ROOT_PASS}" shutdown
  wait "$pid" || true
fi

# --- Enforce TCP listen on 3306 ---
mkdir -p /etc/my.cnf.d
cat >/etc/my.cnf.d/zz-override.cnf <<'CNF'
[mysqld]
bind-address = 0.0.0.0
port = 3306
skip-networking = 0
CNF

echo "[run] Starting MariaDB (TCP :3306, 0.0.0.0)…"
exec mysqld --user=mysql --datadir="$DB_DIR" --bind-address=0.0.0.0 --port=3306 --skip-networking=0