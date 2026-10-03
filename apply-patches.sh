#!/bin/bash
set -euo pipefail
TREE=$(cd "$(dirname "$0")" && pwd)
SOURCE=$(cd "$TREE/../../.." && pwd)
apply_patch_group() {
    local checkout="$1"
    shift
    (
        cd "$SOURCE/$checkout"
        for patch in "$@"; do
            if git apply --reverse --check "$patch" 2>/dev/null; then
                echo "Already applied ($checkout): $(basename "$patch")"
            else
                git apply --check "$patch"
                git apply "$patch"
            fi
        done
    )
}

apply_patch_group bootable/recovery "$TREE"/patches/*.patch
apply_patch_group system/vold "$TREE"/patches/vold/*.patch
