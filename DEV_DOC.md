# DEV_DOC

## Prerequisites

-   Docker
-   Docker Compose
-   Make

------------------------------------------------------------------------

## Project Setup

Clone repository and configure `.env`.

------------------------------------------------------------------------

## Environment Configuration

Variables: LOGIN - DOMAIN_NAME - NETWORK_NAME - MYSQL_DATABASE - MYSQL_USER - DATA_PATH - WP_TITLE - WP_ADMIN_USR - WP_ADMIN_EMAIL - WP_ADMIN_PWD - WP_USER_USR - WP_USER_EMAIL - WP_USER_PWD


------------------------------------------------------------------------

## Build

make build or docker compose build

------------------------------------------------------------------------

## Run

make or docker compose up -d

------------------------------------------------------------------------

## Managing Containers

docker compose ps docker compose logs -f docker exec -it
`<container_name>`{=html} sh

------------------------------------------------------------------------

## Volumes & Persistence

Data stored in:

/home/`<login>`{=html}/data

Volumes: - db - wp

------------------------------------------------------------------------

## Cleaning

make clean

------------------------------------------------------------------------

## Troubleshooting

docker compose logs docker ps docker network ls

------------------------------------------------------------------------
