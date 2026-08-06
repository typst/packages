# Contributing to PhysKit

Thank you for helping make physics diagrams easier to author in Typst.

## Design rules

1. Keep the two-level architecture strict.
2. High-level modules may use `geometry` and `primitives`; they must not call CeTZ directly.
3. Constructors return data. Rendering happens in `diagram`.
4. Connections reference named object anchors rather than duplicated coordinates.
5. Every public feature needs a compiling example or test.
6. Public API changes must be recorded in `CHANGELOG.md`.

## Development workflow

1. Create a focused branch.
2. Add or update tests and examples.
3. Compile every file under `tests/` and `examples/`.
4. Update documentation and the changelog.
5. Open a pull request describing the physical concept and API design.

## Commit style

Use short imperative summaries. Conventional Commit prefixes are encouraged:

- `feat:` new public behavior;
- `fix:` bug fix;
- `docs:` documentation only;
- `test:` test changes;
- `refactor:` internal restructuring.
