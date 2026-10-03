# SPDX-License-Identifier: Apache-2.0
# Recovery is built on SDK 32, not a new full system/vendor product.
# Keep the physical launch API in runtime properties without requiring absent
# system SDK 33 stubs in the android-12.1 build tree.
PRODUCT_USE_DYNAMIC_PARTITIONS := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

PRODUCT_PACKAGES += \
    update_engine_sideload \
    fastbootd \
    android.hardware.fastboot@1.1-impl-mock \
    android.hardware.boot@1.0 \
    android.hardware.boot@1.1 \
    android.hardware.boot@1.2 \
    android.hardware.keymaster@3.0 \
    android.hardware.keymaster@4.0 \
    android.hardware.keymaster@4.1 \
    android.hardware.gatekeeper@1.0 \
    libion \
    libxml2 \
    liblzma \
    libcrypto \
    libcap

# No fake build modules or missing-dependency suppression. Proprietary HALs and
# their vendor dependencies are installed through the recovery/root overlay.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware=qcom \
    ro.twrp.default_timezone=CST-8 \
    ro.product.device=meizu20Pro \
    ro.product.vendor.device=meizu20Pro \
    ro.vendor.build.security_patch=2023-10-01 \
    ro.vendor.api_level=33 \
    ro.board.platform=kalama \
    ro.adb.secure=0 \
    ro.crypto.volume.filenames_mode=aes-256-cts \
    sys.usb.controller=a600000.dwc3 \
    vendor.usb.use_ffs_mtp=1
