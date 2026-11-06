// ===========================================================================
//  geomtools/canvas.typ — the drawing backend.
//
//  Every tool in this package is described ONCE, as plain geometry: a list of
//  polygons, polylines, circles, arcs and labels. This module then renders
//  that description in one of two modes:
//
//    "clean"  — crisp lines, exactly as the LaTeX original draws them
//    "rough"  — the same geometry re-drawn with a hand-drawn wobble
//
//  Writing each tool twice would guarantee the two modes drift apart, so the
//  mode is a property of the RENDERER, never of the tool.
//
//  Coordinates arrive in maths orientation (y up, centimetres) and are
//  flipped exactly once, here.
// ===========================================================================

// --- geometry helpers ------------------------------------------------------
#let sh-map(ct, sh) = ct.map(sh)
#let vadd(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let vsub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vmul(a, k) = (a.at(0) * k, a.at(1) * k)
#let vnorm(a) = calc.sqrt(a.at(0) * a.at(0) + a.at(1) * a.at(1))
#let dist(a, b) = vnorm(vsub(a, b))
#let vangle(a) = calc.atan2(a.at(0), a.at(1))

/// Rotate `p` about the origin by `ang`, then translate by `at`, then scale.
#let xform(p, at: (0, 0), rot: 0deg, scale: 1.0, flip-y: false) = {
  let (x, y) = p
  if flip-y { y = -y }
  x *= scale
  y *= scale
  let (co, si) = (calc.cos(rot), calc.sin(rot))
  (at.at(0) + x * co - y * si, at.at(1) + x * si + y * co)
}

/// Points along a circular arc.
#let arc-pts(centre, r, a0, a1, steps: 64) = {
  let n = calc.max(2, steps)
  range(n + 1).map(i => {
    let t = a0 + (a1 - a0) * i / n
    vadd(centre, (r * calc.cos(t), r * calc.sin(t)))
  })
}

#let circle-pts(centre, r, steps: 96) = arc-pts(centre, r, 0deg, 360deg,
  steps: steps)

/// A rectangle as a closed contour.
#let rect-pts(a, b) = (
  (a.at(0), a.at(1)), (b.at(0), a.at(1)),
  (b.at(0), b.at(1)), (a.at(0), b.at(1)),
)

// ---------------------------------------------------------------------------
//  the primitive list
// ---------------------------------------------------------------------------
//  A tool returns an array of these. Keeping them as data (rather than as
//  content) is what lets the same description be drawn crisp or rough.

#let p-poly(pts, closed: true, fill: none, stroke: auto, weight: 1.0,
            role: "edge", dash: none) = ((
  kind: "poly", pts: pts, closed: closed, fill: fill, stroke: stroke,
  weight: weight, role: role, dash: dash,
),)

#let p-line(a, b, stroke: auto, weight: 1.0, role: "tick", dash: none) = ((
  kind: "poly", pts: (a, b), closed: false, fill: none, stroke: stroke,
  weight: weight, role: role, dash: dash,
),)

#let p-circle(centre, r, fill: none, stroke: auto, weight: 1.0,
              role: "edge", dash: none) = ((
  kind: "circle", centre: centre, r: r, fill: fill, stroke: stroke,
  weight: weight, role: role, dash: dash,
),)

#let p-arc(centre, r, a0, a1, wedge: false, fill: none, stroke: auto,
           weight: 1.0, role: "edge", dash: none) = ((
  kind: "arc", centre: centre, r: r, a0: a0, a1: a1, wedge: wedge,
  fill: fill, stroke: stroke, weight: weight, role: role, dash: dash,
),)

#let p-label(pos, body, size: 6pt, fill: auto, rotate: 0deg,
             anchor: "centre") = ((
  kind: "label", pos: pos, body: body, size: size, fill: fill,
  rotate: rotate, anchor: anchor,
),)

// ---------------------------------------------------------------------------
//  rendering
// ---------------------------------------------------------------------------

#let _cm(l) = if type(l) == length { l / 1cm } else { l }

/// Build one Typst `curve` from a list of point lists.
#let _curve(paths, flip, closed: false, ..style) = {
  let segs = ()
  for path in paths {
    if path.len() < 2 { continue }
    let p0 = path.first()
    segs.push(curve.move((p0.at(0) * 1cm, flip - p0.at(1) * 1cm)))
    for p in path.slice(1) {
      segs.push(curve.line((p.at(0) * 1cm, flip - p.at(1) * 1cm)))
    }
    if closed { segs.push(curve.close(mode: "straight")) }
  }
  if segs.len() == 0 { return none }
  curve(..style, ..segs)
}

// --- the wobble ------------------------------------------------------------
//  A tiny deterministic PRNG, so "rough" is reproducible: the same figure
//  wobbles identically on every compile. Park-Miller, as PGF uses.

#let _rnd(seed) = {
  let s = calc.rem(seed * 48271, 2147483647)
  if s < 0 { s += 2147483647 }
  s / 2147483647.0
}

