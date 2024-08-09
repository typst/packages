#import "/lib/i18n.typ": en-us

#let make-prob-overview(
  font-size: 1em,
  i18n: en-us.make-prob-overview,
  ..items,
) = [
  #align(center + horizon)[
    #text(size: 1.5em)[
      #table(
        columns: 4,
        inset: (x: .5em, y: .65em),
        align: horizon,
        stroke: (x: none),
        row-gutter: (5.2pt, auto),
        table.vline(x: 2, start: 0),
        table.vline(x: 3, start: 0),
        table.cell(colspan: 2)[#i18n.problem], i18n.difficulty, i18n.author,
        ..items
      )
    ]
  ]
]
