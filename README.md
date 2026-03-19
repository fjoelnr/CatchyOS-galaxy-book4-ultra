# CachyOS on Samsung Galaxy Book 4 Ultra (NP960XGL-XG1DE)

Community fixes and workarounds for running CachyOS Linux on the Samsung Galaxy Book 4 Ultra.

> **Inspired by** [fedora-galaxy-book4-ultra](https://github.com/regiscaio/fedora-galaxy-book4-ultra) — but with more working hardware 😄

## Hardware

| Component | Spec |
|---|---|
| CPU | Intel Core Ultra 9 185H (Meteor Lake) |
| GPU | Intel Arc (iGPU) + NVIDIA GeForce RTX 4070 Laptop |
| RAM | 32 GB LPDDR5X |
| Storage | 1 TB NVMe PCIe Gen4 |
| Display | 16" WQXGA+ AMOLED 2880×1800 |
| Audio | Realtek ALC298 + 4× Maxim MAX98390 amps |
| Camera | OmniVision OV02C10 (Intel IPU6 MIPI) |
| Fingerprint | LighTuning ETU905A80-E (`1c7a:05a1`) |
| WiFi | Intel Wi-Fi 6E AX211 |
| Bluetooth | Intel AX211 |

## Status

| Feature | Status | Notes |
|---|---|---|
| Internal speakers | ✅ Working | Requires `linux-cachyos-rc` kernel |
| NVIDIA RTX 4070 | ✅ Working | Open kernel modules |
| Intel Arc iGPU | ✅ Working | Out of the box |
| WiFi | ✅ Working | Out of the box |
| Bluetooth | ✅ Working | Out of the box |
| Fingerprint (sudo) | ✅ Working | Requires patched libfprint |
| Camera | ⏳ Partial | Sensor probes, streaming pending ecosystem |
| Thunderbolt/USB4 | ❓ Untested | |

## Quick Start

### 1. Install the RC kernel (required for speakers)

```bash
sudo pacman -S linux-cachyos-rc linux-cachyos-rc-headers
```

### 2. Remove conflicting DKMS (critical!)

```bash
sudo dkms remove max98390-hda/1.0 --all
sudo pacman -Rns max98390-hda
```

Reboot into `linux-cachyos-rc`.

### 3. Install NVIDIA Open Modules for all kernels

```bash
sudo pacman -S linux-cachyos-rc-nvidia-open linux-cachyos-nvidia-open linux-cachyos-lts-nvidia-open
```

### 4. Fix fingerprint sensor

```bash
# See fingerprint/README.md for full instructions
cd fingerprint && ./build-libfprint-sdcp.sh
```

## Details

- [Audio (Speakers)](audio/README.md)
- [Fingerprint](fingerprint/README.md)
- [Camera](camera/README.md)
- [NVIDIA](nvidia/README.md)
- [Kernel / OV02C10 patch](kernel/README.md)

## Kernel

Tested on `linux-cachyos-rc` **7.0.0-rc3-2-cachyos-rc**.
The speaker fix (PR [thesofproject/linux#5616](https://github.com/thesofproject/linux/pull/5616)) will land in `linux-cachyos` stable once Linux 7.0 is released.

## Contributing

Found something that works? PRs welcome.
Tested on model **NP960XGL-XG1DE** — other Galaxy Book 4 Ultra variants may differ slightly.
