// Copyright 2024 Felix Schladt https://github.com/FelixSchladt

#import "colors.typ": *

#let styledtable(
  stroke: hm_grey_dark,
  background_odd: hm_red_very_light,
  background_even: hm_white,
  _table_) = {
  set table.hline(stroke: stroke)
  set block(breakable: true)
  set table(
   align: left,
   fill: (_, y) => if calc.odd(y) {background_odd} else {background_even},
   stroke: none,
  )

  align(center,
    block(
      radius: 5pt,
      stroke: 0pt,
      clip: true,
      width: auto,
      breakable: true,
      _table_
    )
  )
}