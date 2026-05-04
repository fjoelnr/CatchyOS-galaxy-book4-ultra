# Audio — Internal Speakers

## Status: ✅ Working (linux-cachyos stable ≥ 7.0)

The Samsung Galaxy Book 4 Ultra uses a Realtek ALC298 HDA codec (SSID `144d:c1d8`) with
4× Maxim MAX98390 speaker amplifiers connected via Intel SSP2.

## Root Cause

The `linux-cachyos` stable kernel (6.x) lacks the ACPI match for this device, causing a
generic SOF machine driver to load with a topology that has no SSP2 pipeline — resulting
in silence.

The fix originates from [thesofproject/linux PR #5616](https://github.com/thesofproject/linux/pull/5616),
which was **closed** (the maintainers determined these patches belong in the mainline kernel,
not the SOF repo, and directed the author to submit to `linux-sound@vger.kernel.org`).
CachyOS carries the patches as a downstream addition in `linux-cachyos-rc`.

The fix is **not in mainline Linux 7.0** (the patches were not submitted upstream in time).
However, CachyOS includes them as a downstream addition in `linux-cachyos` stable since
the 7.0.3-1.1 build (2026-05-02). The RC kernel is no longer required for audio.
Track the CachyOS-side history at
[CachyOS/linux-cachyos #749](https://github.com/CachyOS/linux-cachyos/issues/749).

### Why the DKMS package breaks things

If you previously installed the `max98390-hda` DKMS package as a workaround, it **must be
removed** before the RC kernel fix works. DKMS modules in `/updates/dkms/` take precedence
over native kernel modules, silently overriding the correct implementation.

The symptom: `lsmod | grep max98390` shows `(OE)` (Out-of-tree/External) next to the module name.

## Fix

### Step 1 — Update to linux-cachyos 7.0

The speaker fix is included in `linux-cachyos` stable since `7.0.3-1.1` (2026-05-02).
A plain system update is sufficient:

```bash
sudo pacman -Syu
```

Reboot into `linux-cachyos` (7.0.x). The RC kernel is no longer required.

### Step 2 — Remove DKMS (critical)

```bash
sudo dkms remove max98390-hda/1.0 --all
sudo pacman -Rns max98390-hda  # if installed as a package
```

### Step 3 — Reboot into linux-cachyos-rc

Select the RC kernel in the Limine boot menu.

### Verify

```bash
# Modules should load WITHOUT the (OE) tag
lsmod | grep max98390
# Expected: snd_hda_scodec_max98390    16384  1 snd_hda_scodec_max98390_i2c

# Test audio
speaker-test -t sine -f 440 -c 2
```

## Future

The CachyOS downstream patches are the current fix. The original author of
thesofproject/linux PR #5616 still needs to submit the patches to
`linux-sound@vger.kernel.org` for inclusion in mainline Linux. Until then,
vanilla kernel users remain without speaker support on this device.

## Technical Details

- Machine driver: `snd-soc-skl-hda-dsp` → requires `ALC298_FIXUP_SAMSUNG_MAX98390_4_AMPS` quirk
- Speaker amps: 4× MAX98390 at I2C addresses 0x38/0x39/0x3c/0x3d
- Audio path: ALC298 → Intel SOF DSP → SSP2 → MAX98390
- `serial_multi_instantiate` registers all 4 amps as ACPI devices (`MAX98390:00`–`MAX98390:03`)
