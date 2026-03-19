FROM alpine:3.22

RUN apk update && apk upgrade && apk add --no-cache \
    bash \
    curl \
    unzip \
    openssl \
    ca-certificates \
    mariadb-client \
    netcat-openbsd \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-phar \
    php82-curl \
    php82-mbstring \
    php82-xml \
    php82-xmlreader \
    php82-session \
    php82-openssl \
    php82-json \
    php82-zip \
    php82-gd \
    php82-exif \
    php82-intl \
    php82-pdo \
    php82-pdo_mysql \
    php82-opcache

RUN ln -s /usr/bin/php82 /usr/bin/php

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

RUN grep -q '^www-data:' /etc/group || addgroup -S www-data && \
    grep -q '^www-data:' /etc/passwd || adduser -S -G www-data -h /var/www -s /sbin/nologin www-data

RUN mkdir -p /var/www/html /usr/src/wordpress /run/php && \
    chown -R www-data:www-data /var/www /usr/src/wordpress /run/php

WORKDIR /tmp
RUN curl -o wordpress.tar.gz -fSL https://wordpress.org/latest.tar.gz && \
    tar -xzf wordpress.tar.gz -C /usr/src/wordpress --strip-components=1 && \
    rm wordpress.tar.gz

RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php82/php-fpm.d/www.conf && \
    sed -i 's|^user = .*|user = www-data|' /etc/php82/php-fpm.d/www.conf && \
    sed -i 's|^group = .*|group = www-data|' /etc/php82/php-fpm.d/www.conf && \
    sed -i 's|^;clear_env = no|clear_env = no|' /etc/php82/php-fpm.d/www.conf

WORKDIR /var/www/html

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/sbin/php-fpm82", "-F"]