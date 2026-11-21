# Third-party notices

Pelermaid bundles the Pele renderer as QuickJS bytecode (`pele.kbc1`) and uses the
`@preview/ctxjs` Typst package as its JavaScript runtime. The license texts below are
shipped as separate files so they travel with the bundled code.

## Bundled in `pele.kbc1`

### Pele

- Project: Pele (<https://github.com/obsidianmd/pele>)
- Version: 1.12.0
- Source revision: `8aff183` (Release 1.12.0, 2026-10-26)
- License: MIT, copyright (c) 2026 kepano
- License text: [`LICENSES/PELE-MIT.txt`](LICENSES/PELE-MIT.txt)

Pele is bundled by `js/` with esbuild and compiled to `pele.kbc1` with
`ctxjs_module_bytecode_builder` from CtxJS 0.5.0.

### Lucide icon

- Project: Lucide (<https://lucide.dev>)
- Asset: `rotate-ccw`, used by Pele's zoom controls
- Version: Lucide v1.14.0
- License: ISC, copyright (c) 2026 Lucide Icons and Contributors
- License text: [`LICENSES/LUCIDE-ISC.txt`](LICENSES/LUCIDE-ISC.txt)

## Runtime dependency (not bundled)

### CtxJS

- Project: CtxJS (<https://github.com/lublak/typst-ctxjs-package>)
- Version: 0.5.0
- License: MIT, copyright (c) 2026 lublak
- License text: [`LICENSES/CTXJS-MIT.txt`](LICENSES/CTXJS-MIT.txt)

CtxJS is resolved by Typst as `@preview/ctxjs:0.5.0`. Its WebAssembly runtime and
Typst sources are downloaded separately and are not part of this package.

## Package license

Pelermaid's own files are MIT licensed; see [`LICENSE`](LICENSE). Because the
distributed bytecode contains both MIT and ISC code, the package manifest declares
`license = "MIT AND ISC"`.