/// Displace a polyline a little, the way a hand would draw it.
///
/// Long edges get resampled first: a hand cannot draw a 12 cm ruler edge as
/// one dead-straight stroke, and only sampling the endpoints would keep it
/// straight no matter how large the amplitude.
#let _wobble(pts, amp: 0.018, seed: 1, step: 0.55) = {
  if pts.len() < 2 { return pts }
  // resample
  let dense = (pts.first(),)
  for i in range(1, pts.len()) {
    let a = pts.at(i - 1)
    let b = pts.at(i)
    let d = dist(a, b)
    let n = calc.max(1, calc.min(40, int(d / step)))
    for j in range(1, n + 1) {
      dense.push(vadd(a, vmul(vsub(b, a), j / n)))
    }
  }
  // displace, with the ends held tighter so shapes still meet at corners
  let m = dense.len()
  range(m).map(i => {
    let p = dense.at(i)
    let t = i / calc.max(1, m - 1)
    let edge = calc.min(t, 1 - t) * 2          // 0 at the ends, 1 in the middle
    let k = amp * (0.35 + 0.65 * calc.min(1.0, edge * 2.2))
    let u = _rnd(seed * 7919 + i * 31) - 0.5
    let v = _rnd(seed * 104729 + i * 17) - 0.5
    // a slow drift plus a little jitter reads as a pen, not as noise
    let drift = calc.sin(t * 3.1 * 1rad + seed * 1rad) * amp * 0.55
    (p.at(0) + u * k * 2 + drift * 0.4, p.at(1) + v * k * 2 + drift * 0.6)
  })
}

/// Render a primitive list.
///
///   prims    what a tool returned
///   mode     "clean" | "rough"
///   width/height  the drawing box, in cm
#let render(
  prims,
  mode: "clean",
  colour: black,
  roughness: 1.0,
  seed: 1,
  box-size: none,      // ((x0, x1, y0, y1)) or none to fit
  padding: 0.25,
) = {
  // --- extent ---
  let pts = ()
  for c in prims {
    let k = c.kind
    if k == "poly" { pts += c.pts }
    else if k == "circle" {
      let (x, y) = c.centre
      pts += ((x - c.r, y - c.r), (x + c.r, y + c.r))
    } else if k == "arc" {
      pts.push(c.centre)
      pts += arc-pts(c.centre, c.r, c.a0, c.a1, steps: 12)
    } else if k == "label" { pts.push(c.pos) }
  }
  if pts.len() == 0 { return box() }

  let (x0, x1, y0, y1) = if box-size != none { box-size } else {
    let xs = pts.map(p => p.at(0))
    let ys = pts.map(p => p.at(1))
    (calc.min(..xs) - padding, calc.max(..xs) + padding,
     calc.min(..ys) - padding, calc.max(..ys) + padding)
  }
  let W = x1 - x0
  let H = y1 - y0
  let flip = H * 1cm
  let sh(p) = (p.at(0) - x0, p.at(1) - y0)

  let rough = mode == "rough"
  let amp = 0.030 * roughness

  box(width: W * 1cm, height: H * 1cm, {
    for (i, c) in prims.enumerate() {
      let k = c.kind
      if k == "label" {
        // Labels are always set as type: a "rough" numeral would be a
        // different typeface, not a wobblier one.
        let (px, py) = sh(c.pos)
        place(top + left, dx: px * 1cm, dy: flip - py * 1cm,
          place(center + horizon, rotate(c.rotate,
            text(size: c.size,
              fill: if c.fill == auto { colour } else { c.fill },
              c.body))))
        continue
      }

      let stroke-colour = if c.stroke == auto { colour } else { c.stroke }
      // UN ARC DE CONSTRUCTION SE TRACE EN TIRETS. C'est la convention des
      // manuels : le trait plein est la figure, le tiret est la trace de
      // l'instrument, qu'on efface ensuite. `dash` est donc porté par la
      // primitive, comme `stroke` et `weight`.
      let st = if stroke-colour == none { none } else {
        let base = (paint: stroke-colour, thickness: c.weight * 0.6pt,
          join: "round", cap: "round")
        let d = c.at("dash", default: none)
        if d == none { base } else { base + (dash: d) }
      }

      // A 2 mm graduation tick and a 12 cm ruler edge cannot take the same
      // absolute wobble: at any useful amplitude for the edge, the ticks
      // dissolve. Scale the wobble down for short marks and detail.
      let amp-i = if c.role == "tick" { amp * 0.30 }
                  else if c.role == "detail" { amp * 0.35 }
                  else { amp }

      // turn the primitive into contours
      let contours = if k == "poly" {
        (c.pts,)
      } else if k == "circle" {
        (circle-pts(c.centre, c.r),)
      } else {
        let a = arc-pts(c.centre, c.r, c.a0, c.a1)
        ((if c.wedge { (c.centre,) + a } else { a }),)
      }
      let closed = if k == "poly" { c.closed } else if k == "circle" { true }
                   else { c.wedge }

      let draw = contours.map(ct => sh-map(ct, sh))
      // fill first, then stroke
      if c.fill != none {
        place(top + left, _curve(draw, flip, closed: true,
          fill: c.fill, stroke: none, fill-rule: "even-odd"))
      }
      if st != none {
        let paths = if rough {
          // two passes at slightly different offsets read as a pen going
          // over the line twice, which is what a hand-drawn edge looks like
          let a = draw.map(ct => _wobble(ct, amp: amp-i, seed: seed + i * 13))
          // an edge gets a second pass: a pen going over the line twice
          if c.role == "edge" {
            a + draw.map(ct => _wobble(ct, amp: amp-i * 0.85,
              seed: seed + i * 13 + 501))
          } else { a }
        } else { draw }
        place(top + left, _curve(paths, flip, closed: closed and not rough,
          stroke: st, fill: none))
      }
    }
  })
}
