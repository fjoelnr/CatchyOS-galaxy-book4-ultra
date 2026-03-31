# Camera — OmniVision OV02C10 (Intel IPU6)

## Status: ✅ Working (libcamera SimplePipeline)

The Galaxy Book 4 Ultra uses an OmniVision OV02C10 sensor connected via MIPI CSI-2 to
the Intel IPU6. After three patches and using the `simple` libcamera pipeline, the
camera streams correctly including proper AE/AGC exposure control.

## Required Components

| Component | Purpose | Source |
|---|---|---|
| `ov02c10` DKMS patch | 26 MHz clock support | `kernel/ov02c10-fix/` + [Andycodeman's installer](https://github.com/Andycodeman/samsung-galaxy-book4-linux-fixes) |
| `ipu-bridge-fix` DKMS | Samsung 960XGL rotation quirk (180°) | [Andycodeman's installer](https://github.com/Andycodeman/samsung-galaxy-book4-linux-fixes) |
| libcamera (from source) | OV02C10 `CameraSensorHelper` (missing in Arch package) | See below |

## Installation

### Step 1 — Kernel patches (DKMS)

Install via Andycodeman's all-in-one installer:

```bash
git clone https://github.com/Andycodeman/samsung-galaxy-book4-linux-fixes.git
bash ~/samsung-galaxy-book4-linux-fixes/webcam-fix-libcamera/install.sh
```

The installer handles `ov02c10-26mhz-fix` and `ipu-bridge-fix` DKMS modules and
configures CPU debayer (required because the NVIDIA RTX 4070 breaks GPU debayer on
the simple pipeline).

### Step 2 — Build libcamera from source

The Arch package is currently `libcamera 0.7.0-1`, which still has two issues that cause a dark image:

1. Missing `CameraSensorHelperOv02c10` — the IPA cannot map gain register values to
   linear gain, so AE/AGC applies wrong gain → black or very dark image.
2. `kExposureOptimal = 2.5/5` — the default AGC brightness target is tuned for
   outdoor photography (avoid blown highlights). For a laptop webcam it's too dark.
   The build script raises this to `4.0/5` for a natural indoor brightness.

A build script is provided in the `webcam-fix-libcamera` subdirectory of the
`samsung-galaxy-book4-linux-fixes` repo:

```bash
bash ~/samsung-galaxy-book4-linux-fixes/webcam-fix-libcamera/build-libcamera-arch.sh
```

This builds libcamera `v0.7.0` from source with the sensor helper patch applied and
installs it to `/usr` (replacing the Arch system package). Build time: ~5 minutes.

> **Important**: The build must target `prefix=/usr` (not `/usr/local`). Both installs
> have SONAME `libcamera.so.0.7`, but `ldconfig` always prefers `/usr/lib` over
> `/usr/local/lib`. Installing to `/usr/local` causes the system IPA module (without
> the OV02C10 helper) to still be loaded, producing a dark image.

After the build, install the pacman hook so you get a reminder if `libcamera` is
updated by a system upgrade:

```bash
sudo cp ~/samsung-galaxy-book4-linux-fixes/webcam-fix-libcamera/libcamera-ov02c10-rebuild.hook \
    /etc/pacman.d/hooks/libcamera-ov02c10-rebuild.hook
```

After building, restart PipeWire:

```bash
systemctl --user restart pipewire wireplumber
```

### Step 3 — Verify

```bash
# List cameras
cam --list
# → Available cameras: 1: Internal front camera (_SB_.PC00.LNK0...)

# Capture test frames
cam -c 1 --capture=5 --file=/tmp/test#.ppm

# GStreamer test
gst-launch-1.0 libcamerasrc ! videoconvert ! autovideosink
```

Camera apps (GNOME Camera, Cheese, OBS, Firefox, etc.) should work normally via PipeWire.

## How It Works

```
OV02C10 sensor (I2C 3-0036, 26 MHz)
    │
    └─► Intel IPU6 CSI2 port 4
            │
            └─► libcamera SimplePipeline
                    │  (CPU debayer, NVIDIA workaround)
                    └─► PipeWire / libcamera-apps
```

The `simple` pipeline is used instead of the `ipu6` pipeline because the IPU6
hardware pipeline requires the Intel camera HAL (`ipu6-camera-hal`), which uses
entity names from older kernels that no longer match the kernel 7.x V4L2 routing API.

## Root Causes and Fixes

### Clock frequency mismatch (26 MHz)

Upstream `ov02c10` driver hardcodes 19.2 MHz. Samsung's firmware uses 26 MHz.
Fixed by the `ov02c10-fix` DKMS module in `kernel/ov02c10-fix/`.

### Image rotation (upside-down without fix)

Samsung 960XGL is not in the upstream `ipu-bridge` DMI quirk table, so the sensor
reports `rotation=0` instead of `rotation=180`. Fixed by the `ipu-bridge-fix` DKMS
module from Andycodeman's repo.

### Missing OV02C10 sensor helper (dark image)

`CameraSensorHelperOv02c10` is not present in libcamera `v0.7.0` (the current upstream
release and the current Arch package). Without it,
the IPA cannot compute the correct analogue gain mapping for AE/AGC, producing a very
dark or black image. Fixed by building libcamera from source with the helper class
added to `src/ipa/libipa/camera_sensor_helper.cpp`:

```cpp
class CameraSensorHelperOv02c10 : public CameraSensorHelper
{
public:
    CameraSensorHelperOv02c10()
    {
        gain_ = AnalogueGainLinear{ 1, 0, 0, 16 };
    }
};
REGISTER_CAMERA_SENSOR_HELPER("ov02c10", CameraSensorHelperOv02c10)
```

### AGC brightness target too low (dark image even with sensor helper)

libcamera's soft IPA AGC uses `kExposureOptimal = kExposureBinsCount / 2.0 = 2.5`
(middle of 5 histogram bins). This targets ~50th percentile brightness, which is
correct for outdoor photography but produces a noticeably dark webcam image.

Fixed in the build script by patching `src/ipa/simple/algorithms/agc.cpp`:

```cpp
// Default:
static constexpr float kExposureOptimal = kExposureBinsCount / 2.0; // = 2.5

// Patched (webcam brightness):
static constexpr float kExposureOptimal = 4.0;
```

### NVIDIA GPU debayer conflict

The RTX 4070 causes EGL issues with the simple pipeline's GPU debayer. The installer
auto-detects this and forces CPU debayer via `LIBCAMERA_IPA_SIMPLE_TUNING` environment
configuration.

## Maintenance

After a system `libcamera` package update, pacman will overwrite the patched build.
The hook installed above will warn you when this happens. Re-run to restore:

```bash
bash ~/samsung-galaxy-book4-linux-fixes/webcam-fix-libcamera/build-libcamera-arch.sh
systemctl --user restart pipewire wireplumber
```

This is the same maintenance pattern as the fingerprint fix — see
`fingerprint/libfprint-sdcp-rebuild.hook`.

## Technical Details

- Sensor: OmniVision OV02C10
- I2C: bus 3, address `0x36`
- ACPI: `OVTI02C1`
- Interface: MIPI CSI-2 → Intel IPU6 CSI2 port 4
- Master clock: 26 MHz (Samsung, patched)
- Pipeline: libcamera `simple` (not `ipu6`)
- Kernel: `linux-cachyos-rc` ≥ 7.0.0-rc5 (tested on rc5; rc6 released upstream 2026-03-29)
