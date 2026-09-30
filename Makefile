HOST_IMAGE ?= localhost/homelab-host:latest
GUEST_IMAGE ?= localhost/homelab-guest:latest

.PHONY: help lint host guest iso qcow2 host-check host-config

help: ## Show available targets
	@grep -E '^[a-z0-9-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf " %-12s%s\n", $$1, $$2}'

lint: ## Run all pre-commit hooks
	pre-commit run --all-files

host: ## Build the host bootc image
	podman build --pull=newer -f os/host/Containerfile -t $(HOST_IMAGE) os

guest: ## Build the guest (VM) bootc image
	podman build --pull=newer -f os/guest/Containerfile -t $(GUEST_IMAGE) os

iso: ## Build the host installer ISO (run on the host, needs sudo)
	os/host/install/build-iso.sh

qcow2: ## Build the guest VM base disk (run on the host, needs sudo)
	os/guest/build-qcow2.sh

host-check: ## Dry-run the host configuration and show diffs
	cd ansible && ansible-playbook playbooks/host.yml --check --diff

host-config: ## Apply the host configuration
	cd ansible && ansible-playbook playbooks/host.yml
