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

Expected state: sensor detection and basic streaming work with the patched `libcamera` `simple` pipeline.

```bash
dmesg | grep -i ov02c10
media-ctl -p -d /dev/media0
v4l2-ctl --list-devices
cam --list
```

Interpretation:

- good: the sensor probes, the IPU6 media topology is present, and `cam --list` shows the internal camera
- better: a short `cam -c 1 --capture=1 --file=/tmp/gb4u-test.ppm` capture succeeds
- bad: the sensor no longer probes at all after a kernel change

## Platform Features

Expected state: the `samsung-galaxybook` driver exposes backlight, profiles, and firmware attributes.

```bash
ls /sys/class/leds/samsung-galaxybook::kbd_backlight
cat /sys/firmware/acpi/platform_profile
find /sys/class/firmware-attributes/samsung-galaxybook/attributes -maxdepth 2 -type f
```

Interpretation:

- good: the LED path exists, `platform_profile` reads successfully, and firmware attributes are populated
- bad: the platform driver no longer binds or the sysfs paths disappear after a kernel change

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
