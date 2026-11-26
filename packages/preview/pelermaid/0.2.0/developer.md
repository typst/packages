# Development

This file covers building, testing, and releasing Pelermaid. User documentation lives in
[README.md](README.md).

## Repository layout

| Path | Purpose |
| --- | --- |
| `lib.typ` | Typst API, presets, config resolution, and rendering |
| `js/src/main.js` | JavaScript wrapper around Pele |
| `js/src/sanitize.js` | SVG sanitizer for Typst's renderer |
| `js/src/icons.js`, `js/src/lucide-icons.js` | Bundled Lucide icon subset |
| `pele.kbc1` | QuickJS bytecode bundle shipped with the package |
| `tests/parity.mjs` | Extension-vs-Pele SVG parity check |
| `tests/config.typ` | Theme, font, series, icon, and transparent-canvas assertions |
| `tests/corpus/` | One Mermaid source per supported diagram family, plus examples |
| `tests/corpus.typ` | Renders the visual corpus gallery |
| `scripts/` | Build, staging, packaging, and release helpers |
| `.github/workflows/` | CI and release pipelines |

## Requirements

- Typst 0.15 or newer
- Bun 1.4.3
- Rust 1.99.1 and Cargo, only for regenerating `pele.kbc1`
- Docker, only for the official package checker

Pinned dependencies:

| Dependency | Version |
| --- | --- |
| Pele | `1.13.0` (`js/package.json`) |
| CtxJS | `@preview/ctxjs:0.5.0` (`lib.typ`) |
| CtxJS source commit | `c4c270035bac9a825564ca1257735c704ec8988a` (`scripts/build.sh`) |
| Lucide subset | v1.14.0, 79 glyphs and 31 aliases |
| Bun | `1.4.3` |
| Typst in CI | `0.15.0` |
| Typst in release | `0.15.1` |

## Build

```bash
./scripts/build.sh
```

The script:

1. Installs the pinned `pele` npm package and builds `js/dist/pele.mjs` with esbuild.
2. Obtains `ctxjs_module_bytecode_builder` from the pinned CtxJS source, cached under
   `.cache/ctxjs`.
3. Writes `pele.kbc1`.

Pele is consumed from npm; no Git submodule is required. `pele.kbc1` is committed and shipped.
CI does not rebuild it. The release workflow does, and fails if the result differs from the
committed file.

The JavaScript wrapper is in `js/src/main.js`; SVG sanitization is in `js/src/sanitize.js`.

## Local install

The helper scripts install the working tree into Typst's local package namespace:

```bash
# Linux / WSL Typst
./scripts/install-local.sh

# Native Windows Typst when running under WSL
./scripts/install-windows.sh
```

After staging the package with `./scripts/stage-package.sh`, compile examples with
`--package-path dist/packages`.

## Tests

### Parity with Pele

```bash
cd js
bun install --frozen-lockfile
bun run build
cd ..
bun tests/parity.mjs
```

`tests/parity.mjs` dumps the theme and render options that `build-config()` resolves in
`lib.typ`, renders every `tests/corpus/**/*.mmd` source with Pele's JavaScript bundle, renders
the same source through `mermaid-svg`, and fails unless the SVGs are byte-identical. The
extension is the source of truth for the preconfigured config; there is no duplicated theme in
the test.

### Config assertions

```bash
typst eval --root . --in tests/config.typ 'none'
```

This runs assertions for preset selection, document adaptation, contrast guards, font stacks,
series cycling, icon resolution and overrides, and transparent-canvas decorations. It does not
produce a PDF.

### Visual corpus

```bash
./scripts/build-diagrams.sh
```

This writes `artifacts/corpus.pdf`, the gallery attached to releases. CI cannot inspect the
rendered pages; the release artifact is the visual check a human reviews.

## CI

`.github/workflows/ci.yml` runs a single job on Typst 0.15.0:

