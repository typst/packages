// ===========================================================================
//  sketchbook/engine.typ — the low-level sketch engine.
//
//  Reimplements the TikZ/PGF `sketch` decoration: every path is resampled
//  and offset perpendicular to itself, so lines look hand-drawn. The hot
//  loop is pure Typst (src/sketchcore.typ): a deterministic PRNG, so a given
//  seed always draws the same wobble. Pen strokes ("vintage" mode) are computed
//  by nibart (antique.typ).
//
//  Most users never import this directly — see blocks.typ / lib.typ.
// ===========================================================================

#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "antique.typ": nib-stroke, polyline-path
#import "theme.typ": theme-state

#import "sketchcore.typ" as core

/// Default decoration parameters (PGF's own defaults).
#let DEFAULTS = (
  segment: 0.5,      // sampling step, in pt
  amplitude: 0.5,    // wobble size, in pt  <- the main knob
  randomness: 2.0,   // irregularity of the wobble rhythm
  wavelength: 100.0, // length of one wobble
  epsilon: 0.02,     // output simplification tolerance, in pt (0 = off)
)

#let PT-PER-CM = 28.3465

// Typst's `str(float)` renders negatives with U+2212 (a real minus sign),
// which no Rust float parser accepts. Normalise before crossing the boundary.
#let fmt(x) = {
  let v = calc.round(x, digits: 5)
  if calc.abs(v) < 1e-9 { return "0.0" }
  str(v).replace("\u{2212}", "-")
}

// ---------------------------------------------------------------------------
//  decoration
// ---------------------------------------------------------------------------

/// Run the sketch decoration over a polyline given in canvas units (cm).
#let sketch-points(pts, seed: 1, closed: false, ..opt) = {
  let o = DEFAULTS + opt.named()
  let q = pts.map(p => (p.at(0) * PT-PER-CM, p.at(1) * PT-PER-CM))
  let out = core.decorate(q, segment: o.segment, amplitude: o.amplitude, randomness: o.randomness,
    wavelength: o.wavelength, seed: seed, closed: closed)
  out.map(p => (p.at(0) / PT-PER-CM, p.at(1) / PT-PER-CM))
}

/// PGF's `rand`, exposed: `n` values in [-1, 1] for a given seed.
#let randoms(seed, n) = core.randoms(seed, n)

// ---------------------------------------------------------------------------
//  drawing
// ---------------------------------------------------------------------------

/// Shared vintage branch for the stroke renderers: a plain fill plus a
/// nib-drawn outline, in the stroke's own paint (native colours kept).
#let _vintage-draw(q, closed, sty, vintage-pen: none) = {
  let fill = sty.at("fill", default: none)
  let stroke = sty.at("stroke", default: none)
  if fill != none {
    draw.line(..q, close: closed, fill: fill, stroke: none)
  }
  if stroke == none { return }
  let paint = stroke.at("paint", default: sty.at("paint", default: black))
  let th = stroke.at("thickness", default: sty.at("thickness", default: 1pt)) / 1cm
  let pen = if vintage-pen == none { (th * 1.7, th * 0.55, 24deg) } else { vintage-pen }
  nib-stroke(polyline-path(q), pen: pen, closed: closed, fill: paint)
}

/// A hand-drawn polyline. Extra named args go straight to CeTZ's `line`.
///
/// `vintage: true` renders the outline with an elliptical nib instead of a
/// constant-width stroke (the engraved look): the line is kept
/// straight (the wobble is dropped) and its thickness follows the pen's
/// angle to the path. The stroke's own `paint` is used, so a box stays in
/// its native colours.
#let s-line(pts, seed: 1, closed: false, vintage: false, vintage-pen: none,
            opts: (:), ..style) = {
  draw.get-ctx(_ => {
    let o = if vintage { opts + (amplitude: 0) } else { opts }
    let q = sketch-points(pts, seed: seed, closed: closed, ..o)
    if vintage {
      _vintage-draw(q, closed, style.named(), vintage-pen: vintage-pen)
    } else {
      draw.line(..q, close: closed, ..style)
    }
  })
}

// --- shape builders (return point lists) -----------------------------------
#let rect-pts(a, b) = (
  (a.at(0), a.at(1)), (b.at(0), a.at(1)),
  (b.at(0), b.at(1)), (a.at(0), b.at(1)),
)

