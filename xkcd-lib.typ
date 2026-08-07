// ============================================================================
//  xkcd-lib.typ — the TikZ/PGF "sketch" decoration for Typst + CeTZ,
//  with the hot loop implemented as a Rust WASM plugin.
//
//  Ports https://tex.stackexchange.com/a/445690 (Frunobulax, CC BY-SA 4.0),
//  retrieved 2026-07-27.
//
//  Typst 0.15.1 / CeTZ 0.5.2 / plugin built for wasm32-unknown-unknown.
// ============================================================================

#import "@preview/cetz:0.5.2"
#import cetz.draw

#let sketch-plugin = plugin("sketch.wasm")

// PGF defaults, from the \pgfset block in the original document
#let DEFAULTS = (
  segment: 0.5,     // segment length, in TeX points
  amplitude: 0.5,   // amplitude,      in TeX points
  randomness: 2.0,  // /pgf/decoration/randomness
  wavelength: 100.0,// /pgf/decoration/wavelength
  epsilon: 0.02,    // RDP simplification tolerance, in pt (0 disables)
)

#let PT-PER-CM = 28.3465

// CAREFUL: Typst's `str(float)` renders negative numbers with a Unicode
// MINUS SIGN (U+2212), not ASCII "-", which no Rust float parser accepts.
// Normalise it here.
#let fmt(x) = {
  let v = calc.round(x, digits: 5)
  if calc.abs(v) < 1e-9 { return "0.0" }
  str(v).replace("\u{2212}", "-")
}

// ---------------------------------------------------------------------------
//  low-level: run the decoration over a polyline given in *canvas units*
//  (cm by default). Returns a new polyline in canvas units.
// ---------------------------------------------------------------------------
#let sketch-points(
  pts,
  seed: 1,
  closed: false,
  scale: (1.0, 1.0),
  ..opt,
) = {
  let o = DEFAULTS + opt.named()
  // The decoration runs in *paper* space: TikZ applies xscale/yscale to the
  // coordinates, then decorates, so the wobble is never stretched. We do the
  // same by pre-multiplying here and dividing back afterwards.
  let (sx, sy) = scale
  let flat = ()
  for p in pts {
    flat.push(fmt(p.at(0) * sx * PT-PER-CM))
    flat.push(fmt(p.at(1) * sy * PT-PER-CM))
  }
  let params = (
    o.segment, o.amplitude, o.randomness, o.wavelength,
    seed, if closed { 1 } else { 0 }, o.epsilon,
  ).map(fmt).join(" ")

  let out = str(sketch-plugin.decorate(
    bytes(params),
    bytes(flat.join(" ")),
  ))
  if out.trim() == "" { return pts }
  let nums = out.split(" ").map(float)
  let res = ()
  for i in range(0, int(nums.len() / 2)) {
    res.push((
      nums.at(2 * i) / PT-PER-CM / sx,
      nums.at(2 * i + 1) / PT-PER-CM / sy,
    ))
  }
  res
}

// ---------------------------------------------------------------------------
//  path builders — everything is flattened to a polyline, then decorated
// ---------------------------------------------------------------------------
#let flatten-bezier(p0, c1, c2, p3, n: 24) = {
  range(n + 1).map(i => {
    let t = i / n
    let u = 1 - t
    let (a, b, c, d) = (u*u*u, 3*u*u*t, 3*u*t*t, t*t*t)
    (
      a*p0.at(0) + b*c1.at(0) + c*c2.at(0) + d*p3.at(0),
      a*p0.at(1) + b*c1.at(1) + c*c2.at(1) + d*p3.at(1),
    )
  })
}

#let flatten-arc(center, r, start-deg, end-deg, n: 40) = {
  range(n + 1).map(i => {
    let a = (start-deg + (end-deg - start-deg) * i / n) * 1deg
    (center.at(0) + r * calc.cos(a), center.at(1) + r * calc.sin(a))
  })
}

