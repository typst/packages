// Horizontal list: equal blocks side by side.  Import with:  #import "hlist.typ": hlist
//
//   #hlist(([Plan], [Execute], ([Review], rgb("#e64553"))))
#import "common.typ": palette, _lab, _col

#let hlist(
  items,
  text-fill: white,
  size: 18pt,
  height: 3cm,
  radius: 8pt,
  gutter: 10pt,
  inset: 12pt,
) = {
  set par(justify: false, leading: 0.5em)
  grid(columns: items.map(_ => 1fr), column-gutter: gutter,
    ..items.enumerate().map(((i, it)) =>
      box(width: 100%, height: height, fill: _col(it, i), radius: radius, inset: inset,
        align(center + horizon, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)]))))
}
