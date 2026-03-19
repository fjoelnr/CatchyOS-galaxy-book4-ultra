#!/usr/bin/env bash
# build-libfprint-sdcp.sh
# Builds and installs TenSeventy7's libfprint fork with SDCP support
# for the LighTuning ETU905A80-E fingerprint sensor (1c7a:05a1).
#
# Run this script after any system libfprint update to restore SDCP support.

set -euo pipefail

REPO_URL="https://github.com/TenSeventy7/libfprint-egismoc-sdcp.git"
BUILD_DIR="$HOME/libfprint-egismoc-sdcp"

echo "==> Installing build dependencies..."
sudo pacman -S --needed --noconfirm \
    git meson ninja pkgconf glib2-devel \
    libgudev nss gobject-introspection \
    libusb pixman cairo

if [[ -d "$BUILD_DIR" ]]; then
    echo "==> Updating existing clone..."
    git -C "$BUILD_DIR" pull
else
    echo "==> Cloning libfprint-egismoc-sdcp..."
    git clone "$REPO_URL" "$BUILD_DIR"
fi

cd "$BUILD_DIR"

# Clean previous build if present
if [[ -d build ]]; then
    echo "==> Removing previous build directory..."
    rm -rf build
fi

echo "==> Configuring..."
meson setup build --prefix=/usr \
    -Ddoc=false \
    -Dgtk-examples=false \
    -Dintrospection=false

echo "==> Building..."
ninja -C build

echo "==> Installing..."
sudo ninja -C build install

echo "==> Restarting fprintd..."
sudo systemctl restart fprintd

echo ""
echo "Done. libfprint version: $(pkg-config --modversion libfprint-2)"
echo "If this is a fresh install, enroll your finger with:"
echo "  fprintd-enroll -f right-index-finger"
