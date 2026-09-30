HOST_IMAGE ?= localhost/homelab-host:latest

.PHONY: help lint host

help: ## Show available targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

lint: ## Run all pre-commit hooks
	pre-commit run --all-files

host: ## Build the host bootc image
	podman build --pull=newer -t $(HOST_IMAGE) os/host
