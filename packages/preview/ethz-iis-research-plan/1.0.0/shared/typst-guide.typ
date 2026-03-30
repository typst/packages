// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>
//
// Quick reference guide for Typst, aimed at LaTeX users.
// Included by default as the first appendix by the thesis template.
// To replace it with your own appendices, pass an appendices array:
//
//   #show: thesis.with(
//     appendices: (
//       include "/chapters/appendix.typ",
//     ),
//   )

#import "@preview/gentle-clues:1.3.1": code, info, tip

= Typst Quick Guide

Typst is a modern typesetting system designed as a faster, more ergonomic
alternative to LaTeX. This guide covers the most common tasks for writing a
thesis, with LaTeX equivalents shown alongside every Typst example.

#info[
  The full Typst documentation is available at
  #link("https://typst.app/docs"). The interactive web app at
  #link("https://typst.app") lets you experiment without any local installation.
]

== Document Structure

A thesis file using this template starts with:

#code[```typ
#import "@preview/ethz-iis-thesis:1.0.0": thesis, acr, acrpl
#import "/acronyms.typ": acronyms

#show: thesis.with(
  title: "My Thesis",
  author: "Jane Doe",
  // ... other parameters
)

= Introduction   // chapter
== Background    // section
=== Details      // subsection
```]

In LaTeX this corresponds to `\chapter{}`, `\section{}`, `\subsection{}`. There
is no preamble or `\begin{document}` — the template handles all of that.

== Text Formatting

#table(
  columns: (1fr, 1.4fr, 1.4fr),
  stroke: none,
  table.hline(stroke: 1.5pt),
  table.header([*Feature*], [*LaTeX*], [*Typst*]),
  table.hline(stroke: 0.75pt),
  [Bold],
  [#raw("\\textbf{text}")],
  [#raw("*text*") or #raw("#strong[text]")],
  [Italic],
  [#raw("\\textit{text}")],
  [#raw("_text_") or #raw("#emph[text]")],
  [Monospace],
  [#raw("\\texttt{text}")],
  [#raw("`text`")],
  [Superscript],
  [#raw("x\\textsuperscript{2}")],
  [#raw("x#super[2]")],
  [Subscript],
  [#raw("x\\textsubscript{i}")],
  [#raw("x#sub[i]")],
  [Forced linebreak],
  [#raw("\\\\")],
  [#raw("\\ ") (backslash + space)],
  [Non-breaking space],
  [`~`],
  [`~`],
  [Quotation marks],
  [#raw("``text''")],
  [#raw("\"text\"") (auto smart quotes)],
  [Hyperlink],
  [#raw("\\href{url}{label}")],
  [#raw("#link(\"url\")[label]")],
  table.hline(stroke: 1.5pt),
)

== Mathematics

Typst uses `$...$` for both inline and display math. Adding spaces _inside_
the delimiters switches to display (block) mode:

#table(
  columns: (1fr, 1.4fr, 1.4fr),
  stroke: none,
  table.hline(stroke: 1.5pt),
  table.header([*Feature*], [*LaTeX*], [*Typst*]),
  table.hline(stroke: 0.75pt),
  [Inline math],
  [#raw("$x^2$")],
  [#raw("$x^2$")],
  [Display math],
  [#raw("\\[ x^2 \\]")],
  [#raw("$ x^2 $") (spaces inside `$`)],
  [Fraction],
  [#raw("\\frac{a}{b}")],
  [#raw("$a/b$")],
  [Square root],
  [#raw("\\sqrt{x}")],
  [#raw("$sqrt(x)$")],
  [Sum / integral],
  [#raw("\\sum_{i=0}^{n}")],
  [#raw("$sum_(i=0)^n$")],
  [Greek letters],
  [#raw("\\alpha, \\beta")],
  [#raw("$alpha, beta$")],
  [Bold math],
  [#raw("\\mathbf{A}")],
  [#raw("$bold(A)$")],
  [Aligned equations],
  [#raw("\\begin{align}..\\end{align}")],
  [#raw("$ a &= b \\ c &= d $")],
  table.hline(stroke: 1.5pt),
)

#tip[
  Math function names in Typst have no backslash: `sin`, `cos`, `lim`, `max`,
  etc. See the #link("https://typst.app/docs/reference/symbols/sym/")[symbol
    reference] for the full list of available symbols.
]

== Figures

#code[```typ
#figure(
  image("figures/arch.svg", width: 80%),
  caption: [A descriptive caption.],
) <fig:arch>

