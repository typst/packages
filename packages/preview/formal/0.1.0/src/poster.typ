#import "/src/general.typ": accent-color, formal-general, ghost-color

#let formal-poster(
  paper: "a1",
  lang: "en",
  title: "Title",
  authors: "Authors",
  department: "Department",
  font-size: 18pt,
  font-family: "New Computer Modern",
  margin: 4cm,
  frame-thickness: 1.5cm,
  frame-outset: 0cm,
  footer: "Footer",
  conference: "Conference",
  dates: "2024",
  contacts: [],
  right-column: none,
  body,
) = {
  // Apply general style
  show: formal-general.with(
    frame-thickness: frame-thickness,
    frame-outset: frame-outset,
  )

  // Paper format
  let font-size-title = font-size * 2.5
  let font-size-authors = font-size * 2.0
  let font-size-department = font-size * 1.5

  set text(font: font-family, size: font-size, lang: lang)

  let footer = {
    set align(right)
    set text(fill: ghost-color)
    text(size: font-size-department, conference) + linebreak()
    text(size: font-size-department, dates)
  }

  set page(paper: paper, margin: margin, footer: footer, footer-descent: -frame-thickness / 2)

  // Style
  set list(marker: text(font: "Menlo", fill: accent-color)[➤])

  // Math
  set math.equation(numbering: "(1)")

  // Header

  {
    // Decrease line spacing for main header
    set par(leading: 0.4em)
    set align(center)

    // Authors, affiliation, ...
    grid(
      rows: 3,
      row-gutter: 1em,
      text(size: font-size-title, fill: accent-color, weight: "medium", title),
      // Empty line
      none,
      text(size: font-size-authors, authors),
      text(size: font-size-department, style: "italic", department),
      text(size: font-size-department, contacts),
    )
  }

  // Headings
  show heading.where(level: 1): it => {
    v(1.5em, weak: true)
    set text(size: 1em, weight: 900, fill: accent-color)
    block[
      #smallcaps(it.body)
    ]
    v(0.5em)
  }

  show heading.where(level: 2): it => {
    text(size: 0.9 * font-size, fill: accent-color, it.body + [.])
  }

  // Body
  set par(justify: true, spacing: 0.65em)

  v(2em)

  // Poster content
  grid(
    columns: (2fr, 3fr),
    gutter: 3em,
    body, right-column,
  )
}
