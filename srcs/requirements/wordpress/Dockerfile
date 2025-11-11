FROM alpine:3.19

# PHP-FPM + rozsądne rozszerzenia do WP
RUN apk add --no-cache \
    php82 php82-fpm php82-mysqli php82-opcache php82-phar php82-json \
    php82-mbstring php82-curl php82-xml php82-zip php82-session \
    curl ca-certificates bash shadow

# php-fpm na TCP:9000 (zamiast socketa)
RUN sed -ri 's|^;?listen = .*$|listen = 9000|' /etc/php82/php-fpm.d/www.conf \
 && sed -ri 's|^user = .*|user = nobody|' /etc/php82/php-fpm.d/www.conf \
 && sed -ri 's|^group = .*|group = nogroup|' /etc/php82/php-fpm.d/www.conf

# WP-CLI
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
      -o /usr/local/bin/wp && chmod +x /usr/local/bin/wp

# Katalog na WP
RUN mkdir -p /var/www/html && chown -R nobody:nogroup /var/www

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/var/www/html"]
EXPOSE 9000

HEALTHCHECK --interval=10s --timeout=3s --retries=30 \
  CMD php82 -r 'exit(!is_file("/var/www/html/wp-config.php"));'

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm82","-F"]