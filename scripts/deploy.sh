#!/bin/bash

# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
set -euox pipefail

usage() {
  echo "Usage: $0 <ssh-user> <ssh-host> <topology-path> <max-mtu-between-hosts> <digital-twin-max-mtu> [<interface>, default=ens192]"
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

MAX_MTU_BETWEEN_HOSTS=${4:-}
if [[ -z "$MAX_MTU_BETWEEN_HOSTS" ]]; then
  usage
fi

DIGITAL_TWIN_MAX_MTU=${5:-}
if [[ -z "$DIGITAL_TWIN_MAX_MTU" ]]; then
  usage
fi

INTERFACE=${6:-ens192}

# Needs DIGITAL_TWIN_MAX_MTU + VXLAN_OVERHEAD(50) + ETH_FCS_LEN(4) + VLAN_ETH_HLEN(18)
NEEDS_MTU=$((DIGITAL_TWIN_MAX_MTU + 72))
if [[ "$NEEDS_MTU" -gt "$MAX_MTU_BETWEEN_HOSTS" ]]; then
  echo "ERROR: DIGITAL_TWIN_MAX_MTU($DIGITAL_TWIN_MAX_MTU) plus overhead(72) is greated than MAX_MTU_BETWEEN_HOSTS($MAX_MTU_BETWEEN_HOSTS)"
  exit 1
fi

ssh -T "$SSH_USER@$SSH_HOST" sudo TOPOLOGY_PATH="$TOPOLOGY_PATH" MAX_MTU_BETWEEN_HOSTS="$MAX_MTU_BETWEEN_HOSTS" DIGITAL_TWIN_MAX_MTU="$DIGITAL_TWIN_MAX_MTU" INTERFACE="$INTERFACE" bash << 'EOF'
set -euox pipefail

TOPOLOGY_REAL_PATH=$(realpath "$TOPOLOGY_PATH")
TOPOLOGY_DIR_PATH=$(dirname "$TOPOLOGY_REAL_PATH")
if [[ -f "$TOPOLOGY_DIR_PATH/clab.env" ]]; then
  set -o allexport && source "$TOPOLOGY_DIR_PATH/clab.env" && set +o allexport
fi

ip link set mtu $MAX_MTU_BETWEEN_HOSTS dev $INTERFACE

# DIGITAL_TWIN_MAX_MTU + ETH_FCS_LEN(4) + VLAN_ETH_HLEN(18)
export MAX_SUPPORTED_FRAME_SIZE=$(($DIGITAL_TWIN_MAX_MTU + 22))
export CLAB_LABDIR_BASE=/run

clab deploy -t "$TOPOLOGY_PATH" --skip-post-deploy -d --max-workers 8 --reconfigure

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
