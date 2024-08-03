.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

help: ## Print this help
	@echo "Usage: make {build|init|preview|article|book|textlint}"
	@echo
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## exec docker-compose build
	@docker compose build

init: build ## exec docker-compose build & npx zenn init
	@docker compose run --rm npx zenn init

preview: ## exec npx zenn preview
	@docker compose up

article: ## exec npx zenn new:article
	@docker compose run --rm npx zenn new:article

book: ## exec npx zenn new:book
	@docker compose run --rm npx zenn new:book
	
textlint: ## exec npx textlint articles/*.md
	@docker compose run --rm npx textlint articles/*.md