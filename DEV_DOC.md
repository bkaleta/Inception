*This project has been created as part of the 42 curriculum by <bkaleta>*

# DEV_DOC

## Prerequisites

-   Docker
-   Docker Compose
-   Make

------------------------------------------------------------------------

## Project Setup

Clone repository and configure ".env".

------------------------------------------------------------------------

## Environment Configuration

Variables: 
    Main:
        LOGIN - DOMAIN_NAME - NETWORK_NAME - DATA_PATH 
    Database:
        DB_NAME - DB_USER -  - DB_PASSWORD - DB_ROOT_PASSWORD - DB_HOST
    Wordpress
        WP_TITLE - WP_ADMIN_USER - WP_ADMIN_EMAIL - WP_ADMIN_PASSWORD - WP_USER_NAME - WP_USER_EMAIL - WP_USER_PASSWORD


------------------------------------------------------------------------

## Build

make build or docker compose build

------------------------------------------------------------------------

## Run

make or docker compose up -d

------------------------------------------------------------------------

## Managing Containers

docker compose ps docker compose logs -f docker exec -it "container_name" sh

------------------------------------------------------------------------

## Volumes & Persistence

Data stored in:

/home/login/data

Volumes: - db - wp

------------------------------------------------------------------------

## Cleaning

make clean

------------------------------------------------------------------------

## Troubleshooting

docker compose logs docker ps docker network ls

------------------------------------------------------------------------
