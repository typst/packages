// "My Index" — Typst template. Defines styles/helpers only; doesn't
// print anything itself. Usage in the actual document:
//
//   #import "template.typ": *
//   #show: index-doc.with(title: "My Index")
//   #toc()                          <- optional table of contents
//
//   = Home                          <- Area   (level 1)
//   == Finances                     <- Category (level 2)
//   === 11.01 Bank Statements       <- ID      (level 3)
//   #info[Monthly statements, PDF only]
//   #physloc[Filing cabinet, drawer 2]
//   #subid[11.01.01 — Checking account]
//   ==== Some note as its own line   <- looks like #info, no bullet
//
// Safe to tweak values below; don't rename anything left of `=`.

// ---- Knobs ----
// Toggle: prints "1", "1.1", "1.1.1", "1.1.1.1" in front of =, ==,
// ===, ==== headings (outline-style, each level nested under its
// parent). Off by default since Area/Category/ID headings already
// carry their own hand-typed numbers (like "11.01") — turning this
// on adds an extra outline number in front of those, it doesn't
// replace them. Uses Typst's real heading numbering under the hood,
// so #toc() automatically shows the same numbers, in sync, for free.
#let number-sections = true


#let idx-font = "Recursive Mn Csl St" // must match OS font name exactly
#let idx-heading-weight = "medium" // only Medium is installed for now
#let idx-body-weight = "medium"

#let size-area = 12pt      // Area (level 1)
#let size-category = 11pt  // Category (level 2)
#let size-id = 10pt        // ID (level 3)
#let size-note = 8pt       // info/physloc/subid/level-4 headings

#let indent-category = 0.5in
#let indent-id = 0.75in
#let indent-note = 1in

#let area-color = rgb("#660000")
#let category-color = rgb("#879D89")
#let id-color = rgb("#546E87")
#let physloc-color = rgb("#EE0000")
#let page-bg = rgb("#f4ecd8")

#let link-color = rgb("#546E87")
#let table-header-fill = rgb("#e4d9bd")
#let table-stripe-fill = rgb("#faf6ec")
#let table-line-color = area-color.lighten(40%)
#let quote-bar-color = category-color
#let code-bg = rgb("#eee6d3")
#let code-header-fill = code-bg.darken(8%)
#let code-font = "DejaVu Sans Mono"
#let code-line-numbers = true
#let code-line-number-color = id-color.lighten(35%)



