
#let ai-ethics-template(
  title: [],
  abstract: [],
  author: (),
  keywords: (),
  doc,
) = {

  // -- Text
  let font-size = 9.5pt
  set text(size: font-size, font: "New Computer Modern")

  // -- Header
  set page(header: context {
    if here().page() > 1 [
      #grid(
        columns: (1cm, 1fr, 1cm),
        [#here().page()],
        align(center, [#text(size: 8pt, title)])
      )
    ]
  }, header-ascent: 2em)

  // -- Margins
  set page(margin: (x: 4.5cm, top: 5.5cm, bottom: 5cm))

  // -- Headings
  show heading.where(level: 1): set heading(numbering: (n) => {numbering("1", n) + h(0.35cm)})

  show heading.where(level: 1): it => [
    #set text(size: 12pt)
    #it
    #v(0.2em)
  ]
  
  show heading.where(level: 2): it => {
    block(above: par.spacing, below: 0pt)
    box(text(size: font-size, it)) + h(0.25cm)
  }


  // -- Bibliography
  show bibliography: set bibliography(title: [References #v(0.5em)])
  
  show bibliography: it => {
    show heading: set heading(numbering: none)
    it
  }

  // -- Lists
  show list: set list(marker: [#text(baseline: -0.2em, size: 15pt, "•")])
  show list: it => [
    #pad(y: 0.5em, [
      #it
    ])
  ]

  // Front-matter Content
  align(center, [
    #v(0.75cm)
    #text(weight: "bold", size: 1.6em, title)
    #v(1em)
    
    #text(size: 12pt, author.name)
    #v(0.5em)

    #emph([
      #{author.number} \
      #{author.email} \
      #{author.course} \
    ])
  ])

  v(1em)
  
  block([
    #line(length: 100%)
    #v(-0.1cm)
    
    *Abstract* \

    #{abstract} \

    #emph[Keywords]: #h(0.5em) #(keywords.join(", "))
    
    #v(-0.1cm)

    #line(length: 100%)
  ])

  // -- Paragraph indents
  set par(first-line-indent: 1em, spacing: 0.65em, justify: true)


  doc
}