#let arc-pts(centre, r, a0, a1, n: 40) = range(n + 1).map(i => {
  let a = (a0 + (a1 - a0) * i / n) * 1deg
  (centre.at(0) + r * calc.cos(a), centre.at(1) + r * calc.sin(a))
})

#let circle-pts(centre, r, n: 64) = arc-pts(centre, r, 0, 360, n: n)

#let ellipse-pts(centre, rx, ry, n: 72) = range(n + 1).map(i => {
  let a = 360deg * i / n
  (centre.at(0) + rx * calc.cos(a), centre.at(1) + ry * calc.sin(a))
})

#let bezier-pts(p0, c1, c2, p3, n: 24) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  let (a, b, c, d) = (u*u*u, 3*u*u*t, 3*u*t*t, t*t*t)
  (
    a*p0.at(0) + b*c1.at(0) + c*c2.at(0) + d*p3.at(0),
    a*p0.at(1) + b*c1.at(1) + c*c2.at(1) + d*p3.at(1),
  )
})

#let polygon-pts(centre, r, n: 5, start: 90) = range(n).map(i => {
  let a = (start + 360 * i / n) * 1deg
  (centre.at(0) + r * calc.cos(a), centre.at(1) + r * calc.sin(a))
})

#let star-pts(centre, r-outer, r-inner, n: 5, start: 90) = range(2 * n).map(i => {
  let r = if calc.even(i) { r-outer } else { r-inner }
  let a = (start + 360 * i / (2 * n)) * 1deg
  (centre.at(0) + r * calc.cos(a), centre.at(1) + r * calc.sin(a))
})

#let rounded-rect-pts(a, b, radius: 0.3, n: 8) = {
  // `a` is the top-left corner, `b` the bottom-right. No comparisons:
  // lengths may mix units (pt + em), which Typst cannot compare.
  let (x0, y0) = (a.at(0), a.at(1))
  let (x1, y1) = (b.at(0), b.at(1))
  let r = radius
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


/// A "plaque" outline: a rectangle whose corners curl INWARD in a quarter
/// arc, like a hand-drawn certificate border.
#let plaque-pts(a, b, curl: 0.42, n: 10) = {
  // `a` is the top-left corner, `b` the bottom-right. No comparisons:
  // lengths may mix units (pt + em), which Typst cannot compare.
  let (x0, y0) = (a.at(0), a.at(1))
  let (x1, y1) = (b.at(0), b.at(1))
  let r = curl
  // Each corner is a quarter arc centred OUTSIDE the box, so the edge bows
  // inward towards the middle -- the certificate/plaque look.
  let corner(cx, cy, a0, a1) = range(n + 1).map(i => {
    let ang = (a0 + (a1 - a0) * i / n) * 1deg
    (cx + r * calc.cos(ang), cy + r * calc.sin(ang))
  })
  let out = ()
  out.push((x0 + r, y0))
  out.push((x1 - r, y0))
  out += corner(x1, y0, 180, 90)          // bottom-right, bowing in
  out.push((x1, y1 - r))
  out += corner(x1, y1, 270, 180)         // top-right
  out.push((x0 + r, y1))
  out += corner(x0, y1, 0, -90)           // top-left
  out.push((x0, y0 + r))
  out += corner(x0, y0, 90, 0)            // bottom-left
  out
}

/// A stadium / pill: a rectangle with fully round ends.
#let stadium-pts(a, b, n: 18) = {
  let (x0, y0) = (calc.min(a.at(0), b.at(0)), calc.min(a.at(1), b.at(1)))
  let (x1, y1) = (calc.max(a.at(0), b.at(0)), calc.max(a.at(1), b.at(1)))
  let r = (y1 - y0) / 2
  let cxl = x0 + r
  let cxr = x1 - r
  let arc(cx, a0, a1) = range(n + 1).map(i => {
    let ang = (a0 + (a1 - a0) * i / n) * 1deg
    (cx + r * calc.cos(ang), (y0 + y1) / 2 + r * calc.sin(ang))
  })
  arc(cxr, -90, 90) + arc(cxl, 90, 270)
}

