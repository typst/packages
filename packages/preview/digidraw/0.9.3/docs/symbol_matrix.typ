#import "@preview/digidraw:0.9.3"
#show raw: set text(font: "Fantasque Sans Mono")
#set table(stroke: 0.5pt, inset: 1mm)
#set page(width: auto, height: auto, margin: 1mm)

#show table.cell: set block(breakable: false)

#let swave = wave.with(
  symbol-height: 6mm,
  symbol-width: 7mm,
  tick-format: none,
  debug: false
)

#let symbols-right = (
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
)


#let symbols-left = (
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
)

#table(
  columns: (auto,) + symbols-left.len() * (1.8cm,), rows: (auto,) + symbols-right.len() * (1.5cm,),
  align: horizon + center,
  table.header(block(), ..symbols-left.map(x => strong(raw(x)) + text(raw("x"), gray)),),
  ..for s in symbols-right {
    (
      text(raw("x"), gray) + strong(raw(s)),
      ..symbols-left.map(x => {
        table.cell(swave(
            (signal: ((wave: x + s),)),
        ) + v(1mm, weak: true) + grid(rows: (3.5mm), columns: (6mm,6mm), fill: gray.lighten(70%), column-gutter: 1mm)[#strong(raw(x))][#strong(raw(s))])
      }),
    )
  }
)
