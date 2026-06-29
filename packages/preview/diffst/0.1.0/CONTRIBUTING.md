# Contributing

Run commands from the repository root.

## Prerequisites

Install the Rust WASM target, `wasm-opt` from Binaryen, and make sure `typst`
is on your `PATH`:

```sh
rustup target add wasm32-unknown-unknown
```

Optional tools:

- `uv`, used by the helper scripts in `scripts/`.
- `typst-package-check` and `typship`, used for release validation.

## Build the WASM Artifact

The package loads `plugin.wasm` from the repository root. The smoke script
builds the release WASM artifact and refreshes `plugin.wasm`:

```sh
sh scripts/smoke.sh
```

This runs `cargo test`, builds
`target/wasm32-unknown-unknown/release/diffst_wasm.wasm`, optimizes it with
`wasm-opt -Oz --enable-bulk-memory`, writes the result to `plugin.wasm`, and
compiles the example Typst files to `${TMPDIR:-/tmp}/diffst-smoke`.

To build only the Rust artifact manually:

```sh
cargo test
cargo build --release --target wasm32-unknown-unknown
wasm-opt -Oz --enable-bulk-memory target/wasm32-unknown-unknown/release/diffst_wasm.wasm -o plugin.wasm
```

## Compile Test Files

Compile the package import smoke file:

```sh
typst compile --root . tests/package-import-smoke/test.typ /tmp/diffst-package-import-smoke.pdf
```

Compile all examples:

```sh
sh scripts/smoke.sh
```

## Populate the Typst Universe PR Folder

Create the folder layout expected by the Typst package repository:

```sh
scripts/package-pr.py
```

This recreates:

```text
package-pr/packages/preview/diffst/0.1.0/
```

The script reads `typst.toml`, uses the package name and version, and respects
the manifest `exclude` list.

Validate the generated package:

```sh
typst-package-check check --offline package-pr/packages/preview/diffst/0.1.0
(cd package-pr/packages/preview/diffst/0.1.0 && typship check)
```

Install the generated package into the `@local` namespace and compile an import
smoke test:

```sh
sh scripts/local-package-smoke.sh
```

Copy the generated `packages/preview/diffst/0.1.0/` directory into a branch of
the official Typst packages repository when opening the release PR.
