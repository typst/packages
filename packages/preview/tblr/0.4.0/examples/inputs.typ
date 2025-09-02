#import "../tblr.typ": *
#import "@preview/rowmantic:0.4.0": rowtable

#set page(height: auto, width: auto, margin: 0em)

#set table(stroke: none)
#grid(columns: 3, gutter: 3em,

tblr(
  rows(0, stroke: (bottom: 1pt), hooks: strong),
  content-hook: from-dataframe,
  (one:   ("1", "4"),
   two:   ("2", "5"),
   three: ("3", "6"))
),

tblr(
  rows(0, stroke: (bottom: 1pt), hooks: strong),
  content-hook: from-csv,
  "one, two, three
   1,   2,   3
   4,   5,   6"
),

tblr(
  rows(0, stroke: (bottom: 1pt), hooks: strong),
  content-hook: rowtable.with(table: arguments),
  [one & two & three],
  [1   & 2   & 3],
  [4   & 5   & 6],
)

)  // end of grid
