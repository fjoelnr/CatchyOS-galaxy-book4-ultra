# AGENTS.md

## Purpose

This repository documents hardware support, workarounds, and patching notes for running CachyOS on the Samsung Galaxy Book 4 Ultra (`NP960XGL-XG1DE`).

## Working Rules

- Prefer documentation and reproducible steps over speculative fixes.
- Do not claim hardware support without local validation notes.
- Keep distro-specific commands explicit and testable.
- Preserve upstream attribution when referring to kernel patches, issues, or forks.
- Treat camera support as experimental until streaming is verified.

## Change Expectations

- Update the relevant component README when behavior changes.
- Update root `README.md` when setup flow or support status changes.
- Record repo-level operational guidance in `docs/`.
- Keep ANR scaffolding (`.agents/`, `docs/`, this file) in place even if minimal.

## Validation

- For shell changes: run `bash -n` at minimum.
- For docs changes: keep commands copy-pasteable and paths accurate.
- For kernel/module notes: state tested kernel/package versions when known.
