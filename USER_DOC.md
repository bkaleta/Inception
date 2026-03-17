# USER_DOC

## Overview

This project provides a containerized WordPress environment using Docker
Compose. It consists of three services: - NGINX (HTTPS server) -
WordPress (PHP-FPM) - MariaDB (database)

------------------------------------------------------------------------

## Available Services

-   Website: https://`<your-domain>`{=html}
-   WordPress Admin Panel: https://`<your-domain>`{=html}/wp-admin

------------------------------------------------------------------------

## Starting the Project

To start the project:

make or docker compose up -d --build

------------------------------------------------------------------------

## Stopping the Project

docker compose down

------------------------------------------------------------------------

## Accessing the Website

Open in browser:

https://`<your-domain>`{=html}

------------------------------------------------------------------------

## Accessing Admin Panel

https://`<your-domain>`{=html}/wp-admin

Use credentials defined in `.env` file.

------------------------------------------------------------------------

## Credentials

Credentials are stored in: - `.env` file.

------------------------------------------------------------------------

## Checking Services

docker ps docker compose logs -f

------------------------------------------------------------------------

## Verifying NGINX (HTTPS only)

Commands used to verify that NGINX is accessible only through port 443.

curl -I http://localhost curl -kI https://localhost

nc -zv localhost 80 nc -zv localhost 443

------------------------------------------------------------------------

## Verifying Database

Enter MariaDB container:

docker exec -it mariadb sh

Login to database:

mariadb -u root -p\$(cat /run/secrets/db_root_password)

Check database structure:

SHOW DATABASES; USE wordpress; SHOW TABLES;

Verify WordPress users:

SELECT ID, user_login, user_email FROM wp_users;

Check roles:

SELECT \* FROM wp_usermeta WHERE meta_key='wp_capabilities';

Exit:

exit

------------------------------------------------------------------------
