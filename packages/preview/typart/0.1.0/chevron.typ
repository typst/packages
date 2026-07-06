// Chevron: sequential right-pointing arrows.  Import with:  #import "chevron.typ": chevron
//
//   #chevron(([Phase 1], [Phase 2], ([Phase 3], rgb("#e64553"))))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let chevron(
  items,
  w: 5,
  h: 2.4,
  notch: 0.9,
  text-fill: white,
  size: 18pt,
) = canvas({
  import draw: *
  let n = items.len()
  let step = w - notch
  let x0 = -(n * step) / 2
  for (i, it) in items.enumerate() {
    let x = x0 + i * step
    line((x, -h / 2), (x + w - notch, -h / 2), (x + w, 0),
         (x + w - notch, h / 2), (x, h / 2), (x + notch, 0),
         close: true, fill: _col(it, i), stroke: white + 1.5pt)
    content((x + w / 2 + notch / 2, 0), box(width: (w - notch) * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])))
  }
})
