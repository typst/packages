# Development and releases

Install Python 3.11 or later and Typst 0.13.1 or later. CI runs the same suite
against Typst 0.13.1 and 0.14.2.

```sh
./scripts/check
```

The checker compiles every `tests/*.typ` fixture whose name does not contain
`errors`, verifies the invalid-input fixtures, compiles the README quick start
in a fresh project, and compiles the demo. Generated
PDFs and the staged package live in a temporary directory and are removed when
the command finishes. Use `--typst /path/to/typst` to select another compiler, or
`--skip-demo` while working on a component.

The `tests/package-*.typ` fixtures import `@preview/lineal:0.2.0`. The checker
copies the distributable file set to a private package directory and passes it
to Typst with `--package-path`. This verifies real package imports and bundled
resources without replacing a globally cached or installed package.

## Adding tests

- Put a successful compilation fixture directly in `tests/`.
- Put a rejected-input fixture in `tests/invalid/`. It must fail an explicit
  assertion. An optional first-line `// expect-error: message` comment requires
  that message in the diagnostic as well.
- For one fixture with several `sys.inputs` cases, add a `tests/*-errors.json`
  list. Each entry has `source` relative to `tests/`, `inputs` as string keys and
  values, and `error` as the expected assertion-message substring.

Compilation tests catch broken imports, missing assets and invalid inputs.
Render new layouts and inspect their PDF output before merging visual changes.

## Packaging

```sh
./scripts/package /tmp/lineal-0.2.0
./scripts/package --install-local --replace
```

The first command stages `src/`, `lib.typ`, `typst.toml`, `README.md`, `LICENSE`
and `docs/` in a new or empty directory outside the repository. It excludes
tests, scripts, the demo, Git metadata and generated output. The second installs
the same files under `@local/lineal:0.2.0`; `--replace` only replaces an existing
local package with the same name and version. Neither command installs into the
global `@preview` namespace.

## Publishing

1. Update `typst.toml`, documented imports and the package fixtures together.
2. Run `./scripts/check` with both supported compiler versions and inspect the demo.
3. Merge the reviewed source and tag that exact commit.
4. Stage its files into `packages/preview/lineal/<version>/` in a fork of
   [`typst/packages`](https://github.com/typst/packages).
5. Open a package-update PR. Keep earlier published version directories unchanged.

Keep the README, license files and runtime assets in the submission. Exclude
large documentation images and PDFs from the downloaded bundle through the
manifest. See the official [submission guidelines](https://github.com/typst/packages/blob/main/docs/README.md)
and [file-selection guidance](https://github.com/typst/packages/blob/main/docs/tips.md).