// ---- Document wrapper ----
#let doc(title: "My Index", body) = {
  set page(paper: "us-letter", margin: 1in, numbering: "1", number-align: center, fill: page-bg)
  set text(font: idx-font, size: 12pt, weight: idx-body-weight, lang: "en")
  set par(justify: false, leading: 0.68em)
  set heading(numbering: if number-sections { "1.1.1.1" } else { none })

  // Area (level 1)
  show heading.where(level: 1): it => block(above: 1.7em, below: 0.7em)[
    #if it.numbering != none [
      #context text(fill: area-color, size: size-area, weight: idx-heading-weight)[
        #counter(heading).display(it.numbering) ~ #it.body
      ]
    ] else [
      #text(fill: area-color, size: size-area, weight: idx-heading-weight, it.body)
    ]
  ]

  // Category (level 2)
  show heading.where(level: 2): it => pad(left: indent-category)[
    #block(above: 1.1em, below: 0.35em)[
      #if it.numbering != none [
        #context text(fill: category-color, size: size-category, weight: idx-heading-weight)[
          #counter(heading).display(it.numbering) ~ #it.body
        ]
      ] else [
        #text(fill: category-color, size: size-category, weight: idx-heading-weight, it.body)
      ]
    ]
  ]

  // ID (level 3)
  show heading.where(level: 3): it => pad(left: indent-id)[
    #block(above: 0.55em, below: 0.15em)[
      #if it.numbering != none [
        #context text(fill: id-color, size: size-id, weight: idx-heading-weight)[
          #counter(heading).display(it.numbering) ~ #it.body
        ]
      ] else [
        #text(fill: id-color, size: size-id, weight: idx-heading-weight, it.body)
      ]
    ]
  ]

  // Generic line (level 4): styled like #info (plain black, note
  // size/weight, same indent) but with no bullet, so it reads as a
  // one-off heading rather than a bulleted note.
  show heading.where(level: 4): it => block(above: 1em, below: 0.4em)[
    #pad(left: indent-note)[
      #if it.numbering != none [
        #context text(font: idx-font, size: size-note, weight: idx-body-weight)[
          #counter(heading).display(it.numbering) ~ #it.body
        ]
      ] else [
        #text(font: idx-font, size: size-note, weight: idx-body-weight, it.body)
      ]
    ]
  ]

  // Lists
  set list(indent: 0.25in, spacing: 0.6em, marker: ([•], [◦], [‣]))
  set enum(indent: 0.25in, spacing: 0.6em, numbering: "1.a.i.")

  // Tables: header row shaded, body rows striped
  set table(
    stroke: 0.5pt + table-line-color,
    inset: 6pt,
    fill: (x, y) => if y == 0 { table-header-fill } else if calc.odd(y) { table-stripe-fill } else { none },
  )
  show table.cell.where(y: 0): set text(weight: "bold")

  // Code blocks: shaded box, language label, optional line numbers
  show raw: set text(font: code-font, size: 9pt)
  show raw.where(block: true): it => block(
    fill: code-bg,
    radius: 4pt,
    width: 100%,
    clip: true,
  )[
    #if it.lang != none [
      #block(width: 100%, inset: (x: 10pt, top: 6pt, bottom: 6pt), fill: code-header-fill)[
        #text(size: 8pt, fill: id-color, weight: "bold", tracking: 0.5pt, upper(it.lang))
      ]
    ]
    #block(inset: 10pt, width: 100%)[
      #if code-line-numbers [
        #grid(
          columns: (auto, 1fr),
          column-gutter: 10pt,
          row-gutter: 0pt,
          ..it.lines.map(line => (
            box(height: 1.4em, text(fill: code-line-number-color, str(line.number))),
            box(height: 1.4em, line.body),
          )).flatten()
        )
      ] else [
        #it
      ]
    ]
  ]

  // Blockquotes
  show quote.where(block: true): it => block(
    inset: (left: 1em),
    stroke: (left: 2pt + quote-bar-color),
  )[
    #set text(style: "italic")
    #it.body
  ]

  // Links
  show link: it => text(fill: link-color, underline(it))

  // Figure captions
  show figure.caption: it => text(fill: id-color, size: size-note, style: "italic", it)

  // Title block
  align(center)[
    #text(fill: area-color, size: 22pt, weight: "bold", title)
  ]
  v(0.5em)
  line(length: 100%, stroke: 0.5pt + area-color.lighten(30%))
  v(1em)

  body
}

// ---- Table of contents ----
// Call #toc() once, right after #show: index-doc.with(...), if you
// want a listing page. Its own "Table of Contents" heading is never
// numbered and never lists itself — only the real headings below it
// show up, with the same numbers as in the body (or no numbers, if
// number-sections is off).
#let toc() = {
  align(center)[  #text(fill: area-color, size: 18pt, weight: idx-heading-weight)[Table of Contents]]
  show outline.entry.where(level: 1): it => text(fill: area-color.lighten(25%).desaturate(50%), it)
  show outline.entry.where(level: 2): it => text(fill: category-color.lighten(25%).desaturate(50%), it)
  show outline.entry.where(level: 3): it => text(fill: id-color.lighten(25%).desaturate(50%), it)
  outline(title: none, indent: auto)
  pagebreak()
}

// ---- Leaf notes (info / physloc / subid) ----
#let note(body, fill: black, weight: idx-body-weight, style: "normal") = pad(left: indent-note)[
  #set text(font: idx-font, size: size-note, fill: fill, weight: weight, style: style)
  #box[•~#body]
]

#let info(body) = note(body)
#let physloc(body) = note(body, fill: physloc-color, weight: "bold", style: "italic")
#let subid(body) = note(body)

// ---- General prose-page helpers ----
#let callout(body, fill: table-header-fill) = block(
  fill: fill,
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  body,
)

#let blockquote(body) = quote(block: true, body)

#let divider() = line(
  length: 100%,
  stroke: 1.25pt + rgb("#660000").transparentize(25%),
)