#let flatten-circle(center, r, n: 64) = flatten-arc(center, r, 0, 360, n: n)

#let rect-points(a, b) = (
  (a.at(0), a.at(1)), (b.at(0), a.at(1)),
  (b.at(0), b.at(1)), (a.at(0), b.at(1)),
)

// sample y = f(x) like TikZ's  plot[domain=..,samples=..]
#let plot-points(f, from, to, samples: 100) = {
  range(samples + 1).map(i => {
    let x = from + (to - from) * i / samples
    (x, f(x))
  })
}

// ---------------------------------------------------------------------------
//  drawing wrappers (CeTZ elements)
// ---------------------------------------------------------------------------
#let xkcd-line(pts, seed: auto, closed: false, scale: (1.0, 1.0), opts: (:), ..style) = {
  draw.get-ctx(ctx => {
    let s = if seed == auto { 1 } else { seed }
    let q = sketch-points(pts, seed: s, closed: closed, scale: scale, ..opts)
    draw.line(..q, close: closed, ..style)
  })
}

#let xkcd-rect(a, b, seed: 1, scale: (1.0, 1.0), opts: (:), ..style) = {
  xkcd-line(rect-points(a, b), seed: seed, closed: true, scale: scale, opts: opts, ..style)
}

#let xkcd-circle(c, r, seed: 1, scale: (1.0, 1.0), opts: (:), ..style) = {
  xkcd-line(flatten-circle(c, r), seed: seed, closed: true, scale: scale, opts: opts, ..style)
}

#let xkcd-arc(c, r, a0, a1, seed: 1, scale: (1.0, 1.0), opts: (:), ..style) = {
  xkcd-line(flatten-arc(c, r, a0, a1), seed: seed, scale: scale, opts: opts, ..style)
}

#let xkcd-plot(f, from, to, samples: 100, seed: 1, scale: (1.0, 1.0), opts: (:), ..style) = {
  xkcd-line(plot-points(f, from, to, samples: samples), seed: seed, scale: scale, opts: opts, ..style)
}

// grid, each line decorated separately (as TikZ does)
#let xkcd-grid(a, b, step: 1, seed: 1, scale: (1.0, 1.0), ..style) = {
  let out = ()
  let i = a.at(0)
  let k = seed
  while i <= b.at(0) + 1e-9 {
    out.push(xkcd-line(((i, a.at(1)), (i, b.at(1))), seed: k, scale: scale, ..style))
    i += step
    k += 1
  }
  let j = a.at(1)
  while j <= b.at(1) + 1e-9 {
    out.push(xkcd-line(((a.at(0), j), (b.at(0), j)), seed: k, scale: scale, ..style))
    j += step
    k += 1
  }
  out.join()
}

// the pltblue of the original: \definecolor{pltblue}{HTML}{1F77B4}
#let pltblue = rgb("#1F77B4")

// ===========================================================================
//  General-purpose shapes.
//
//  None of this is special-cased in the engine: every one of these just
//  builds a list of points and hands it to the same decorator. If you can
//  compute coordinates for it, you can draw it.
// ===========================================================================

#let ellipse-points(center, rx, ry, n: 72) = {
  range(n + 1).map(i => {
    let a = 360deg * i / n
    (center.at(0) + rx * calc.cos(a), center.at(1) + ry * calc.sin(a))
  })
}

// regular n-gon; `start` rotates it (degrees)
#let polygon-points(center, r, n: 5, start: 90) = {
  range(n).map(i => {
    let a = (start + 360 * i / n) * 1deg
    (center.at(0) + r * calc.cos(a), center.at(1) + r * calc.sin(a))
  })
}

// star with `n` spikes, alternating outer/inner radius
#let star-points(center, r-outer, r-inner, n: 5, start: 90) = {
  range(2 * n).map(i => {
    let r = if calc.even(i) { r-outer } else { r-inner }
    let a = (start + 360 * i / (2 * n)) * 1deg
    (center.at(0) + r * calc.cos(a), center.at(1) + r * calc.sin(a))
  })
}

