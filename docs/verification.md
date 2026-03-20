# Verification

## Goal

Provide a short, reproducible verification routine after kernel, package, or workaround changes on the Samsung Galaxy Book 4 Ultra (`NP960XGL-XG1DE`).

Run the checks component by component instead of guessing from partial symptoms.

## Baseline Context

Before verifying individual components, record the current system state:

```bash
uname -r
pacman -Q | grep -E 'linux-cachyos|nvidia|libfprint|fprintd|pipewire'
```

## Audio

Expected state: internal speakers work on `linux-cachyos-rc` without the `max98390-hda` DKMS module.

```bash
lsmod | grep max98390
speaker-test -t sine -f 440 -c 2
```

Interpretation:

- good: `snd_hda_scodec_max98390` loads without `(OE)` and speaker test is audible
- bad: module shows `(OE)` or speaker output is still silent

## NVIDIA

Expected state: the RTX 4070 works with prebuilt open kernel modules, not DKMS.

```bash
nvidia-smi
prime-run glxinfo | grep 'OpenGL renderer'
```

Interpretation:

- good: `nvidia-smi` shows the laptop GPU and the offloaded renderer is NVIDIA
- bad: `nvidia-smi` fails or PRIME offload still uses the iGPU

## Fingerprint

Expected state: `libfprint-egismoc-sdcp` is installed and enrolled fingerprints survive reboot.

```bash
pkg-config --modversion libfprint-2
fprintd-list "$USER"
fprintd-verify
```

Interpretation:

- good: `libfprint` reports the SDCP-capable version and verification succeeds
- bad: enrollment disappears after reboot or `fprintd-verify` cannot match

## Camera

Expected state: sensor detection works, streaming still does not.

```bash
dmesg | grep -i ov02c10
media-ctl -p -d /dev/media0
v4l2-ctl --list-devices
```

Interpretation:

- good: the sensor probes and the IPU6 media topology is present
- expected current limitation: streaming still fails because the HAL/routing gap is unresolved
- bad: the sensor no longer probes at all after a kernel change

## Wi-Fi and Bluetooth

Expected state: both work out of the box.

```bash
nmcli device status
bluetoothctl show
```

Interpretation:

- good: Wi-Fi is managed and Bluetooth controller is powered
- bad: device missing or soft-blocked after kernel/package changes

## When to Update the Repo

Update the repository when one of these changes:

1. support state changes from working to broken or vice versa
2. kernel/package requirements change
3. verification output changes materially
4. an upstream workaround becomes obsolete