// Reference it anywhere in the text:
As shown in @fig:arch ...
```]

Labels are placed with `<label>` directly after the closing `)` of `figure()`.
`@label` is the equivalent of `\autoref{}` — Typst automatically prefixes
"Figure", "Table", "Section", etc.

== Tables

Typst tables use `stroke: none` with `table.hline` for booktabs-style rules:

#code[```typ
#figure(
  table(
    columns: (auto, 1fr, 1fr),
    stroke: none,
    table.hline(stroke: 1.5pt),                // \toprule
    table.header([*Config*], [*Freq.*], [*Area*]),
    table.hline(stroke: 0.75pt),               // \midrule
    [Baseline], [500 MHz], [142 500 µm²],
    [Opt.],     [700 MHz], [164 900 µm²],
    table.hline(stroke: 1.5pt),                // \bottomrule
  ),
  caption: [Synthesis results.],
) <tab:results>
```]

Column widths accept `auto` (fit content), fixed lengths (`3cm`), or fractional
(`1fr`, `2fr`) to share available space proportionally.

== Labels and Cross-References

#code[```typ
= Introduction <chap:intro>     // label a heading
#figure(...) <fig:arch>         // label a figure

As shown in @fig:arch and discussed in @chap:intro ...
```]

== Bibliography and Citations

#code[```typ
#show: thesis.with(
  bibliography: bibliography("references.bib", style: "ieee", full: true),
)

As shown in @smith2023 ...      // equivalent to \cite{smith2023}
```]

The `.bib` format is identical to LaTeX. The bibliography is rendered
automatically at the end of the document.

== Lists

#code[```typ
// Unordered list (\begin{itemize})
- First item
- Second item
  - Nested item

// Ordered list (\begin{enumerate})
+ First item
+ Second item

// Term list (\begin{description})
/ Term: Definition of the term.
```]

== Including External Files

#code[```typ
// Render content from another file (\input equivalent):
include "/chapters/introduction.typ"

// Import bindings without rendering (for macros / dicts):
#import "/acronyms.typ": acronyms
```]

== Useful Packages

#table(
  columns: (auto, 1fr),
  stroke: none,
  table.hline(stroke: 1.5pt),
  table.header([*Package*], [*Purpose*]),
  table.hline(stroke: 0.75pt),
  [`@preview/cetz`], [Drawing and diagrams (TikZ equivalent)],
  [`@preview/acrostiche`],
  [Acronym management (#raw("\\newacronym") equivalent)],
  [`@preview/gentle-clues`], [Callout / admonition boxes],
  [`@preview/lovelace`], [Algorithm pseudocode],
  [`@preview/equate`], [Numbered sub-equations],
  table.hline(stroke: 1.5pt),
)

Packages are imported with a version-pinned line — Typst downloads them
automatically on first use, no manual installation needed:

#code[```typ
#import "@preview/cetz:0.4.2": canvas, draw
```]

Browse the full package registry at #link("https://typst.app/universe").

== Appendices

This guide is included as the default appendix. Once you add your own
`appendices` parameter, the guide is replaced by your content. Each entry is a
content block whose first line should be a level-1 heading:

#code[```typ
#show: thesis.with(
  appendices: (
    include "/chapters/appendix.typ",
  ),
)
```]

To include this guide alongside your own appendices, import `typst-guide` from
the package and add it to the array:

#code[```typ
#import "@preview/ethz-iis-thesis:1.0.0": thesis, acr, acrpl, typst-guide

#show: thesis.with(
  appendices: (
    include "/chapters/appendix.typ",
    typst-guide,
  ),
)
```]

To omit all appendices, pass an empty array:

#code[```typc
appendices: (),
```]
