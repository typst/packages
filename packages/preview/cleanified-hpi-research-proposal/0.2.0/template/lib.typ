#import "@preview/biceps:0.0.1": *

#let project(
  // The title of the research proposal
  title: "",

  // The author of the research proposal
  author: "",

  // Date of the research proposal
  date: "",

  // Chair where the research will be conducted
  chair: "",

  // Additional logos the research should be conducted with
  additional-logos: (),

  // Define at which position the HPI Logo should be at
  hpi-logo-index: 1,

  // Enable or Disable HPI logo
  enable-hpi-logo: true,

  // Enable or Disable University of Potsdam Logo
  enable-up-logo: false,

  // An abstract
  abstract: [],

  // Abstract formatting; used in the text function.
  abstract-formatting: (),

  // Enable table of contents
  enable-toc: true,

  // Use a double-column layout
  double-column: false,

  body,
) = {
  let column-num = 1
  if double-column {
    column-num = 2
  }

  // Set the document's basic properties.
  set document(author: author, title: title)
  set page(
    margin: (left: 15mm, right: 15mm, top: 20mm, bottom: 15mm),
    numbering: none,
    number-align: end,
    columns: column-num,
  )

  let font-size-reduction = 0pt
  if double-column {
    font-size-reduction = 1pt
  }
  set text(font: "Libertinus Serif", size: 9pt - font-size-reduction, lang: "en")
  show math.equation: set text(weight: 400)

  // Shows paragraph breaks by only indending the following paragraph.
  set par(
    first-line-indent: 1.5em,  // Indent the first line of paragraphs
    spacing: 0.65em,         // Remove extra space between paragraphs (or use your baseline)
  )

  // Configure page properties.
  set page(
    header: context {
      // Are we on a page that starts a chapter?
      let i = here().page()
      if i == 1 {
        return
      }

      // Find the heading of the section we are currently in.
      let before = query(selector(heading).before(here()))
      if before != () {
        set text(0.95em)
        let header = before.last().body
        let author = text(style: "italic", author)
        grid(
          columns: (1fr, 10fr, 1fr),
          align: (left, center, right),
          if calc.even(i) [#i],
          // Swap `author` and `title` around, or possibly with `heading`
          // to change what is displayed on each side.
          if calc.even(i) { author } else { title },
          if calc.odd(i) [#i],
        )
      }
      align(center, line(length: 100%, stroke: 0.5pt))
    }
  )


  // Configure chapter headings.
  show heading.where(level: 1): it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    if not double-column {
      v(1%)
    }
    text(size: 13pt - font-size-reduction, weight: "bold", block([#number #it.body]))

    if double-column {
      v(0.2em)
    } else {
      v(0.5em)
    }
  }

  // Configure chapter headings.
  show heading.where(level: 2): it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    v(0.7%)
    text(size: 12pt - font-size-reduction, fill: rgb("#404040"), weight: "bold", block([#number #it.body]))
    v(0.3em)
  }

  // Configure chapter headings.
  show heading.where(level: 3): it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    v(0.7%)
    text(size: 11pt - font-size-reduction, fill: rgb("#404040"), weight: "bold", block([#number #it.body]))
  }

  set heading(numbering: "1.1.1.1.1 ·")

  let _logos = additional-logos

  if enable-up-logo {
    _logos.push(image("up-logo.svg", height: 50pt))
  }

  if enable-hpi-logo {
    hpi-logo-index = calc.min(hpi-logo-index, _logos.len())
    _logos.insert(hpi-logo-index, image("hpi-logo.svg", height: 50pt))
  }

  if _logos.len() > 6 {
    panic("Cannot display this template with more than 6 logos.")
  }

  let column_widths = (3fr, 1fr)
  if _logos.len() == 2 {
    column_widths = (4fr, 2fr,)
  } else if _logos.len() > 2 {
    column_widths = (1fr,)
  }
  // Heading of the proposal
  // Also contains the logos if less than 3 are used
  place(top,
    scope: "parent",
    float: true,
    grid(
      columns: column_widths,
      grid.cell(block[
        #text(title, size: 18pt, weight: "bold") \ \ // Excluded from font size reduction
        #text(author, style: "italic") --
        #text(date, style: "italic") \
        Chair of #text(chair)
      ]),
      if _logos.len() == 1 {
         grid.cell(
          align(horizon + center, _logos.at(0))
        )
      } else if (_logos.len() == 2) {
        align(center+ horizon,
          grid(
            columns: (1fr, 1fr),
            _logos.at(0),
            _logos.at(1)
          )
        )
      }
    )
  )

  // If more than 2 logos are used, they are displayed here
  // below the title
  if _logos.len() > 2 {
    // At most 6 logos. More logos will panic.
    let height = 36pt
    align(horizon + center,
      grid(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        rows: 36pt,
        _logos.at(0),
        _logos.at(1),
        _logos.at(2),
        if _logos.len() > 3 { _logos.at(3) } else { [] },
        if _logos.len() > 4 { _logos.at(4) } else { [] },
        if _logos.len() > 5 { _logos.at(5) } else { [] },
      )
    )
  }

  if abstract != [] {
    let default-abstract-formatting = (
      fill: rgb("#2e2e2e"),
      style: "italic",
    )

    if abstract-formatting == () {
      abstract-formatting = default-abstract-formatting
    } else {
      if not abstract-formatting.keys().contains("fill") {
        abstract-formatting.fill = default-abstract-formatting.fill
      }
      if not abstract-formatting.keys().contains("style") {
        abstract-formatting.style = default-abstract-formatting.style
      }
    }

    let abstract-width = 100%
    box([
      #text([*Abstract*], ..abstract-formatting).
      #text([#abstract], ..abstract-formatting)
    ], width: abstract-width)
  }

  // Outline
  // Does not show heading lower than level 2.
  if enable-toc {
    v(1em)
    line(length: 100%)
    if double-column {
      v(-0.8em)
    } else {
      v(-1.6em)
    }
    outline(depth: 2)
    if double-column {
      v(1em)
    } else {
      v(0.5em)
    }
  }

  line(length: 100%)

  // Main body.
  set par(justify: true)

  body
}
