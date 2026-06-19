#!/usr/bin/env bash
set -euo pipefail

CACHE="$(dfx cache show)"
mops sources | grep -v -- '--package core' || true
echo "--package core ${CACHE}/core"
