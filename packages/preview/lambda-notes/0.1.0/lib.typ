#import "@preview/algorithmic:1.0.7": *
#import "@preview/algorithmic:1.0.7": algorithm-figure as base-algorithm-figure, style-algorithm as base-style-algorithm
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

// --- "note" component ---
#let note(body) = block(
  breakable: false,
  stroke: (
    left: 2pt + rgb("000000"),
    rest: 0.5pt,
  ),
  radius: 2pt,
  inset: (x: 14pt, y: 10pt),
  body,
)

// --- "callout" component ---
#let callout(
  title: none,
  color: blue,
  body,
) = block(
  breakable: false,
  fill: color.lighten(90%),
  stroke: (
    left: 3pt + color,
    rest: 1pt + color.lighten(60%),
  ),
  radius: 5pt,
  inset: 12pt,
  width: 100%,
)[
  #if title != none [
    #text(weight: "bold", fill: color)[#title]
    #v(0.5em)
  ]
  #body
]

// --- Algorithm Style ---
#let algorithm-figure = base-algorithm-figure.with(
  vstroke: .5pt + luma(200),
  inset: 0.3em,
  line-numbers-format: x => [#x],
)
#let style-algorithm = base-style-algorithm.with(
  hlines: (grid.hline(stroke: 1pt), grid.hline(stroke: 1pt), grid.hline(stroke: 1pt)),
)

// ============================================================
// --- lambda-notes: template declaration ---
// ============================================================
#let lambda-notes(
  title: none,
  author: none,
  date: none,
  subject: none,
  keywords: (),
  color: none,
  show-outline: true,
  outline-title: [Contents],
  chapter-label: [Chapter],
  body,
) = {
  set document(
    title: title,
    author: if type(author) == str or type(author) == array { author } else { () },
    description: subject,
    keywords: keywords,
  )

  // Header with h1 — kept local, only lambda-notes needs it
  let running-header() = context {
    let elems = query(
      heading.where(level: 1).or(heading.where(level: 2)).before(here()),
    )
    let h1 = none
    let h2 = none
    for e in elems {
      if e.level == 1 {
        h1 = e
        h2 = none
      } else if e.level == 2 {
        h2 = e
      }
    }
    let show-header = h1 != none and h1.location().page() != here().page()
    if show-header {
      set text(size: 9pt, fill: luma(100), weight: "regular")
      grid(
        columns: (1fr, 1fr),
        align(left)[#emph(h1.body)], align(right)[#if h2 != none { emph(h2.body) }],
      )
      v(-0.6em)
      line(length: 100%, stroke: 0.4pt + luma(180))
    }
  }

  // Dynamic color (if provided)
  let theme-color = if color == none { black } else { color }
  set page(
    numbering: "1",
    number-align: right,
  )
  set heading(numbering: "1.")
  // Heading 1 break
  show heading.where(level: 1): it => {
    if it.outlined {
      pagebreak(weak: true)
      v(1.5em)
      block(breakable: false)[
        #text(size: 11pt, fill: theme-color, tracking: 2pt, weight: "bold")[
          #context {
            let num = counter(heading).at(it.location()).first()
            if (num > 0) { upper[#chapter-label #num] }
          }
        ]
        #v(0.4em)
        #text(size: 25pt, weight: "bold", fill: theme-color.darken(10%))[#it.body]
        #line(length: 100%, stroke: theme-color)
      ]
      v(1em)
    } else {
      it
    }
  }
  // Heading spacing + dynamic color
  show heading: it => {
    v(1em)
    text(fill: theme-color, it)
    v(0.5em)
  }
  // Link color (theme, with internal cross-references in a distinct color)
  show link: it => {
    let label-color = rgb("#57B94F")
    if type(it.dest) == label {
      underline(text(fill: label-color, it))
    } else {
      underline(text(fill: theme-color, it))
    }
  }
  // Table style
  show table: it => {
    v(1em)
    block(breakable: false, it)
  }
  set table(
    fill: (x, y) => if y == 0 { theme-color.lighten(85%) } else if calc.even(y) { rgb("f9f9f9") } else { white },
    stroke: 0.5pt + rgb("b0b0b0"),
    align: (x, y) => if x == 0 { left + horizon } else { center + horizon },
    inset: 8pt,
  )

  set figure(numbering: "1")
  show: codly-init.with()
  codly(
    number-format: none,
    display-name: false,
    languages: codly-languages,
  )
  show: style-algorithm
  // Title block — matches the theme-color + rule + tracked-meta language used by headings
  align(center)[
    #v(2em)
    #text(size: 26pt, weight: "bold", fill: theme-color.darken(10%))[#title]
    #v(0.6em)
    #line(length: 30%, stroke: 1pt + theme-color)
    #v(0.6em)
    #text(size: 10.5pt, fill: luma(100), tracking: 1.5pt)[#author #sym.dot.c #date]
    #v(2.5em)
  ]

  // Code snippets
  show raw.where(block: true): it => block(
    fill: rgb("#f4f4f4"),
    inset: 8pt,
    radius: 4pt,
    width: 100%,
    text(size: 9pt, font: "DejaVu Sans Mono", it),
  )
  show raw.where(block: false): it => box(
    fill: rgb("#f0f0f0"),
    inset: (x: 4pt, y: 2pt),
    radius: 2pt,
    text(font: "DejaVu Sans Mono", size: 9.5pt, it),
  )

  set page(header: running-header())

  show outline.entry.where(level: 1): it => {
    v(0.6em)
    strong(it)
  }
  if show-outline {
    outline(title: outline-title)
  }
  body
}