/// Catmull-Rom spline *through* the given points.
#let smooth-pts(pts, samples: 12, closed: false) = {
  let n = pts.len()
  if n < 3 { return pts }
  let idx(i) = if closed { pts.at(calc.rem(i + n, n)) } else {
    pts.at(calc.clamp(i, 0, n - 1))
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

/// Starburst / "explosion" outline around a rectangle.
#let starburst-pts(a, b, spacing: 0.42, spike: 0.34, jitter: 0.55, seed: 1) = {
  let (x0, y0) = (calc.min(a.at(0), b.at(0)), calc.min(a.at(1), b.at(1)))
  let (x1, y1) = (calc.max(a.at(0), b.at(0)), calc.max(a.at(1), b.at(1)))
  let (w, h) = (x1 - x0, y1 - y0)
  let nx = int(calc.max(2, calc.round(w / spacing)))
  let ny = int(calc.max(2, calc.round(h / spacing)))
  let r = randoms(seed, 2 * (nx + ny) + 4)
  if r.len() == 0 { return rect-pts(a, b) }

  let edge(p, q, n, ox, oy, k) = {
    let seg = ()
    for i in range(n) {
      let t0 = i / n
      let tm = (i + 0.5) / n
      let inner = (
        p.at(0) + (q.at(0) - p.at(0)) * t0,
        p.at(1) + (q.at(1) - p.at(1)) * t0,
      )
      let mid = (
        p.at(0) + (q.at(0) - p.at(0)) * tm,
        p.at(1) + (q.at(1) - p.at(1)) * tm,
      )
      let j1 = r.at(calc.rem(k + i, r.len()))
      let j2 = r.at(calc.rem(k + i + 7, r.len()))
      let len = spike * (1 + jitter * j1)
      let dent = spike * 0.18 * j2
      seg.push((inner.at(0) - ox * dent, inner.at(1) - oy * dent))
      seg.push((mid.at(0) + ox * len, mid.at(1) + oy * len))
    }
    (seg, k + n)
  }

  let out = ()
  let k = 0
  let e = edge((x0, y0), (x1, y0), nx, 0, -1, k); out += e.at(0); k = e.at(1)
  e = edge((x1, y0), (x1, y1), ny, 1, 0, k);      out += e.at(0); k = e.at(1)
  e = edge((x1, y1), (x0, y1), nx, 0, 1, k);      out += e.at(0); k = e.at(1)
  e = edge((x0, y1), (x0, y0), ny, -1, 0, k);     out += e.at(0)
  out
}

// ---------------------------------------------------------------------------
//  hatching  (scanline clip against the real outline, holes included)
// ---------------------------------------------------------------------------
#let hatch-segments(contours, angle: 45, spacing: 0.16, offset: 0.0) = {
  let cs = contours.map(ct => ct.map(p => (p.at(0) * PT-PER-CM, p.at(1) * PT-PER-CM)))
  core.hatch(cs, angle: angle, spacing: spacing * PT-PER-CM, offset: offset * PT-PER-CM).map(sg => (
    (sg.at(0).at(0) / PT-PER-CM, sg.at(0).at(1) / PT-PER-CM),
    (sg.at(1).at(0) / PT-PER-CM, sg.at(1).at(1) / PT-PER-CM),
  ))
}

#let s-hatch(contours, angle: 45, spacing: 0.16, offset: 0.0, shrink: 0.10,
             seed: 1, ..style) = {
  let segs = hatch-segments(contours, angle: angle, spacing: spacing,
    offset: offset)
  let i = 0
  for (a, b) in segs {
    let d = (b.at(0) - a.at(0), b.at(1) - a.at(1))
    let len = calc.sqrt(d.at(0) * d.at(0) + d.at(1) * d.at(1))
    if len > shrink * 2.2 {
      let u = (d.at(0) / len, d.at(1) / len)
      let t0 = shrink * (0.35 + 0.9 * calc.fract(calc.sin(i * 12.9898) * 43758.5453))
      let t1 = shrink * (0.35 + 0.9 * calc.fract(calc.sin(i * 78.233) * 43758.5453))
      s-line(
        ((a.at(0) + u.at(0) * t0, a.at(1) + u.at(1) * t0),
         (b.at(0) - u.at(0) * t1, b.at(1) - u.at(1) * t1)),
        seed: seed + i, ..style)
    }
    i += 1
  }
}


