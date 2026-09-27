#let govern = (
  body,
  adoption-date: datetime.today(),
  draft: false,
) => [
  #set text(font: "EB Garamond", size: 12pt)
  #set page(
    margin: (left: 3cm, rest: 2.5cm),
    background: if draft [#rotate(45deg)[
        #text(size: 120pt, fill: luma(80%))[
          *DRAFT*
        ]
      ]
    ],
  )
  #set par(justify: true)

  #show title: set text(size: 16pt)
  #show heading: set text(size: 14pt)

  #align(center + horizon)[
    #title()
    #v(1em)
    #context document.author.join(", ")\
    #adoption-date.display()
  ]

  #set page(
    header: [_#context document.title #h(1fr) #context document.author.join(", ")_],
    footer: [_#adoption-date.display() #h(1fr) Page #context counter(page).display("1 of 1", both: true)_],
  )

  #outline()

  #pagebreak()

  #set heading(numbering: (.., v) => numbering("1", v))
  #show heading: it => {
    if it.level > 2 { panic("Heading lower than section is undefined") }

    let prefix = if it.level == 1 { "Article" } else { "Section" }

    let num = counter(heading).display(it.numbering)

    set text(size: if it.level == 1 { 14pt } else { 12pt })

    block(sticky: true)[
      #smallcaps[#lower[#prefix #num: #it.body]]
    ]
  }

  #set enum(numbering: (..nums) => {
    strong[#smallcaps[#numbering("a)", ..nums)]]
  })

  #body
]
