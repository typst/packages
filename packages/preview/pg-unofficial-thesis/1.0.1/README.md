# pg-unofficial-thesis

Unofficial, community-built Typst template for diploma theses (bachelor's,
engineering, master's) at **Politechnika Gdańska**, in Polish or English. It is
not endorsed by the university. It follows the
[Regulamin procesu dyplomowania PG](https://cdn.files.pg.edu.pl/zie/Strona%20polska/Studenci/5.%20Regulaminy/Regulamin%20procesu%20dyplomowania_01.10.2026.pdf)
(2026), [Zarządzenie Rektora PG nr 53/2022](https://cdn.files.pg.edu.pl/wilis/Studenci/Dyplomy/ZR%2053-2022.pdf)
and the layout of the [official PG LaTeX template](https://git.pg.edu.pl/p1252239/latex_template_for_diploma).

## Start your thesis

```sh
typst init @preview/pg-unofficial-thesis:1.0.1 moja-praca
cd moja-praca
typst watch main.typ
```

In the [Typst web app](https://typst.app), choose **Start from template** and
search for `pg-unofficial-thesis`.

You get a ready project: `main.typ` holds the thesis data, `chapters/` the
text, and `bibliography.bib` the references. The sample chapters show figures,
tables, code, equations and citations; replace them with your own.

## Usage

```typst
#import "@preview/pg-unofficial-thesis:1.0.1": *

#show: thesis.with(
  kind: "engineering", // "bachelor", "engineering", "engineering-project" or "master"
  title-pl: [Tytuł pracy],
  title-en: [Thesis title],
  authors: ((name: "Jan Kowalski", album: "123456"),),
  supervisor: "dr inż. Jan Nowak",
  title-page: image("strona-tytulowa.pdf"), // from Moja PG
  abstract-pl: [...],
  keywords-pl: ("słowo", "kluczowe"),
  abstract-en: [...],
  keywords-en: ("key", "words"),
  abbreviations: (PG: [Politechnika Gdańska]),
  bibliography: bibliography("bibliography.bib"),
  appendices: include "appendix.typ",
)

= Wstęp i cel pracy
...
```

The template orders the parts as PG requires:
1. Title page.
2. Statement or blank page.
3. Streszczenie and Abstract.
4. Spis treści and Wykaz oznaczeń i skrótów.
5. Chapters.
6. Wykaz literatury, Wykaz rysunków and Wykaz tabel.
7. Dodatki.

It applies:
- A4 with mirrored margins: 2.5 cm, and 3.5 cm on the inner side.
- Arial 10 pt, justified, line spacing 1.5 lines.
- PG heading styles.
- Captions of the form `Rys. 1.1.` and `Tabela 1.1.`.
- Page numbers hidden on pages 1–2.
- Non-breaking spaces after one-letter words.
- A PN-ISO 690 numeric bibliography.

| Option | Default | |
|---|---|---|
| `lang` | `"pl"` | `"en"` for a thesis in English |
| `title-page` | `auto` | `image("….pdf")` from Moja PG; `auto` draws a draft look-alike |
| `statement` | `none` | `image("….pdf")` for page 2 |
| `oecd-pl`, `oecd-en` | `none` | OECD field of science |
| `faculty`, `field`, `specialization`, `consultant` | `none` | Shown on the draft title page |
| `list-of-figures`, `list-of-tables` | `auto` | Added when the thesis has figures/tables |
| `list-of-listings` | `false` | "Wykaz listingów" |
| `two-sided` | `true` | Mirrored margins for double-sided printing |
| `orphans` | `true` | Non-breaking spaces after *a, i, o, u, w, z* |
| `font` | `("Arial", "Liberation Sans")` | Liberation Sans has Arial's metrics |

Helpers:
- `#written-by[Jan Kowalski]` at the end of a heading names the author of that
  chapter in a team thesis.
- `#ang[term]` prints *(ang. term)*.

In Polish, `@label` prints only the number, so you can decline the noun:
`na rysunku @schemat`.

## Before you submit

- Use the title page from Moja PG: `title-page: image("….pdf")`.
- Streszczenie and Abstract: at least 300 words together, at most one page each.
- File name: `PDI_<nr albumu>.pdf` (engineering), `PDL_…` (bachelor) or
  `PDM_…` (master).

## Example

- [`docs/template.pdf`](docs/template.pdf): what `typst init` gives you.
- [`docs/example.pdf`](docs/example.pdf): the sample thesis from the official
  PG LaTeX template, ported to this template (source in `examples/pg-official`
  in the [repository](https://github.com/KanarekLife/pg-thesis-typst)).

## Development

```sh
make          # build template/ and the example into build/
make test     # compile the test documents
make check    # versions, builds and typst-package-check (needs podman or docker)
```

CI rebuilds the PDFs in `docs/` whenever the sources on `main` change.

To release, bump `version` in `typst.toml` and in every
`@preview/pg-unofficial-thesis:…` import, add an entry to `CHANGELOG.md`, and
push a `vX.Y.Z` tag. CI then creates the GitHub release and opens the pull
request to [typst/packages](https://github.com/typst/packages) (using the
`PACKAGES_TOKEN` secret; without it, run `make publish` locally).

## About

Written with [Claude](https://claude.com/claude-code) (Anthropic);
maintained by Stanisław Nieradko. If anything here disagrees with the
regulations linked above, the regulations win.

## License

[MIT-0](LICENSE): use, modify and share it, including the files `typst init`
copies into your project, without attribution.

`examples/pg-official` is not part of the published package. Its text comes
from the official PG LaTeX template by Magdalena Godlewska (LPPL 1.3c), and it
includes the PG logo.
