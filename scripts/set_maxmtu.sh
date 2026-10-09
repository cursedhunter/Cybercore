#!/bin/bash

# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
set -euox pipefail

usage() {
  echo "Usage: $0 <ssh-user> <ssh-host> <interface>"
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

INTERFACE=${3:-}
if [[ -z "$INTERFACE" ]]; then
  usage
fi

ssh -T "$SSH_USER@$SSH_HOST" sudo bash -s -- "$INTERFACE" << 'EOF'
set -euox pipefail

INTERFACE=${1:-}

MAX_MTU=$(ip -d link show dev $INTERFACE | egrep -o "maxmtu[[:space:]]+[0-9]+" | cut -d " " -f2)

ip link set mtu $MAX_MTU dev $INTERFACE

echo $MAX_MTU
EOF
