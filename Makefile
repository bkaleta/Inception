SHELL := /bin/bash

COMPOSE_FILE := srcs/docker-compose.yml
ENV_FILE := srcs/.env
COMPOSE := docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

.PHONY: all create_dirs hosts build up down logs ps clean fclean re hostsclean

all: hosts create_dirs up

create_dirs:
	@echo "📂 Tworzenie katalogów danych..."
	@set -a; . $(ENV_FILE); set +a; \
	mkdir -p "$${DATA_PATH}/db" "$${DATA_PATH}/wp"; \
	chmod -R 755 "$${DATA_PATH}"; \
	echo "✅ Utworzono: $${DATA_PATH}/db oraz $${DATA_PATH}/wp"

hosts:
	@echo "🌐 Dodawanie wpisu do /etc/hosts..."
	@set -a; . $(ENV_FILE); set +a; \
	if ! grep -q "$${DOMAIN_NAME}" /etc/hosts; then \
		echo "127.0.0.1 $${DOMAIN_NAME}" | sudo tee -a /etc/hosts > /dev/null; \
		echo "✅ Dodano $${DOMAIN_NAME} do /etc/hosts"; \
	else \
		echo "ℹ️  Wpis $${DOMAIN_NAME} już istnieje w /etc/hosts"; \
	fi

build:
	$(COMPOSE) build --no-cache

up:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean:
	@echo "🧹 Zatrzymywanie i usuwanie kontenerów..."
	$(COMPOSE) down -v --remove-orphans
	@echo "🗑️  Usuwanie katalogu danych..."
	@set -a; . $(ENV_FILE); set +a; \
	sudo rm -rf "$${DATA_PATH}"; \
	echo "✅ Dane wyczyszczone."

hostsclean:
	@echo "🌐 Usuwanie wpisu z /etc/hosts..."
	@set -a; . $(ENV_FILE); set +a; \
	sudo sed -i "\|$${DOMAIN_NAME}|d" /etc/hosts || true

fclean: clean hostsclean
	@echo "💥 Usuwanie cache Dockera..."
	docker system prune -af
	docker volume prune -f

re: fclean all