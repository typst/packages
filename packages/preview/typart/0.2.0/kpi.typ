// KPI stat cards: big value + caption in a row.  Import with:  #import "kpi.typ": kpi
//
//   #kpi((("< 1%", [Target EER]), ([99%], [Accuracy], rgb("#40a02b"))))
#import "common.typ": _col
#import "hlist.typ": hlist

#let kpi(
  items,
  h: 3.6cm,
  value-size: 38pt, label-size: 16pt,
  text-fill: white,
  gutter: 12pt, radius: 10pt, inset: 14pt,
) = hlist(
  items.enumerate().map(((i, it)) => (
    stack(dir: ttb, spacing: 8pt, it.at(0), text(weight: "regular", size: label-size, it.at(1))),
    _col(it, i, at: 2),
  )),
  text-fill: text-fill, size: value-size, height: h, radius: radius, gutter: gutter, inset: inset)
