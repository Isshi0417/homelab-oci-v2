#!/usr/bin/env bash

set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(git -C "$here" rev-parse --show-toplevel)"

IMAGE="${IMAGE:-ghcr.io/isshi0417/homelab-guest:lateest}"
BIB_IMAGE="quay.io/centos-bootc/bootc-image-builder:latest"

mkdir -p "$repo/output"
sudo podman pull "$IMAGE"
sudo podman run --rm -it --privileged --pull=newer \
  --security-opt label=type:unconfined_t \
  -v "$here/disk.toml:/config.toml:ro" \
  -v "$repo/output:/output" \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  "$BIB_IMAGE" build --type qcow2 "$IMAGE"

sudo chown -R "$(id -u):$(id -g)" "$repo/output"
echo "Disk ready: $repo/output/qcow2/disk.qcow2"
