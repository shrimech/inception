FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y \
        php-fpm:8.1 \
        php-mysql:8.1 && \
        wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/bin/wp && \
        chmod +x /usr/bin/wp
        
RUN sed -i 's/^listen.*/listen = 0.0.0.0:9000/' /etc/php/8.1/fpm/pool.d/www.conf

COPY conf/mariadb.sh /usr/local/bin/mariadb.sh

RUN chmod +x /usr/local/bin/mariadb.sh



ENTRYPOINT ["/usr/local/bin/mariadb.sh"]