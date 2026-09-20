# Packaging

`lib.typ` is the package entry point. `template/main.typ` is the file players
start with. `typst.toml` defines the package name, version, and template.

Freedoom: Phase 1 is included, so a new project opens straight into E1M1.

## Build and try it

From the repository root, run:

```sh
make package
```

This creates two things:

- `build/packages/preview/doom-wasm/0.1.0`: the files for the Universe submission.
- `build/doom-wasm-web.zip`: a project you can unzip and upload to the Typst web app.

To try the package before it's published:

```sh
typst init --package-path build/packages @preview/doom-wasm:0.1.0 build/my-doom
typst compile --package-path build/packages build/my-doom/main.typ build/my-doom.pdf
```

For live preview, set your editor's package path to the full path of
`build/packages`. Or open `build/doom-wasm-web/main.typ`, which uses local file
imports and doesn't need that setting.

## Test it

```sh
make test
make test-package
```

The package test creates a fresh project with `typst init` and checks gameplay,
custom controls, CLI input, and save/load. It also extracts and compiles the web
zip. Both start with the included Freedoom data.

## What's included

The package contains the WASM plugin, its source and build scripts, the Typst
files, and Freedoom's game data and license notices. The original DOOM WAD,
tests, build output, and upstream screenshots are left out.

Freedoom's full Phase 1 IWAD is about 29 MB before compression. It includes all
four episodes and hasn't been edited. The web zip is about 11 MB.

The engine and library use GPL-2.0-or-later. Freedoom uses BSD-3-Clause. The files
in `template/` use MIT-0 so players can modify and share their documents freely.

## Submit to Universe

The author is seniormars. The source is at
[SeniorMars/doom-typst](https://github.com/SeniorMars/doom-typst).

Copy the staged package into `packages/preview/doom-wasm/0.1.0` in a fork of
[typst/packages](https://github.com/typst/packages), then open a PR titled
`doom-wasm:0.1.0`. The current submission is [PR #5893](https://github.com/typst/packages/pull/5893).
The package can be downloaded from Universe after it's accepted and published.

Use a screenshot of the unchanged starter project for `thumbnail.png`. Keep
README images out of the runtime bundle with the manifest's `exclude` setting.
Keep the license files in the bundle.

The official [submission guide](https://github.com/typst/packages/blob/main/docs/README.md)
and [manifest reference](https://github.com/typst/packages/blob/main/docs/manifest.md)
cover the remaining requirements.
