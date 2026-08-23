// KPI stat cards: big value + caption in a row.  Import with:  #import "kpi.typ": kpi
//
//   #kpi((("< 1%", [Target EER]), ([99%], [Accuracy], rgb("#40a02b"))))
#import "common.typ": palette, _lab, _col

#let kpi(
  items,
  h: 3.6cm,
  value-size: 38pt, label-size: 16pt,
  text-fill: white,
  gutter: 12pt, radius: 10pt, inset: 14pt,
) = {
  set par(justify: false, leading: 0.5em)
  grid(columns: items.map(_ => 1fr), column-gutter: gutter,
    ..items.enumerate().map(((i, it)) => box(
      width: 100%, height: h, radius: radius, inset: inset,
      fill: it.at(2, default: palette.at(calc.rem(i, palette.len()))),
      align(center + horizon, stack(dir: ttb, spacing: 8pt,
        box(text(fill: text-fill, weight: "bold", size: value-size)[#it.at(0)]),
        text(fill: text-fill, size: label-size)[#it.at(1)])))))
}
