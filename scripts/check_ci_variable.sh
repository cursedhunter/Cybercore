#!/bin/bash

set -eo pipefail

usage() {
  echo "Usage: $0 <env_var_name> <error_msg>"
  exit 1
}

VAR_NAME=${1:-}
if [[ -z "$VAR_NAME" ]]; then
  usage
fi

ERROR_MSG=${2:-}
if [[ -z "$ERROR_MSG" ]]; then
  usage
fi

if [ -z "${!VAR_NAME+x}" ]; then
  echo $ERROR_MSG
  exit 1
else
  echo "Environment variable '$VAR_NAME' is defined with value: ${!VAR_NAME}"
  exit 0
fi
