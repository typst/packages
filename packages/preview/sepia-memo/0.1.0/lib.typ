// SPDX-License-Identifier: CC-BY-SA-4.0
// Copyright (c) 2026 Chen Gao and the vintage-latex repository contributors.
// Adapted from Foadsf/vintage-latex, example 01, with the optional math-font
// pairing from example 15. Source revision and changes are recorded in NOTICE.
// https://github.com/Foadsf/vintage-latex

// The three-part rule follows example 01's thin/thick/thin proportions.
#let printer-rule(ink: rgb("#231F1A")) = align(center, block(
  above: 0.7em,
  below: 0.7em,
  grid(
    columns: (19%, 7.5%, 19%),
    column-gutter: 0.45em,
    align: horizon,
    line(length: 100%, stroke: 0.35pt + ink),
    line(length: 100%, stroke: 1.05pt + ink),
    line(length: 100%, stroke: 0.35pt + ink),
  ),
))

// Pair one short paragraph with a right-margin note. Reserving the height of
// both cells prevents adjacent notes from overlapping. Keep this block short:
// it stays together on one page and assumes the memo's 38 mm right margin.
#let memo-note(note, body) = block(
  width: 100% + 30mm,
  breakable: false,
  above: 0.65em,
  below: 0.65em,
  grid(
    columns: (1fr, 24mm),
    column-gutter: 6mm,
    body,
    {
      set par(justify: false, first-line-indent: 0pt, leading: 0.5em)
      text(size: 8.5pt, note)
    },
  ),
)

/// Cream-paper research memo. The defaults use only Typst's embedded fonts.
#let memo(
  title: [Untitled memo],
  subtitle: none,
  author: "",
  date: none,
  paper: "a4",
  font: "Libertinus Serif",
  math-font: "New Computer Modern Math",
  paper-color: rgb("#F4EBDD"),
  ink: rgb("#231F1A"),
  body,
) = {
  set document(title: title, author: author)
  set page(
    paper,
    margin: (top: 25mm, bottom: 26mm, left: 27mm, right: 38mm),
    fill: paper-color,
    numbering: "1",
    number-align: center,
  )
  set text(
    font: font,
    size: 11pt,
    fill: ink,
    lang: "en",
    number-type: "lining",
    number-width: "proportional",
    historical-ligatures: false,
    discretionary-ligatures: false,
  )
  set par(justify: true, leading: 0.6em, first-line-indent: 1em)
  set heading(numbering: none)
  show heading: set block(above: 1.25em, below: 0.6em)
  show heading.where(level: 1): set text(
    size: 11pt, weight: "regular", tracking: 0.055em, features: ("smcp",),
  )
  show heading.where(level: 2): set text(
    size: 11pt, weight: "regular", style: "italic",
  )
  show math.equation: set text(font: math-font)
  show table: set text(size: 10pt, number-type: "lining", number-width: "tabular")
  set table(stroke: none, inset: (x: 7pt, y: 5pt))
  show figure.where(kind: table): set block(breakable: true)
  show raw: set text(font: "DejaVu Sans Mono", size: 0.82em)
  show footnote.entry: set text(size: 8.5pt)

  align(center, {
    set par(first-line-indent: 0pt, justify: false)
    text(size: 9pt, tracking: 0.1em, smallcaps[Research memorandum])
    v(0.75em)
    text(size: 19pt, tracking: 0.025em, smallcaps(title))
    if subtitle != none {
      v(0.55em)
      text(size: 10.5pt, style: "italic", subtitle)
    }
    printer-rule(ink: ink)
    let byline = ()
    if author != "" { byline.push(text(size: 9.5pt, author)) }
    if date != none { byline.push(text(size: 9.5pt, date)) }
    byline.join(h(0.8em) + text("·") + h(0.8em))
  })
  v(1em)
  body
}
