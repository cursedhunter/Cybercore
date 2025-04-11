#!/bin/bash

set -euox pipefail

usage() {
  echo "Usage: $0 <ssh-user> <ssh-host> <ci-token-job> <ci-registry> <ci-registry-user>"
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

CI_JOB_TOKEN=${3:-}
if [[ -z "$CI_JOB_TOKEN" ]]; then
  usage
fi

CI_REGISTRY=${4:-}
if [[ -z "$CI_REGISTRY" ]]; then
  usage
fi

CI_REGISTRY_USER=${5:-}
if [[ -z "$CI_REGISTRY_USER" ]]; then
  usage
fi

ssh -T "$SSH_USER@$SSH_HOST" CI_JOB_TOKEN="$CI_JOB_TOKEN" CI_REGISTRY="$CI_REGISTRY" CI_REGISTRY_USER="$CI_REGISTRY_USER" bash << 'EOF'
echo "$CI_JOB_TOKEN" | docker login "$CI_REGISTRY" -u "$CI_REGISTRY_USER" --password-stdin
EOF
