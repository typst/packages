// SPDX-License-Identifier: CC-BY-SA-4.0
// Copyright (c) 2026 Chen Gao and the vintage-latex repository contributors.
// Adapted from Foadsf/vintage-latex, example 01, with the optional math-font
// pairing from example 15. Source revision and changes are recorded in NOTICE.
// https://github.com/Foadsf/vintage-latex

// The three-part rule follows example 01's thin/thick/thin proportions.
#let printer-rule(ink: rgb("#231F1A")) = align(center, block(
  above: 1.15em,
  below: 1.15em,
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
      text(size: 10pt, note)
    },
  ),
)

#let _paper-inset = 10pt

// Markers locate each fragment while the block keeps native pagination.
#let _paper-background() = context {
  let noise(n) = {
    let x = calc.sin(n * 12.9898rad) * 43758.5453
    x - calc.floor(x)
  }

  let torn-edge(length, seed) = {
    let count = calc.ceil(length / 4pt)
    range(count + 1).map(i => {
      let x = i / count * length
      let depth = (2.3 + 1.2 * calc.sin(x / 1pt * 0.073rad + seed * 1rad)
        + 0.7 * calc.sin(x / 1pt * 0.21rad) + 1.8 * noise(i + seed))
      if noise(i + seed + 61) > 0.975 { depth += 2 }
      (x, depth * 1pt)
    }).filter(p => 6pt <= p.at(0) and p.at(0) <= length - 6pt)
  }

  let paper-outline(width, height, seed) = (
    torn-edge(width, seed)
    + torn-edge(height, seed + 17).map(p => (width - p.at(1), p.at(0)))
    + torn-edge(width, seed + 39).rev().map(p => (p.at(0), height - p.at(1)))
    + torn-edge(height, seed + 53).rev().map(p => (p.at(1), p.at(0)))
  )

  let current = here().page()
  let margin = page.margin
  let margin-top = if type(margin) == dictionary { margin.top } else { margin }
  let margin-bottom = if type(margin) == dictionary { margin.bottom } else { margin }
  let ends = query(<sepia-paper-end>)
  for (index, start) in query(<sepia-paper-start>).enumerate() {
    let first = start.location().position()
    let end = ends.find(it => it.value == start.value.id)
    if end == none { continue }
    let last = end.location().position()
    if not (first.page <= current and current <= last.page) { continue }
    let upper = if current == first.page { first.y - _paper-inset }
      else { margin-top }
    let lower = if current == last.page { last.y + _paper-inset }
      else { page.height - margin-bottom }
    let x = first.x - _paper-inset
    let width = start.value.width + 2 * _paper-inset
    let height = lower - upper
    if height <= 0pt { continue }
    let seed = index * 43 + current * 11
    let shape = polygon.with(..paper-outline(width, height, seed), stroke: none)
    // The shadow follows the torn outline.
    place(top + left, dx: x + 1.2pt, dy: upper + 1.7pt,
      shape(fill: rgb("#65594C").transparentize(86%)))
    place(top + left, dx: x + 0.5pt, dy: upper + 0.7pt,
      shape(fill: rgb("#65594C").transparentize(91%)))
    place(top + left, dx: x, dy: upper, shape(fill: gradient.linear(
      rgb("#ECE5DA"), rgb("#E5DACB"), angle: 100deg,
    )))
    if current == first.page {
      place(top + left, dx: x + width * (0.06 + 0.22 * noise(seed + 3)),
        dy: upper - 2.5pt + 1.5pt * noise(seed + 7),
        rotate((-15 + 28 * noise(seed + 9)) * 1deg, polygon(
          (0pt, 1pt), (13pt, 0pt), (33pt, 0.8pt), (32pt, 9pt),
          (19pt, 8.5pt), (0.8pt, 9.5pt),
          fill: rgb("#9B8C72").transparentize(78%), stroke: none,
        )))
      place(top + left, dx: x + width * (0.68 + 0.20 * noise(seed + 5)),
        dy: upper - 1.5pt + 1.5pt * noise(seed + 11),
        rotate((-12 + 27 * noise(seed + 13)) * 1deg, polygon(
          (0pt, 0.5pt), (29pt, 0pt), (29.8pt, 8pt),
          (16pt, 9pt), (0.5pt, 8.5pt),
          fill: rgb("#9B8C72").transparentize(83%), stroke: none,
        )))
    }
  }
}

/// A torn-paper emphasis block; use at the top level inside memo.
#let memo-inset(body, title: none) = layout(size => context {
  let id = here()
  block(width: 100%, inset: _paper-inset, breakable: true)[
    #set par(first-line-indent: 0pt)
    #block(width: 100%, sticky: true, above: 0pt, below: 0.35em)[
      #block(height: 0pt, above: 0pt, below: 0pt)[
        #metadata((id: id, width: size.width - 2 * _paper-inset)) <sepia-paper-start>
      ]
      #if title != none {
        text(size: 10.5pt, tracking: 0.06em, smallcaps(title))
      }
    ]
    #body
    #block(height: 0pt, above: 0pt, below: 0pt)[
      #metadata(id) <sepia-paper-end>
    ]
  ]
})

/// Cream-paper research memo. Install EB Garamond and Garamond-Math for the defaults.
#let memo(
  title: [Untitled memo],
  subtitle: none,
  author: "",
  date: none,
  paper: "a4",
  font: "EB Garamond",
  math-font: "Garamond-Math",
  paper-color: rgb("#F4EBDD"),
  ink: rgb("#231F1A"),
  body,
) = {
  set document(title: title, author: author)
  set page(
    paper,
    margin: (top: 25mm, bottom: 26mm, left: 27mm, right: 38mm),
    fill: paper-color,
    background: _paper-background(),
    numbering: "1",
    number-align: center,
  )
  set text(
    font: font,
    size: 13pt,
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
  show heading: set text(weight: "bold", style: "normal")
  show heading.where(level: 1): set text(
    size: 19pt,
    weight: "regular",
    tracking: 0.04em,
    features: ("smcp",),
  )
  show heading.where(level: 2): set text(
    size: 17pt,
    weight: "regular",
    style: "italic",
  )
  show heading.where(level: 3): set text(size: 14pt)
  show math.equation: set text(font: math-font)
  show table: set text(size: 11.5pt, number-type: "lining", number-width: "tabular")
  set table(stroke: none, inset: (x: 7pt, y: 5pt))
  show figure.where(kind: table): set block(breakable: true)
  show raw: set text(font: "DejaVu Sans Mono", size: 0.82em)
  show footnote.entry: set text(size: 10pt)

  align(center, {
    set par(first-line-indent: 0pt, justify: false)
    text(size: 10pt, tracking: 0.1em, smallcaps[Research memorandum])
    v(0.75em)
    text(size: 28pt, tracking: 0.025em, smallcaps(title))
    if subtitle != none {
      v(0.55em)
      text(size: 12.5pt, style: "italic", subtitle)
    }
    printer-rule(ink: ink)
    let byline = ()
    if author != "" { byline.push(text(size: 11pt, author)) }
    if date != none { byline.push(text(size: 11pt, date)) }
    byline.join(h(0.8em) + text("·") + h(0.8em))
  })
  v(1em)
  body
}
