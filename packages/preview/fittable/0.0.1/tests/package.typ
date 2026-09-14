#import "/src/package.typ" as fittable: *

#set page(width: 500pt, height: auto)

#let data = ([a], [long long col], [middle], lorem(20))
#let length = data.len()

#let test(x, func, s: true, ..args) = (
  if s {fit.with(func: func)} else {func}
)(
  columns: (100pt, auto, auto, 9%),
  func.header(..range(4).map(str).map(strong)),
  [Z],
  lorem(x),
  [Z],
  [Z],
  func.hline(),
  [Z],
  [Z],
  [XXXX],
  [Z],
  ..args,
)

The white space is distributed equally between `auto` cols.
#fit(columns: (auto,) * (length - 1), ..data.slice(0, -1))
#table(columns: (auto,) * (length - 1), ..data.slice(0, -1), stroke: gray)

If not enough space, `auto` cols are as wide as their content.
#fit(columns: (auto,) * length, ..data)
// #table(columns: (auto,) * length, ..data)

Absolute length and ratio columns are kept as is.
#test(1, table)
#test(1, table, s: false, stroke: gray)

#test(12, table)
// #test(12, table, s: false)

Fractional columns are allocated the width as the white space of
an `auto` column every `1fr` despite their intrinsic width.
Who would ever use this?
#fit(columns: (auto, 1fr, auto), ..data.slice(0, -1))
