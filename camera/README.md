# Camera — OmniVision OV02C10 (Intel IPU6)

## Status: ⏳ Partial — Sensor probes, streaming not yet working

The Galaxy Book 4 Ultra uses an OmniVision OV02C10 sensor connected via MIPI CSI-2 to
the Intel IPU6 (Image Processing Unit). The sensor is detected by the kernel after a
clock patch, but streaming is currently blocked by ecosystem gaps.

## Root Cause

Two separate issues prevent a working camera:

### 1. Clock frequency mismatch

The upstream `ov02c10` kernel driver hardcodes a 19.2 MHz master clock
(`OV02C10_MCLK 19200000`). Samsung's firmware configures 26 MHz. The driver rejects
this and aborts probe with `EINVAL`.

**Fix:** A patched kernel module that also accepts 26 MHz is provided in
`kernel/ov02c10-fix/`. See [Kernel README](../kernel/README.md) for installation.

With the patch the sensor probes successfully and appears in the media topology:

```
ov02c10 3-0036 → Intel IPU6 CSI2 4 → Intel IPU6 CSI2 BE SOC
```

### 2. HAL / V4L2 routing API mismatch (unresolved)

Linux 7.x introduced a new V4L2 routing API for IPU6. The Intel camera HAL
(`ipu6-camera-hal`) and supporting XML sensor configuration files use entity names
from older kernels (e.g. `Intel IPU6 CSI-2 $CSI_PORT`) that no longer match the
kernel 7.x topology (`Intel IPU6 CSI2 4`). This causes:

- `MediaControl init failed` in HAL logs
- `VIDIOC_STREAMON: Broken pipe` when attempting to stream
- `/dev/video*` devices exist but produce no frames

This is a kernel/HAL ecosystem gap. No fix is available yet.

## What Works

- Sensor detected on I2C bus 3 address `0x36`
- ACPI entry `OVTI02C1` matches the driver
- Media topology created by IPU6 (`/dev/media0`)
- `/dev/video0` – `/dev/video7` created

## What Doesn't Work

- Streaming (`VIDIOC_STREAMON` fails)
- Any camera application (GNOME Camera, Firefox, OBS, etc.)

## Tracking

- Intel IPU6 V4L2 routing API transition: upstream kernel work ongoing
- `ipu6-camera-hal` entity name update: pending

## Technical Details

- Sensor: OmniVision OV02C10
- I2C: bus 3, address `0x36`
- ACPI: `OVTI02C1`
- Interface: MIPI CSI-2 → Intel IPU6
- Clock: 26 MHz (Samsung default, patched)
- Media topology: `ov02c10 3-0036` → `Intel IPU6 CSI2 4` → `Intel IPU6 CSI2 BE SOC`
