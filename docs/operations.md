# Operations

## Update Routine

When the system or repo changes materially:

1. retest the affected hardware component
2. update the component-specific README
3. update the root status table if support level changed
4. note the tested kernel/package versions

## Release/Promotion Model

- feature work should start on a feature branch
- merge into `develop` first
- promote `develop` to `main` once documentation is coherent and reviewed

## Review Priorities

- correctness of commands
- accuracy of support status
- explicit upstream references
- clear distinction between verified and speculative content
