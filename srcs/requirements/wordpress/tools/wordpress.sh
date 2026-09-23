#!/bin/bash

set -e

mkdir -p /var/www/html



    echo "WordPress core downloaded successfully."
until mysqladmin ping --host=mariadb --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --silent; do
    sleep 1
done
echo "MariaDB is up and running!----------"
if [ ! -f wp-config.php ]; then

    wp core download --allow-root


    wp config create  --dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" --dbpass="${MYSQL_PASSWORD}" --dbhost=mariadb --allow-root

    wp core install  --url="${DOMAIN_NAME}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASSWORD}" --admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root

    wp user create  "${WP_USER}" "${WP_EMAIL}" --user_pass="${WP_PASSWORD}" --role=author --allow-root

fi
    chown --recursive www-data:www-data /var/www/html

exec php-fpm8.2 -F
