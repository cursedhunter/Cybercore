#!/bin/bash

# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
set -euox pipefail

usage() {
  echo "Usage: $0 <ssh-user> <ssh-host> <clab-hosts-path>"
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

CLAB_HOSTS_PATH=${3:-}
if [[ -z "$CLAB_HOSTS_PATH" ]]; then
  usage
fi

ETC_HOSTS_PATH=${4:-/etc/hosts}

ssh -T "$SSH_USER@$SSH_HOST" sudo CLAB_HOSTS_PATH="$CLAB_HOSTS_PATH" ETC_HOSTS_PATH="$ETC_HOSTS_PATH" bash << 'EOF'
set -euox pipefail

TEMP_FILE=$(mktemp)

awk -F ',' '{print $2, $1}' "$CLAB_HOSTS_PATH" > "$TEMP_FILE"

START_MARKER='### BEGIN CLAB HOST ENTRIES'
END_MARKER='### END CLAB HOST ENTRIES'

START_MARKER_PATTERN="^$START_MARKER\$"
END_MARKER_PATTERN="^$END_MARKER\$"

sed -i "/$START_MARKER_PATTERN/,/$END_MARKER_PATTERN/d" "$ETC_HOSTS_PATH"

{
  echo "$START_MARKER"
  cat "$TEMP_FILE"
  echo "$END_MARKER"
} >> "$ETC_HOSTS_PATH"

EOF
