.PHONY: help
.PHONY: build pull down down-% logs-% up up-%
.PHONY: clean init lint ping rollout status test
.PHONY: traefik-http traefik-https-letsencrypt traefik-https-mkcert
.PHONY: sequelace
.SILENT:

# If custom.makefile exists include it.
-include custom.Makefile

SITECTL ?= sitectl
SITECTL_CONTEXT ?=
SITECTL_ARGS := $(if $(SITECTL_CONTEXT),--context $(SITECTL_CONTEXT),)

help: ## Show this help message
	echo 'Usage: make [target]'
	echo ''
	echo 'Available targets:'
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%s\033[0m\t%s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort | column -t -s $$'\t'

status: ## Show the current status of the development environment
	$(SITECTL) $(SITECTL_ARGS) validate
	$(SITECTL) $(SITECTL_ARGS) traefik ingress-status

traefik-http: ## Switch to HTTP mode (default)
	$(SITECTL) $(SITECTL_ARGS) traefik tls http

traefik-https-mkcert: ## Switch to HTTPS mode using mkcert self-signed certificates
	$(SITECTL) $(SITECTL_ARGS) traefik tls mkcert

traefik-https-letsencrypt: ## Switch to HTTPS mode using Let's Encrypt ACME
	$(SITECTL) $(SITECTL_ARGS) traefik tls letsencrypt

pull:
	$(SITECTL) $(SITECTL_ARGS) compose pull --ignore-buildable --ignore-pull-failures

build: pull ## Build the drupal container
	id -u > ./certs/UID
	$(SITECTL) $(SITECTL_ARGS) compose build

lint: ## Lint custom Drupal code
	./scripts/lint.sh

test: ## Run custom Drupal tests
	./scripts/test.sh

init: ## Get the host machine configured to run ISLE
	./scripts/init.sh

up: ## Start docker compose project
	$(SITECTL) $(SITECTL_ARGS) compose up --remove-orphans -d

up-%:  ## Start a specific service (e.g., make up-drupal)
	$(SITECTL) $(SITECTL_ARGS) compose up $*

down:  ## Stop/remove the docker compose project's containers and network.
	$(SITECTL) $(SITECTL_ARGS) compose down

down-%:  ## Stop/remove a specific service (e.g., make down-traefik)
	$(SITECTL) $(SITECTL_ARGS) compose stop $*
	$(SITECTL) $(SITECTL_ARGS) compose rm -f $*

logs-%:  ## Look at logs for a specific service (e.g., make logs-drupal)
	$(SITECTL) $(SITECTL_ARGS) compose logs $* --tail 20 -f

clean:  ## Delete all stateful data.
	./scripts/clean.sh

ping:  ## Ensure site is available.
	$(SITECTL) $(SITECTL_ARGS) healthcheck

rollout: ## Roll out the currently checked out Drupal stack.
	./scripts/rollout.sh

sequelace:
	$(SITECTL) $(SITECTL_ARGS) sequelace
