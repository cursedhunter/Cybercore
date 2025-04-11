#!/bin/bash

set -euo pipefail

umask 002

source /opt/avd-venv/bin/activate

exec "$@"
