*This project has been created as part of the 42 curriculum by <bkaleta>*

# USER_DOC

## Overview

This project provides you with three services 
    WordPress (PHP-FPM)
    NGINX (HTTPS server)
    MariaDB (database)

All three services are stored in "containers" which are separate boxes 
sharing OS core which makes them fast to build.
All three services share network and are able to "speak" with each other.

------------------------------------------------------------------------

## Available Services

-   Website: https://your-domain
-   WordPress Admin Panel: https://your-domain/wp-admin

------------------------------------------------------------------------

## Starting the Project

To start the project:
After downloading the repository go it root and use following commands.
Please check if you are in right folder you have to be in a place where
you have Makefile.

------------------------------------------------------------------------
## Building the Project

if you use command "make" the project will build it self from the scrach 
using docker compose so you can use it for a shortcut or go with command
docker compose up -d --build 

to use docker compose up -d --build you have to go to srcs file and use
it there

------------------------------------------------------------------------

## Stopping the Project

in order to stop the containers please use make down or 
docker compose down similarlly as in the previous section

------------------------------------------------------------------------

## Accessing the Website

Open in browser:

https://your-domain

------------------------------------------------------------------------

## Accessing Admin Panel

Open in browser:

https://your-domain/wp-admin

Use credentials defined in .env file.

------------------------------------------------------------------------

## Credentials

Credentials are stored in: - .env file.

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
