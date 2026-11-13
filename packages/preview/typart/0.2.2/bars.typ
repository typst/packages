// Bars: labelled horizontal bars with values (results, benchmarks).
// Import with:  #import "bars.typ": bars
//
//   #bars((([Ours], 94.2, rgb("#e64553")), ([Baseline A], 88.7), ([Baseline B], 81.3)), unit: "%")
#import "common.typ": _txt

#let bars(
  items,
  max: auto,
  unit: "",
  accent: rgb("#aab4f7"),
  track: luma(238),
  text-fill: rgb("#1f1f3a"),
  value-fill: white,
  size: 16pt,
  bar-h: 0.9cm,
  gap: 8pt,
) = layout(area => {
  let top = if max == auto { calc.max(..items.map(it => it.at(1))) } else { max }
  let names = items.map(it => _txt(it.at(0), text-fill, size, weight: auto))
  let bar-w = area.width - calc.max(..names.map(b => measure(b).width)) - 12pt
  let pad = bar-h / 3
  grid(columns: (auto, bar-w), column-gutter: 12pt, row-gutter: gap, align: (right + horizon, left + horizon),
    ..items.enumerate().map(((i, it)) => {
      let fill-w = bar-w * it.at(1) / top
      let inside = _txt([#it.at(1)#unit], value-fill, size * 0.85)
      // a value that does not fit in its bar goes just after it, in the text colour
      let fits = measure(inside).width + 2 * pad <= fill-w
      (
        names.at(i),
        box(width: bar-w, height: bar-h, fill: track, radius: bar-h / 2, {
          place(box(width: fill-w, height: bar-h, fill: it.at(2, default: accent), radius: bar-h / 2))
          if fits {
            place(left + horizon, dx: fill-w - pad - measure(inside).width, inside)
          } else {
            place(left + horizon, dx: fill-w + pad, _txt([#it.at(1)#unit], text-fill, size * 0.85))
          }
        }),
      )
    }).flatten())
})
