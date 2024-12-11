// #import "@preview/tblr:0.2.0": *
#import "../tblr.typ": *
#import "@preview/zero:0.3.0": ztable

#set page(height: auto, width: auto, margin: 0em)

#show table: set text(number-type: "lining", number-width: "tabular")

#let pop = csv.decode("
China,1313,9596,136.9
India,1095,3287,333.2
United States,298,9631,31.0
Indonesia,245,1919,127.9
Brazil,188,8511,22.1
Pakistan,165,803,206.2
Bangladesh,147,144,1023.4
Russia,142,17075,8.4
Nigeria,131,923,142.7"
).flatten()

#set table(stroke: none)

#tblr(header-rows: 1, columns: 4,
  table-fun: ztable,
  align: (left+bottom, center, center, center),
  // ztable formatting
  format: (none, auto, auto, auto),
  // formatting directives
  rows(within: "header", 0, fill: blue, hooks: (strong, text.with(white))),
  rows(within: "body", calc.even, fill: gray.lighten(80%)),
  // content
  [Country], [Population \ (millions)],[Area\ (1000 sq. mi.)],[Pop. Density\ (per sq. mi.)],
  ..pop
)

