#!/bin/bash

set -euox pipefail

usage() {
  echo "Usage: $0 <ssh-user> <ssh-host> <topology-path> [<max-supported-frame-size>]"
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

TOPOLOGY_PATH=${3:-}
if [[ -z "$TOPOLOGY_PATH" ]]; then
  usage
fi

MAX_SUPPORTED_FRAME_SIZE=${4:-9236}

ssh -T "$SSH_USER@$SSH_HOST" sudo TOPOLOGY_PATH="$TOPOLOGY_PATH" MAX_SUPPORTED_FRAME_SIZE="$MAX_SUPPORTED_FRAME_SIZE" bash << 'EOF'
set -euox pipefail

PHY_MTU=$(($MAX_SUPPORTED_FRAME_SIZE + 50))

ip link set mtu $PHY_MTU dev ens192

TOPOLOGY_REAL_PATH=$(realpath "$TOPOLOGY_PATH")
TOPOLOGY_DIR_PATH=$(dirname "$TOPOLOGY_REAL_PATH")
if [[ -f "$TOPOLOGY_DIR_PATH/clab.env" ]]; then
  set -o allexport && source "$TOPOLOGY_DIR_PATH/clab.env" && set +o allexport
fi

export MAX_SUPPORTED_FRAME_SIZE
export CLAB_LABDIR_BASE=/run

timeout --preserve-status 20m clab deploy -t "$TOPOLOGY_PATH" --skip-post-deploy -d --max-workers 8

ALL_NODES_COUNT=$(docker ps -a --format '{{lower .Names}}' --filter 'label=clab-node-kind=ceos' --filter "label=clab-topo-file=$TOPOLOGY_REAL_PATH" | wc -l)
if [[ "$ALL_NODES_COUNT" == "0" ]]; then
  echo -e "Deployment failed, no nodes found after deployment:\n"
  docker ps -a
  exit 1
fi

RUNNING_NODES_COUNT=$(docker ps --format '{{lower .Names}}' --filter 'label=clab-node-kind=ceos' --filter "label=clab-topo-file=$TOPOLOGY_REAL_PATH" --filter 'status=running' | wc -l)
if [[ "$ALL_NODES_COUNT" != "$RUNNING_NODES_COUNT" ]]; then
  echo -e "Deployment failed, not all nodes are running:\n"
  docker ps -a
  exit 1
fi
EOF
