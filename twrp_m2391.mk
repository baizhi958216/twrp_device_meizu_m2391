# SPDX-License-Identifier: Apache-2.0
DEVICE_PATH := device/meizu/m2391
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, $(DEVICE_PATH)/device.mk)

PRODUCT_DEVICE := m2391
PRODUCT_NAME := twrp_m2391
PRODUCT_BRAND := meizu
PRODUCT_MANUFACTURER := meizu
PRODUCT_MODEL := MEIZU 20 Pro
# Both identifiers occur in this OTA. The actual OTA pre-device is meizu20Pro.
TARGET_OTA_ASSERT_DEVICE := meizu20Pro,m2391
PRODUCT_GMS_CLIENTID_BASE := android-meizu