/// Outline + hatch in one call, for arbitrary contours.
///
/// `contours` is a list of point lists: the first is the outline, any further
/// ones are holes. Used for hatched lettering (see the gallery).
#let s-hatched-shape(
  contours,
  angle: 45,
  spacing: 0.16,
  shrink: 0.10,
  fill: none,
  hatch-stroke: (paint: black, thickness: 0.8pt),
  outline-stroke: (paint: black, thickness: 1.6pt),
  seed: 1,
) = {
  if fill != none {
    s-line(contours.first(), seed: seed, closed: true, stroke: none, fill: fill)
  }
  s-hatch(contours, angle: angle, spacing: spacing, shrink: shrink,
    seed: seed + 500, stroke: hatch-stroke)
  if outline-stroke != none {
    for (j, ct) in contours.enumerate() {
      s-line(ct, seed: seed + 900 + j * 30, closed: true,
        stroke: outline-stroke)
    }
  }
}


// ---------------------------------------------------------------------------
//  paintbrush
//
//  A pen stroke has one width; a brush does not. These build the OUTLINE of a
//  variable-width stroke, then fill it -- so the mark swells in the middle and
//  tapers at the ends like a loaded brush lifting off the paper.
// ---------------------------------------------------------------------------

/// Densify a polyline so the width profile has something to vary along.
#let densify(pts, n: 90) = {
  if pts.len() < 2 { return pts }
  // cumulative length
  let acc = (0.0,)
  for i in range(1, pts.len()) {
    let d = calc.sqrt(
      calc.pow(pts.at(i).at(0) - pts.at(i - 1).at(0), 2) +
      calc.pow(pts.at(i).at(1) - pts.at(i - 1).at(1), 2))
    acc.push(acc.last() + d)
  }
  let total = acc.last()
  if total <= 0 { return pts }
  range(n + 1).map(k => {
    let s = total * k / n
    let i = 0
    while i < acc.len() - 2 and acc.at(i + 1) < s { i += 1 }
    let seg = acc.at(i + 1) - acc.at(i)
    let u = if seg > 1e-9 { (s - acc.at(i)) / seg } else { 0.0 }
    let a = pts.at(i)
    let b = pts.at(i + 1)
    (a.at(0) + (b.at(0) - a.at(0)) * u, a.at(1) + (b.at(1) - a.at(1)) * u)
  })
}

/// Built-in width profiles, as functions of t in [0,1].
#let brush-profiles = (
  // fat middle, pointed ends -- a stroke laid down and lifted
  taper: t => calc.pow(calc.sin(calc.pi * t), 0.42),
  // heavy at the start, thinning away -- a brush running out of paint
  drag: t => calc.pow(1 - t, 0.55) * 0.9 + 0.1,
  // even, with just the ends rounded off
  flat: t => calc.min(1.0, calc.min(t, 1 - t) * 14 + 0.35),
  // swelling towards the end
  swell: t => 0.25 + 0.75 * calc.pow(t, 0.8),
)

/// The closed outline of a variable-width stroke along `pts`.
#let brush-outline(
  pts,
  width: 0.30,
  profile: "taper",
  n: 90,
) = {
  let path = densify(pts, n: n)
  let m = path.len()
  if m < 3 { return () }
  let prof = if type(profile) == function { profile }
    else { brush-profiles.at(profile, default: brush-profiles.taper) }

  let left = ()
  let right = ()
  for i in range(m) {
    let t = i / (m - 1)
    let w = width / 2 * calc.max(prof(t), 0.0)
    // tangent from the neighbours, so the normal turns smoothly
    let a = path.at(calc.max(i - 1, 0))
    let b = path.at(calc.min(i + 1, m - 1))
    let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
    let len = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-9)
    let (nx, ny) = (-dy / len, dx / len)
    let p = path.at(i)
    left.push((p.at(0) + nx * w, p.at(1) + ny * w))
    right.push((p.at(0) - nx * w, p.at(1) - ny * w))
  }
  left + right.rev()
}

