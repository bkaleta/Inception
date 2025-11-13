FROM alpine:3.19

# Używamy ARG, aby móc zdefiniować nazwę użytkownika/domeny podczas budowania
ARG USER_CN=bkaleta

RUN apk update && \
    apk add --no-cache nginx openssl bash

# Tworzenie katalogów SSL
RUN mkdir -p /etc/nginx/ssl

# Generowanie certyfikatu SSL i klucza
# Używamy ścieżek z Twoim loginem: /etc/nginx/ssl/bkaleta.crt i bkaleta.key
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
        -out /etc/nginx/ssl/${USER_CN}.crt \
        -keyout /etc/nginx/ssl/${USER_CN}.key \
        -subj "/C=PL/ST=Warsaw/L=Warsaw/O=42 School/OU=${USER_CN}/CN=${USER_CN}/"

# Zapewnienie, że klucz jest bezpieczny
RUN chmod 600 /etc/nginx/ssl/${USER_CN}.key

# --- START BLOKU KOPIOWANIA KONFIGURACJI ---
# Usuń domyślne konfiguracje z Alpine, aby uniknąć konfliktów
RUN rm -f /etc/nginx/http.d/default.conf 2>/dev/null || true

# KROK 1: Kopiowanie głównej konfiguracji Nginx (z blokiem http)
# Pamiętaj: ten plik musi zawierać kontekst 'http { ... include /etc/nginx/conf.d/*.conf; }'
COPY ./conf.d/nginx.conf /etc/nginx/nginx.conf

# KROK 2: Kopiowanie konfiguracji serwera (z blokiem server)
COPY ./conf.d/default.conf /etc/nginx/conf.d/default.conf
# --- KONIEC BLOKU KOPIOWANIA KONFIGURACJI ---


RUN mkdir -p /run/nginx

EXPOSE 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]