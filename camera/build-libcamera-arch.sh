#!/usr/bin/env bash
# build-libcamera-arch.sh
# Builds libcamera 0.7.0 from source with patches for Samsung Galaxy Book 4 Ultra:
#
# Patch 1: OV02C10 CameraSensorHelper
#   The Arch packaged libcamera lacks CameraSensorHelperOv02c10, causing AE/AGC
#   to use wrong gain mapping → very dark or black image.
#
# Patch 2: AGC brightness target (kExposureOptimal 2.5 → 4.0)
#   The default target of 2.5/5.0 is designed for outdoor photography (avoid blown
#   highlights). For a laptop webcam in a normal room this produces a too-dark image.
#   4.0/5.0 targets the upper brightness range, giving a natural webcam appearance.
#
# NOTE: prefix=/usr so our patched IPA replaces the system package at /usr/lib.
#   Using /usr/local would be overridden by ldconfig's preference for /usr/lib.
set -e

BUILD_DIR="/tmp/libcamera-ipu6-build"
VERSION="v0.7.0"

echo "==> Installing build dependencies..."
sudo pacman -S --needed --noconfirm \
    git meson ninja gcc pkgconf cmake \
    python-yaml python-ply python-jinja \
    gnutls libyaml libevent \
    gstreamer gst-plugins-base \
    libdrm libjpeg-turbo libtiff \
    openssl libelf libunwind

echo "==> Cloning libcamera $VERSION..."
rm -rf "$BUILD_DIR"
git clone --depth 1 --branch "$VERSION" \
    https://git.libcamera.org/libcamera/libcamera.git "$BUILD_DIR"
cd "$BUILD_DIR"

echo "==> Patch 1: OV02C10 CameraSensorHelper..."
HELPER_FILE="src/ipa/libipa/camera_sensor_helper.cpp"
if ! grep -q "CameraSensorHelperOv02c10" "$HELPER_FILE"; then
    sed -i '/#endif.*__DOXYGEN__/i\
class CameraSensorHelperOv02c10 : public CameraSensorHelper\
{\
public:\
\tCameraSensorHelperOv02c10()\
\t{\
\t\tgain_ = AnalogueGainLinear{ 1, 0, 0, 16 };\
\t}\
};\
REGISTER_CAMERA_SENSOR_HELPER("ov02c10", CameraSensorHelperOv02c10)\
' "$HELPER_FILE"
    echo "  ✓ OV02C10 sensor helper patched"
else
    echo "  ✓ OV02C10 sensor helper already present"
fi

echo "==> Patch 2: AGC brightness target (kExposureOptimal 2.5 → 4.0)..."
AGC_FILE="src/ipa/simple/algorithms/agc.cpp"
if grep -q "kExposureBinsCount / 2.0" "$AGC_FILE"; then
    # Replace the kExposureOptimal line to target brighter images (4.0 out of 5 bins)
    sed -i 's|static constexpr float kExposureOptimal = kExposureBinsCount / 2\.0;|static constexpr float kExposureOptimal = 4.0; /* patched: webcam brightness (default 2.5) */|' "$AGC_FILE"
    echo "  ✓ AGC target raised to 4.0/5 bins"
elif grep -q "kExposureOptimal = 4.0" "$AGC_FILE"; then
    echo "  ✓ AGC target already patched"
else
    echo "  ✗ WARNING: Could not patch AGC target (pattern not found)"
fi

echo "==> Configuring..."
meson setup build \
    -Dprefix=/usr \
    -Dpipelines=simple \
    -Dipas=simple \
    -Dgstreamer=enabled \
    -Dv4l2=true \
    -Ddocumentation=disabled \
    -Dtest=false

echo "==> Building (this takes a few minutes)..."
ninja -C build

echo "==> Installing to /usr (replaces system package)..."
sudo ninja -C build install
sudo ldconfig

echo "==> Verifying..."
if strings /usr/lib/libcamera/ipa/ipa_soft_simple.so | grep -q "CameraSensorHelperOv02c10"; then
    echo "  ✓ OV02C10 sensor helper present in system IPA module"
else
    echo "  ✗ WARNING: OV02C10 sensor helper NOT found in system IPA module"
fi

echo ""
echo "Done! Restart PipeWire and test:"
echo "  systemctl --user restart pipewire wireplumber"
echo "  cam --list"
echo "  cam -c 1 --capture=5 --file=/tmp/test#.ppm"
