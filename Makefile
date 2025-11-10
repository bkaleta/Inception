# Makefile w katalogu głównym projektu

COMPOSE_FILE = srcs/docker-compose.yml

all: build up

build:
	docker compose -f $(COMPOSE_FILE) build

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

clean: down
	docker system prune -af
	docker volume prune -f

re: clean all
