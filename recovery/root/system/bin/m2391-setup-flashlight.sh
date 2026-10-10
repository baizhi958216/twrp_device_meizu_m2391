#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
# Enable the stock camera module that contains the physical SY7808 driver.
# The original module and all on-disk firmware remain unchanged.
exec > /tmp/m2391-flashlight.log 2>&1
set -eu
base=/tmp/m2391-flashlight
mkdir -p "$base/vendor_dlkm"
cleanup() { umount "$base/vendor_dlkm" 2>/dev/null || true; }
trap cleanup EXIT
setprop m2391.flashlight.status starting
fail() { echo "$*"; setprop m2391.flashlight.status unavailable; exit 1; }
[ ! -d /sys/module/camera ] || fail 'Camera module already loaded; reboot before retry'
slot=$(getprop ro.boot.slot_suffix)
case "$slot" in _a|_b) ;; *) fail 'Invalid slot suffix' ;; esac
n=0
while [ ! -b "/dev/block/mapper/vendor_dlkm$slot" ] && [ ! -b /dev/block/mapper/vendor_dlkm ]; do
    n=$((n + 1)); [ "$n" -le 60 ] || fail 'Logical partition unavailable'
    sleep 1
done
block="/dev/block/mapper/vendor_dlkm$slot"
[ -b "$block" ] || block=/dev/block/mapper/vendor_dlkm
mount -t erofs -o ro "$block" "$base/vendor_dlkm" || fail 'vendor_dlkm mount failed'
src="$base/vendor_dlkm/lib/modules/camera.ko"
hash=$(sha256sum "$src"); hash=${hash%% *}
[ "$hash" = 49cabc5930df4c479a47c7b817c2523c2805b41fd6300353f6fbce46cd3d5147 ] || fail "Unreviewed camera module SHA-256: $hash"
cp "$src" "$base/camera.ko"
# Replace only the two reviewed recovery-mode early-return branches with NOPs.
# Preserve the original init/exit, relocations and kernel ABI/signature checks.
printf '\037\040\003\325' | dd of="$base/camera.ko" bs=1 seek=2825644 conv=notrunc 2>/dev/null
printf '\037\040\003\325' | dd of="$base/camera.ko" bs=1 seek=2825656 conv=notrunc 2>/dev/null
hash=$(sha256sum "$base/camera.ko"); hash=${hash%% *}
[ "$hash" = f9c48a00f03cbbf8ec60d4e8b42a2bde0936b8fe68b2c492f7fe79fe6e48fb30 ] || fail 'Patched module hash mismatch'
cleanup
insmod "$base/camera.ko" || fail 'Camera module load failed'
n=0
while [ ! -e /sys/class/meizu/flash/flash_both ]; do
    n=$((n + 1)); [ "$n" -le 20 ] || fail 'SY7808 probe timed out'
    sleep 1
done
# Start with both physical LEDs off.
echo -1 > /sys/class/meizu/flash/flash_both
setprop m2391.flashlight.status ready
echo 'SY7808 flashlight control ready'
