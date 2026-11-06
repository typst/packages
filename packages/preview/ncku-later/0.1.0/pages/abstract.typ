#let make-abstract-en(keywords: (), it) = [
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
    )[Abstract]]


  #v(0.5cm)

  #h(1em) // first-line-indent for first par.
  #it

  #v(0.5cm)
  #h(-1em)
  Keywords: #keywords.join(", ")

  #pagebreak()
]

#let make-abstract-zh-tw(keywords: (), it) = [
  #set text(size: 12pt)
  #set par(
    leading: 1.2em,
    first-line-indent: 1em,
    linebreaks: "optimized",
  )
  #show heading.where(level: 1): set text(size: 21pt)

  #align(center)[#heading(level: 1, numbering: none, outlined: true)[摘要]]

  #v(0.5cm)
  #h(1em) // first-line-indent for first par.
  #it

  #v(0.5cm)
  #h(-1em)
  關鍵字：#keywords.join("、")

  #pagebreak()
]
