#let make-acknowledge-en(it) = [
  #set text(12pt)
  #set par(
    leading: 1.2em,
    first-line-indent: 1em,
    linebreaks: "optimized",
  )
  #show heading.where(level: 1): set text(21pt)

  #align(center)[
    #heading(
      level: 1,
      numbering: none,
      outlined: true,
    )[Acknowledgements]]

  #v(0.5cm)
  #h(1em) // first-line-indent for first par.
  #it
  #pagebreak()
]

#let make-acknowledge-zh-tw(keywords: (), it) = [
  #set text(size: 12pt)
  #set par(
    leading: 1.2em,
    first-line-indent: 1em,
    linebreaks: "optimized",
  )
  #show heading.where(level: 1): set text(size: 21pt)

  #align(center)[#heading(level: 1, numbering: none, outlined: true)[致謝]]

  #v(0.5cm)
  #h(1em) // first-line-indent for first par.
  #it
  #pagebreak()
]
