FROM alpine:3.22

RUN apk update && apk upgrade
RUN apk add --no-cache php82 php82-fpm php82-mysqli bash unzip curl openssl

# Create system user and group 'www_data' (Alpine-safe)
RUN addgroup -S www_data && \
    adduser -S -G www_data -h /var/www -s /sbin/nologin www_data

# Create WordPress directory and set ownership
# /var/www/html będzie docelowym woluminem
RUN mkdir -p /var/www/html && chown -R www_data:www_data /var/www/html

# --- POPRAWKA: Pobieramy pliki do TYMCZASOWEGO katalogu ---
WORKDIR /tmp
RUN mkdir -p /usr/src/wordpress && chown -R www_data:www_data /usr/src/wordpress
RUN curl -o wordpress.tar.gz -fSL https://wordpress.org/latest.tar.gz && \
    tar -xzf wordpress.tar.gz -C /usr/src/wordpress --strip-components=1 && \
    rm wordpress.tar.gz

# --- KONIEC POPRAWKI ---

WORKDIR /var/www/html

RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php82/php-fpm.d/www.conf && \
    sed -i 's|^user = .*|user = www_data|' /etc/php82/php-fpm.d/www.conf && \
    sed -i 's|^group = .*|group = www_data|' /etc/php82/php-fpm.d/www.conf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]