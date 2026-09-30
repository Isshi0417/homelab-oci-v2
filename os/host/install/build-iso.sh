#!/usr/bin/env bash

set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(git -C "$here" rev-parse --show-toplevel)"

IMAGE="${IMAGE:-ghcr.io/isshi0417/homelab-host:latest}"
BIB_IMAGE="quay.io/centos-bootc/bootc-image-builder:latest"
required=(ADMIN_USER ADMIN_PASSWORD_HASH SSH_PUBKEY HOST_NAME TIMEZONE INSTALL_DISK WIFI_SSID WIFI_PSK)

if [[ ! -f "$here/install.env" ]]; then
    echo "Missing $here/install.env (copy install.env.example and fill it in)" >&2
    exit 1
fi

set -a
# shellcheck source=/dev/null
source "$here/install.env"
set +a

for var in "${required[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "install.env: $var is empty" >&2
        exit 1
    fi
done

umask 077
config="$here/config.toml"
trap 'rm -rf "$config"' EXIT
# shellcheck disable=SC2016  # envsubst needs the literal ${VAR} names
envsubst "$(printf '${%s} ' "${required[@]}")" < "$here/config.toml.in" > "$config"

mkdir -p "$repo/output"
sudo podman pull "$IMAGE"
sudo podman run --rm -it --privileged --pull=newer \
    --security-opt label=type:unconfined_t \
    -v "$config:/config.toml:ro" \
    -v "$repo/output:/output" \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    "$BIB_IMAGE" build --type anaconda-iso "$IMAGE"

sudo chown -R "$(id -u):$(id -g)" "$repo/output"
echo "ISO ready: $repo/output/bootiso/install.iso"
