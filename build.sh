#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
set -eo pipefail
TREE=$(cd "$(dirname "$0")" && pwd)
SOURCE=$(cd "$TREE/../../.." && pwd)
cd "$SOURCE"
# The official minimal manifest omits VTS/fuzzer projects.
export ALLOW_MISSING_DEPENDENCIES=true
bash "$TREE/apply-patches.sh"
source build/envsetup.sh
lunch twrp_m2391-eng
mka -j"${JOBS:-8}" recoveryimage
sha256sum out/target/product/m2391/recovery.img
