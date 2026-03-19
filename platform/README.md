# Platform Features — samsung-galaxybook

## Status: ✅ Fully Working

The `samsung-galaxybook` kernel driver binds to the ACPI device `SAM0430:00` and exposes
keyboard backlight, performance profiles, battery charge threshold, and firmware attributes.

## Features Overview

| Feature | Status | Path |
|---|---|---|
| Keyboard backlight | ✅ Working | `/sys/class/leds/samsung-galaxybook::kbd_backlight/` |
| Performance profiles | ✅ Working | `/sys/firmware/acpi/platform_profile` |
| Battery charge threshold | ✅ Working | `/sys/class/power_supply/BAT1/charge_control_end_threshold` |
| Block recording (camera/mic privacy) | ✅ Working | `/sys/class/firmware-attributes/samsung-galaxybook/attributes/block_recording/` |
| Power on lid open | ✅ Working | `/sys/class/firmware-attributes/samsung-galaxybook/attributes/power_on_lid_open/` |
| USB charging (off state) | ✅ Working | `/sys/class/firmware-attributes/samsung-galaxybook/attributes/usb_charging/` |

## Keyboard Backlight

4 levels: 0 (off) — 1 — 2 — 3 (maximum).

```bash
# Read current brightness
cat /sys/class/leds/samsung-galaxybook::kbd_backlight/brightness

# Set brightness (0–3)
echo 2 | sudo tee /sys/class/leds/samsung-galaxybook::kbd_backlight/brightness
```

The Fn+F9 key controls backlight brightness directly via the driver.

## Performance Profiles

Three profiles available: `quiet`, `balanced`, `performance`.

```bash
# Read current profile
cat /sys/firmware/acpi/platform_profile

# Switch profile
echo performance | sudo tee /sys/firmware/acpi/platform_profile
echo quiet       | sudo tee /sys/firmware/acpi/platform_profile
echo balanced    | sudo tee /sys/firmware/acpi/platform_profile
```

Profiles integrate with `power-profiles-daemon` — GNOME / KDE power mode buttons
will switch between them automatically.

## Battery Charge Threshold ⭐

Limits maximum charge to protect battery longevity. Recommended: **80%**.
With 80% the battery lasts significantly longer over years of use.

### Set permanently (udev rule)

```bash
printf 'ACTION=="add", KERNEL=="BAT1", SUBSYSTEM=="power_supply", ATTR{charge_control_end_threshold}="80"\n' \
  | sudo tee /etc/udev/rules.d/80-battery-charge-threshold.rules

# Apply immediately without reboot
echo 80 | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold
```

### Verify

```bash
cat /sys/class/power_supply/BAT1/charge_control_end_threshold
# → 80
```

### Temporarily disable (e.g. before travel)

```bash
echo 100 | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold
```

The udev rule reapplies the threshold on the next boot.

## Firmware Attributes

### block_recording

Hardware-level camera/microphone privacy lock — blocks the lens cover input device.
Default: `0` (off). Values: `0` = allow, `1` = block.

```bash
# Read
cat /sys/class/firmware-attributes/samsung-galaxybook/attributes/block_recording/current_value

# Block camera/mic (privacy mode)
echo 1 | sudo tee /sys/class/firmware-attributes/samsung-galaxybook/attributes/block_recording/current_value

# Unblock
echo 0 | sudo tee /sys/class/firmware-attributes/samsung-galaxybook/attributes/block_recording/current_value
```

### power_on_lid_open

Controls whether the laptop powers on automatically when the lid is opened.
**Recommended: `1` (enabled)** — makes the laptop behave like expected on every other platform.

```bash
# Enable (recommended)
echo 1 | sudo tee /sys/class/firmware-attributes/samsung-galaxybook/attributes/power_on_lid_open/current_value

# Disable
echo 0 | sudo tee /sys/class/firmware-attributes/samsung-galaxybook/attributes/power_on_lid_open/current_value
```

### usb_charging

Controls USB port charging while the laptop is powered off.
Default: `1` (enabled) — no change needed.

```bash
# Read
cat /sys/class/firmware-attributes/samsung-galaxybook/attributes/usb_charging/current_value

# Enable (default)
echo 1 | sudo tee /sys/class/firmware-attributes/samsung-galaxybook/attributes/usb_charging/current_value
```

## WiFi Power Management

The Intel AX211 WiFi adapter has power save enabled by default on Linux, which can cause
latency spikes and occasional disconnects. Disable it permanently:

```bash
printf '[connection]\nwifi.powersave = 2\n' \
  | sudo tee /etc/NetworkManager/conf.d/wifi-powersave-off.conf
sudo systemctl restart NetworkManager
```

Verify: `iw dev wlan0 get power_save` should show `Power save: off`.

## Technical Details

- ACPI device: `SAM0430:00`
- Driver: `samsung-galaxybook` (in mainline kernel since 6.x)
- Additional modules: `hid_samsung`, `firmware_attributes_class`, `platform_profile`
- Battery: 76 Wh design capacity (4757 mAh)
