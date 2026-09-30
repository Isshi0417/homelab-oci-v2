#!/usr/bin/env bash

# Runs once after the dev container is created
set -euo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Install git hooks and Ansible dependencies once they exist in the repo
[[ -f .pre-commit-config.yaml ]] && pre-commit install --install-hooks
[[ -f ansible/requirements.yml ]] && ansible-galaxy install -r ansible/requirements.yml

# Sanity check
if podman info --format '{{.Host.RemoteSocket.Path}}' >/dev/null 2>&1; then
  echo "podman: connected to host engine"
else
  echo "WARNING: host Podman socket not reachable."
  echo "         On the host run: systemctl --user enable --now podman.socket"
fi

echo
echo "Toolchain:"
terraform version | sed -n 1p
tflint --version | sed -n 1p
ansible --version | sed -n 1p
ansible-lint --version | sed -n 1p
molecule --version | sed -n 1p
echo "cosign $(cosign version --json 2>/dev/null | jq -r .gitVersion)"
hugo version | cut -d' ' -f1-2
podman --version
