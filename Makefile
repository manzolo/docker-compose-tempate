ENV_FILE := .env
DOCKER_COMPOSE := docker compose
RED := \033[0;31m
NC := \033[0m # No Color

# Load variables from the .env file if it exists
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export $(shell sed 's/=.*//' $(ENV_FILE))
endif


.PHONY: start enter stop logs pull prepare uninstall

# Target to start the containers
start:
	@echo "Restarting $(DOCKER_COMPOSE) containers..."
	$(DOCKER_COMPOSE) up --remove-orphans -d

# Target to enter the container
enter:
	@if [ -z "${SERVICE_NAME}" ]; then \
	    echo "$(RED)Error: SERVICE_NAME is not set. Please define it in your environment or .env file.$(NC)"; \
	    exit 1; \
	fi

	@echo "Entering container: ${SERVICE_NAME}..."
	$(DOCKER_COMPOSE) run --remove-orphans ${SERVICE_NAME} /bin/bash

# Target to stop and remove the containers
stop:
	@echo "Stopping and removing $(DOCKER_COMPOSE) containers..."
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) rm -f

# Target to follow the container logs
logs:
	@echo "Displaying container logs..."
	$(DOCKER_COMPOSE) logs -f

# Target to pull the images
pull:
	@echo "Pulling images..."
	$(DOCKER_COMPOSE) pull

# Target to prepare the environment (e.g., pulling the latest images)
prepare:
	@echo "Preparing environment..."
	$(DOCKER_COMPOSE) pull
	
# Target to uninstall: stop containers, remove them, and delete all images and volumes
uninstall:
	@echo "Uninstalling..."
	$(DOCKER_COMPOSE) down && $(DOCKER_COMPOSE) rm -f
	$(DOCKER_COMPOSE) down --rmi all --volumes

help:
	@echo "Available targets:"
	@echo "  start    - Restart Docker Compose containers"
	@echo "  enter    - Enter a specific container (SERVICE_NAME must be set)"
	@echo "  stop     - Stop and remove Docker Compose containers"
	@echo "  logs     - Follow container logs"
	@echo "  pull     - Pull the latest images"
	@echo "  prepare  - Prepare the environment by pulling images"
	@echo "  uninstall- Remove containers, images, and volumes"
