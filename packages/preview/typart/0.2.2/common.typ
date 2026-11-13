// Shared utilities: colour palette, item accessors and native drawing helpers.
// Coordinates are Typst lengths with y pointing down; numeric sizes are cm.
#let palette = (
  rgb("#aab4f7"),   // lavender
  rgb("#a7dd9b"),   // green
  rgb("#f9c74f"),   // amber
  rgb("#e64553"),   // red
  rgb("#74c7ec"),   // sky
)
#let _lab(it) = if type(it) == array { it.at(0) } else { it }
#let _col(it, i, at: 1) = if type(it) == array and it.len() > at { it.at(at) } else { palette.at(calc.rem(i, palette.len())) }
#let _u(x) = if type(x) == length { x } else { x * 1cm }

#let _txt(body, fill, size, weight: "bold") = {
  set par(justify: false)
  text(fill: fill, size: size, ..if weight != auto { (weight: weight) }, body)
}

#let _label(it, fill, size) = _txt(_lab(it), fill, size)

// Measuring helpers; call them inside `context`.
#let _tallest(bodies, w) = calc.max(0pt, ..bodies.map(b => measure(b, width: w).height))

// Largest size <= `size` at which every label, wrapped at width w, fits its slot
// (one shared size, as in SmartArt).  w is a length or per-label array; h is a
// maximum height (length or array) or a test `(i, width, height) => bool` for
// shaped slots.  A label that fits at `size` fits at any smaller size, so only
// the overflowing ones are re-measured while bisecting on the size.
#let _fit(labels, fill, size, w, h) = {
  let n = labels.len()
  let ws = if type(w) == array { w } else { (w,) * n }
  let inside = if type(h) == function { h } else if type(h) == array { (i, lw, lh) => lh <= h.at(i) } else { (i, lw, lh) => lh <= h }
  let fits(i, s) = {
    let m = measure(_txt(labels.at(i), fill, s), width: ws.at(i))
    m.width <= ws.at(i) + 0.01pt and inside(i, m.width, m.height)
  }
  let over = range(n).filter(i => not fits(i, size))
  if over.len() == 0 { return size }
  let (lo, hi) = (size * 0.3, size)
  for _ in range(6) {
    let mid = (lo + hi) / 2
    if over.all(i => fits(i, mid)) { lo = mid } else { hi = mid }
  }
  lo
}

// Slot test for a label centred in a circle of radius r: its corners stay inside.
#let _in-circle(r) = (i, lw, lh) => calc.norm(lw / 2pt, lh / 2pt) * 1pt <= r

// Centre `body` on (x, y), wrapping at width `w`.  The tall slot gives `horizon`
// room to centre any number of lines; being placed, it takes no space.
#let _put(x, y, body, w: 40cm) = place(top + left, dx: x - w / 2, dy: y - 50cm,
  box(width: w, height: 100cm, align(center + horizon, body)))

#let _poly(..pts, fill: none, stroke: none) = place(top + left, polygon(fill: fill, stroke: stroke, ..pts))

#let _dot(x, y, r, fill: none, stroke: none) = place(top + left, dx: x - r, dy: y - r,
  circle(radius: r, fill: fill, stroke: stroke))

// Filled triangular arrowhead whose base centre is `from` and tip is `tip`.
#let _head(from, tip, paint, half) = {
  let (fx, fy) = from
  let (tx, ty) = tip
  let len = calc.norm((tx - fx) / 1pt, (ty - fy) / 1pt) * 1pt
  let (nx, ny) = (-(ty - fy) / len, (tx - fx) / len)
  _poly(tip, (fx + nx * half, fy + ny * half), (fx - nx * half, fy - ny * half), fill: paint)
}

// Polyline through `pts` with arrowheads at its ends; head size scales with the stroke.
#let _arrow(..pts, paint: black, thickness: 2pt, head: auto, start: false, end: true, dash: none) = {
  let pts = pts.pos()
  let hl = if head == auto { thickness * 2.6 + 3pt } else { head }
  // the point d before `to` on the segment from `from`
  let back(from, to, d) = {
    let len = calc.norm((to.at(0) - from.at(0)) / 1pt, (to.at(1) - from.at(1)) / 1pt) * 1pt
    (to.at(0) - (to.at(0) - from.at(0)) * (d / len), to.at(1) - (to.at(1) - from.at(1)) * (d / len))
  }
  let shaft = pts
  if end { shaft.at(-1) = back(pts.at(-2), pts.at(-1), hl * 0.8) }
  if start { shaft.at(0) = back(pts.at(1), pts.at(0), hl * 0.8) }
  place(top + left, curve(stroke: (paint: paint, thickness: thickness, join: "round", dash: dash),
    curve.move(shaft.first()), ..shaft.slice(1).map(curve.line)))
  if end { _head(back(pts.at(-2), pts.at(-1), hl), pts.at(-1), paint, hl * 0.5) }
  if start { _head(back(pts.at(1), pts.at(0), hl), pts.at(0), paint, hl * 0.5) }
}

// Point on a circle; angles are counter-clockwise from +x as on paper.
#let _polar(cx, cy, r, a) = (cx + r * calc.cos(a), cy - r * calc.sin(a))

// Cubic Bézier segments of the arc from angle a0 to a1 (start point excluded);
// `ry` makes it an elliptical arc with vertical radius ry.
#let _arc(cx, cy, r, a0, a1, ry: auto) = {
  let sy = if ry == auto { 1 } else { ry / r }
  let n = calc.max(1, calc.ceil(calc.abs((a1 - a0) / 90deg)))
  let d = (a1 - a0) / n
  let k = 4 / 3 * calc.tan(d / 4) * r
  let pt(a) = (cx + r * calc.cos(a), cy - r * sy * calc.sin(a))
  range(n).map(i => {
    let s = a0 + i * d
    let e = s + d
    let (sx, sy0) = pt(s)
    let (ex, ey) = pt(e)
    curve.cubic(
      (sx - k * calc.sin(s), sy0 - k * sy * calc.cos(s)),
      (ex + k * calc.sin(e), ey + k * sy * calc.cos(e)),
      (ex, ey))
  })
}

// An open elliptical ring centred on (cx, cy), its arrowhead turning anticlockwise at the top.
#let _loop(cx, cy, rx, ry, paint, t) = {
  let hl = t * 2.5 + 4pt
  let pt(a) = (cx + rx * calc.cos(a), cy - ry * calc.sin(a))
  let a1 = 450deg - hl / rx * 1rad
  place(top + left, curve(stroke: (paint: paint, thickness: t, cap: "round"), curve.move(pt(125deg)),
    .._arc(cx, cy, rx, 125deg, a1 + hl * 0.2 / rx * 1rad, ry: ry)))
  _head(pt(a1), pt(450deg), paint, hl * 0.6)
}

// Box of size w x h centred on (x, y) with `body` centred inside.
#let _node(x, y, w, h, body, fill: none, stroke: none, radius: 0pt, inset: 0.2cm) = place(top + left,
  dx: x - w / 2, dy: y - h / 2,
  box(width: w, height: h, fill: fill, stroke: stroke, radius: radius, inset: (x: inset),
    align(center + horizon, body)))
