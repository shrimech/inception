#!/bin/bash

mkdir -p /var/www/html

wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -O /usr/local/bin/wp
chmod +x /usr/local/bin/wp

until mysqladmin ping --host=mariadb --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --silent; do
    sleep 1
done
if [ ! -f wp-config.php ]; then
    wp core download --path=/var/www/html --allow-root

    chown --recursive www-data:www-data /var/www/html

    wp config create  --dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" --dbpass="${MYSQL_PASSWORD}" --dbhost=mariadb --allow-root

    wp core install  --url="${DOMAIN_NAME}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASSWORD}" --admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root

    wp create user   --user_pass="${WP_PASSWORD}" --user_email="${WP_EMAIL}" --role=author "${WP_USER}" --allow-root

fi

exec /usr/sbin/php-fpm -F

