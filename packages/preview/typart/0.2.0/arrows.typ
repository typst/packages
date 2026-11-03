// Converging or diverging arrows to/from a centre.  Import with:  #import "arrows.typ": arrows
//
//   #arrows(([Idea 1], [Idea 2], [Idea 3]), core: [Core])
//   #arrows(([Branch 1], [Branch 2]), diverge: true)
#import "common.typ": _arrow, _col, _dot, _fit, _in-circle, _label, _node, _put, _tallest, _txt, _u

#let arrows(
  items,
  core: none,
  diverge: false,
  radius: 4.8,
  bw: 3.6, bh: 1.6,
  text-fill: white, size: 16pt,
  core-fill: rgb("#1f1f3a"), core-r: 1.4,
) = context {
  let (bw, core-r) = (_u(bw), _u(core-r))
  let n = items.len()
  let labels = items.map(it => _label(it, text-fill, size))
  let bh = calc.max(_u(bh), _tallest(labels, bw - 0.4cm) + 0.8cm)
  let dirs = range(n).map(i => {
    let a = 90deg - i * 360deg / n
    (calc.cos(a), -calc.sin(a))
  })
  // distance from a box centre to its border along a spoke (slab method)
  let edge(ux, uy) = calc.min(
    if calc.abs(ux) > 1e-9 { bw / 2 / calc.abs(ux) } else { bw },
    if calc.abs(uy) > 1e-9 { bh / 2 / calc.abs(uy) } else { bh })
  // every arrow keeps at least 0.8cm of shaft
  let radius = calc.max(_u(radius), ..dirs.map(((ux, uy)) => core-r + 0.4cm + 0.8cm + 0.25cm + edge(ux, uy)))
  let xs = dirs.map(((x, y)) => radius * x)
  let ys = dirs.map(((x, y)) => radius * y)
  let x0 = calc.max(core-r, bw / 2 - calc.min(..xs))
  let y0 = calc.max(core-r, bh / 2 - calc.min(..ys))
  let width = x0 + calc.max(core-r, calc.max(..xs) + bw / 2)
  let height = y0 + calc.max(core-r, calc.max(..ys) + bh / 2)
  box(width: width, height: height, {
    for (i, it) in items.enumerate() {
      let (ux, uy) = dirs.at(i)
      let far = radius - edge(ux, uy) - 0.25cm
      let near-box = (x0 + far * ux, y0 + far * uy)
      let near-core = (x0 + (core-r + 0.4cm) * ux, y0 + (core-r + 0.4cm) * uy)
      let col = _col(it, i)
      if diverge {
        _arrow(near-core, near-box, paint: col, thickness: 6pt)
      } else {
        _arrow(near-box, near-core, paint: col, thickness: 6pt)
      }
      _node(x0 + radius * ux, y0 + radius * uy, bw, bh, labels.at(i), fill: col, radius: 0.15cm)
    }
    _dot(x0, y0, core-r, fill: core-fill, stroke: white + 2pt)
    if core != none {
      let w = 2 * core-r - 0.3cm
      _put(x0, y0, _txt(core, white, _fit((core,), white, size, w, _in-circle(core-r - 0.15cm))), w: w)
    }
  })
}
