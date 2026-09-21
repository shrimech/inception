FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl  \
    mariadb-server 
   
# Generate SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=MA/ST=Rabat/L=Rabat/O=1337/CN=${DOMAIN_NAME}"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
