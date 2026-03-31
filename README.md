# CachyOS on Samsung Galaxy Book 4 Ultra (NP960XGL-XG1DE)

Practical hardware fixes and field notes for running CachyOS Linux on the Samsung Galaxy Book 4 Ultra.

This repository focuses on one concrete machine variant: `NP960XGL-XG1DE`. It documents what already works, what still needs work, and which patches or workarounds are currently required.

> Inspired by [fedora-galaxy-book4-ultra](https://github.com/regiscaio/fedora-galaxy-book4-ultra), but tailored to CachyOS and this exact hardware target.

## Scope

- Audio and speaker bring-up
- Fingerprint sensor support
- NVIDIA setup and known pitfalls
- Camera/kernel patching status
- Reproducible setup notes for this laptop model

Out of scope:

- Generic Linux laptop tuning unrelated to this device
- Unsupported distro-specific variants beyond CachyOS
- Claims for untested Galaxy Book 4 Ultra SKUs

## Hardware

| Component | Spec |
| --- | --- |
| CPU | Intel Core Ultra 9 185H (Meteor Lake) |
| GPU | Intel Arc (iGPU) + NVIDIA GeForce RTX 4070 Laptop |
| RAM | 32 GB LPDDR5X |
| Storage | 1 TB NVMe PCIe Gen4 |
| Display | 16" WQXGA+ AMOLED 2880x1800 |
| Audio | Realtek ALC298 + 4x Maxim MAX98390 amps |
| Camera | OmniVision OV02C10 (Intel IPU6 MIPI) |
| Fingerprint | LighTuning ETU905A80-E (`1c7a:05a1`) |
| WiFi | Intel Wi-Fi 6E AX211 |
| Bluetooth | Intel AX211 |

## Status

| Feature | Status | Notes |
| --- | --- | --- |
| Internal speakers | Working | Requires `linux-cachyos-rc` kernel |
| NVIDIA RTX 4070 | Working | Use open kernel modules, no DKMS |
| Intel Arc iGPU | Working | Out of the box |
| WiFi | Working | Out of the box |
| Bluetooth | Working | Out of the box |
| Fingerprint (sudo) | Working | Requires patched `libfprint` |
| Camera | Working | Requires DKMS patches + libcamera built from source |
| Platform features | Working | `samsung-galaxybook` exposes backlight, profiles, battery threshold, firmware attributes |
| Thunderbolt/USB4 | Untested | No verified notes yet |

## Quick Start

### 1. Install the RC kernel

```bash
sudo pacman -S linux-cachyos-rc linux-cachyos-rc-headers
```

### 2. Remove conflicting speaker DKMS if present

```bash
sudo dkms remove max98390-hda/1.0 --all
sudo pacman -Rns max98390-hda
```

Reboot into `linux-cachyos-rc`.

### 3. Install NVIDIA open kernel modules

```bash
sudo pacman -S \
  linux-cachyos-rc-nvidia-open \
  linux-cachyos-nvidia-open \
  linux-cachyos-lts-nvidia-open
```

### 4. Build the fingerprint fix

```bash
./fingerprint/build-libfprint-sdcp.sh
```

### 5. Review the component docs

- [Audio](audio/README.md)
- [Fingerprint](fingerprint/README.md)
- [Camera](camera/README.md)
- [NVIDIA](nvidia/README.md)
- [Platform features](platform/README.md)
- [Kernel / OV02C10 patch](kernel/README.md)
- [Current repo status](docs/STATUS.md)

## Verification

Use [docs/verification.md](docs/verification.md) after kernel, driver, or package changes to quickly retest the machine baseline.

## Repository Layout

```text
audio/         Speaker/audio fix notes
camera/        Camera status and current blockers
fingerprint/   SDCP/libfprint workaround
kernel/        Kernel notes and OV02C10 patch
nvidia/        NVIDIA installation guidance
platform/      samsung-galaxybook platform-driver features
docs/          Project overview and operations notes
```

## Known Gaps

- Camera works via `simple` pipeline; the IPU6 hardware pipeline (`ipu6`) remains unsupported due to V4L2 routing API incompatibilities.
- `CameraSensorHelperOv02c10` is not yet in upstream libcamera — manual source build required after any `libcamera` system update.
- Speaker fix not yet in mainline kernel; thesofproject/linux PR #5616 was closed (out of SOF scope) and patches need upstream submission via linux-sound@vger.kernel.org.
- Thunderbolt/USB4 is not yet documented.
- Suspend/resume and long-term stability notes are still thin.
- The repository still needs more polished hardware test logs across kernel upgrades.

## Audience

This repository is useful for:

- owners of the same Samsung laptop model
- Linux users testing CachyOS on recent Intel + NVIDIA hybrid laptops
- contributors who want to upstream or document working fixes

## Current Baseline

- Tested on `linux-cachyos-rc` `7.0.0-rc5-2-cachyos-rc` (rc6 released upstream 2026-03-29)
- CachyOS stable kernel: `linux-cachyos` 6.19.7-1
- Speaker fix: patches from [thesofproject/linux PR #5616](https://github.com/thesofproject/linux/pull/5616) carried as CachyOS downstream patch; **Linux 7.0 stable expected mid-April 2026**, after which `linux-cachyos` stable will include the fix
- Camera: working via DKMS patches + libcamera `v0.7.0` built from source; `CameraSensorHelperOv02c10` still absent from upstream libcamera
- Fingerprint workaround uses an SDCP-capable `libfprint` fork ([MR #146](https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/146) still unmerged upstream)
- Platform controls work through the upstream `samsung-galaxybook` kernel driver

## Contributing

Contributions should prefer evidence over guesses:

- include exact kernel/package versions
- state whether the test was performed on `NP960XGL-XG1DE`
- document expected and actual behavior
- keep distro-specific commands explicit

For repository conventions and agent-oriented structure, see [AGENTS.md](AGENTS.md).
