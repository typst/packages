
#let report(title: "",
  studies: none,
  course: none,
  date: "",
  authors: (),
  teachers: (),
  logo: image("images/logo-polytech.png"),
  seal: image("images/sceauULB.png", width: 20cm),
  lang: "fr",
  body
) = {

  set document(author: authors, title: title)
  set text(size: 12pt, lang: lang)

  // Place the seal on the background
  set page(
    background: place(
      dx: 5cm,
      dy: 14cm,
      rotate(-10deg)[
        #box(width: 20cm, height: 20cm)[
          #seal
        ]
      ]
    )
  )

  // Level 1 headings
  set heading(numbering: "1.1")
  show heading.where(level: 1): he => {
    pagebreak()
    v(3em)
    align(center)[
      #box(width: 100%, height: 70pt, fill: rgb("#808080").transparentize(70%))[
        #align(top + right)[
          #set text(size: 70pt, style: "italic", weight: "regular", fill: rgb("#808080").transparentize(5%))
          #v(-24pt)
          #if type(he.numbering) == str {
            counter(heading).display(he.numbering.slice(0, -2))
          } else if he.numbering != none {
            upper((he.numbering), (he.level).slice(0, -2))
          }
        ]
        #align(bottom + right)[
          #box(inset: 9pt)[
            #text(size: 18pt)[#he.body]
          ]
        ]

      ]
    ]
  }
  
  // First page
  box(width: 6cm, height: 1.5cm)[
    #align(left + horizon)[
      #logo
      #studies
    ]
  ]
  v(2em)
  align(center)[
    #text(weight: "bold")[#course]
  ]
  v(2em)
  line(length: 100%, stroke: 1.6pt + black)
  v(-11pt)
  line(length: 100%, stroke: 0.4pt + black)
  v(1em)
  align(center)[
    #text(size: 24pt)[#title]
  ]
  v(1em)
  line(length: 100%, stroke: 0.4pt + black)
  v(-11pt)
  line(length: 100%, stroke: 1.6pt + black)
  grid(
    columns: (1fr, 1fr),
    inset: 20%,
    [
      #if authors.len() > 0 {
        align(left)[
          #for author in authors {
            author
            linebreak()
          }
        ]
      }
    ],
    [
      #if teachers.len() > 0 {
        align(right)[
          #for teacher in teachers {
            teacher
            linebreak()
          }
        ]
      }
    ]
  )

  align(center + bottom)[
    #date
  ]

  // Page numbering starting after the first page
  set page(
    background: none,
    numbering: "1",
  )

  // Bold level 1 headings in the outline
  show outline.entry.where(level: 1): i => {
    strong(i)

  }
  
  // Indent at the start of a paragraph and justify
  set par(
    first-line-indent: (
      amount: 1.5em,
      all: true,
    ),
    justify: true,
  )

  body
}
