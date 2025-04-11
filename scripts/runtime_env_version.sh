#!/usr/bin/env bash

set -euo pipefail

# all files relative to project root
# script working dir should be project root
env -i cat runtime-env/* \
  dist/* \
  pyproject.toml \
  requirements.txt \
  collection-requirements.yml \
  .pre-commit-config.yaml \
  | md5sum | cut -d ' ' -f1
