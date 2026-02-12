# texst

`TeXst` is a Typst package for LaTeX-like academic paper formatting.

## Start Here

Use one of these two paths:

1. Published package (Typst Universe):

```typst
#import "@preview/texst:0.1.0": paper
```

2. Local repository checkout (before/without publication):

```typst
#import "./src/lib.typ": paper
```

## Manual Install (No `@preview`)

If you download the repo manually, you can install it as a local Typst package:

1. Download and unzip this repository.
2. Copy its contents into this folder structure:
   - macOS: `~/Library/Application Support/typst/packages/local/texst/0.1.0/`
   - Linux: `~/.local/share/typst/packages/local/texst/0.1.0/`
   - Windows: `%APPDATA%\\typst\\packages\\local\\texst\\0.1.0\\`
3. Import from `@local` in your Typst file:

```typst
#import "@local/texst:0.1.0": paper
```

## Fastest Way to Use It

Copy this into your `main.typ`:

```typst
#import "@preview/texst:0.1.0": paper

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
typst init @preview/texst:0.1.0
```

This generates a starter project from `template/main.typ`.

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
- `caption_note(body)`
- `caption_with_note(title, note)`
- `table_note(body)`
- `theorem`, `proof`, `prop`, `lem`, `rem`, `asp`

## Style Overrides

Pass a `style` dictionary to override defaults:

```typst
#show: doc => paper(
  title: [Styled Paper],
  style: (
    body_font: "Libertinus Serif",
    page_margin: (x: 1in, y: 1in),
    heading_numbering: "1.",
    accent_main: rgb(20, 40, 120),
  ),
  doc,
)
```

Common keys include:
- `page_margin`, `page_numbering`
- `body_font`, `body_size`
- `paragraph_leading`, `paragraph_indent`
- `heading_numbering`, `heading_size`, `heading_weight`
- `footnote_numbering`, `accent_main`

## Local Development

- `examples/minimal.typ` is the local smoke test.
- `template/main.typ` is the package template entrypoint.
- Compile locally:

```bash
typst compile --root . examples/minimal.typ /tmp/minimal.pdf
```
