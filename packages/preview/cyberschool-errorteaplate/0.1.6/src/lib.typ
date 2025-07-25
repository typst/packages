#import "@preview/codly:1.3.0": *
#show: codly-init.with()

#import "@preview/codly-languages:0.1.8": *
#codly(languages: codly-languages)

#let conf(
  title: none,
  pre-title: none,
  subtitle: none,
  authors: (),
  logos: (),
  abstract: [],
  outline-title: none,
  doc,
) = {

  let cyber_blue = rgb("#3444A3")
  let purple = rgb("#9C76FD")
  let darker_purple = rgb("#8564DF")
  let darker_darker_purple = rgb("#744DC1")

  set align(center)
  set page(number-align: center, numbering: "1")
  set par(justify: true)

  // Display logos
  let nb_logos = logos.len()
  grid(
    align: center + horizon,
    columns: (1fr, )* nb_logos,
    ..logos.map(logo => logo(width: 100pt))
  )

  set align(center + horizon)
  strong(line(length: 100%, stroke: cyber_blue))
  strong(text(pre-title, size: 17pt))
  linebreak()
  linebreak()
  strong(text(cyber_blue, 17pt, title))
  strong(line(length: 100%, stroke: cyber_blue))

  // Display authors
  for chunk in authors.chunks(3) {
  block(spacing: 24pt, grid(
    columns: (1fr,) * chunk.len(),
    ..chunk.map(author => [
      #author.name \
      #author.affiliation \
      #link("mailto:" + author.email)
    ]),
  ))
} 

  // Display abstract
  par(justify: true)[
    *Abstract* \
    #abstract
  ]
  set align(center + bottom)
  // Display current year
  datetime.today().display("[year]")

  pagebreak(weak: true, to: "odd")
  //set align(start)

  show outline: it => {
    show heading: set align(center)
    show heading: set text(purple)
    it
  } 

  show outline.entry : it => {
    if (it.level == 1){
    v(20pt, weak: true)
    strong(it)
  } else {
    it
  }
  }
  set align(start + top)
  show outline: set text(cyber_blue)

  set outline.entry(fill: none)
  outline(
    title: outline-title,
    indent: 1em,
  )

  pagebreak()

  set align(start + top)
  set heading(numbering: "1.")
  show heading.where(level: 1) : set text(purple)
  show heading.where(level: 2) : set text(darker_purple)
  show heading.where(level: 3) : set text(darker_darker_purple)

  doc
}
