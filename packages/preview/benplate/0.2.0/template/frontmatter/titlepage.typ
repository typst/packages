#let titlepage(
  university: "",
  faculty: "",
  field: "",
  type: "",
  author: "",
  date: none,
  advisor: "",
  first-reviewer: "",
  second-reviewer: "",
  accent-color: rgb(165, 28, 48),
  date-format: "[day].[month].[year]",
) = {
  page(margin: (x: 40mm, y: 50mm))[
    #show title: it => text(17pt, weight: "regular", tracking: 1pt, hyphenate: false, upper(it))

    #set align(center)
    #set par(leading: 15pt, justify: false)

    #grid(
      rows: (auto, 1fr, auto, auto),
      [
        #text(20pt, accent-color, university)\
        #text(15pt, weight: "semibold")[
          Faculty of #faculty\
          Department of #field
        ]
      ],
      align(horizon, text(13pt, type)),
      [
        #block(width: 100%, stroke: (y: 0.5pt), inset: (y: 2.2em), title())

        #v(6em)
      ],
      [
        submitted by\
        #author\
        #date.display(date-format)

        #v(3em)

        *Advisor:*\
        #advisor

        #v(3em)

        *Reviewers:*\
        #first-reviewer\
        #second-reviewer
      ],
    )
  ]

  pagebreak(weak: true, to: "odd")
}
