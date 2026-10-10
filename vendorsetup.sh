#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Source before envsetup/lunch: OrangeFox reads FOX_* from the environment.
if [ "${FOX_BUILD_DEVICE:-}" = m2391 ]; then
export FOX_BUILD_TYPE=Unofficial
export OF_MAINTAINER=baizhi958216
export TARGET_DEVICE_ALT=meizu20Pro
export FOX_LOCAL_CALLBACK_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/orangefox-pre-build.sh"

# Virtual A/B with dedicated, kernel-less recovery_a/recovery_b images.
export FOX_AB_DEVICE=1
export FOX_VIRTUAL_AB_DEVICE=1
export OF_AB_DEVICE_WITH_RECOVERY_PARTITION=1
export OF_FORCE_PREBUILT_KERNEL=1
export OF_USE_LZ4_COMPRESSION=1
export OF_DISABLE_MIUI_SPECIFIC_FEATURES=1
export FOX_INSTALLER_DISABLE_AUTOREBOOT=1
export FOX_VANILLA_BUILD=1

# 1440x3200 panel expressed in OrangeFox's 1080-wide theme coordinates.
export OF_SCREEN_H=2400
export OF_STATUS_H=96
export OF_STATUS_INDENT_LEFT=48
export OF_STATUS_INDENT_RIGHT=48
export OF_CLOCK_POS=1
export OF_HIDE_NOTCH=1
export OF_USE_GREEN_LED=0
export OF_ALLOW_DISABLE_NAVBAR=0
export OF_DEFAULT_TIMEZONE='CST-8;CST-8'
export OF_QUICK_BACKUP_LIST='/boot;/init_boot;/vendor_boot;/recovery;/dtbo;/efs1;'

# Keep Fox tools/addons available even before /data can be decrypted.
export FOX_MOVE_MAGISK_INSTALLER_TO_RAMDISK=1
export FOX_USE_UPDATED_MAGISKBOOT=1
export FOX_USE_NANO_EDITOR=1
export FOX_USE_TAR_BINARY=1
export FOX_USE_SED_BINARY=1
export FOX_USE_LZ4_BINARY=1
export FOX_USE_ZSTD_BINARY=1
export FOX_USE_BASH_SHELL=1

# Meizu's SY7808 torch uses /sys/class/meizu/flash/flash_both via the GUI hook.
fi
