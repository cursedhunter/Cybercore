#!/bin/bash

# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
eval "$(ssh-agent -s)"

base64 -d < "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -

ssh-add -L

mkdir -p ~/.ssh && chmod 700 ~/.ssh

if [ -f "$CLAB_KNOWN_HOSTS" ]; then
  cp "$CLAB_KNOWN_HOSTS" ~/.ssh/known_hosts && chmod 600 ~/.ssh/known_hosts
fi

if [ -f "$SSH_CONFIG" ]; then
  cp "$SSH_CONFIG" ~/.ssh/config && chmod 600 ~/.ssh/config
fi
