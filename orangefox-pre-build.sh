#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

# init_boot is unpacked after recovery on this device. Newer ROMs inject their
# bionic libraries into /system/lib64, but recovery still uses its own linker.
# Keep a matched recovery runtime in a directory absent from the generic ramdisk.
if [ "${2:-}" != --first-call ]; then
    exit 0
fi
RAMDISK=${1:?OrangeFox must pass the recovery ramdisk directory}
DEST="$RAMDISK/system/lib64/recovery-bionic"
mkdir -p "$DEST"
for library in libc.so libdl.so libm.so ld-android.so; do
    test -s "$RAMDISK/system/lib64/$library"
    cp -p "$RAMDISK/system/lib64/$library" "$DEST/$library"
done
echo 'Preserved the recovery bionic runtime against init_boot overlays.'

# Use OrangeFox's AMOLED Black style as the fallback before /data is unlocked.
# A user's saved custom theme still takes precedence through the normal loader.
test -s "$RAMDISK/twres/themes/styles/Black.xml"
cp -p "$RAMDISK/twres/themes/styles/Black.xml" "$RAMDISK/twres/themes/style.xml"
echo 'Selected the built-in Black theme as the default.'
