#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
set -eu
node=/sys/class/meizu/flash/flash_both
[ "$(getprop m2391.flashlight.status)" = ready ] && [ -w "$node" ] || exit 1
case "${1:-}" in
    on) echo 0 > "$node" ;; # lowest stock continuous-torch duty, both LEDs
    off) echo -1 > "$node" ;; # stop both LEDs and release the flash power
    *) exit 1 ;;
esac
