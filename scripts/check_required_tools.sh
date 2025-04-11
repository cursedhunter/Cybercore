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

required_tools=("docker" "clab")
missing_tools=0

for tool in "${required_tools[@]}"; do
  ssh -T "$SSH_USER@$SSH_HOST" command -v $tool
  if [ $? -ne 0 ]; then
    echo "Error: Tool '$tool' is not installed on $SSH_HOST."
    missing_tools=1
  else
    echo "Tool '$tool' is installed on $SSH_HOST."
  fi
done

if [ $missing_tools -eq 1 ]; then
  echo "This host is missing required some required tools, failing pipeline."
  exit 1
fi

echo "All specified tools are installed."
