#!/bin/bash

# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
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

if ssh -T "$SSH_USER@$SSH_HOST" hostname; then
  echo "SSH connection successful."
else
  echo "
  Unable to connect to $SSH_HOST via SSH.
  In case of SSH host verification failure, the \$SSH_CONFIG or \$CLAB_KNOWN_HOSTS CI variables can modified to control this behavior.
  "
  exit 1
fi
