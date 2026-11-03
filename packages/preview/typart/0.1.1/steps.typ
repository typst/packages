// Vertical numbered steps list.  Import with:  #import "steps.typ": steps
//
//   #steps(([Plan], [Execute], ([Review], rgb("#e64553"))))
#import "common.typ": palette, _lab, _col

#let steps(
  items,
  accent: rgb("#73c25a"),
  box-fill: rgb("#ebedf5"),
  text-fill: rgb("#1f1f3a"),
  size: 18pt,
  radius: 8pt,
  gutter: 10pt,
  inset: 14pt,
) = {
  set text(size: size, fill: text-fill)
  set par(justify: false, leading: 0.5em)
  stack(dir: ttb, spacing: gutter, ..items.enumerate().map(((i, it)) => {
    let fill = if type(it) == array and it.len() > 1 { it.at(1) } else { box-fill }
    grid(columns: (auto, 1fr), column-gutter: gutter, align: (horizon, horizon),
      box(width: 1.6em, height: 1.6em, fill: accent, radius: 50%,
        align(center + horizon, text(fill: white, weight: "bold")[#(i + 1)])),
      box(width: 100%, fill: fill, radius: radius, inset: inset, _lab(it)))
  }))
}