#let rounded-rect-points(a, b, radius: 0.3, n: 8) = {
  let (x0, y0) = (calc.min(a.at(0), b.at(0)), calc.min(a.at(1), b.at(1)))
  let (x1, y1) = (calc.max(a.at(0), b.at(0)), calc.max(a.at(1), b.at(1)))
  let r = calc.min(radius, (x1 - x0) / 2, (y1 - y0) / 2)
  let corner(cx, cy, a0) = range(n + 1).map(i => {
    let a = (a0 + 90 * i / n) * 1deg
    (cx + r * calc.cos(a), cy + r * calc.sin(a))
  })
  let out = ((x0 + r, y0),)
  out += corner(x1 - r, y0 + r, -90)
  out += corner(x1 - r, y1 - r, 0)
  out += corner(x0 + r, y1 - r, 90)
  out += corner(x0 + r, y0 + r, 180)
  out
}

// pie/donut wedge: centre -> arc -> back to centre
#let wedge-points(center, r, a0, a1, n: 32) = {
  (center,) + flatten-arc(center, r, a0, a1, n: n)
}

// smooth curve THROUGH a set of points (Catmull-Rom spline)
#let smooth-points(pts, samples: 12, closed: false) = {
  let n = pts.len()
  if n < 3 { return pts }
  let idx(i) = {
    if closed { pts.at(calc.rem(i + n, n)) }
    else { pts.at(calc.clamp(i, 0, n - 1)) }
  }
  let last = if closed { n - 1 } else { n - 2 }
  let out = ()
  for i in range(0, last + 1) {
    let (p0, p1, p2, p3) = (idx(i - 1), idx(i), idx(i + 1), idx(i + 2))
    for s in range(samples) {
      let t = s / samples
      let (t2, t3) = (t * t, t * t * t)
      out.push(range(2).map(k => 0.5 * (
        2 * p1.at(k)
        + (-p0.at(k) + p2.at(k)) * t
        + (2 * p0.at(k) - 5 * p1.at(k) + 4 * p2.at(k) - p3.at(k)) * t2
        + (-p0.at(k) + 3 * p1.at(k) - 3 * p2.at(k) + p3.at(k)) * t3
      )))
    }
  }
  if not closed { out.push(pts.last()) }
  out
}

#let xkcd-ellipse(c, rx, ry, seed: 1, ..style) = {
  xkcd-line(ellipse-points(c, rx, ry), seed: seed, closed: true, ..style)
}
#let xkcd-polygon(c, r, n: 5, start: 90, seed: 1, ..style) = {
  xkcd-line(polygon-points(c, r, n: n, start: start), seed: seed, closed: true, ..style)
}
#let xkcd-star(c, r-outer, r-inner, n: 5, start: 90, seed: 1, ..style) = {
  xkcd-line(star-points(c, r-outer, r-inner, n: n, start: start),
    seed: seed, closed: true, ..style)
}
#let xkcd-rounded-rect(a, b, radius: 0.3, seed: 1, ..style) = {
  xkcd-line(rounded-rect-points(a, b, radius: radius), seed: seed, closed: true, ..style)
}
#let xkcd-wedge(c, r, a0, a1, seed: 1, ..style) = {
  xkcd-line(wedge-points(c, r, a0, a1), seed: seed, closed: true, ..style)
}
#let xkcd-smooth(pts, samples: 12, closed: false, seed: 1, ..style) = {
  xkcd-line(smooth-points(pts, samples: samples, closed: closed),
    seed: seed, closed: closed, ..style)
}
#let xkcd-bezier(p0, c1, c2, p3, seed: 1, ..style) = {
  xkcd-line(flatten-bezier(p0, c1, c2, p3), seed: seed, ..style)
}
