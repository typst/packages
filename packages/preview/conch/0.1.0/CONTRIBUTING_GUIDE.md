# Contributing & maintainer guide

## Building from source

Requires Rust with the `wasm32-unknown-unknown` target and [just](https://github.com/casey/just):

```bash
rustup target add wasm32-unknown-unknown
just build
```

Unit tests for the shell, parser, and helpers live in the crate sources (`#[cfg(test)]`); run:

```bash
just test
# or: cd wasm && cargo test
```

The build writes `conch.wasm` to the package root. **Ship that file with the package** (it is required at runtime); rebuild and commit it whenever the WASM code changes. Typst loads it from `src/wasm.typ` via `plugin("../conch.wasm")` (path is relative to that file).

## Formatting

`just fmt` runs Just self-format (`just --fmt`), `cargo fmt` in `wasm/`, [typstyle](https://github.com/Enter-tainer/typstyle) on `*.typ`, and [Prettier](https://prettier.io) on `*.md` at the repo root. Options for Markdown live in [`.prettierrc.json`](.prettierrc.json) (e.g. `proseWrap: preserve`). Install `typstyle` and `prettier` on your `PATH` so the `just` recipe `require()` calls succeed.

## Package layout

- **`lib.typ`** — package entrypoint (`typst.toml` → `entrypoint`). Re-exports the public API only.
- **`src/`** — implementation modules (`theme`, `wasm`, `frame`, `ansi`, `session`, `render`, `terminal`). Internal imports are relative within `src/`.
- **`wasm/conch-wasm/`** — Rust source for `conch.wasm`. Embeds the [wasmi](https://github.com/wasmi-labs/wasmi) WASM interpreter for running user-provided WASM plugins inside the shell.
- **`wasm/bare-vfs/`** — in-memory virtual filesystem crate (`no_std`, inode-based).
- **`wasm/demo-plugin/`** — example WASM plugin crate (`upper` command). Build with `just build-demo-plugin`.

## Maintainer commands

- `just thumbnail` — regenerate `thumbnail.png` (Typst Universe requires it for template packages).
- `just gif` — compile a Typst animation to GIF (needs `ffmpeg`, just ≥ 1.46 for CLI flags). Defaults to `demo/demo.typ` → `demo/demo.gif`. Options are `--src`, `-o`/`--out`, `-f`/`--fps`, `--frames-dir`, and `--hold-*` (forwards to `typst --input conch_hold_*`; implementation in `src/terminal.typ`; see `just --usage gif`).
  - **Frames directory:** by default PNGs go in a temp dir and are removed when the recipe exits. If you pass **`--frames-dir`**, that path is wiped and recreated before rendering, then **left on disk** afterward (so you can inspect frames). Only temp dirs are deleted automatically.
- `just build-demo-plugin` — compile `wasm/demo-plugin/` to `demo/demo-plugin.wasm`.
- `just demos` — compile all `demo/*.typ` to PNG screenshots (also builds `conch.wasm` and `demo-plugin.wasm`).
- `typst-package-check check .` — optional lint for `typst.toml` and fenced code in `README.md`. If it warns on snippets that **compile fine with `typst compile`**, treat that as a checker limitation; do not contort documentation to silence it.

## Plugin system

Users can extend conch with custom commands via two mechanisms:

- **WASM plugins** (`system(wasm-plugins: ...)`) — compiled WASM modules executed inside conch via the embedded wasmi interpreter. They run synchronously in the pipeline like built-in commands. Protocol: receive `{args, stdin, files}` JSON, return `{stdout, exit-code, writes}` JSON. See `wasm/demo-plugin/` for the canonical example.
- **Typst function plugins** (`system(plugins: ...)`) — plain Typst functions called via the delegate protocol. Simpler but limited to standalone/pipeline-tail position.

WASM plugins are registered via `register_plugin()` in `lib.rs` (called from `src/session.typ` before execution) and dispatched from `commands/mod.rs`. The plugin host lives in `plugin_host.rs`.

## Publishing (Typst Universe)

1. Bump `version` in `typst.toml` (and `@preview/conch:…` strings in `README.md`, `template/main.typ`, and anywhere else — e.g. `rg '@preview/conch'` from the repo root).
2. Run `just build` and `just thumbnail`. Optionally run `typst-package-check` as above; fix real issues, keep examples readable.
3. Add a `repository = "https://github.com/…/conch"` (or `homepage`) entry under `[package]` if the project is public — Universe links it from the package page.
4. Copy the package directory into a fork of [typst/packages](https://github.com/typst/packages) at `packages/preview/conch/<version>/` (path segments must match `name` and `version` in the manifest) and open a PR.

The `exclude` list in `typst.toml` keeps heavy assets (e.g. `demo/`) out of the compiler download bundle; README illustrations remain available on the package’s Universe page.
