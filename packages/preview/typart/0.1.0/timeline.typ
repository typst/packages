// Timeline: milestones along a horizontal line.  Import with:  #import "timeline.typ": timeline
//
//   #timeline((("2024", [Start]), ("2025", [Pilot]), ("2026", [Launch])))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let timeline(
  items,
  accent: rgb("#73c25a"),
  text-fill: rgb("#1f1f3a"),
  size: 16pt, date-size: 14pt, step: 5,
) = canvas({
  import draw: *
  let n = items.len()
  let x = i => i * step
  line((-step * 0.5, 0), ((n - 1) * step + step * 0.6, 0),
    mark: (end: ">", fill: accent), stroke: accent + 4pt)
  for (i, it) in items.enumerate() {
    let xi = x(i)
    let col = it.at(2, default: palette.at(calc.rem(i, palette.len())))
    let up = calc.rem(i, 2) == 0
    let s = if up { 1 } else { -1 }
    line((xi, 0), (xi, s * 0.9), stroke: col + 2pt)
    circle((xi, 0), radius: 0.28, fill: col, stroke: white + 2pt)
    content((xi, s * 1.25), text(fill: accent, weight: "bold", size: date-size)[#it.at(0)])
    content((xi, s * 2.05), box(width: (step + 0.4) * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#it.at(1)])))
  }
})
