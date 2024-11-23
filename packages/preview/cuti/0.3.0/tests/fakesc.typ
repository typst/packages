#import "../lib.typ": *
#set page(margin: 2cm)
#show table.cell.where(y: 0): it => {strong(it)}

// Please add `set text(font: ...)` to test how text appears in different fonts when testing typography layouts.

#[
  #let en-test(s) = table(
    columns: (1fr, ) * 3,
    stroke: 0.5pt,
    table.header(
      [Original],
      [Small Capitals - Font],
      [FakeSC - `cuti`]
    ),
    s,
    smallcaps(s),
    fakesc(s)
  )

  #en-test(lorem(30))

  #set par(justify: true)

  #en-test(lorem(30))
]