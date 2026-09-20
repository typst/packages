# Package and template

The public entry point is `lib.typ`, the starter is `template/main.typ`, and
`typst.toml` declares the package as `doom-wasm:0.1.0` in the preview namespace.
The default game data is the unmodified Freedoom: Phase 1 0.13.0 IWAD. The
initial template opens E1M1 without requiring the player to upload anything.

## Test the submission locally

```sh
make test
make test-package
```

`make package` stages the submission at `build/packages/preview/doom-wasm/0.1.0`
and creates `build/doom-wasm-web.zip`. It includes the engine sources, build
scripts, Freedoom data, and license notices. It excludes the original DOOM WAD,
upstream screenshots, tests, and local build artifacts.

The full Freedoom IWAD is about 29 MB. Keeping it unmodified preserves all four
episodes, their textures and sprites, and normal level progression. The zipped
package is smaller, but this is still larger than a typical document template.

To try the staged files before they are available from Universe:

```sh
typst init --package-path build/packages @preview/doom-wasm:0.1.0 build/my-doom
typst compile --package-path build/packages build/my-doom/main.typ build/my-doom.pdf
```

Configure the editor's package path to the absolute path of `build/packages`.
Alternatively, open `build/doom-wasm-web/main.typ`, which uses file imports.
Upload the contents of the web zip to a Typst project to try it online.

`make test-package` initializes an isolated project using the staged preview
package and tests the default game, remapped controls, CLI input, save export,
and save loading. It also extracts and compiles the web zip without a package
lookup. No game files are manually added for the default-game checks.

## Submission

The package author is seniormars and the source repository is
https://github.com/SeniorMars/doom-typst.

Submit the staged directory at `packages/preview/doom-wasm/0.1.0` in a pull request
to [typst/packages](https://github.com/typst/packages). The title is
`doom-wasm:0.1.0`. The package will become downloadable after that submission is
accepted and published; switching the import namespace alone does not publish it.

The thumbnail must show the freshly initialized template, without extra input.
README screenshots are excluded from the runtime bundle. The template files use
MIT-0 so players can freely modify and distribute their starter documents.
The engine/library use GPL-2.0-or-later and Freedoom uses BSD-3-Clause.

See the official [submission guide](https://github.com/typst/packages/blob/main/docs/README.md)
and [manifest format](https://github.com/typst/packages/blob/main/docs/manifest.md).
