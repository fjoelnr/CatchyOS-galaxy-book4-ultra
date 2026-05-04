# Kernel

## Recommended Kernel

**`linux-cachyos`** (stable) — tested on `7.0.3-1.1` (2026-05-02)

```bash
sudo pacman -Syu
```

The 7.0 stable kernel includes the speaker fix as a CachyOS downstream patch.
The RC kernel is no longer required for normal use.

The stable kernel is sufficient for:
- Internal speakers (MAX98390 ACPI match — patches from [thesofproject/linux PR #5616](https://github.com/thesofproject/linux/pull/5616), carried as a CachyOS downstream patch; not in mainline Linux 7.0)
- OV02C10 camera sensor detection (with the DKMS patch below)

## OV02C10 Clock Patch

The upstream `ov02c10` driver only accepts a 19.2 MHz master clock. Samsung uses
26 MHz. The patch in `ov02c10-fix/` adds support for 26 MHz.

### Install via DKMS

```bash
sudo cp -r kernel/ov02c10-fix /usr/src/ov02c10-fix-1.0
sudo dkms add ov02c10-fix/1.0
sudo dkms build ov02c10-fix/1.0 --kernelver $(uname -r)
sudo dkms install ov02c10-fix/1.0
```

> **Note:** Unlike `max98390-hda`, this DKMS module is placed in `/updates/dkms/`
> which overrides the in-kernel `ov02c10`. This is intentional — the upstream driver
> does not yet support 26 MHz.

### Manual build (without DKMS)

```bash
cd kernel/ov02c10-fix
make CC=clang LD=ld.lld
sudo cp ov02c10.ko /lib/modules/$(uname -r)/updates/
sudo depmod -a
sudo modprobe -r ov02c10 && sudo modprobe ov02c10
```

### Verify

```bash
dmesg | grep -i ov02c10
# Expected: ov02c10 3-0036: ov02c10_probe: ... successfully
lsmod | grep ov02c10
# (OE) tag is expected here — this is the patched version
```

## Speaker Fix (Audio)

The speaker fix is included in `linux-cachyos` stable since `7.0.3-1.1` (2026-05-02).
See [Audio README](../audio/README.md). The RC kernel is no longer required for audio.

## Patch Details

| Patch | Status | Upstream |
|---|---|---|
| MAX98390 ACPI match (speakers) | ✅ In `linux-cachyos-rc` | [PR #5616](https://github.com/thesofproject/linux/pull/5616) closed; pending linux-sound LKML submission |
| OV02C10 26 MHz clock (camera) | 🔧 DKMS workaround | Not yet submitted |