/// A paintbrush stroke: the loaded body, plus bristle streaks and a few dry
/// gaps where the brush skipped.
#let s-brush(
  pts,
  colour: black,
  width: 0.30,
  profile: "taper",
  bristles: 5,          // thin streaks drawn along the stroke
  bristle-alpha: 55%,     // how much paler the bristle streaks are
  dry: 0.0,             // 0..1 -- how much the stroke breaks up
  opacity: 100%,
  seed: 1,
  roughness: 0.7,
  n: 90,
) = {
  let opts = (amplitude: 0.28 * roughness, wavelength: 260)
  let body = brush-outline(pts, width: width, profile: profile, n: n)
  let out = ()
  if body.len() > 2 {
    let c = if opacity == 100% { colour } else {
      colour.transparentize(100% - opacity)
    }
    out.push(s-line(body, seed: seed, closed: true, fill: c, stroke: none,
      opts: opts))
  }
  // bristle streaks: thin lines riding the stroke at different offsets
  if bristles > 0 {
    let path = densify(pts, n: n)
    let m = path.len()
    let r = randoms(seed * 7 + 3, bristles * 3 + 6)
    let prof = if type(profile) == function { profile }
      else { brush-profiles.at(profile, default: brush-profiles.taper) }
    for k in range(bristles) {
      let jitter = r.at(calc.rem(k, r.len()))
      let off = (k / calc.max(bristles - 1, 1) - 0.5) * 0.72 + jitter * 0.08
      // trim the ends so streaks sit inside the body
      let a = int(m * (0.16 + 0.14 * calc.abs(jitter)))
      let b = int(m * (0.84 - 0.14 * calc.abs(r.at(calc.rem(k + 2, r.len())))))
      if b - a > 4 {
        let line-pts = range(a, b).map(i => {
          let t = i / (m - 1)
          let w = width / 2 * calc.max(prof(t), 0.0)
          let pa = path.at(calc.max(i - 1, 0))
          let pb = path.at(calc.min(i + 1, m - 1))
          let (dx, dy) = (pb.at(0) - pa.at(0), pb.at(1) - pa.at(1))
          let ln = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-9)
          let p = path.at(i)
          // ride at a fraction of the LOCAL half-width, so the streak stays
          // inside the body wherever the stroke narrows
          (p.at(0) - dy / ln * w * off * 1.4, p.at(1) + dx / ln * w * off * 1.4)
        })
        out.push(s-line(line-pts, seed: seed + 40 + k * 11,
          stroke: (paint: colour.lighten(bristle-alpha), thickness: 0.7pt,
            cap: "round"),
          opts: (amplitude: 0.18, wavelength: 300)))
      }
    }
  }
  // dry patches: little pale nicks bitten out of the body
  if dry > 0 {
    let path = densify(pts, n: n)
    let m = path.len()
    let count = int(dry * 9)
    let r = randoms(seed * 13 + 5, count * 3 + 6)
    let prof2 = if type(profile) == function { profile }
      else { brush-profiles.at(profile, default: brush-profiles.taper) }
    for k in range(count) {
      let t = 0.12 + 0.74 * calc.rem(
        calc.abs(r.at(calc.rem(k * 2, r.len()))) * 3.7, 1.0)
      let i = int(t * (m - 1))
      let span = int(m * (0.03 + 0.05 * calc.abs(
        r.at(calc.rem(k * 2 + 1, r.len())))))
      let a = calc.max(i - span, 1)
      let b = calc.min(i + span, m - 2)
      if b - a > 1 {
        // a thin gap skimming along the stroke where the brush skipped
        let off = 0.55 * r.at(calc.rem(k * 3, r.len()))
        let seg = range(a, b + 1).map(j => {
          let tt = j / (m - 1)
          let w = width / 2 * calc.max(prof2(tt), 0.0)
          let pa = path.at(calc.max(j - 1, 0))
          let pb = path.at(calc.min(j + 1, m - 1))
          let (dx, dy) = (pb.at(0) - pa.at(0), pb.at(1) - pa.at(1))
          let ln = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-9)
          let p = path.at(j)
          (p.at(0) - dy / ln * w * off * 1.5, p.at(1) + dx / ln * w * off * 1.5)
        })
        out.push(s-line(seg, seed: seed + 200 + k,
          stroke: (paint: white.transparentize(25%),
            thickness: (width * 5.5) * 1pt, cap: "round"),
          opts: (amplitude: 0.15, wavelength: 300)))
      }
    }
  }
  out.join()
}

// ---------------------------------------------------------------------------
//  flat-3D extrusion of an arbitrary polygon
// ---------------------------------------------------------------------------
#let poly-area(pts) = {
  let a = 0.0
  let n = pts.len()
  for i in range(n) {
    let p = pts.at(i)
    let q = pts.at(calc.rem(i + 1, n))
    a += p.at(0) * q.at(1) - q.at(0) * p.at(1)
  }
  a / 2
}

