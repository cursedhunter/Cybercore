#!/bin/bash

set -euo pipefail

exec 2>&1

usage() {
  echo "Usage: $0 <anta-inventory-path> <test-catalogs-path> <node-name> [<nrfu-reports-path>]"
  exit 1
}

ANTA_INVENTORY_PATH=${1:-}
TEST_CATALOGS_PATH=${2:-}
NODE_NAME=${3:-}
NRFU_REPORT_PATH=${4:-nrfu_reports}

if [[ -z "$ANTA_INVENTORY_PATH" ]]; then
  usage
fi

if [[ -z "$TEST_CATALOGS_PATH" ]]; then
  usage
fi

if [[ -z "$NODE_NAME" ]]; then
  usage
fi

anta nrfu --enable -d "$NODE_NAME" \
  -i "$ANTA_INVENTORY_PATH" -c "$TEST_CATALOGS_PATH/$NODE_NAME-catalog.yml" \
  json -o "$NRFU_REPORT_PATH/$NODE_NAME.json"
