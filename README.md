*This project has been created as part of the 42 curriculum by <bkaleta>*

# Inception

## Description

The goal of this project is to set up a small infrastructure using
Docker and Docker Compose. The infrastructure consists of multiple
containers that work together to provide a fully functional WordPress
environment.

The project includes three main services:

-   NGINX - a web server responsible for serving HTTPS traffic.
-   MariaDB - a database used by WordPress.
-   WordPress - a PHP-based CMS running on PHP-FPM.

Each service runs inside its own Docker container, and the containers
communicate with each other through a dedicated Docker network.

The infrastructure also uses Docker volumes to persist data and Docker
secrets / environment variables to manage configuration securely.

------------------------------------------------------------------------

# Project Architecture

The infrastructure consists of three containers:

NGINX │ │ WordPress │ │ MariaDB

-   NGINX listens only on port 443 (HTTPS).
-   WordPress communicates with MariaDB through the internal Docker
    network.
-   MariaDB stores persistent data in a volume.

------------------------------------------------------------------------

# Design Choices

## Virtual Machines vs Docker

  -----------------------------------------------------------------------
  Virtual Machines                    Docker
  ----------------------------------- -----------------------------------
  Each VM includes a full operating   Containers share the host OS kernel
  system

  Higher resource consumption         Lightweight and faster

  Slower startup time                 Containers start almost instantly

  Strong isolation                    Process-level isolation
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Secrets vs Environment Variables

  -----------------------------------------------------------------------
  Environment Variables               Docker Secrets
  ----------------------------------- -----------------------------------
  Stored in ".env" files              Stored in secure files mounted
                                      inside containers

  Easy to configure                   More secure for sensitive data

  Visible in container environment    Not exposed directly as environment
                                      variables
  -----------------------------------------------------------------------

In this project: - Most configuration values are stored in ".env" -
Database passwords are stored using Docker secrets

------------------------------------------------------------------------

## Docker Network vs Host Network

  -----------------------------------------------------------------------
  Docker Network                      Host Network
  ----------------------------------- -----------------------------------
  Containers communicate via internal Containers share host networking
  DNS

  Better isolation                    Less isolation

  Default and recommended approach    Often restricted in production
  -----------------------------------------------------------------------

The project uses a custom bridge network ("inception") so containers can
communicate securely.

------------------------------------------------------------------------

## Docker Volumes vs Bind Mounts

  Docker Volumes               Bind Mounts
  ---------------------------- --------------------------------
  Managed by Docker            Directly maps host directories
  More portable                Depends on host filesystem
  Recommended for production   Often used for development

The project uses Docker named volumes to store persistent data while
ensuring the data is stored on the host inside:

/home/<login>/data

Persistent volumes: - WordPress files - MariaDB database files

------------------------------------------------------------------------

# Instructions

## Requirements

-   Docker
-   Docker Compose
-   Make

## Running the Project

Build and start all containers:

make or docker compose up -d --build

## Stop the infrastructure

make down or docker compose down

## Rebuild containers

make up or docker compose build

## View logs

docker compose logs -f

------------------------------------------------------------------------

# Most Common Docker Commands

  Command        Description
  -------------- -----------------------------------------
  docker build   Builds a Docker image from a Dockerfile
  docker run     Runs a new container from an image
  docker pull    Downloads an image from a registry
  docker push    Uploads an image to a registry
  docker ps      Lists running containers
  docker stop    Stops a running container
  docker rm      Removes a stopped container
  docker rmi     Removes an image
  docker exec    Executes a command inside a container
  docker logs    Shows container logs

------------------------------------------------------------------------

# Most Common Docker Compose Commands

  -----------------------------------------------------------------------
  Command                     Description
  --------------------------- -------------------------------------------
  docker compose up           Builds and starts containers

  docker compose down         Stops and removes containers, networks and
                              volumes

  docker compose start        Starts existing containers

  docker compose stop         Stops containers

  docker compose restart      Restarts containers

  docker compose build        Builds images defined in docker-compose.yml

  docker compose ps           Lists containers managed by Compose

  docker compose logs         Displays logs

  docker compose exec         Runs a command inside a container

  docker compose pull         Pulls images from registry

  docker compose push         Pushes images to registry
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# NGINX Tests

Commands used to verify that NGINX is accessible only through port 443.

curl -I http://localhost curl -kI https://localhost

nc -zv localhost 80 nc -zv localhost 443

Browser tests:

http://bkaleta.42.fr https://bkaleta.42.fr

Expected result: - HTTP (80) → connection refused - HTTPS (443) →
WordPress page loads

------------------------------------------------------------------------

# WordPress / Database Tests

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

# Resources

Docker documentation\
https://docs.docker.com/

Docker Compose documentation\
https://docs.docker.com/compose/

NGINX documentation\
https://nginx.org/en/docs/

WordPress CLI documentation\
https://developer.wordpress.org/cli/

MariaDB documentation\
https://mariadb.org/documentation/

------------------------------------------------------------------------

# Use of AI Tools

AI tools (including ChatGPT) were used to: 
  clarify Docker concepts
  debug container networking issues 
  improve shell scripts verify

All code and configuration were reviewed and tested manually.