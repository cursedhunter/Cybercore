#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: $0 <ssh-user> <ssh-host>"
  exit 1
}

SSH_USER=${1:-}
if [[ -z "$SSH_USER" ]]; then
  usage
fi

SSH_HOST=${2:-}
if [[ -z "$SSH_HOST" ]]; then
  usage
fi

ssh -T "$SSH_USER@$SSH_HOST" bash << 'EOF'
set -euox pipefail

export CLAB_LABDIR_BASE=/run
timeout --preserve-status 10m clab destroy --all --cleanup || true

RUNNING_CONTAINER_IDS=$(docker ps -q --filter "label=containerlab")
if [[ ! -z "$RUNNING_CONTAINER_IDS" ]]; then
  echo "Killing all running containers $RUNNING_CONTAINER_IDS"
  docker kill $RUNNING_CONTAINER_IDS
fi

echo "Pruning docker"
docker system prune -f --volumes

echo "Cleaning topology files older than 20days"
find . -name "mclab-*" -mtime +20 -exec rm -rf "{}" +
EOF
