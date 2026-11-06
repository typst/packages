# ab-annotate

Annotated bibliographies for Typst. Each entry renders as **citation → abstract → user annotation**, all pulled from standard BibLaTeX fields in a `.bib` file.

- `abstract` — journal abstract (often present in Zotero exports)
- `annotation` — your own notes on the source (with `annote` accepted as a fallback)

Both fields are optional per entry. Entries without either render as normal citations.

## Usage

```typst
#import "@preview/ab-annotate:0.1.0": annotated-bib

#set page(paper: "us-letter", margin: 1in)

= Annotated Bibliography

#annotated-bib(
  read("references.bib", encoding: none),
  title: none,
  style: "apa",
)
```

> **Why `read(..., encoding: none)`?** Typst resolves file paths relative to the file that syntactically contains the `read()` call. Because this function lives inside the package, it can't open your `.bib` directly — you pass in the bytes yourself, and the package handles the rest.

## BibTeX entry format

```bibtex
@article{smith2024,
  author     = {Smith, Jane},
  title      = {Rural Election Administration Challenges},
  journal    = {Journal of Elections and Public Opinion},
  year       = {2024},
  abstract   = {This paper examines the unique challenges...},
  annotation = {Key paper for the adaptive informality framework.
                Smith's typology maps well onto the Delta cases.}
}
```

## Parameters

```typst
#annotated-bib(
  read("references.bib", encoding: none),
  title: "Annotated Bibliography",   // or `none` to suppress
  style: "apa",                       // any CSL style Typst ships with
  show-abstract: true,
  show-annotation: true,
  show-labels: true,
  abstract-label: "Abstract",
  annotation-label: "Annotation",
  indent: 1.5em,
  block-spacing: 0.5em,
  entry-spacing: 1.2em,
)
```

## How it works

Typst's `bibliography()` function renders as a monolithic block with no per-entry hooks, so `ab-annotate`:

1. Parses the `.bib` file itself to collect `abstract` / `annotation` fields per key.
2. Declares `bibliography()` to register citation keys, but suppresses its grouped output with `show bibliography: _ => none`.
3. Walks the entries in `.bib` order and renders each one with `cite(key, form: "full")` — pulling the CSL-styled reference — followed immediately by its abstract/annotation block (with a colored left border for visual grouping).

The result is a true annotated bibliography: each citation is followed by its own notes, rather than annotations appearing as a separate grouped section.

### Caveat on entry order

Because entries are emitted in the order they appear in the `.bib` file, ordering follows your source file rather than the CSL style's sort order. For author-year styles (APA, APSA, Chicago), sort your `.bib` alphabetically by first-author surname if order matters.

## Cross-format companion

This package is part of a cross-format toolchain that also provides:

- a **biblatex `.sty`** package for LaTeX
- a **Lua filter / Quarto extension** for Quarto (PDF, HTML, Typst, Word)

All three read the same `.bib` fields. See [github.com/cwimpy/ab-annotate](https://github.com/cwimpy/ab-annotate) for the LaTeX and Quarto implementations.

## License

MIT
