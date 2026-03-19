# Fingerprint Sensor — LighTuning ETU905A80-E

## Status: ✅ Working (sudo + fprintd)

The Samsung Galaxy Book 4 Ultra ships with a LighTuning (Egis Technology) ETU905A80-E
fingerprint sensor (`1c7a:05a1`). It is a **Match-on-Chip (MoC)** sensor that uses the
**SDCP (Secure Device Communication Protocol)** to store templates permanently on the chip.

## Root Cause

Mainline `libfprint` does not yet implement SDCP for Egis MoC sensors. Without SDCP,
enrollment appears to succeed but fingerprints are not persisted to the chip — after a
reboot every enrolled finger is gone.

The upstream fix is tracked in [libfprint MR #146](https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/146)
(open since 2020, still WIP as of early 2026).

**Working solution:** [TenSeventy7/libfprint-egismoc-sdcp](https://github.com/TenSeventy7/libfprint-egismoc-sdcp) —
a fork with full SDCP support for the `0x05a1` device ID.

## Fix

### Step 1 — Build dependencies

```bash
sudo pacman -S git meson ninja pkgconf glib2-devel \
    libgudev nss gobject-introspection \
    libusb pixman cairo
```

### Step 2 — Build and install

```bash
./fingerprint/build-libfprint-sdcp.sh
```

Or manually:

```bash
git clone https://github.com/TenSeventy7/libfprint-egismoc-sdcp.git ~/libfprint-egismoc-sdcp
cd ~/libfprint-egismoc-sdcp
meson setup build --prefix=/usr -Ddoc=false -Dgtk-examples=false -Dintrospection=false
ninja -C build
sudo ninja -C build install
```

### Step 3 — Restart fprintd and enroll

```bash
sudo systemctl restart fprintd
fprintd-enroll -f right-index-finger
```

### Step 4 — Verify persistence

```bash
fprintd-verify
# Swipe finger, confirm match
sudo reboot
fprintd-verify   # Should still match after reboot
```

### sudo integration

PAM is already configured on CachyOS. No changes needed — `pam_fprintd.so` is present
as `sufficient` in `/etc/pam.d/system-auth`. After successful enrollment, `sudo` will
prompt for fingerprint.

### Verify

```bash
# Check library version (should show 1.94.9 with SDCP support)
pkg-config --modversion libfprint-2

# List enrolled fingers
fprintd-list "$USER"

# Test sudo
sudo echo "fingerprint sudo works"
```

## Keeping libfprint Updated

The custom-built library will be overwritten if `libfprint` is upgraded via pacman.
Run the build script again after any `libfprint` update, or use the pacman hook:

```bash
sudo cp fingerprint/libfprint-sdcp-rebuild.hook /etc/pacman.d/hooks/
```

See `fingerprint/libfprint-sdcp-rebuild.hook` for the hook definition.

## Technical Details

- Sensor: LighTuning ETU905A80-E (Egis `0x05a1`)
- Protocol: SDCP (Secure Device Communication Protocol) — Match-on-Chip
- Templates stored on chip, not in `/var/lib/fprint/`
- USB ID: `1c7a:05a1`
- libfprint fork: `libfprint-egismoc-sdcp` v1.94.9
