#!/bin/sh

set -eu

datadir=/var/lib/mysql
socket=/run/mysqld/mysqld.sock
initialized_marker="$datadir/.inception_initialized"

mysql_root_password=${MYSQL_ROOT_PASSWORD:-}
mysql_database=${MYSQL_DATABASE:-}
mysql_user=${MYSQL_USER:-}
mysql_password=${MYSQL_PASSWORD:-}

if [ -z "$mysql_root_password" ]; then
    echo "MYSQL_ROOT_PASSWORD must be set" >&2
    exit 1
fi

if [ -z "$mysql_database" ] || [ -z "$mysql_user" ] || [ -z "$mysql_password" ]; then
    echo "MYSQL_DATABASE, MYSQL_USER, and MYSQL_PASSWORD must be set" >&2
    exit 1
fi

mkdir -p /run/mysqld "$datadir"
chown -R mysql:mysql /run/mysqld "$datadir"

initialize_database=0
if [ ! -f "$initialized_marker" ]; then
    initialize_database=1
fi
if [ ! -d "$datadir/mysql" ]; then
    mysql_install_db --user=mysql --datadir="$datadir" --skip-test-db
fi

if [ "$initialize_database" -eq 0 ]; then
    exec mariadbd --user=mysql --datadir="$datadir"
fi

mariadb_args="--user=mysql --datadir=$datadir --socket=$socket --skip-networking"
mariadbd $mariadb_args &
server_pid=$!

cleanup() {
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

attempt=0
until mariadb-admin --socket="$socket" -uroot ping >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 30 ]; then
        echo "MariaDB did not become ready" >&2
        exit 1
    fi
    sleep 1
done

sql_escape() {
    printf "%s" "$1" | sed "s/'/''/g"
}

root_password=$(sql_escape "$mysql_root_password")
database=$(sql_escape "$mysql_database")
user=$(sql_escape "$mysql_user")
password=$(sql_escape "$mysql_password")

mariadb --socket="$socket" -uroot <<-SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$root_password';
    CREATE DATABASE IF NOT EXISTS \`$database\`;
    CREATE USER IF NOT EXISTS '$user'@'%' IDENTIFIED BY '$password';
    ALTER USER '$user'@'%' IDENTIFIED BY '$password';
    GRANT ALL PRIVILEGES ON \`$database\`.* TO '$user'@'%';
    FLUSH PRIVILEGES;
SQL

mariadb-admin --socket="$socket" -uroot -p"$mysql_root_password" shutdown
wait "$server_pid"
touch "$initialized_marker"
chown mysql:mysql "$initialized_marker"
trap - EXIT INT TERM
exec mariadbd --user=mysql --datadir="$datadir"