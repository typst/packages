#let report(
  title: "A Report Template",
  subtitle: "",
  authors: (
    (
      name: "John Doe",
      number: "",
    ),
  ),
  font: "",
  font-size: 11pt,
  lang: "en",
  date: "",
  sans: true,
  cover-image: none,
  paper: "a4",
  line-spacing: 1,
  table-of-contents: true,
  table-of-figures: false,
  doc,
) = {

  // metadata
  set document(title: title, author: authors.map(a => a.name))

  set text(
    font: 
      if (font != "") {
        font
      } else {
        if sans {"Liberation Sans"} else {"Libertinus Serif"}
      }
    ,
    size: font-size,
    lang: lang,

    ligatures: false
  )

  // COVER

  set page(
    numbering: none,
    paper: paper,
  )
  
  set par(
    first-line-indent: (amount: 0.5in, all: true),
    justify: true,
    leading: line-spacing*0.65em,
    spacing: 0.65em,
    linebreaks: "optimized",
  )

  set block(spacing: 1.2em)

  set heading(numbering: "1.")
  set math.equation(numbering: "(1)")
  set figure(numbering: "(1)")

  show heading: set block(below: 1em)

  show ref: it => highlight(fill: rgb("fff3a1"), it)

  if cover-image != none {
    align(top + left)[
      #cover-image
    ]
  }

  align(horizon + center)[
    #text(24pt, title, weight: "bold")
    #v(0.3em)
    #text(12pt, subtitle, weight: "regular")
  ]

  v(12em, weak: true)
  align(horizon + center)[
    #text(
      weight: "semibold",
      list(
        marker: "",
        body-indent: 0pt,
        ..authors.map(a => if a.number != none { [#columns(2, gutter: -10cm)[#a.name #colbreak() #a.number]] } else { a.name }),
      )
    )
  ]

  if date != "" [#align(center + bottom)[#text(date)]]

  pagebreak()

  // OTHER PAGES

  set footnote.entry(separator: none)
  show footnote.entry: set text(size: 0.8em, fill: rgb(0, 0, 0, 80%))

  let footer = context [
    #line(length: 100%)
    #set text(0.8em,)

    #grid(
      columns: (1fr, auto),
      align: (horizon + left, horizon + right),

      text(fill: rgb(0, 0, 0, 60%))[#title -- #subtitle],
      counter(page).display()
    )

  ]

  set page(
    footer: footer
  )

  // TABLE OF CONTENTS
  if table-of-contents == true {
    {
      set par(first-line-indent: 0pt)

      show outline.entry.where(level: 1): it => {
        v(1em, weak: true)
        strong(it)
      }

      outline(title: [Table of Contents #v(1em)], indent: auto,)
      
      pagebreak()
    }
  }

  // TABLE OF FIGURES
  if table-of-figures == true {
    {
      set par(first-line-indent: 0pt)

      outline(
        title: [Table of Figures #v(1em)],
        target: figure.where(kind: image),
        indent: auto,
      )
    }

    pagebreak()
  }

  doc
}