/// Side faces only; draw before the front face.
#let extrude-sides(pts, off, fill: gray, stroke: none, seed: 1,
                   opts: (amplitude: 0.28, wavelength: 220)) = {
  let ccw = poly-area(pts) > 0
  let n = pts.len()
  let out = ()
  for i in range(n) {
    let p = pts.at(i)
    let q = pts.at(calc.rem(i + 1, n))
    let e = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let nx = if ccw { e.at(1) } else { -e.at(1) }
    let ny = if ccw { -e.at(0) } else { e.at(0) }
    if nx * off.at(0) + ny * off.at(1) > 1e-9 {
      out.push(s-line(
        (p, q, (q.at(0) + off.at(0), q.at(1) + off.at(1)),
         (p.at(0) + off.at(0), p.at(1) + off.at(1))),
        seed: seed + i * 7, closed: true, fill: fill, stroke: stroke,
        opts: opts))
    }
  }
  out.join()
}

// ---------------------------------------------------------------------------
//  Rough.js
//
//  Written in pure Typst (src/sketchcore.typ), in the manner of Rough.js
//  (MIT, Preet Shihn): every edge is overdrawn twice with a bowed Bezier,
//  ellipses are built from two passes, and the fill styles (hachure,
//  cross-hatch, zigzag, dots...) roughen their own strokes. A given seed
//  always draws the same shape. This reads more like a felt-tip sketch than
//  the pencil wobble of the `sketch` decoration above.
// ---------------------------------------------------------------------------

/// Rough.js drawing options.
#let ROUGH = (
  max-offset: 2.0,        // maxRandomnessOffset
  roughness: 1.0,         // 0 = clean, 1 = default, 3+ = very loose
  bowing: 1.0,            // how much each edge bows away from straight
  curve-tightness: 0.0,
  curve-fitting: 0.95,
  curve-step-count: 9.0,
  preserve-vertices: false,  // true = corners stay put
  disable-multi-stroke: false,  // true = draw each edge once, not twice
  seed: 1,
)

// rough options in pt, as the core expects them
#let _ro(o) = o

#let _back(passes) = passes.map(p => p.map(q => (q.at(0) / PT-PER-CM, q.at(1) / PT-PER-CM)))
#let _pt-pts(pts) = pts.map(p => (p.at(0) * PT-PER-CM, p.at(1) * PT-PER-CM))

/// Rough.js polyline: returns a LIST of point-lists (usually two passes).
#let rough-points(pts, closed: false, ..opt) = {
  let o = ROUGH + opt.named()
  _back(core.rough-poly(_pt-pts(pts), o, closed: closed))
}

/// Rough.js ellipse outline, as a list of point-lists.
#let rough-ellipse-points(centre, w, h, ..opt) = {
  let o = ROUGH + opt.named()
  _back(core.rough-ellipse(centre.at(0) * PT-PER-CM, centre.at(1) * PT-PER-CM, w * PT-PER-CM, h * PT-PER-CM, o))
}

/// Rough.js open curve through the given points.
#let rough-curve-points(pts, ..opt) = {
  let o = ROUGH + opt.named()
  _back(core.rough-curve(_pt-pts(pts), o))
}

// --- drawing wrappers ------------------------------------------------------

/// Draw a Rough.js polyline. `fill` fills the first pass only.
/// `vintage: true` draws the outline with an elliptical nib (straight
/// path, engraved thickness) in the stroke's own paint.
#let r-line(pts, closed: false, fill: none, vintage: false, vintage-pen: none,
            opts: (:), ..style) = {
  if vintage {
    return _vintage-draw(pts, closed, (fill: fill) + style.named(), vintage-pen: vintage-pen)
  }
  let passes = rough-points(pts, closed: closed, ..opts)
  let out = ()
  if fill != none and passes.len() > 0 {
    out.push(draw.line(..passes.first(), close: true, fill: fill,
      stroke: none))
  }
  for p in passes {
    out.push(draw.line(..p, ..style))
  }
  out.join()
}

