# SPDX-License-Identifier: Apache-2.0
# Based on the supplied stock firmware.
DEVICE_PATH := device/meizu/m2391

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_VARIANT := generic
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_BOARD_PLATFORM := kalama
TARGET_BOOTLOADER_BOARD_NAME := kalama
TARGET_NO_BOOTLOADER := true

# Stock recovery is a standalone, kernel-less Android boot image v4.
# The real stock kernel is supplied to satisfy build-system prerequisites;
# BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE keeps it OUT of recovery.img.
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
TARGET_FORCE_PREBUILT_KERNEL := true
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_KERNEL_PAGESIZE := 4096
BOARD_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS += --header_version 4
BOARD_RECOVERY_MKBOOTIMG_ARGS := --header_version 4 --os_version 13.0.0 --os_patch_level 2023-10
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
BOARD_USES_RECOVERY_AS_BOOT := false
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := false
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := false
BOARD_RAMDISK_USE_LZ4 := true
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600

# Dedicated recovery: do not build/repack boot, init_boot or vendor_boot.
BOARD_BUILD_SYSTEM_ROOT_IMAGE := false
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_USES_METADATA_PARTITION := true
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
TARGET_COPY_OUT_VENDOR := vendor

# An unsigned AVB hash footer preserves the image layout on an unlocked device.
# No stock signing key, vbmeta replacement, or anti-rollback bypass is implied.
BOARD_AVB_ENABLE := true
BOARD_AVB_RECOVERY_ADD_HASH_FOOTER_ARGS += --rollback_index 1

# System properties must match this OTA for KeyMint version checks.
# These do not change the TWRP source SDK or the stock recovery boot header.
PLATFORM_VERSION := 16.0.0
PLATFORM_VERSION_LAST_STABLE := 16
PLATFORM_SECURITY_PATCH := 2025-12-05

# Values from vendor/recovery, not the Android 16 system version.
# Do not emit full-system GRF board API properties into an SDK-32 recovery.
# Physical launch API 33 is recorded in vendor.prop.
VENDOR_SECURITY_PATCH := 2023-10-01
BOOT_SECURITY_PATCH := 2023-10-01

AB_OTA_UPDATER := true
# This is a recovery product, not a ROM OTA generator. List from payload manifest.
include $(DEVICE_PATH)/ota-partitions.mk

# FBEv2 + metadata encryption; actual CE unlock on Flyme 12.6 is unverified.
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_USE_FSCRYPT_POLICY := 2
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true

# First-stage init uses stock vendor_boot/modules.load.recovery. Retry the UI
# drivers from the SAME running vendor_boot before starting the TWRP GUI.
TW_LOAD_VENDOR_MODULES := "msm_drm.ko goodix_ts.ko mz_gesture_ts.ko qti_battery_charger.ko"
TW_LOAD_VENDOR_BOOT_MODULES := true

TW_THEME := portrait_hdpi
TW_DEFAULT_LANGUAGE := zh_CN
TW_EXTRA_LANGUAGES := true
# Qualcomm RTC is a counter plus the current phone's ats_2 offset.
TARGET_RECOVERY_QCOM_RTC_FIX := true
TW_CUSTOM_CLOCK_POS := "right"
TW_CUSTOM_BATTERY_POS := "center"
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
# Leave TW_MAX_BRIGHTNESS unset: TWRP reads the panel's max_brightness.
TW_DEFAULT_BRIGHTNESS := 2784
# Resolved by sensor type before the GUI starts; thermal_zone0 is PA, not CPU.
TW_CUSTOM_CPU_TEMP_PATH := "/tmp/m2391-cpu-temp"
TW_FRAMERATE := 60
# AW8697 uses the reviewed stock module and finite mBack waveform.
# Apply patches/0001-m2391-haptics.patch before building (apply-patches.sh).
TW_DEVICE_VERSION := m2391
RECOVERY_SDCARD_ON_DATA := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_INCLUDE_FASTBOOTD := true
TW_INCLUDE_LPTOOLS := true
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true

# Ensure the explicitly requested HAL interfaces enter the recovery ramdisk.
TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.keymaster@3.0.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.keymaster@4.0.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.keymaster@4.1.so