1. Build `js/dist/pele.mjs`.
2. Run `tests/parity.mjs`.
3. Run the `tests/config.typ` assertions.

CI does not install Rust, rebuild `pele.kbc1`, compile PDFs, stage packages, or run the Docker
package checker. Those are release concerns.

## Release

Releases are built by `.github/workflows/release.yml`. Configure this once:

1. Create a `release` environment (Settings → Environments) with a required reviewer.
2. Add `TYPST_PACKAGES_TOKEN` as a secret on that environment, not at repository level.
   It only needs to push a branch to your `typst/packages` fork, so a fine-grained PAT
   with Contents: read/write on that fork is enough. Create it on the same account as
   `PACKAGES_FORK_OWNER`, and make sure that account already has a `packages` fork.
3. Restrict environment deployments to `v*`, plus `main` if you want to rehearse with
   `workflow_dispatch`.
4. Add the repository variable `PUSH_PACKAGES_FORK=true` when tag pushes should push the
   branch. Without it, tag pushes only create the GitHub release.

The `build` job:

1. Installs Rust 1.99.1, then runs `./scripts/build.sh`.
2. Verifies that `pele.kbc1` matches the committed bytecode.
3. Runs the parity and config checks.
4. Runs `./scripts/check-release.sh`.
5. Builds `artifacts/corpus.pdf`.
6. Stages the package, compiles the examples, and runs the official package checker.
7. Uploads the package and gallery artifacts.

The `github-release` job attaches the package tarball and `corpus.pdf` to the release. Before
approving the `release` environment for `push-packages`, download and inspect `corpus.pdf`.

The `push-packages` job pushes a branch to your `typst/packages` fork and prints a compare URL.
Open the pull request against `typst/packages` yourself. Rehearse with a `workflow_dispatch`
with `push_packages` off, then run it again with the input on (or against a scratch fork)
before publishing a real version.

## Version bump checklist

1. Update `version` in `typst.toml`.
2. Update the versioned import line in `README.md` and in `examples/*.typ`.
   `scripts/check-release.sh` enforces both.
3. Add a `## <version>` section to `CHANGELOG.md`.
4. Rebuild `pele.kbc1` if the JavaScript wrapper or Pele changed: `./scripts/build.sh`.
5. Tag the release as `v<version>`.
6. Run or verify the release workflow.

Keep explanatory prose free of package versions where possible. The import line stays
versioned so users can copy the current release; the pinned dependency versions live here.

## Packaging

```bash
./scripts/stage-package.sh
./scripts/package-check.sh
./scripts/push-packages-fork.sh dist/packages/preview/pelermaid/<version>
```

`stage-package.sh` copies only the files that belong in the published package into
`dist/packages/preview/<name>/<version>`. It also rejects dotfiles and build tooling in the
staged payload.

`package-check.sh` runs the official `ghcr.io/typst/package-check` image. It supplies a sparse
clone of `typst/packages` containing CtxJS so the checker can resolve the preview dependency.
Set `PACKAGE_CHECK_ONLINE=1` to enable the network-only lints.

`push-packages-fork.sh` pushes the staged package to the `typst/packages` fork configured in
the release environment.

## Offline CtxJS

`lib.typ` imports `@preview/ctxjs:0.5.0`. If an offline or Tinymist setup cannot resolve
preview packages, vendor the CtxJS package and change the import in `lib.typ`.

## Diagram gallery

Each tagged release attaches `corpus.pdf`, built from `tests/corpus.typ`:

<https://github.com/mohamedamrnady/typst-pelermaid/releases/latest/download/corpus.pdf>

GitHub's `/releases/latest/download/` path always redirects to the newest release, so the link
stays current.

## License

Pelermaid is MIT licensed. `pele.kbc1` bundles Pele (MIT) and a subset of Lucide icons (ISC);
the full texts are in `LICENSES/`. Because the distributed bytecode contains both, the
manifest declares `MIT AND ISC`. See [`LICENSE`](LICENSE) and
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
