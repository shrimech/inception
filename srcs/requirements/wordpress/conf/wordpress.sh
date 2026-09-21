#!/bin/bash

set -e

mkdir -p /var/www/html

# curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
#         mv wp-cli.phar /usr/local/bin/wp && \
# chmod +x /usr/local/bin/wp

    echo "WordPress core downloaded successfully."
until mysqladmin ping --host=mariadb --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --silent; do
    sleep 1
done
echo "MariaDB is up and running!----------"
if [ ! -f wp-config.php ]; then

    wp core download --allow-root

    chown --recursive www-data:www-data /var/www/html

    wp config create  --dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" --dbpass="${MYSQL_PASSWORD}" --dbhost=mariadb --allow-root

    wp core install  --url="${DOMAIN_NAME}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASSWORD}" --admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root

    wp user create   --user_login="${WP_USER}" --user_pass="${WP_PASSWORD}" --user_email="${WP_EMAIL}" --role=author --allow-root

fi
# PHP_FPM_BIN=""
# if command -v php-fpm >/dev/null 2>&1; then
#     PHP_FPM_BIN=$(command -v php-fpm)
# else
#     for name in php-fpm8.2 php-fpm8 php-fpm7.4 php-fpm; do
#         if command -v "$name" >/dev/null 2>&1; then
#             PHP_FPM_BIN=$(command -v "$name")
#             break
#         fi
#     done
#     for path in /usr/sbin/php-fpm /usr/sbi/2 /usr/sbin/php-fpm8 /usr/sbin/php-fpm7.4; do
#         if [ -x "$path" ] && [ -z "$PHP_FPM_BIN" ]; then
#             PHP_FPM_BIN="$path"
#             break
#         fi
#     done
# fi

# if [ -z "$PHP_FPM_BIN" ]; then
#     echo "php-fpm binary not found; aborting"
#     exit 127
# fi

# echo "Starting $PHP_FPM_BIN"
exec php-fpm8.2 -F
