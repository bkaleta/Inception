COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE     = srcs/.env

all: create_dirs build up

create_dirs:
	@echo "📂 Tworzenie katalogów na podstawie $(ENV_FILE)…"
	@set -a; . $(ENV_FILE); set +a; \
	mkdir -p "$${DATA_PATH}/db" "$${DATA_PATH}/wp"; \
	echo "✅ Utworzone: $${DATA_PATH}/db oraz $${DATA_PATH}/wp"

build:
	docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE) build

up:
	docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE) up -d

down:
	docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE) down

clean: down
	docker system prune -af
	docker volume prune -f

re: clean all

.PHONY: all create_dirs build up down clean re
