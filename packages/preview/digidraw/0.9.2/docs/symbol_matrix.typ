#import "@preview/digidraw:0.9.2"
#show raw: set text(font: "Fantasque Sans Mono")
#set table(stroke: 0.5pt, inset: 1mm)
#set page(width: auto, height: auto, margin: 1mm)

#show table.cell: set block(breakable: false)

#let swave = wave.with(show-guides: true, stroke-guides: white, show-tick-lines: false, size: 5mm, name-gutter: 0pt)

#let symbols = (
  "x",
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "p",
  "P",
  "n",
  "N",
  "l",
  "L",
  "h",
  "H",
  "z",
  "u",
  "d",
  "|",
  ".",
  "/",
)

#table(
  columns: (auto,) + symbols.len() * (1.55cm,),
  align: horizon + center,
  table.header(block(), ..symbols.map(x => strong(raw(x)) + text(raw("x"), gray)),),
  ..for s in symbols {
    (
      text(raw("x"), gray) + strong(raw(s)),
      ..symbols.map(x => {
        table.cell(swave(
            (signal: ((wave: x + s),)),
        ) + grid(rows: (1em), columns: (1em,1em), fill: gray.lighten(70%), column-gutter: 1mm)[#strong(raw(x))][#strong(raw(s))])
      }),
    )
  }
)
