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
) = {
  set align(center + horizon)
  set par(leading: 15pt)
  page(
    margin: (left: 40mm, right: 40mm, top: 50mm, bottom: 50mm),
    numbering: none,
  )[
    #text(fill: rgb(165, 28, 48), 20pt)[#university]\
    #text(weight: "semibold", 15pt)[
      Faculty of #faculty\
      Department of #field
    ]

      #v(40pt)
      #text(13pt)[#type]

      #v(30pt)
      #line(length:100%, stroke:(thickness: 0.5pt))
      #v(7pt)#title()#v(11pt)
      #line(length:100%, stroke:(thickness: 0.5pt))


      #v(40pt)
      submitted by\
      #author\
      #date.display("[day].[month].[year]")

      #v(40pt)

      *Advisor:*\
      #advisor

      #v(40pt)

      *Reviewers:*\
      #first-reviewer\
      #second-reviewer
  ]

  pagebreak(weak: true, to: "odd")
}
