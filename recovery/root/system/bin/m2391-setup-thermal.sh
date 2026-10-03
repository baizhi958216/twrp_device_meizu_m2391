#!/system/bin/sh
# Only expose a live CPU sensor to the TWRP status bar; never alter trip points.
# Node numbering can change with the running vendor_boot/kernel.
for wanted in cpuss-0 cpuss-1 cpuss-2 cpuss-3 cpu-0-0 cpu-1-0; do
    for zone in /sys/class/thermal/thermal_zone*; do
        read -r sensor < "$zone/type" || continue
        [ "$sensor" = "$wanted" ] || continue
        value=$(cat "$zone/temp" 2>/dev/null) || continue
        case "$value" in ''|*[!0-9]*) continue ;; esac
        [ "$value" -gt 0 ] && [ "$value" -lt 150000 ] || continue
        ln -sf "$zone/temp" /tmp/m2391-cpu-temp || exit 1
        echo "m2391: CPU temperature sensor $sensor at $zone/temp" > /dev/kmsg
        exit 0
    done
done
# No symlink means TWRP hides the CPU temperature instead of displaying zero.
echo 'm2391: no readable CPU temperature sensor found' > /dev/kmsg
exit 1
