#!/bin/bash

mkdir -p /var/run/mysqld

chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld


if [ ! -d "/var/lib/mysql/mysql" ]; then

    echo "Initializing MariaDB data directory..."

    mariadb-install-db \
        --datadir=/var/lib/mysql \
        --user=mysql

    mariadbd --user=mysql --datadir=/var/lib/mysql &
    
    echo "Waiting for MariaDB..."

    until mariadb-admin ping --socket=/run/mysqld/mysqld.sock --silent; do
        sleep 1
    done

    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

fi

exec mysqld --user=mysql