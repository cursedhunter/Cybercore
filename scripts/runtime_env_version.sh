#!/usr/bin/env bash

# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
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