/// Draw a Rough.js ellipse. `vintage: true` as for #r-line.
#let r-ellipse(centre, w, h, fill: none, vintage: false, vintage-pen: none,
               opts: (:), ..style) = {
  if vintage {
    return _vintage-draw(ellipse-pts(centre, w / 2, h / 2), true,
      (fill: fill) + style.named(), vintage-pen: vintage-pen)
  }
  let passes = rough-ellipse-points(centre, w, h, ..opts)
  let out = ()
  if fill != none and passes.len() > 0 {
    out.push(draw.line(..passes.first(), close: true, fill: fill,
      stroke: none))
  }
  for p in passes {
    out.push(draw.line(..p, ..style))
  }
  out.join()
}

#let r-circle(centre, r, ..a) = r-ellipse(centre, 2 * r, 2 * r, ..a)

/// Draw a Rough.js rectangle.
#let r-rect(a, b, ..rest) = r-line(rect-pts(a, b), closed: true, ..rest)

/// Draw a Rough.js open curve. `vintage: true` as for #r-line.
#let r-curve(pts, vintage: false, vintage-pen: none, opts: (:), ..style) = {
  if vintage {
    return _vintage-draw(resample-pts(pts, step: 0.4, closed: false),
      false, style.named(), vintage-pen: vintage-pen)
  }
  let passes = rough-curve-points(pts, ..opts)
  passes.map(p => draw.line(..p, ..style)).join()
}

// --- Rough.js fill styles --------------------------------------------------

/// The eight Rough.js fill styles.
#let FILL-STYLES = ("hachure", "solid", "zigzag", "cross-hatch", "dots",
                    "sunburst", "dashed", "zigzag-line")

/// Fill geometry for a set of contours: returns a list of polylines.
#let rough-fill-points(contours, style: "hachure", angle: -41, gap: 0.28,
                       seed: 1) = {
  _back(core.rough-fill(contours.map(_pt-pts), style, angle, gap * PT-PER-CM, seed))
}

/// Draw a Rough.js fill inside `contours`. Each fill line is itself roughened.
#let r-fill(contours, style: "hachure", angle: -41, gap: 0.28, seed: 1,
            colour: black, weight: 0.8pt, rough: true, opts: (:)) = {
  if style == "solid" {
    return draw.line(..contours.first(), close: true, fill: colour,
      stroke: none)
  }
  let lines = rough-fill-points(contours, style: style, angle: angle,
    gap: gap, seed: seed)
  let out = ()
  let st = (paint: colour, thickness: weight, cap: "round")
  for (i, l) in lines.enumerate() {
    if style == "dots" {
      out.push(draw.line(..l, close: true, fill: colour, stroke: none))
    } else if rough {
      // roughen each fill stroke, single pass like Rough.js does
      let o = (roughness: 1.0, disable-multi-stroke: true, seed: seed + i) + opts
      for p in rough-points(l, ..o) { out.push(draw.line(..p, stroke: st)) }
    } else {
      out.push(draw.line(..l, stroke: st))
    }
  }
  out.join()
}

/// A filled + stroked Rough.js shape in one call.
/// `vintage: true` (as for #r-line): plain fill + nib outline per contour.
#let r-shape(contours, style: "hachure", angle: -41, gap: 0.28, seed: 1,
             fill: none, stroke: none, weight: 0.8pt, vintage: false,
             vintage-pen: none, opts: (:)) = {
  if vintage {
    let out = ()
    for ct in contours {
      out.push(_vintage-draw(ct, true,
        (fill: if style == "solid" { fill } else { none }, stroke: stroke),
        vintage-pen: vintage-pen))
    }
    return out.join()
  }
  let out = ()
  if fill != none {
    out.push(r-fill(contours, style: style, angle: angle, gap: gap,
      seed: seed, colour: fill, weight: weight, opts: opts))
  }
  if stroke != none {
    for ct in contours {
      out.push(r-line(ct, closed: true, opts: opts, stroke: stroke))
    }
  }
  out.join()
}

/// A rough circular arc. Angles in degrees; `closed` draws the pie wedge.
#let r-arc(centre, w, h, start, end, closed: false, opts: (:), ..style) = {
  let o = ROUGH + opts
  let passes = _back(core.rough-arc(centre.at(0) * PT-PER-CM, centre.at(1) * PT-PER-CM, w * PT-PER-CM, h * PT-PER-CM,
    start * calc.pi / 180, end * calc.pi / 180, closed, o))
  passes.map(p => draw.line(..p, ..style)).join()
}

