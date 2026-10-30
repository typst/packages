# Development guide

[README](../README.md) · [API reference](api.md)

## Structure

| File | Responsibility |
| --- | --- |
| `lib.typ` | Public Portuguese API, view dispatcher, English wrappers and translations |
| `src/modelo.typ` | Data constructors without rendering effects |
| `src/validacao.typ` | Local and collection validation, static text inspection |
| `src/apresentacoes/roteiro.typ` | Shared renderer for script, editorial, and production |
| `src/apresentacoes/editorial.typ` | Notes, warnings, and editorial option validation |
| `src/apresentacoes/blocos.typ` | Frequency-based widths and box positioning |
| `src/apresentacoes/esquema.typ` | Geometric layout calculations and rendering |
| `src/relatorios.typ` | Map, pending-note, dialogue, and text reports |

The canonical model is a tree of dictionaries and arrays, not document state.
English wrappers normalize parameters and common enum values before calling
the Portuguese implementation. Do not introduce a second English data model.

## Checks

Run from the package folder with Typst and Poppler (`pdftotext`) installed:

```sh
typst compile --root . tests/test-modelo.typ /tmp/hq-model.pdf
typst compile --root . tests/test-blocos.typ /tmp/hq-blocks.pdf
typst compile --root . tests/test-english.typ /tmp/hq-english.pdf
python3 tests/verificar.py
```

Typst tests check model behavior, geometry, frequency tiers, actual available
widths, and data equivalence between languages. The Python runner checks
expected errors, visibility, filters, ordering, reports, pagination, and
English rendering. It removes temporary files.

Compile and visually inspect examples after renderer changes. Successful
compilation alone does not establish good page breaks or visual hierarchy.

Examples and the README use `@preview/comicscript:0.3.0`. Before publication,
register a local copy under `preview/comicscript/0.3.0` in a temporary directory
and pass its parent as `--package-path` (or set `TYPST_PACKAGE_PATH`). This tests
the real manifest and package boundary without writing to the global cache.
The runtime bundle needs only `lib.typ`, `src/`, the manifest, README, and license;
the manifest excludes examples and extended documentation from downloads.

## Documentation policy

**Write documentation and READMEs in English first.** English is the default.
Keep Portuguese translations in explicitly named files such as
`README.pt-BR.md`, linked after English. New examples should show English
aliases first; the API reference must include Portuguese equivalents.

Document implemented behavior only. Keep defaults, value mappings, examples,
compatibility notes, and limits synchronized with the public API. Use
namespaced imports to avoid collisions with Typst built-ins.

## Distribution and local copies

The package is not published on Typst Universe. A runtime copy needs `lib.typ`,
the complete `src` folder, and `LICENSE`. Include the manifest and documentation when
useful. Avoid absolute imports back into a development folder.

Keep project-specific scripts, folder names, personal metadata, and working
notes outside this repository. Examples must use synthetic material written
for demonstration. Check both PDF contents and metadata before publishing.

The project uses the MIT License. Keep the license file and copyright notice
when redistributing the package. The manifest's SPDX identifier is `MIT`.
