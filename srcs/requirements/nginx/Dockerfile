FROM alpine:3.19

ARG DOMAIN_NAME=bkaleta.42.fr

RUN apk update && apk add --no-cache nginx openssl bash

RUN mkdir -p /etc/nginx/ssl /run/nginx

RUN openssl req -x509 -nodes -newkey rsa:4096 -sha256 -days 365 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=PL/ST=Warsaw/L=Warsaw/O=42 School/OU=${DOMAIN_NAME}/CN=${DOMAIN_NAME}" \
    -addext "subjectAltName=DNS:${DOMAIN_NAME}"

RUN chmod 600 /etc/nginx/ssl/server.key

RUN rm -f /etc/nginx/conf.d/default.conf /etc/nginx/http.d/default.conf 2>/dev/null || true

COPY ./conf.d/nginx.conf /etc/nginx/nginx.conf
COPY ./conf.d/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]