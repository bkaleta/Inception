# Setting alpine to be OS for this image
FROM alpine:3.18

# Installing MariaDB and additional tools needed
RUN apk update && apk add --no-cache mariadb mariadb-client bash openrc

# Creating catalog + setting owner
RUN mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Copying init script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Port and Volumen
EXPOSE 3306
VOLUME ["/var/lib/mysql"]

# Entrypoint
ENTRYPOINT ["entrypoint.sh"]