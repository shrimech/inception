FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y \
        php-fpm \
        php-mysql \
        php-cli \
        mariadb-client \
        ca-certificates \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget  https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
        chmod +x wp-cli.phar &&\
        mv wp-cli.phar /usr/local/bin/wp 
        
RUN sed -i 's/^listen.*/listen = 0.0.0.0:9000/' /etc/php/*/fpm/pool.d/www.conf

COPY tools/wordpress.sh /usr/local/bin/wordpress.sh

RUN chmod +x /usr/local/bin/wordpress.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/wordpress.sh"]