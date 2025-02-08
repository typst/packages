
#let header = {
  set align(bottom)
  show table.cell.where(y: 0): set align(left)
  set text(weight: "bold")
  table(
    stroke: (y: none),
    columns: (0.8fr, 1.4fr, 0.8fr),
    rows: 1fr,
    table.hline(),
    [Document ID], [Title], [page],
    [PREFIX-12345678],
    [Product Specification document],
    [
      #context counter(page).display(
        "1 / 1",
        both: true,
      )
    ],
  )
}

#let footer = {
  set text(weight: "bold")
  table(
    stroke: (y: none),
    columns: (0.8fr, 1.4fr, 0.8fr),
    rows: 1fr,
    [PREFIX-12345678],
    [Product Specification document],
    [
      #context counter(page).display(
        "1 / 1",
        both: true,
      )
    ],
    table.hline(),
  )
}
#import "@preview/s6t5-page-bordering:1.0.0": s6t5-page-bordering
#show: s6t5-page-bordering.with(
  margin: (left: 30pt, right: 30pt, top: 60pt, bottom: 60pt),
  expand: 15pt,
  space-top: 15pt,
  space-bottom: 15pt,
  stroke-header: none,
  stroke-footer: none,
  header: header,
  footer: footer,
)

= Scope

This specification applies to a product.

= Model

Target is below.
- [type1]
- [type2]
- [type3]


= Document History
#table(
  columns: (auto, auto, auto, 1fr),
  [Version], [Date], [Author], [Modification],
  [1.0.1],
  [yyyy/mm/dd],
  [Shumpei Tanaka],
  [
    - fix ~~~
    - add aaa
  ],

  [1.0.0],
  [yyyy/mm/dd],
  [Shumpei Tanaka],
  [
    - first vertion
  ],
)

