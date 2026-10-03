# TWRP device tree for MEIZU 20 Pro

TWRP device tree for the MEIZU 20 Pro (`m2391`).

## Device specifications

| Feature | Specification |
| --- | --- |
| Device | MEIZU 20 Pro |
| Codename | `m2391`; stock OTA identifier: `meizu20Pro` |
| SoC | Qualcomm Snapdragon 8 Gen 2 (`kalama`) |
| GPU | Adreno 740 |
| Memory | 8 GB / 12 GB, depending on variant |
| Storage | 128 GB / 256 GB / 512 GB, depending on variant |
| Display | 6.81-inch OLED, 3200 × 1440, 120 Hz |
| Battery | 5000 mAh (typical), 80 W wired / 50 W wireless charging |
| Rear cameras | 50 MP main + 50 MP ultrawide + 50 MP portrait telephoto |
| Front camera | 32 MP |

## Feature status

- [x] Boot  
- [x] ADB  
- [x] FDE  
- [x] CPU temperature  
- [x] Haptic feedback  
- [x] Clock  
- [x] MTP  
- [x] Fastbootd  
- [x] Backup and restore

<p align="center">
<img src="https://openfile.meizu.com/group1/M00/0B/50/Cgbj0GTkEiiACPvqAAdsxsQKM48695.png" width="500" height="590">
</p>


## Building

### 1. Fetch the TWRP sources

Use the official [TWRP minimal manifest](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp/tree/twrp-12.1):

```bash
mkdir twrp
cd twrp
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -j8
```

### 2. Add the device tree

Place the complete device tree at `device/meizu/m2391` inside the source checkout. Confirm that these files exist:

```text
device/meizu/m2391/BoardConfig.mk
device/meizu/m2391/twrp_m2391.mk
device/meizu/m2391/build.sh
```

### 3. Build the recovery image

Run from the TWRP source root:

```bash
JOBS=8 bash device/meizu/m2391/build.sh
```

Output:

```text
out/target/product/m2391/recovery.img
```

## Installation

The bootloader must be unlocked.

Check the current slot:

```bash
fastboot getvar current-slot
```

**Run only the command matching the returned slot:**

| Current slot | Flash command (run from the TWRP source root) |
| --- | --- |
| `a` | `fastboot flash recovery_a out/target/product/m2391/recovery.img` |
| `b` | `fastboot flash recovery_b out/target/product/m2391/recovery.img` |

Then reboot into recovery:

```bash
fastboot reboot recovery
```

## Credits and licensing

- [Team Win Recovery Project](https://github.com/TeamWin/android_bootable_recovery): recovery sources and build interfaces.
- [TWRP minimal manifest](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp): source manifest and build instructions.