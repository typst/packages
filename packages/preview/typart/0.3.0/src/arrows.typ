// Converging or diverging arrows to/from a centre.  Import with:  #import "arrows.typ": arrows
//
//   #arrows(([Idea 1], [Idea 2], [Idea 3]), core: [Core])
//   #arrows(([Branch 1], [Branch 2]), diverge: true)
#import "common.typ": _arrow, _canvas, _dot, _fit, _in-circle, _items, _lens, _node, _on, _or, _put, _tallest, _theme, _txt

#let arrows(
  items,
  core: none,
  diverge: false,
  radius: 8em,
  item-width: 6em,
  item-height: 2.7em,
  core-radius: 2.3em,
  core-fill: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("arrows", theme, style)
  let items = _items("arrows", items, t.palette)
  let (radius, bw, bh, core-r, size, em) = _lens("arrows", radius: radius, item-width: item-width,
    item-height: item-height, core-radius: core-radius, text-size: text-size, em: 1em).values()
  let n = items.len()
  let labels = items.map(it => _txt(it.label, _on(t, it.fill), size))
  let bh = calc.max(bh, _tallest(labels, bw - 0.7 * em) + 1.3 * em)
  let dirs = range(n).map(i => {
    let a = 90deg - i * 360deg / n
    (calc.cos(a), -calc.sin(a))
  })
  // distance from a box centre to its border along a spoke (slab method)
  let edge(ux, uy) = calc.min(
    if calc.abs(ux) > 1e-9 { bw / 2 / calc.abs(ux) } else { bw },
    if calc.abs(uy) > 1e-9 { bh / 2 / calc.abs(uy) } else { bh })
  // arrows stop short of the core and of their box, and keep at least 1.3em of shaft
  let (off-core, off-box) = (0.65 * em, 0.4 * em)
  // ... and neighbouring boxes stay apart: clear of each other across or down
  let clear(d, side) = if calc.abs(d) > 1e-9 { (side + off-box) / calc.abs(d) } else { float.inf * 1pt }
  let radius = calc.max(radius, ..dirs.map(((ux, uy)) => core-r + off-core + 1.3 * em + off-box + edge(ux, uy)),
    ..if n > 1 {
      dirs.zip(dirs.slice(1) + dirs.slice(0, 1)).map((((ax, ay), (bx, by))) => calc.min(clear(ax - bx, bw), clear(ay - by, bh)))
    })
  let xs = dirs.map(((x, y)) => radius * x)
  let ys = dirs.map(((x, y)) => radius * y)
  let x0 = calc.max(core-r, bw / 2 - calc.min(..xs))
  let y0 = calc.max(core-r, bh / 2 - calc.min(..ys))
  let w = x0 + calc.max(core-r, calc.max(..xs) + bw / 2)
  let h = y0 + calc.max(core-r, calc.max(..ys) + bh / 2)
  _canvas("arrows", t, width, area, w, h, {
    for (i, it) in items.enumerate() {
      let (ux, uy) = dirs.at(i)
      let far = radius - edge(ux, uy) - off-box
      let near-box = (x0 + far * ux, y0 + far * uy)
      let near-core = (x0 + (core-r + off-core) * ux, y0 + (core-r + off-core) * uy)
      let (from, to) = if diverge { (near-core, near-box) } else { (near-box, near-core) }
      _arrow(from, to, paint: it.fill, thickness: t.thick * 1.6)
      _node(shadow: t.shadow, x0 + radius * ux, y0 + radius * uy, bw, bh, labels.at(i), fill: it.fill, radius: t.corner-radius,
        inset: 0.35 * em)
    }
    _dot(shadow: t.shadow, x0, y0, core-r, fill: _or(core-fill, t.line), stroke: t.surface + 0.12 * em)
    if core != none {
      let cw = 2 * core-r - 0.5 * em
      _put(x0, y0, _txt(core, _on(t, _or(core-fill, t.line)), _fit((core,), t.ink, size, cw, _in-circle(core-r - 0.25 * em))), w: cw)
    }
  })
})
