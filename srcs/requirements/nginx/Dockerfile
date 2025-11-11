FROM alpine:3.19

RUN apk add --no-cache nginx openssl curl bash

# Czyści defaulty i dodaje naszą konf
RUN rm -f /etc/nginx/http.d/default.conf 2>/dev/null || true
COPY conf.d/default.conf /etc/nginx/http.d/default.conf

# Entrypoint (generowanie certu, start w foreground)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/var/www/html", "/var/log/nginx"]
EXPOSE 443

HEALTHCHECK --interval=10s --timeout=3s --retries=12 \
  CMD curl -kfsS https://localhost/ >/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx","-g","daemon off;"]