// ===========================================================================
//  Inner relief, after the `shadowed` package (TimVo): an SVG mask
//  blurred with feGaussianBlur, clipped to a rounded box — a true
//  Gaussian fall-off on every side and corner, which stacked copies or
//  gradient bands cannot match. `mode: "sunken"` (creusé) darkens the
//  top-left rim and lightens the bottom-right one; `"raised"` (bombé)
//  does the opposite. Returns an image the size of the box, meant to
//  lie on top of the box fill.
// ===========================================================================

#let relief(
  w, h,
  mode: "sunken",      // "sunken" (creusé) | "raised" (bombé)
  radius: 4pt,
  depth: 5pt,          // how far the rim fades inward
  strength: 0.55,      // rim opacity at the edge, 0-1
) = {
  // Soft inner rim built from stacked translucent rounded strokes, the
  // same recipe as fabox's outer shadows: each band sits a bit deeper
  // and a bit fainter, so the alphas pile up into a smooth Gaussian-like
  // fade on all four sides, corners included. Sunken stacks a symmetric
  // dark rim; raised stacks a diagonal bevel (light top-left, dark
  // bottom-right) via a gradient stroke paint.
  let sunk = mode == "sunken" or mode == "creuse"
  let L = 14
  let s = calc.min(1, calc.max(0, strength))
  block(width: w, height: h, clip: true, {
    if sunk {
      // one symmetric dark rim, all four sides
      for i in range(L) {
        let t = (i + 0.5) / L
        let c = depth * t
        let th = depth / L * 2.4
        let a = s * (1 - t) * (1 - t) * 2.6 / L
        if a > 0.004 {
          place(top + left, dx: c, dy: c,
            rect(width: w - 2 * c, height: h - 2 * c,
              radius: calc.max(radius - c, 0.4pt),
              stroke: (thickness: th,
                paint: black.transparentize(100% - a * 100%))))
        }
      }
    } else {
      // raised: a darker rim on the top side, then a lighter and
      // thinner one on the bottom side — the face reads bulged
      for i in range(L) {
        let t = (i + 0.5) / L
        let c = depth * t
        let th = depth / L * 2.4
        let a = s * (1 - t) * (1 - t) * 2.6 / L
        if a > 0.004 {
          place(top + left, dx: c, dy: c,
            rect(width: w - 2 * c, height: h - 2 * c,
              radius: calc.max(radius - c, 0.4pt),
              stroke: (thickness: th, paint: gradient.linear(
                (black.transparentize(100% - a * 100%), 0%),
                (black.transparentize(100% - a * 40%), 30%),
                (black.transparentize(100%), 100%),
                angle: 90deg))))
        }
      }
      let d2 = depth * 0.6
      for i in range(L) {
        let t = (i + 0.5) / L
        let c = d2 * t
        let th = d2 / L * 2.4
        let a = s * 0.5 * (1 - t) * (1 - t) * 2.6 / L
        if a > 0.004 {
          place(top + left, dx: c, dy: c,
            rect(width: w - 2 * c, height: h - 2 * c,
              radius: calc.max(radius - c, 0.4pt),
              stroke: (thickness: th, paint: gradient.linear(
                (white.transparentize(100%), 0%),
                (white.transparentize(100%), 45%),
                (white.transparentize(100% - a * 100%), 100%),
                angle: 90deg))))
        }
      }
    }
  })
}

/// A plain rounded box with a `shadowed`-style inner shadow: the
/// surface reads carved into the page (creusé).
///
/// ```typ
/// #insetbox[Cette boîte a une ombre interne.]
/// ```
#let insetbox(
  body,
  radius: 6pt,
  blur: 5pt,
  strength: 0.6,
  back: white,
  inset: (x: 12pt, y: 10pt),
  width: 100%,
) = context layout(avail => {
  let print-mode = theme-state.get().mode == "print"
  let back = if print-mode { white } else { back }
  if print-mode { set text(fill: black) }
  let W = if type(width) == ratio { avail.width * width } else { width }
  let inner = block(width: W, inset: inset, body)
  let H = measure(inner).height
  block(width: W, height: H, {
    place(top + left, rect(width: W, height: H, radius: radius, fill: back,
      stroke: if print-mode { 0.9pt + black } else { none }))
    place(top + left,
      relief(W, H, mode: "sunken", radius: radius, depth: blur,
        strength: strength))
    place(top + left, inner)
  })
})

/// French alias.
#let boite-creusee(..a) = insetbox(..a)

