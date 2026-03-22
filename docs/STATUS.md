# Status

## Summary

This repository currently documents a mostly working CachyOS setup for the Samsung Galaxy Book 4 Ultra (`NP960XGL-XG1DE`).

## Current State

- internal speakers work on `linux-cachyos-rc`
- NVIDIA works with prebuilt open kernel modules
- fingerprint works with the SDCP-capable `libfprint` fork
- camera works with the patched OV02C10 path and a source-built `libcamera`
- `samsung-galaxybook` platform features are working and documented
- verification routines exist for core hardware paths

## Known Gaps

- camera still depends on local patching and a custom `libcamera` build
- Thunderbolt/USB4 still lacks verified notes
- long-term suspend/resume behavior is not documented well enough yet
- tested baseline notes should be refreshed whenever the kernel or package stack changes materially

## Next Milestone

Move from "works with documented patching" toward "easy to retest after upgrades":

1. keep the tested kernel/package baseline current
2. add stronger post-upgrade verification evidence
3. reduce dependence on local workarounds as upstream fixes land
