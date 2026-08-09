SHELL := /bin/bash

.PHONY: help init up clean reconcile healthcheck test lint
.SILENT:

-include custom.Makefile

help: ## Show this help message
	echo 'Usage: make [target]'
	echo ''
	echo 'Available targets:'
	awk -f scripts/make-help.awk $(MAKEFILE_LIST) | sort | column -t -s $$'\t'

init reconcile: ## Generate or repair declared initialization state
	sitectl compose reconcile

up: ## Start the complete site and wait for health
	sitectl compose up --wait

clean: ## Delete generated local state after confirmation
	sitectl compose clean

healthcheck: ## Check Compose and application health
	sitectl healthcheck

test: ## Verify the running application and run custom Drupal tests when present
	./scripts/test.sh

lint: ## Lint custom Drupal code
	./scripts/lint.sh
