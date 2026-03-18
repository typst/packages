#import "@preview/tblr:0.1.0": *
// #import "../tblr.typ": *

#{
set page(height: auto, width: auto, margin: 0em)

let pop = csv.decode("
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

set table(stroke: none)

tblr(header-rows: 1, columns: 4,
  align: (left+bottom, center, center, center),
  // formatting directives
  header-rows(0, fill: aqua.lighten(60%), hooks: strong),
  body-cols(0, fill: gray.lighten(70%), hooks: strong),
  body-rows(1, 6, hooks: text.with(red)),
  cells(((2, -3), end), hooks: strong),
  // content
  [Country], [Population \ (millions)],[Area\ (1000 sq. mi.)],[Pop. Density\ (per sq. mi.)],
  ..pop
)

}