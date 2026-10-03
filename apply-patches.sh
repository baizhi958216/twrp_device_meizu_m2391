#!/bin/bash
set -euo pipefail
TREE=$(cd "$(dirname "$0")" && pwd)
SOURCE=$(cd "$TREE/../../.." && pwd)
cd "$SOURCE/bootable/recovery"
for PATCH in "$TREE"/patches/*.patch; do
    if git apply --reverse --check "$PATCH" 2>/dev/null; then
        echo "Already applied: $(basename "$PATCH")"
    else
        git apply --check "$PATCH"
        git apply "$PATCH"
    fi
done
