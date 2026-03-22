# Operations

## Update Routine

When the system or repo changes materially:

1. retest the affected hardware component
2. run the relevant checks from [Verification](verification.md)
3. update the component-specific README
4. update the root status table if support level changed
5. update `docs/STATUS.md` if the repo-wide baseline changed
6. note the tested kernel/package versions

## Release/Promotion Model

- feature work should start on a feature branch
- merge into `develop` first
- promote `develop` to `main` once documentation is coherent and reviewed

## Review Priorities

- correctness of commands
- accuracy of support status
- explicit upstream references
- clear distinction between verified and speculative content
- repeatability of verification steps
