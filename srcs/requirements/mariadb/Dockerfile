FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y \
        mariadb-client \
        mariadb-server

COPY conf/mariadb.sh /usr/local/bin/mariadb.sh

RUN chmod +x /usr/local/bin/mariadb.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb.sh"]