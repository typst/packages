// Copyright 2024 Felix Schladt https://github.com/FelixSchladt

#import "../colors.typ": *

#let styledtable(
  stroke: hm-grey-dark,
  background-odd: hm-red-very-light,
  background-even: hm-white,
  table) = {
  set table.hline(stroke: stroke)
  set block(breakable: true)
  set table(
   align: left,
   fill: (_, y) => if calc.odd(y) {background-odd} else {background-even},
   stroke: none,
  )

  align(center,
    block(
      radius: 5pt,
      stroke: 0pt,
      clip: true,
      width: auto,
      breakable: true,
      table
    )
  )
}