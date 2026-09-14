// Hand-drawn lines, after the TikZ decoration `sketch`
// (tex.stackexchange.com/a/445690): a path is walked in steps of `segment`
// pt, every point is offset perpendicular to the path by
// `amplitude * sin(2πt/wavelength)`, where t performs a random walk with
// step `randomness^rand`. `rand` comes from the PGF generator (Park-Miller
// with Schrage's trick), so the same seed gives the same wobble as in
// LaTeX. All computed in Typst: a mind map has only a few dozen short
// paths, which needs no plugin.

#import "@preview/cetz:0.5.2"
#import "util.typ": _pt

// --- Hand-drawn lines ------------------------------------------------------
//
// After the TikZ decoration `sketch` (tex.stackexchange.com/a/445690): a
// path is walked in steps of `segment` pt, every point is offset
// perpendicular to the path by `amplitude * sin(2πt/wavelength)`, where t
// performs a random walk with step `randomness^rand`. `rand` comes from the
// PGF generator (Park-Miller with Schrage's trick), so the same seed gives
// the same wobble as in LaTeX. All computed in Typst: a mind map has only a
// few dozen short paths, which needs no plugin.

#let _rng-next(z) = {
  let t = 69621 * calc.rem(z, 30845) - 23902 * calc.quo(z, 30845)
  if t < 0 { t + 2147483647 } else { t }
}

#let _rng-seed(seed) = {
  let z = calc.rem(seed, 2147483647)
  if z <= 0 { z + 2147483646 } else { z }
}

// Uniform on [-1, 1], quantised to five decimals as in TeX.
#let _rng-rand(z) = (calc.rem(z, 200001) - 100000) / 100000

// Wobbles a polyline (points as (x, y) in pt, plain numbers). Returns the
// new points. `closed` closes at the start point.
#let _wobble(pts, hand, seed, closed: false) = {
  let pts = if closed { pts + (pts.first(),) } else { pts }
  let total = range(1, pts.len()).map(i => {
    let (ax, ay) = pts.at(i - 1)
    let (bx, by) = pts.at(i)
    calc.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
  }).sum(default: 0.0)
  let z = _rng-seed(seed)
  let t = 0.0
  let out = (pts.first(),)
  let carry = 0.0     // leftover step from the previous segment
  let done = 0.0      // length walked so far
  let off = 0.0
  for i in range(1, pts.len()) {
    let (ax, ay) = pts.at(i - 1)
    let (bx, by) = pts.at(i)
    let (dx, dy) = (bx - ax, by - ay)
    let len = calc.sqrt(dx * dx + dy * dy)
    if len < 1e-9 { continue }
    let (tx, ty) = (dx / len, dy / len)
    let (nx, ny) = (-ty, tx)
    let d = carry
    while d <= len {
      z = _rng-next(z)
      t = calc.rem(t + calc.pow(hand.randomness, _rng-rand(z)), hand.wavelength)
      off = calc.sin(2 * calc.pi * t / hand.wavelength * 1rad) * hand.amplitude
      // Closed paths: the offset fades out before closing, otherwise a notch
      // remains at the start point.
      if closed { off *= calc.min(1, (total - done - d) / (4 * hand.segment)) }
      out.push((ax + tx * d + nx * off, ay + ty * d + ny * off))
      d += hand.segment
    }
    carry = d - len
    done += len
  }
  if closed { out.push(pts.first()) } else {
    let (ax, ay) = pts.at(pts.len() - 2)
    let (bx, by) = pts.last()
    let (dx, dy) = (bx - ax, by - ay)
    let len = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-9)
    out.push((bx - dy / len * off, by + dx / len * off))
  }
  out
}

// A seed from coordinates, so every line wobbles differently while the
// result stays reproducible.
#let _seed(..xs) = {
  let h = 7
  for x in xs.pos() { h = calc.rem(h * 31 + int(calc.round(calc.abs(x) * 10)), 1000003) }
  h + 1
}

// Cubic Bézier curve as a polyline.
#let _flatten-bezier(p0, c0, c1, p1, n: 24) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  let (a, b, c, d) = (u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t)
  (a * p0.at(0) + b * c0.at(0) + c * c1.at(0) + d * p1.at(0),
   a * p0.at(1) + b * c0.at(1) + c * c1.at(1) + d * p1.at(1))
})

// Rounded rectangle around (cx, cy) as a polyline.
#let _rounded-rect(cx, cy, w, h, r, n: 6) = {
  let r = calc.min(r, w / 2, h / 2)
  if r <= 0.01 {
    return ((cx - w / 2, cy - h / 2), (cx + w / 2, cy - h / 2), (cx + w / 2, cy + h / 2), (cx - w / 2, cy + h / 2))
  }
  let corner(x, y, a0) = range(n + 1).map(i => {
    let a = a0 + 90deg * i / n
    (x + r * calc.cos(a), y + r * calc.sin(a))
  })
  let out = corner(cx + w / 2 - r, cy - h / 2 + r, -90deg)
  out += corner(cx + w / 2 - r, cy + h / 2 - r, 0deg)
  out += corner(cx - w / 2 + r, cy + h / 2 - r, 90deg)
  out += corner(cx - w / 2 + r, cy - h / 2 + r, 180deg)
  out
}

// Draws a polyline (numbers in pt) hand-drawn, in `passes` layers.
#let _hand-line(pts, st, hand, seed, closed: false, fill: none) = {
  import cetz.draw: line
  for p in range(hand.passes) {
    let q = _wobble(pts, hand, seed + 977 * p, closed: closed)
    line(..q, close: closed, stroke: st, fill: if p == 0 { fill } else { none })
  }
}

// The outline of a node as a wobbly path, at (cx, cy) given as lengths.
// Ellipse around (cx, cy) as a polyline.
#let _ellipse-pts(cx, cy, rx, ry, n: 48) = range(n).map(i => {
  let a = 360deg * i / n
  (cx + rx * calc.cos(a), cy + ry * calc.sin(a))
})
