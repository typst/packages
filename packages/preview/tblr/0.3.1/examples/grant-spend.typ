#import "../tblr.typ": *

// Adapted from https://www.storytellingwithdata.com/blog/2012/02/grables-and-taphs
#set page(height: auto, width: auto, margin: 0em)

#let data = from-csv(delimiter: "|", "
Tower Hamlets          | 1  | 3  | 269 | 9692642
Hackney                | 2  | 2  | 225 | 7809608
Southwark              | 3  | 12 | 232 | 7266118
Camden                 | 4  | 14 | 136 | 6140419
Islington              | 5  | 4  | 156 | 5424137
Lambeth                | 6  | 8  | 156 | 5257941
Newham                 | 7  | 2  | 154 | 5217075
Hammersmith and Fulham | 8  | 13 | 109 | 4085708
Merton                 | 9  | 29 | 113 | 3656112
Croydon                | 10 | 20 | 127 | 3629066
")

#let bar(x) = {
  rect(width: int(x) / 7000000 * 2in, fill: blue, text(fill: white, x))
}

#tblr(columns: 5,
  stroke: none,
  align: center+horizon,
  // formatting directives
  rows(within: "header", auto, fill: aqua.lighten(60%), hooks: strong),
  cols(within: "body", 0, align: left, fill: gray.lighten(70%), hooks: strong),
  cols(within: "body", -1, align: left, hooks: bar),
  // content
  table.header([Borough],[Trust\ rank],[Index\ rank],[Number\ of grants],[Amount approved (£)]),
  ..data
)
