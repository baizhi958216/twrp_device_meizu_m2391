#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
# Read the running slot's module; never install a module from another firmware.
exec > /tmp/m2391-haptics.log 2>&1
set -eu
base=/tmp/m2391-haptics
mkdir -p "$base/vendor" "$base/vendor_dlkm"
cleanup() {
    umount "$base/vendor" 2>/dev/null || true
    umount "$base/vendor_dlkm" 2>/dev/null || true
}
trap cleanup EXIT
setprop m2391.haptics.status starting
fail() { echo "$*"; setprop m2391.haptics.status unavailable; exit 1; }
# An original module can return success without registering its driver in
# recovery. Do NOT unload it: its exit calls i2c_del_driver unconditionally.
[ ! -d /sys/module/haptic_hv ] || fail "Module already loaded; reboot before retry"
slot=$(getprop ro.boot.slot_suffix)
case "$slot" in _a|_b) ;; *) fail "Invalid slot suffix" ;; esac
n=0
while [ ! -b "/dev/block/mapper/vendor_dlkm$slot" ] || [ ! -b "/dev/block/mapper/vendor$slot" ]; do
    n=$((n + 1))
    [ "$n" -le 60 ] || fail "Logical partitions unavailable"
    sleep 1
done
mount -t erofs -o ro "/dev/block/mapper/vendor_dlkm$slot" "$base/vendor_dlkm" || fail "vendor_dlkm mount failed"
mount -t erofs -o ro "/dev/block/mapper/vendor$slot" "$base/vendor" || fail "vendor mount failed"
src="$base/vendor_dlkm/lib/modules/haptic_hv.ko"
hash=$(sha256sum "$src"); hash=${hash%% *}
case "$hash" in
    39c255a1f5198216f1a8a3b9a0be1033ecbc98994abcce5b1a03b93f2debdee5)
        offset=102272
        expected=45538e54fa9be05e8e4a31a5820514e1e74d8ecb96fa6094d9990f5340459fbe
        ;;
    # Flyme 12.6 update.zip: disassembly verified; hardware test still pending.
    460973591880841f57038e457a81c9a42970890846b78a46c0115374f5e2ac5c)
        offset=102256
        expected=563b7469b854b19a7b179173a3ab1b664a3c4588751b626a3bb6296cb55a4123
        ;;
    *) fail "Unreviewed module SHA-256: $hash" ;;
esac
echo "Current-slot module SHA-256: $hash; branch offset: $offset"
cp "$src" "$base/haptic_hv.ko"
# .init.text + 0x1c: b.eq skip_init -> b normal_init (+0x38).
# Both complete input and output hashes are required; no generic byte scanning.
printf '\016\000\000\024' | dd of="$base/haptic_hv.ko" bs=1 seek="$offset" conv=notrunc 2>/dev/null
actual=$(sha256sum "$base/haptic_hv.ko"); actual=${actual%% *}
[ "$actual" = "$expected" ] || fail "Patched module hash mismatch"
# Kernel request_firmware looks here. Copy only Awinic RAM waveforms into RAM.
mkdir -p /lib/firmware
[ -f "$base/vendor/firmware/aw_170hz.bin" ] || fail "Missing Awinic waveform"
cp "$base/vendor"/firmware/aw_*.bin /lib/firmware/
cleanup
insmod "$base/haptic_hv.ko" || fail "Module load failed (kernel ABI checks retained)"
n=0
while ! grep -q 'ram_num = 20' /sys/class/meizu/motor/ram_num 2>/dev/null; do
    n=$((n + 1))
    [ "$n" -le 20 ] || fail "AW8697 probe/waveform initialization timed out"
    sleep 1
done
# TWRP's device-specific path uses the finite mBack waveform, never enable.
touch /tmp/m2391-haptics-ready
setprop m2391.haptics.status ready
echo "AW8697 ready; stock mBack one-shot waveform enabled"
