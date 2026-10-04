#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
# TWRP invokes this from the recovery process after opening the fastboot page.
# Do not invoke the USB transition from adbd: config=none kills that caller.
exec > /tmp/m2391-fastbootd.log 2>&1
set -eu
setprop m2391.fastbootd.status preparing
fail() { echo "$*"; setprop m2391.fastbootd.status failed; exit 1; }
slot=$(getprop ro.boot.slot_suffix)
case "$slot" in _a|_b) ;; *) fail "Invalid active slot" ;; esac

# Finish recovery-only waveform setup before removing its read-only mappings.
n=0
while [ "$(getprop init.svc.m2391.haptics)" = running ]; do
    n=$((n + 1))
    [ "$n" -le 10 ] || { setprop ctl.stop m2391.haptics; break; }
    sleep 1
done
umount /tmp/m2391-haptics/vendor 2>/dev/null || true
umount /tmp/m2391-haptics/vendor_dlkm 2>/dev/null || true

setprop sys.usb.config none
n=0
while [ "$(getprop sys.usb.state)" != none ]; do
    n=$((n + 1))
    [ "$n" -le 5 ] || fail "USB teardown timed out"
    sleep 1
done
setprop ctl.start health-hal-2-1

# No super metadata, partition contents, COW devices or inactive-slot mappings
# are changed. fastbootd recreates the active logical mappings writable.
for point in /system_root /system /system_ext /product /vendor /odm /vendor_dlkm /system_dlkm; do
    umount "$point" 2>/dev/null || true
done
for name in system system_ext product vendor odm vendor_dlkm system_dlkm; do
    [ -b "/dev/block/mapper/$name$slot" ] || continue
    /system/bin/lptools unmap "$name$slot" || fail "Busy mapping: $name$slot"
done
setprop m2391.fastbootd.status ready
setprop sys.usb.config fastboot
echo "Health started; active mappings released; fastboot USB requested"
