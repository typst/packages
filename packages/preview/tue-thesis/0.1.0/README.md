# tue-thesis

A modular Typst thesis template in the TU/e house style: B5 pages, chapter
openings with an oversized numeral, running headers, per-chapter figure and
equation numbering, and a draft mode with margin todos.

## Getting started

```sh
typst init @preview/tue-thesis:0.1.0
cd tue-thesis
typst watch main.typ
```

The styling lives in the package; your project only holds content. Everything
starts from the `thesis.with(...)` block at the top of `main.typ`.

## `thesis`

```typst
#import "@preview/tue-thesis:0.1.0": thesis
#show: thesis.with(title: [My Thesis], author: "J. Smith")
```

| Argument | Default | Purpose |
|---|---|---|
| `title` | `[Thesis Title]` | Title page and document metadata |
| `author` | `"A. Author"` | Title page, colophon, PDF metadata |
| `degree` | `"Doctor of Philosophy"` | Degree named on the title page |
| `university` | `"University of Somewhere"` | Awarding institution |
| `faculty`, `department` | `none` | Optional title-page lines |
| `supervisors` | `()` | Array of names, joined on the title page |
| `location` | `none` | Printed alongside the date |
| `date` | `datetime.today()` | Title page and copyright year |
| `keywords` | `()` | PDF metadata |
| `version` | `"v0.1"` | Shown in the draft footer and colophon |
| `draft` | `true` | Widens the outside margin and reveals todo notes |
| `dedication`, `abstract` | `none` | Content for the front-matter pages |

Two more show rules split the document: `#show: appendix` switches heading
numbering to `A.1`, and `#show: backmatter` unnumbers what follows
(bibliography, glossary, index). Draft notes come from `todo`, `should`,
`could`, `would`, `may`, `feedback`, and `at-prof`, with `list-of-todos()`
collecting them onto a final page.

## Layout

| Path | Purpose |
|---|---|
| `main.typ` | Metadata + assembles the document — the file you compile |
| `prelude.typ` | The one import every chapter file starts with |
| `macros.typ` | Your abbreviations (`#ie`, `#eg`) and symbols (`#tick`) |
| `chapters/` | One file per chapter |
| `frontback/` | Dedication, abstract, summary, acknowledgments, CV, glossary |
| `figures/` | External images |
| `refs.bib` | Bibliography (BibTeX format) |

## Common tasks

- **Change metadata** (title, name, supervisors): edit the `thesis.with(...)`
  block at the top of `main.typ`.
- **Toggle draft mode**: `#let draft = true|false` in `main.typ`. Draft mode
  shows margin todos, a version/date footer, and a List of Todos page.
- **Add a chapter**: create `chapters/06_name.typ` starting with
  `#import "../prelude.typ": *` and a `= Chapter Title` heading, then add
  `#include "chapters/06_name.typ"` in `main.typ`.
- **Add a macro**: define it in `macros.typ`; `prelude.typ` re-exports it to
  every chapter.
- **Add a glossary entry**: edit `frontback/glossary.typ`, use `#gls("key")`.
- **Index a term**: `#index("term")` next to the term.
- **Todo notes**: `#should[...]` (must), `#could[...]`, `#would[...]`,
  `#may[...]`, `#feedback[...]`, `#at-prof[...]`.
