.DEFAULT_GOAL := help
.NOTPARALLEL:
DC = docker compose
TOOLS = $(DC) run --rm tools
ARGS ?=
FILE ?= backups/database.sql
PACKAGE ?= obel

.PHONY: help configure setup up down logs composer composer-local wp db-export db-import assets-install assets-build watch check reset release-check install
help: ## Show commands
	@awk 'BEGIN {FS = ":.*## "} /^[a-z-]+:.*## / {printf "%-20s %s\n", $$1, $$2}' Makefile
configure: ## Generate .env and nginx configuration without replacing existing secrets
	$(DC) --env-file .env.example run --rm -e LOCAL_UID=$(shell id -u) -e LOCAL_GID=$(shell id -g) tools php scripts/configure.php
setup: configure composer-local assets-install assets-build up ## Prepare local dependencies and services; then run make install
up: ## Start services, preserving database and uploads
	@test -f .docker/certs/local.pem -a -f .docker/certs/local-key.pem || (echo 'Create trusted certificates first; see README'; exit 1)
	$(DC) up -d --build

down: ## Stop services, preserving all content
	$(DC) down
logs: ## Follow service logs; optionally ARGS=php
	$(DC) logs -f $(ARGS)
composer: ## Production Composer manifest; e.g. ARGS='install'
	$(TOOLS) composer $(ARGS)
composer-local: ## Generate local path manifest and resolve its separate lock
	$(TOOLS) php scripts/local-composer.php
	$(TOOLS) env COMPOSER=composer.local.json composer update --no-interaction
wp: ## WP-CLI; e.g. ARGS='plugin list'
	$(TOOLS) wp $(ARGS)
install: ## First installation; provide ADMIN_PASSWORD, optionally ADMIN_USER and ADMIN_EMAIL
	$(DC) run --rm -e ADMIN_PASSWORD -e ADMIN_USER -e ADMIN_EMAIL tools sh scripts/install.sh

db-export: ## Export DB using WP-CLI; FILE defaults to backups/database.sql
	$(TOOLS) wp db export $(FILE)
db-import: ## Explicitly replace DB content from FILE using WP-CLI
	$(TOOLS) wp db import $(FILE)
assets-install: ## Install locked theme and block dependencies
	$(DC) run --rm -w /workspace/obel node npm ci
	$(DC) run --rm -w /workspace/rune node npm ci
assets-build: ## Build production theme and block assets
	$(DC) run --rm -w /workspace/obel node npm run build
	$(DC) run --rm -w /workspace/rune node npm run build
watch: ## Watch PACKAGE=obel or PACKAGE=rune
	@test "$(PACKAGE)" = obel -o "$(PACKAGE)" = rune
	$(DC) run --rm -w /workspace/$(PACKAGE) node npm run start
check: ## PHP syntax, coding standards, JS/SCSS lint and production builds
	$(TOOLS) sh scripts/syntax.sh
	$(TOOLS) composer lint
	$(TOOLS) sh -c 'for p in obel aeon rune; do composer -d ../$$p install --no-interaction && composer -d ../$$p lint || exit; done'
	$(DC) run --rm -w /workspace/obel node npm run lint:js
	$(DC) run --rm -w /workspace/obel node npm run lint:scss
	$(DC) run --rm -w /workspace/rune node npm run lint:js
	$(DC) run --rm -w /workspace/rune node npm run lint:scss
	$(MAKE) assets-build
release-check: ## Refuse deployment until all custom packages have real tags
	$(TOOLS) php scripts/release-check.php
reset: ## DESTRUCTIVE: remove local DB and uploads; requires CONFIRM=destroy
	@test "$(CONFIRM)" = destroy || (echo 'Use make reset CONFIRM=destroy to delete local content'; exit 1)
	$(DC) down -v
	$(TOOLS) sh -c 'find web/app/uploads -mindepth 1 ! -name .gitkeep -delete'
