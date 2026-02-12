# texst

`TeXst` is a Typst package for LaTeX-like academic paper formatting.

## Start Here

```typst
#import "@preview/texst:0.1.1": paper
```

or use all the helpers:

```typst
#import "@preview/texst:0.1.1": paper, nneq, caption-note, table-note, theorem, proof, prop, lem, rem, asp, cmain, csub, caption-with-note
```

## Fastest Way to Use It

Copy this into your `main.typ`:

```typst
#import "@preview/texst:0.1.1": paper, nneq, caption-note, table-note, theorem, proof, prop, lem, rem, asp, cmain, csub, caption-with-note

#show: doc => paper(
  title: [Paper Title],
  subtitle: [Optional Subtitle],
  authors: (
    (name: [Author One]),
    (name: [Author Two]),
  ),
  date: datetime.today().display("[month repr:long] [day], [year]"),
  abstract: [Write a concise abstract here.],
  doc,
)

#outline(title: [Contents])

#heading(level: 1)[Introduction]

Start writing your paper.

#heading(level: 1)[Appendix]

#heading(level: 2)[Additional Material]

Add supplementary details here.
```

## Initialize a Template Project

```bash
typst init @preview/texst:0.1.1
```

This generates a starter project from `template/main.typ`.

## Migrate an Existing Typst File

If you already have a Typst document, use an LLM coding agent to adapt it to `texst` instead of rewriting by hand.

Suggested workflow:

1. Keep your existing content sections as-is.
2. Replace your current page/layout/title setup with `paper(...)`.
3. Keep custom macros only if they do not overlap with `texst` helpers.
4. Re-run compile and fix any remaining import/name conflicts.

Example prompt for an LLM agent:

```text
Migrate this Typst file to use the texst package.

Requirements:
- Use: #import "@preview/texst:0.1.1": paper
- Wrap document with:
  #show: doc => paper(
    title: [...],
    subtitle: [...],
    authors: (...),
    date: ...,
    abstract: [...],
    doc,
  )
- Preserve all existing section content and citations.
- Remove or refactor conflicting layout/title macros.
- Return a complete updated .typ file.
```

## What `paper(...)` Does

`paper(...)` applies:
- page layout and numbering
- typography defaults
- heading style and spacing
- table/figure alignment and numbering
- equation and reference behavior
- title block and abstract formatting

Your document content is passed through `doc`.

## Public API

- `paper(title:, subtitle:, authors:, date:, abstract:, style:, doc)`
- `nneq(eq)` (unnumbered display equation)
- `caption-note(body)`
- `caption-with-note(title, note)`
- `table-note(body)`
- `cmain(body, color:)`, `csub(body, color:)`
- `theorem`, `proof`, `prop`, `lem`, `rem`, `asp`

## Style Overrides

Pass a `style` dictionary to override defaults:

```typst
#show: doc => paper(
  title: [Styled Paper],
  style: (
    body_font: "Libertinus Serif",
    font_size: 11pt,
    line_spacing: 1.05em,
    page_margin: (x: 1in, y: 1in),
    heading_numbering: "1.",
    cmain_color: rgb(20, 40, 120),
    csub_color: rgb(70, 90, 130),
    accent_link: rgb(20, 40, 120),
    accent_ref: rgb(20, 40, 120),
    accent_cite: rgb(20, 40, 120),
    accent_footnote: rgb(20, 40, 120),
  ),
  doc,
)
```

Common keys include:
- `page_margin`, `page_numbering`
- `body_font`, `body_size`, `font_size`, `body_color`
- `paragraph_leading`, `line_spacing`, `paragraph_indent`
- `heading_numbering`, `heading_size`, `heading_weight`, `heading_color`
- `title_size`, `subtitle_size`, `title_leading`, `abstract_size`, `abstract_leading`
- `cmain_color`, `csub_color`
- `accent_main` (legacy global accent fallback)
- `accent_link`, `accent_ref`, `accent_cite`, `accent_footnote`

## Local Development

- `examples/minimal.typ` is the local smoke test.
- `template/main.typ` is the package template entrypoint.
- Compile locally:

```bash
typst compile --root . examples/minimal.typ /tmp/minimal.pdf
```
