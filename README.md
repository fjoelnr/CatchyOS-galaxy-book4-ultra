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
| Camera | Partial | Sensor probes, streaming still blocked by ecosystem gap |
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
- [Kernel / OV02C10 patch](kernel/README.md)

## Repository Layout

```text
audio/         Speaker/audio fix notes
camera/        Camera status and current blockers
fingerprint/   SDCP/libfprint workaround
kernel/        Kernel notes and OV02C10 patch
nvidia/        NVIDIA installation guidance
docs/          Project overview and operations notes
```

## Known Gaps

- Camera streaming is not solved yet; current state is detection and topology only.
- Thunderbolt/USB4 is not yet documented.
- The repository still needs more polished setup validation and hardware test logs.

## Audience

This repository is useful for:

- owners of the same Samsung laptop model
- Linux users testing CachyOS on recent Intel + NVIDIA hybrid laptops
- contributors who want to upstream or document working fixes

## Current Baseline

- Tested on `linux-cachyos-rc` `7.0.0-rc3-2-cachyos-rc`
- Speaker fix tracks [thesofproject/linux PR #5616](https://github.com/thesofproject/linux/pull/5616)
- Fingerprint workaround uses an SDCP-capable `libfprint` fork

## Contributing

Contributions should prefer evidence over guesses:

- include exact kernel/package versions
- state whether the test was performed on `NP960XGL-XG1DE`
- document expected and actual behavior
- keep distro-specific commands explicit

For repository conventions and agent-oriented structure, see [AGENTS.md](AGENTS.md).
