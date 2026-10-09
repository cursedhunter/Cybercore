#!/bin/bash

# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
set -euo pipefail

usage() {
  echo "Usage: $0 <ssh-user> <ssh-host> <archive-path> <remote-path>"
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

ARCHIVE_PATH=${3:-}
if [[ -z "$ARCHIVE_PATH" ]]; then
  usage
fi

REMOTE_PATH=${4:-}
if [[ -z "$REMOTE_PATH" ]]; then
  usage
fi

ssh -T "$SSH_USER@$SSH_HOST" tar -xzf - --transform="s,^,$REMOTE_PATH/," < "$ARCHIVE_PATH"
