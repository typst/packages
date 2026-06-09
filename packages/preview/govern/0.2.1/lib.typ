#let govern(
  body,
  draft: false,
) = {
  set text(font: "EB Garamond", size: 12pt)

  set page(
    margin: (left: 3cm, rest: 2.5cm),

    background: if draft {
      rotate(45deg)[
        #text(size: 120pt, fill: luma(80%))[*DRAFT*]
      ]
    },
  )

  show title: set text(size: 16pt)

  show heading.where(level: 1): set text(size: 14pt)
  show heading.where(level: 2): set text(size: 12pt)

  let doc-title = context document.title
  let doc-authors = context document.author.join(", ")
  let doc-date = context document.date.display()

  align(center + horizon)[
    #title()

    #v(1em)

    #doc-authors\
    #doc-date
  ]

  set page(
    header: (
      text(style: "italic")[
        #doc-title #h(1fr) #doc-authors
      ]
    ),

    footer: (
      text(style: "italic")[
        #doc-date #h(1fr) Page #context counter(page).display("1 of 1", both: true)
      ]
    ),
  )

  outline()
  pagebreak()

  set par(justify: true)

  set enum(numbering: (..number) => {
    strong(
      smallcaps(
        numbering("a)", ..number),
      ),
    )
  })

  set heading(numbering: "1.1")

  show heading.where(level: 1): set heading(supplement: [Article])
  show heading.where(level: 2): set heading(supplement: [Section])

  show heading: it => {
    if it.level > 2 { panic("Heading lower than section is undefined") }

    let number = counter(heading).display(it.numbering)

    block(
      smallcaps(
        lower[
          #it.supplement #number: #it.body
        ],
      ),
    )
  }

  body
}
