# NVIDIA RTX 4070 Laptop

## Status: ✅ Working

The RTX 4070 Laptop GPU works out of the box with the prebuilt open kernel modules from
the CachyOS repositories. No DKMS required.

## Root Cause (common pitfall)

The `nvidia-dkms` / `nvidia-580xx-dkms` packages fail to compile against
`linux-cachyos-rc` (7.0-rc3) because of incompatible kernel API changes. They also
break other kernel variants' initramfs if referenced in `/etc/mkinitcpio.d/`.

**Do not use DKMS NVIDIA packages on this machine.**

## Fix

Install the prebuilt open modules for all kernels you use:

```bash
sudo pacman -S \
    linux-cachyos-rc-nvidia-open \
    linux-cachyos-nvidia-open \
    linux-cachyos-lts-nvidia-open
```

These packages ship driver **595.45.04** built against their respective kernels.

### Verify

```bash
nvidia-smi
```

Expected output shows the RTX 4070 Laptop with driver 595.xx and CUDA 12.x.

## Power Management

Prime offloading works normally. The iGPU (Intel Arc) handles display output;
the RTX 4070 is used on demand.

```bash
# Run an application on the dGPU
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <app>

# Or via prime-run
prime-run <app>
```

## Technical Details

- GPU: NVIDIA GeForce RTX 4070 Laptop (AD106M)
- Driver: 595.45.04 (open kernel modules)
- Packages: `linux-cachyos-rc-nvidia-open`, `linux-cachyos-nvidia-open`, `linux-cachyos-lts-nvidia-open`
- CUDA: 12.x
- Display: handled by Intel Arc iGPU (PRIME offload setup)
