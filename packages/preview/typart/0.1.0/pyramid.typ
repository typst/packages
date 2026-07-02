// Pyramid (or funnel) diagram.  Import with:  #import "pyramid.typ": pyramid
//
//   #pyramid((([Vision],), [Strategy], ([Tactics], rgb("#e64553"))))
//   #pyramid(([Top], [Middle], [Bottom]), flip: true)   // funnel
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let pyramid(
  levels,
  width: 18,
  height: 12,
  text-fill: white,
  size: 22pt,
  gap: 0.18,
  flip: false,
) = canvas({
  import draw: *
  let n = levels.len()
  let hw(y) = (width / 2) * (if flip { y } else { height - y }) / height
  for (i, it) in levels.enumerate() {
    let col = _col(it, i)
    let yt = height * (1 - i / n) - (if i == 0 { 0 } else { gap / 2 })
    let yb = height * (1 - (i + 1) / n) + gap / 2
    line((-hw(yt), yt), (hw(yt), yt), (hw(yb), yb), (-hw(yb), yb),
      close: true, fill: col, stroke: white + 2pt)
    let yl = if flip { yt - (yt - yb) * 0.32 } else { yb + (yt - yb) * 0.32 }
    content((0, yl), box(width: calc.max(1.2, 2 * hw(yl) - 0.6) * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])))
  }
})
