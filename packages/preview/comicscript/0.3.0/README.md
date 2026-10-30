# comicscript 0.3.0

English | [Português](README.pt-BR.md)

[Source repository](https://github.com/3sdras/comicscript)

A standalone Typst package for comic scripts. Write **pages → rows → panels**
once, then generate reading scripts, editorial drafts, page layouts, production
instructions, and reports from the same data.

All bundled scenes, characters, and editorial notes are synthetic demonstrations.

English and Portuguese commands share the same model. Existing Portuguese
documents remain compatible. The English API translates command options, not
the printed interface: PDF labels and validation messages remain in Portuguese.

Requires **Typst 0.14.1 or later**. No FerrMat or other package dependencies.
The Universe import below becomes available after the submission is accepted.
For a source checkout before publication, use the local import described below.

## Quick start

Save this as `main.typ`:

```typst
#import "@preview/comicscript:0.3.0" as hq

#set page(paper: "a4", margin: 20mm)
#set text(size: 11pt, lang: "en")

#let pages = (
  hq.page(
    1,
    title: [A workshop test],
    hq.row(
      hq.panel[A small robot starts its first test.],
      hq.panel(
        texts: (hq.speech("Alex")[Shall we?],),
      )[Alex watches the control panel.],
    ),
  ),
)

#hq.render(pages)
```

Compile with `typst compile main.typ main.pdf`.
For local development, place the file beside `lib.typ` and replace the import
with `#import "lib.typ" as hq`.
Use the `hq` namespace: `page` is also a built-in Typst function.
Keep the trailing comma in single-item arrays, such as `(item,)`.

## Views and reports

| English mode | Portuguese mode | Output |
| --- | --- | --- |
| `script` | `roteiro` | Descriptions, shots, composition, references, and texts |
| `editorial` | `editorial` | Script plus notes, objectives, statuses, IDs, and review warnings |
| `layout` | `esquema` | Fixed-size geometric panels using row and panel weights |
| `production` | `producao` | Script plus selected technical notes for the artist |

```typst
#hq.render(pages, mode: "editorial", note-statuses: ("open",))
#hq.render(pages, mode: "layout")
#hq.render(pages, mode: "production")

#hq.narrative-map(pages)
#hq.pending-notes(pages)
#hq.dialogues(pages, character: "Alex")
#hq.text-report(pages, word-limit: 60)
```

Each `render` call generates a full view. These calls are independent choices;
use one per document unless you intentionally want several outputs.

## English aliases

| English | Portuguese |
| --- | --- |
| `page`, `row`, `panel` | `pagina`, `linha`, `quadro` |
| `speech`, `caption`, `sound` | `fala`, `legenda`, `som` |
| `note`, `validate`, `render` | `nota`, `validar`, `renderizar` |
| `narrative-map`, `pending-notes` | `mapa-narrativo`, `pendencias` |
| `dialogues`, `text-report` | `dialogos`, `relatorio-textos` |

The aliases accept English parameter names, statuses, common note categories,
and common speech modes. See the [complete API reference](docs/api.md).

## Documentation and examples

- [User guide](docs/manual.md): authoring, views, notes, geometry, styling, and troubleshooting.
- [API reference](docs/api.md): signatures, defaults, aliases, and value mappings.
- [Example index](examples/README.md): Typst sources and compiled PDFs.
- [English example source](examples/example-english.typ) and [PDF](examples/english.pdf).
- [Development guide](docs/development.md): architecture, checks, and documentation policy.

After publication, run from the package directory:

```sh
typst compile --root . examples/example-english.typ examples/english.pdf
typst compile --root . examples/example-english.typ examples/english-layout.pdf --input mode=layout
typst compile --root . examples/example-english.typ examples/english-production.pdf --input mode=production
```

## Development checks and limits

These checks are run from the [source repository](https://github.com/3sdras/comicscript).
Tests are not part of the Universe distribution.

```sh
typst compile --root . tests/test-modelo.typ /tmp/hq-model.pdf
typst compile --root . tests/test-blocos.typ /tmp/hq-blocks.pdf
typst compile --root . tests/test-english.typ /tmp/hq-english.pdf
python3 tests/verificar.py
```

The layout view supports horizontal rows with variable-width panels. Panels
spanning multiple rows, thematic indexes, and structured data export are not
implemented. Word counts inspect static text rather than evaluating images,
formulas, or `context` content. Details are in the user guide.

Licensed under the [MIT License](LICENSE).
