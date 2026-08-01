# PhD Thesis (Typst)

Modular Typst thesis template, ported from the LaTeX template in `latex_temp/`
(kept as reference only).

## Build

```sh
typst compile main.typ        # one-shot build → main.pdf
typst watch main.typ          # rebuild on save
```

## Layout

| Path | Purpose |
|---|---|
| `main.typ` | Metadata + assembles the document — the file you compile |
| `template/thesis.typ` | Style: B5 pages, fonts, headings, headers/footers |
| `template/prelude.typ` | The one import every chapter file starts with |
| `template/macros.typ` | Abbreviations (`#ie`, `#eg`) and symbols (`#tick`) |
| `template/todos.typ` | Draft margin notes (`#should[...]`, `#feedback[...]`) |
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
  `#import "../template/prelude.typ": *` and a `= Chapter Title` heading,
  then add `#include "chapters/06_name.typ"` in `main.typ`.
- **Add a glossary entry**: edit `frontback/glossary.typ`, use `#gls("key")`.
- **Index a term**: `#index("term")` next to the term.
- **Todo notes**: `#should[...]` (must), `#could[...]`, `#would[...]`,
  `#may[...]`, `#feedback[...]`, `#at-prof[...]`.
