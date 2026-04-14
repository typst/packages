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

Typst's `bibliography()` function renders as a monolithic block with no per-entry hooks. `ab-annotate` parses the `.bib` file itself, renders the native `bibliography()` with the chosen CSL style, and then appends styled abstract/annotation blocks for each entry that has them — keyed by citation key, with a colored left border for visual grouping.

### Limitation

Because Typst's bibliography API doesn't yet allow per-entry injection, annotations appear as a grouped section *after* the bibliography rather than interleaved with each entry. When [typst/typst#942](https://github.com/typst/typst/issues/942) lands, `ab-annotate` will switch to true interleaved rendering.

## Cross-format companion

This package is part of a cross-format toolchain that also provides:

- a **biblatex `.sty`** package for LaTeX
- a **Lua filter / Quarto extension** for Quarto (PDF, HTML, Typst, Word)

All three read the same `.bib` fields. See [github.com/cwimpy/ab-annotate](https://github.com/cwimpy/ab-annotate) for the LaTeX and Quarto implementations.

## License

MIT
