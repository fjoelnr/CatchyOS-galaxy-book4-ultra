# Overview

## Goal

Provide a reproducible, device-specific knowledge base for running CachyOS on the Samsung Galaxy Book 4 Ultra (`NP960XGL-XG1DE`).

## What This Repository Contains

- setup guidance for working components
- workarounds for components that need patched userspace or kernel behavior
- patch material for the camera sensor clock issue
- platform-driver features exposed by `samsung-galaxybook`
- references to upstream work that should eventually obsolete local workarounds
- a compact verification routine for retesting hardware after changes

## What Success Looks Like

- a new owner of the same device can reach a mostly working system quickly
- current blockers are visible without reading issue trackers first
- local workarounds are clearly separated from upstream state
- verification steps are short enough to rerun after kernel or package changes
