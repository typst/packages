
#let knowledge-key(
  title: [Paper Title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // The article's paper size. Also affects the margins.
  paper-size: "a4",

  // The content.
  body
) = {
  let line_skip = 0.35em
  let font_size = 6pt
  let level1_color = "#8c195f";
  let level2_color = "#a12b66"; 
  let level3_color = "#b63d6d"; 
  let level4_color = "#cb4f74"; 
  let level5_color = "#C63B65"; 

  set block(spacing: line_skip)
  set par(leading: line_skip, justify: true)
  
  // Configure the page.
  set page(
    paper: paper-size,
    flipped: true,
    margin: ("top": 8mm, "rest": 5mm),
    header-ascent: 1.5mm,
    header: align(center, text(
      1.1em,
      weight: "bold",
      [#title / #authors / #context counter(page).display()],
    )),
  )

  set text(size: font_size, font: "Libertinus Serif")

  set terms(hanging-indent: 0mm)

  show outline.entry.where(level: 1): set text(weight: "bold")

  show heading: set text(white, size: font_size)
  show heading: set block(
    radius: 0.65mm,
    inset: 0.65mm,
    width: 100%,
    above: line_skip,
    below: line_skip,
  )
  show heading.where(level: 1): set block(fill: rgb(level1_color))
  show heading.where(level: 2): set block(fill: rgb(level2_color))
  show heading.where(level: 3): set block(fill: rgb(level3_color))
  show heading.where(level: 4): set block(fill: rgb(level4_color))
  show heading.where(level: 5): set block(fill: rgb(level5_color))
  set heading(numbering: "1.1")

  columns(4, gutter: 2mm, body)
}
