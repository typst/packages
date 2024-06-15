#let project(
  title: "",
  abstract: [],
  rezumat: [],
  author: "",
  coordinator: "",
  date: none,
  logo-ub: none,
  logo-fmi: none,
  body,
) = {
  set document(author: author, title: title)
  set text(
      lang: "ro", 
      size: 12pt,
      // font: "New Computer Modern",
      font: "Times New Roman",
    )
  set page(paper: "a4", margin: 2.5cm)
  
  set heading(numbering: "1.1")

  // subheadings
  show heading: it => [
    #linebreak()
    #it
    #v(0.5em)
  ] 

  // main headings
  show heading.where(level: 1, outlined: true): it => [
  #pagebreak()
  Capitolul #counter(heading).display(it.numbering) 
  #linebreak() 
  #it.body 
  #linebreak()
]
  
  show math.equation: set text(weight: 400)
  
  // Title page.
  grid(
  columns: 3,
  gutter: 14pt,
  align(center, image(logo-ub, width: 70%)),
  align(center, text(
    "UNIVERSITATEA DIN BUCUREȘTI
    
    FACULTATEA DE MATEMATICĂ ȘI INFORMATICĂ", weight: "bold"
  )),
  align(center, image(logo-fmi, width: 70%)),
  )
  align(center, text("SPECIALIZAREA CALCULATOARE 
  ȘI TEHNOLOGIA INFORMAȚIEI", weight: "bold"))

  v(1.5cm)
  align(center, text(18pt, "Proiect de Diplomă", weight: "bold"))
  align(center, text(25pt, title, weight: "bold", ))

  v(3cm)
  align(center, text(16pt, "Absolvent\n" + author, weight: "bold"))
  v(1cm)
  align(center, text(16pt, "Coordonator științific\n" + coordinator, weight: "bold"))

  v(3cm)
  align(center, text(18pt, date, weight: "bold"))
  pagebreak()

    
  // Abstract page.
  set par(justify: true, first-line-indent: 1em, leading: 1.1em)
  align(horizon)[
    #align(center)[#heading(
      outlined: false,
      numbering: none,
      text(0.85em, smallcaps[Rezumat]),
    )]
    #par()[#h(1em)#rezumat]
    
    #linebreak()
    
    #align(center)[#heading(
      outlined: false,
      numbering: none,
      text(0.85em, smallcaps[Abstract]),
    )]
    #par()[#h(1em)#abstract]

  ]
  pagebreak()

  
  // Table of contents.
  outline(depth: 3, indent: true)
  set page(numbering: "1", number-align: center)

  
  // dumb fix for first line indentation
  import "@preview/indenta:0.0.3": fix-indent
  show: fix-indent()
  
  // Main body.
  body
}