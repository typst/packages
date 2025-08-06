#let project(
  // The title of the research proposal
  title: "",

  // The author of the research proposal
  author: "",

  // Date of the research proposal
  date: "",

  // Chair where the research will be conducted
  chair: "",
 
  body,
) = {  
  // Set the document's basic properties.
  set document(author: author, title: title)
  set page(
    margin: (left: 35mm, right: 35mm, top: 30mm, bottom: 30mm),
    numbering: none,
    number-align: end,
  )
  set text(font: "Verdana", lang: "en")
  show math.equation: set text(weight: 400)

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
    
    v(2%)
    text(size: 16pt, weight: "bold", block([#number #it.body]))
    v(0.5em)
  }

  // Configure chapter headings.
  show heading.where(level: 2): it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }
    
    v(1%)
    text(size: 14pt, fill: rgb("#404040"), weight: "bold", block([#number #it.body]))
    v(0.3em)
  }

  // Configure chapter headings.
  show heading.where(level: 3): it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }
    
    v(1%)
    text(size: 13pt, fill: rgb("#404040"), weight: "bold", block([#number #it.body]))
  }
  
  set heading(numbering: "1.1.1.1.1 ·")

  grid(
    columns: (2fr, 1fr),
    grid.cell(block[
      #text(title, size: 18pt, weight: "bold") \ \
      #text(author, style: "italic"),
      #text(date, style: "italic") \
      Chair of #text(chair)
    ]),
    grid.cell(align(horizon, image("hpi_logo.svg", width: 100%)))
  )

  v(1em)
  line(length: 100%)
  v(-1.6em)
  // Outline
  // Does not show heading lower than level 2.
  outline(depth: 2)
  v(0.4em)

  line(length: 100%)

  // Main body.
  set par(justify: true)
 
  body
}
