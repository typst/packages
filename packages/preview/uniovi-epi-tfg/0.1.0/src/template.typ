#import "translated-terms.typ": *

#let template(
  school: "",
  degree: "",
  area: "",
  title: "",
  authors: (),
  supervisor: (),


  paper-size: "a4",
  paper-color: "#ffffff",
  text-color: "#000000",
  text-font: "New Computer Modern",
  text-lang: "es",
  justify: true,

  heading_numbering: "1",
  show-prefix: true,
  show-numbering: true,

  date: none,
  institution-link: "https://www.uniovi.es",
  subject: none,
  lang: "es",
  bibliography-style: "ieee",

  body,
) = {

  let paper-color = rgb(paper-color)
  let text-color = rgb(text-color)
  let line-color = rgb("00000060")

  
  // ==========================================
  // DOCUMENT & COVER CONFIGURATION
  // ==========================================

  set document(
    title: title,
    author: authors.map(a => a.name + " " + a.surname),
    )

  set text(font: text-font, size: 12pt, fill: text-color, lang: text-lang)

  set par(
  justify: true,
  linebreaks: "optimized",
  leading: 1em,
  spacing: 1em,
  )

  set page(
    margin: (top: 3cm, left: 3cm, bottom: 2.5cm, right: 2.5cm),
    numbering: "1",
    number-align: end,

    footer: {
      set text(9pt)
      v(0.9cm)
      stack(
        spacing: 8pt,
        line(length: 100%, stroke: 0.5pt + line-color),
        align(
          center,
          authors.map(author => author.name + " " + author.surname).join(", ")
        ),
      )
    },
  )

  set text(font: "New Computer Modern", lang: lang)
  show math.equation: set text(weight: 400)
  set heading(numbering: "1.1")

  align(center, image("assets/uniovi.webp", height:150pt))
  v(50pt)

  // Title row.
  align(center)[
    #block(text(weight: 900, 18pt, school))
    #v(3.5cm, weak: true)
    #block(text(weight: 800, 16pt, degree))
    #v(2.5cm, weak: true)
    #block(text(weight: 700, 14pt, area))
    #v(2.5cm, weak: true)
    #block(text(weight: 600, 14pt, title))
  ]

  // Author information.
  v(2.5cm, weak: true)
  pad(
    top: 0.5em,
    bottom: 0.5em,
    x: 1em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center)[
        D. #author.surname, #author.name
      ]),
      ..supervisor.map(supervisor => align(center)[
        #get-translation(translated-terms.supervisor): #supervisor.name #supervisor.surname
      ]),
    ),
  )
  // Date
  set align(center)
  set text(10pt)
  pad(
    top: 0.2em,
    bottom: 0.2em,
    x: 2em,
    emph[#date],
  )

  // Main body.
  set align(left)


  // ==========================================
  // CONFIGURATION BODY
  // ==========================================


  set text(font: text-font, size: 12pt, fill: text-color, lang: text-lang)
  
  set bibliography(style: bibliography-style)

  set page(
    header: {
      set text(8.5pt)
      let separator = get-translation(translated-terms.of)

      grid(
        columns: (2cm, 1fr),
        align: (left, right),

        [
          #move(
            dy: 6pt,
            image("assets/uniovi_header.webp"),
          )
        ],
        [
          #get-translation(translated-terms.uniovi) - #school \
          #get-translation(translated-terms.tfg) (#title) -
          #get-translation(translated-terms.page)
          #context {
            let current = counter(page).get().first()
            let total = counter(page).final().first()
            [#numbering("1", current) #separator #numbering("1", total)]
          }
        ],
      )

      line(length: 100%, stroke: 0.5pt + line-color)
      v(0.1cm)
    },
  )


  // ==========================================
  // TITLES AND HEADINGS
  // ==========================================

  // Chapters: 28 pt, bold
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }
  
  show heading.where(level: 1): set text(
    size: 28pt,
    weight: "bold",
  )

  show heading.where(level: 1): set block(
    below: 1em,
  )

  // Sections: 14 pt, bold, uppercase
  show heading.where(level: 2): it => {
    set text(
      size: 14pt,
      weight: "bold",
    )
  
    block(
      above: 2em,
      below: 1em,
    )[
      #counter(heading).display() #upper(it.body)
    ]
  }

  // Subsections: 12 pt, bold
  show heading.where(level: 3): set text(
    size: 12pt,
    weight: "bold",
  )

  show heading.where(level: 3): set block(
    above: 1em,
    below: 1em,
  )

  // Sub-subsections: 12 pt, bold
  show heading.where(level: 4): set text(
    size: 12pt,
    weight: "bold",
  )

  show heading.where(level: 4): set block(
    above: 1em,
    below: 1em,
  )


  // ==========================================
  // FIGURES, TABLES, EQUATIONS & CODE
  // ==========================================

  // Figures
  show figure.where(kind: image): set block(
    above: 1em,
    below: 1em,
  )

  // Tables
  show figure.where(kind: table): set block(
    above: 1em,
    below: 1em,
  )

  // Equations
  show math.equation.where(block: true): set block(
    above: 1em,
    below: 1em,
  )

  set raw(theme: "assets/barf.tmTheme")
  show raw: it => align(center, block(
    fill: rgb("#1e262d"),
    inset: 8pt,
    radius: 1pt,
    align(left, text(fill: rgb("#ffff"), it)),
  ))


  // ==========================================
  // INDEX & BODY
  // ==========================================

  pagebreak()
  
  set text(size: 10pt)

  show outline.entry.where(
    level: 1
  ): set block(above: 1cm)

  show outline.entry.where(
    level: 1
  ): set text(weight: "bold")

  outline()

  set text(size: 12pt)

  pagebreak()


  body

}
