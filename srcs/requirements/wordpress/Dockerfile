FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php-fpm \
        php-mysql \
        php-cli \
        wget && \
    rm -rf /var/lib/apt/lists/*


        
RUN sed -i 's/^listen.*/listen = 0.0.0.0:9000/' /etc/php/*/fpm/pool.d/www.conf

COPY conf/wordpress.sh /usr/local/bin/wordpress.sh

RUN chmod +x /usr/local/bin/wordpress.sh



ENTRYPOINT ["/usr/local/bin/wordpress.sh"]