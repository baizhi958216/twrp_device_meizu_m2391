#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
set -eo pipefail
TREE=$(cd "$(dirname "$0")" && pwd)
SOURCE=$(cd "$TREE/../../.." && pwd)
cd "$SOURCE"
if [ ! -f bootable/recovery/orangefox.mk ] || [ ! -f vendor/recovery/OrangeFox_A12.sh ]; then
    echo 'Use OrangeFox fox_12.1 sources synced with the official sync script.' >&2
    exit 1
fi
export FOX_BUILD_DEVICE=m2391
source "$TREE/vendorsetup.sh"
export LC_ALL=C
# The official minimal manifest omits VTS/fuzzer projects.
export ALLOW_MISSING_DEPENDENCIES=true
bash "$TREE/apply-patches.sh"
source build/envsetup.sh
lunch twrp_m2391-eng
mka -j"${JOBS:-8}" adbd recoveryimage
sha256sum "${OUT_DIR:-out}/target/product/m2391/recovery.img"
sha256sum "${OUT_DIR:-out}"/target/product/m2391/OrangeFox-*.zip
