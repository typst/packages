# Repository Guidelines

## Project Structure & Module Organization
- `src/`: Main Nim sources. Entry point: `src/atlas.nim`. Core modules live under `src/basic/` (parsing, versions, git ops) and helpers like `pkgsearch.nim`, `confighandler.nim`.
- `tests/`: Unit and integration tests. Standalone test programs (e.g., `tbasics.nim`, `testintegration.nim`) plus fixture workspaces under `tests/ws_*`.
- `bin/`: Local development builds (`bin/atlas`).
- `doc/`: Documentation (`doc/atlas.md`).
- Top-level config: `atlas.nimble` (package meta), `config.nims` (dev tasks), `nim.cfg` (compiler flags).

## Build, Test, and Development Commands
- Setup: `nim testReposSetup` to setup the test cache.
- Build (debug): `nim build` — compiles to `bin/atlas` via `config.nims`.
- Build (release): `nim buildRelease` — creates an optimized binary (cross‑arch rules inside `config.nims`).
- Run all tests: `nim test` — downloads test repos (if missing), runs unit and integration suites.
- Unit tests only: `nim unitTests`
- Integration tests: `nim tester`
- Docs: `nim docs` or `nimble docs`
- Try the CLI: `bin/atlas --help`

## Coding Style & Naming Conventions
- Language: Nim 2.x (`requires "nim >= 2.0.0"`).
- Indentation: 2 spaces, no tabs; aim for short lines (~100 cols).
- Naming: types `CamelCase`, procs/vars `camelCase`, modules lowercased (underscores allowed, e.g., `parse_requires.nim` but discouraged).
- Formatting: Mimic the style of the Nim creator @araq when possible.
- Remember that Nim procs/funcs must be declared before usage.

## Testing Guidelines
- Framework: `std/unittest` with executable test files in `tests/`.
- Conventions: prefix with `t` or `test` (e.g., `tserde.nim`, `testsearch.nim`). Place fixtures under `tests/ws_*`.
- Run locally: `nim unitTests` (fast) or `nim test` (full, includes repo fixtures).

## Commit & Pull Request Guidelines
- Commits: short imperative subject (≤72 chars), optional scope (e.g., `test:`, `fix:`), reference issues/PRs (e.g., `(#152)`).
- PRs must include: clear description of motivation and approach, linked issues, test coverage (new/updated tests), and any CLI output diffs or logs if behavior changed.
- CI expectations: ensure `nim test` and `nim build` pass locally before opening the PR.

## Security & Configuration Tips
- Do not commit secrets. `deps/` is project‑local for consumers; in this repo, keep focus on source, tests, and configs.
- When modifying dependency resolution or config handling, document changes in `doc/atlas.md` and add targeted tests in `tests/`.

