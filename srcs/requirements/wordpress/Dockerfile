FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php8.2 \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-zip \
        php8.2-imagick \
        curl \
        ca-certificates \
        mariadb-client && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]

