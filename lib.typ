// =============================================================================
//  sprig — mind maps for Typst
//
//  A hub, branches that grow out of it, and a card at the end of each one.
//  The hub is a polygon with exactly as many sides as there are branches —
//  each branch leaves from the MIDPOINT OF ITS OWN SIDE, so the stalk meets
//  a flat edge square-on — or any other shape you name.
//
//  No dependencies: everything below is drawn with Typst's own `curve`.
// 
// Author: FERGOUS Abdelhak
// =============================================================================

// -----------------------------------------------------------------------------
//  primitives
// -----------------------------------------------------------------------------

/// A deterministic pseudo-random stream in [0, 1).
///
/// A 32-bit xorshift, written out in Typst rather than pulled from a plugin:
/// a package published to Universe should not ship a WASM binary for six
/// numbers' worth of jitter. Deterministic from `seed`, so a document
/// compiles to the same bytes every time.
#let _randoms(seed, n) = {
  let x = calc.rem(seed * 2654435761 + 1013904223, 4294967296)
  if x <= 0 { x = 12345 }
  let out = ()
  for _ in range(n) {
    x = calc.rem(x * 1103515245 + 12345, 2147483648)
    out.push(x / 2147483648.0)
  }
  out
}

#let _arc-pts(centre, r, a0, a1, n: 40) = range(n + 1).map(i => {
  let a = (a0 + (a1 - a0) * i / n) * 1deg
  (centre.at(0) + r * calc.cos(a), centre.at(1) + r * calc.sin(a))
})

#let _circle-pts(centre, r, n: 64) = _arc-pts(centre, r, 0, 360, n: n)

#let _rect-pts(a, b) = (
  (a.at(0), a.at(1)), (b.at(0), a.at(1)),
  (b.at(0), b.at(1)), (a.at(0), b.at(1)),
)

/// Catmull-Rom smoothing, for the waving stalks and the routed paths.
#let _smooth-pts(pts, samples: 12, closed: false) = {
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
      out.push(range(2).map(k => {
        let a = 2 * p1.at(k)
        let b = (-p0.at(k) + p2.at(k)) * t
        let c = (2 * p0.at(k) - 5 * p1.at(k) + 4 * p2.at(k) - p3.at(k)) * t2
        let d = (-p0.at(k) + 3 * p1.at(k) - 3 * p2.at(k) + p3.at(k)) * t3
        0.5 * (a + b + c + d)
      }))
    }
  }
  if not closed { out.push(pts.last()) }
  out
}

/// One or more polylines, as a single `curve`. Coordinates are in
/// CENTIMETRES with y running UP, hence the `flip`.
#let _lines(paths, flip: 0cm, closed: false, ..style) = {
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

/// Fill a set of contours as one region.
#let _fill(contours, flip: 0cm, ..style) = _lines(
  contours, flip: flip, closed: true, fill-rule: "even-odd",
  stroke: none, ..style)

/// A hand-drawn version of a contour: two passes, each displaced.
///
/// The `roughjs` idea, reimplemented: displace every vertex a little, draw
/// the shape twice, and the eye reads pencil. Drawing it ONCE reads as a
/// wobbly line instead — the doubling is what carries it.
#let _rough(contour, flip: 0cm, seed: 1, roughness: 1.0, ..style) = {
  let n = contour.len()
  let out = ()
  for pass in range(2) {
    let r = _randoms(seed + pass * 977, n * 2 + 2)
    out.push(range(n).map(i => {
      let p = contour.at(i)
      (p.at(0) + (r.at(i * 2) - 0.5) * 0.06 * roughness,
       p.at(1) + (r.at(i * 2 + 1) - 0.5) * 0.06 * roughness)
    }))
  }
  _lines(out, flip: flip, closed: true, fill: none, ..style)
}
/// Sampled off the source poster, in the order its branches run.
#let sprig-palettes = (
  poster: (rgb("#1167CA"), rgb("#8CBD14"), rgb("#DF872D"), rgb("#763BA9"),
           rgb("#2AAEA1"), rgb("#F1B203"), rgb("#F47026"), rgb("#DD4C8D")),
  warm:   (rgb("#E4572E"), rgb("#F4A259"), rgb("#F6BD60"), rgb("#E9C46A"),
           rgb("#D08C60"), rgb("#B56576"), rgb("#C9736A"), rgb("#DE8F6E")),
  cool:   (rgb("#0E7C86"), rgb("#2A9D8F"), rgb("#3D5A80"), rgb("#5C80BC"),
           rgb("#6C91BF"), rgb("#7B8CDE"), rgb("#4C956C"), rgb("#3A6EA5")),
  pastel: (rgb("#F4A6A0"), rgb("#F7C59F"), rgb("#EFE6A6"), rgb("#B7D6A8"),
           rgb("#A8D5D5"), rgb("#A8BEDD"), rgb("#C5B0D5"), rgb("#EAB8D1")),
  ink:    (rgb("#2E3440"), rgb("#4C566A"), rgb("#5E81AC"), rgb("#81A1C1"),
           rgb("#8FBCBB"), rgb("#A3BE8C"), rgb("#B48EAD"), rgb("#D08770")),
  mono:   (rgb("#3A3A3A"), rgb("#525252"), rgb("#6B6B6B"), rgb("#848484"),
           rgb("#9D9D9D"), rgb("#767676"), rgb("#5E5E5E"), rgb("#454545")),
)

/// Pick colour `i` from a palette, cycling if there are more branches than
/// colours — a map with ten branches must not run out on the ninth.
#let _hue(pal, i) = {
  let p = if type(pal) == array { pal }
          else { sprig-palettes.at(pal, default: sprig-palettes.poster) }
  p.at(calc.rem(i, p.len()))
}

/// Compass bearings, for placing a sub-leaf by name rather than by angle.
///
/// `"north"` is up and the angles run ANTICLOCKWISE, because that is how
/// the rest of the module measures them — the same convention as `start`
/// and `angle`. Both spellings of the diagonals are accepted: `"north-east"`
/// and `"ne"`, and the French `"nord-est"` too, since the poster this all
/// came from is not in English.
#let sprig-compass = (
  east:  0deg,   e:  0deg,  est:   0deg,
  "north-east": 45deg, ne: 45deg, "nord-est": 45deg,
  north: 90deg,  n: 90deg,  nord: 90deg,
  "north-west": 135deg, nw: 135deg, "nord-ouest": 135deg,
  west:  180deg, w: 180deg, ouest: 180deg,
  "south-west": 225deg, sw: 225deg, "sud-ouest": 225deg,
  south: 270deg, s: 270deg, sud: 270deg,
  "south-east": 315deg, se: 315deg, "sud-est": 315deg,
)

/// Resolve `at:` — a compass name, an angle, or `auto`.
#let _bearing(v) = {
  if v == auto or v == none { return auto }
  if type(v) == angle { return v }
  if type(v) == str {
    let k = lower(v).replace(" ", "-").replace("_", "-")
    if k in sprig-compass { return sprig-compass.at(k) }
    panic("mindmap: unknown direction " + v + " — one of "
      + sprig-compass.keys().join(", ") + ", or an angle")
  }
  auto
}

// -----------------------------------------------------------------------------
//  geometry
// -----------------------------------------------------------------------------

/// A regular `n`-gon, as a point list, in a y-UP frame centred on (0, 0).
///
/// `phase` turns it. To put a SIDE MIDPOINT under every branch angle the
/// polygon is turned by half a step — that is what `_hub-pts` does below,
/// and it is the whole reason the stalks meet flat edges.
/// A regular `n`-gon inscribed in a CIRCLE, or in an ELLIPSE when `ry`
/// differs from `r`.
///
/// The ellipse is the better default for a hub, and for a plain reason: a
/// line of text is almost always wider than it is tall, while a circle
/// grows in every direction at once. Fitting `Missing Data Handling` into a
/// circular hexagon means making it tall enough to hold a wide line — so
/// most of the height is empty. Stretching the same polygon over an ellipse
/// of the text's own proportions holds the words in a shape that is only as
/// tall as it needs to be.
#let _ngon(n, r, phase: 0deg, ry: auto) = {
  let b = if ry == auto { r } else { ry }
  range(n).map(i => {
    let a = phase + 360deg * i / n
    (r * calc.cos(a), b * calc.sin(a))
  })
}

/// The hub outline for `n` branches whose first one points at `start`.
///
/// With `n` sides there are `n` side midpoints; turning the polygon by
/// half a step (`180deg / n`) puts one of them on each branch angle.
#let _hub-pts(n, r, start: 90deg, phase: 0deg, shape: auto, ratio: 1.0,
              ry: auto) = {
  // A hub whose SHAPE is free of the branch count. The brief's rule — one
  // side per branch — is the default and still the interesting case, but a
  // rectangle with twelve branches is a perfectly reasonable diagram and
  // `hub-shape` allows it.
  if shape != auto and shape != none {
    let f = if type(shape) == function { shape }
            else if shape == "circle" { (rr, ph) => _circle-pts((0.0, 0.0), rr, n: 64) }
            else if shape == "box" or shape == "rect" {
              (rr, ph) => {
                let w2 = rr * calc.sqrt(2.0) * ratio
                let h2 = rr * calc.sqrt(2.0) / ratio
                ((-w2 / 2, -h2 / 2), (w2 / 2, -h2 / 2),
                 (w2 / 2, h2 / 2), (-w2 / 2, h2 / 2))
              }
            }
            else if shape == "rounded" {
              (rr, ph) => {
                let w2 = rr * calc.sqrt(2.0) * ratio
                let h2 = rr * calc.sqrt(2.0) / ratio
                let cr = calc.min(w2, h2) * 0.22
                let c1 = _arc-pts((w2 / 2 - cr, -h2 / 2 + cr), cr, 270, 360, n: 7)
                let c2 = _arc-pts((w2 / 2 - cr, h2 / 2 - cr), cr, 0, 90, n: 7)
                let c3 = _arc-pts((-w2 / 2 + cr, h2 / 2 - cr), cr, 90, 180, n: 7)
                let c4 = _arc-pts((-w2 / 2 + cr, -h2 / 2 + cr), cr, 180, 270, n: 7)
                c1 + c2 + c3 + c4
              }
            }
            else if shape == "ellipse" {
              (rr, ph) => range(65).map(i => {
                let a = 360deg * i / 64
                (rr * ratio * calc.cos(a), rr / ratio * calc.sin(a))
              })
            }
            else if type(shape) == int { (rr, ph) => _ngon(shape, rr, phase: ph) }
            else { (rr, ph) => _ngon(n, rr, phase: ph) }
    return f(r, start + 180deg / calc.max(3, n) + phase)
  }
  if n < 3 {
    // Two branches cannot have a polygon: a "2-gon" is a line. A circle is
    // the honest fallback, and it still gives every angle a flat-enough
    // tangent to grow from.
    _circle-pts((0.0, 0.0), r, n: 48)
  } else {
    // A polygon's VERTICES sit at `start + 180/n + k*360/n`, which puts a
    // SIDE MIDPOINT at `start + k*360/n` — exactly the branch angles. Get
    // this offset wrong by half a step and every stalk leaves from a
    // corner instead of a flat edge, which is what the first render did.
    _ngon(n, r, phase: start + 180deg / n + phase, ry: ry)
  }
}

/// Where branch `i` leaves a POLYGONAL hub: the midpoint of its own side.
///
/// For a polygon the side midpoint sits at `r * cos(pi/n)`, the apothem —
/// NOT at `r`. Using `r` floated the stalks off the hub by up to 13 % of
/// the radius on a hexagon, and the gap showed.
#let _hub-foot(n, r, a) = {
  let ap = if n < 3 { r } else { r * calc.cos(180deg / n) }
  (ap * calc.cos(a), ap * calc.sin(a))
}

/// Where the ray at angle `a` leaves a contour.
///
/// With a free-form hub the apothem no longer answers the question, so the
/// ray is INTERSECTED with the outline: walk its edges and keep the nearest
/// crossing. Exact for any convex shape and good enough for the rest, which
/// beats approximating a rectangle by its inscribed circle — that left the
/// stalks floating in the corners.
#let _ray-hit(pts, a, fallback) = {
  let dx = calc.cos(a)
  let dy = calc.sin(a)
  let best = none
  let m = pts.len()
  for i in range(m) {
    let p = pts.at(i)
    let q = pts.at(calc.rem(i + 1, m))
    let ex = q.at(0) - p.at(0)
    let ey = q.at(1) - p.at(1)
    let den = dx * ey - dy * ex
    if calc.abs(den) > 1e-9 {
      // solve  t*(dx,dy) = p + u*(ex,ey)
      let u = (dx * p.at(1) - dy * p.at(0)) / den
      if u >= 0.0 and u <= 1.0 {
        let hx = p.at(0) + ex * u
        let hy = p.at(1) + ey * u
        let t = hx * dx + hy * dy
        if t > 0.0 and (best == none or t < best) { best = t }
      }
    }
  }
  if best == none { fallback } else { (dx * best, dy * best) }
}

/// A tapered stalk from `p0` to `p1`: wide where it leaves the hub, narrow
/// where it meets the leaf, with a slight S-curve.
///
/// The source's stalks are not straight lines but *cones* that swell at the
/// root — that is what makes them read as grown rather than drawn. The
/// outline is two mirrored curves, so the shape is filled, not stroked.
#let _stalk(p0, p1, w0, w1, bend: 0.0, wave: 0.0, waves: 1.6, n: 48) = {
  let (x0, y0) = p0
  let (x1, y1) = p1
  let dx = x1 - x0
  let dy = y1 - y0
  let len = calc.max(0.001, calc.sqrt(dx * dx + dy * dy))
  let ux = dx / len
  let uy = dy / len
  let nx = -uy
  let ny = ux

  // The CENTRELINE first, then the two edges offset from it. Offsetting
  // both edges along the CHORD's normal — as the first version did — is
  // fine for a straight stalk but pinches a curved one: on the inside of a
  // bend the two edges converge. The offsets are taken along the LOCAL
  // tangent instead, so the stalk keeps its width all the way round.
  //
  // Both the bend and the wave are damped by sin(pi*t), which is zero at
  // both ends: the root has to leave the hub square-on and the tip has to
  // arrive at the leaf on axis, whatever the wobble in between.
  let mid(t) = {
    let damp = calc.sin(calc.pi * t)
    // ONE logical line: a continuation may not start with `+`.
    let off = (bend + wave * calc.sin(t * waves * 360deg)) * damp * len * 0.5
    (x0 + ux * len * t + nx * off, y0 + uy * len * t + ny * off)
  }
  let half(t) = (w0 + (w1 - w0) * calc.pow(t, 0.62)) / 2

  let pts = range(n + 1).map(i => mid(i / n))
  let side(sg) = range(n + 1).map(i => {
    let t = i / n
    // local tangent by finite difference, with the ends looking inward
    let a = pts.at(calc.max(0, i - 1))
    let b = pts.at(calc.min(n, i + 1))
    let tx = b.at(0) - a.at(0)
    let ty = b.at(1) - a.at(1)
    let tl = calc.max(0.0001, calc.sqrt(tx * tx + ty * ty))
    let (mx, my) = pts.at(i)
    (mx - ty / tl * sg * half(t), my + tx / tl * sg * half(t))
  })
  side(1.0) + side(-1.0).rev()
}

// -----------------------------------------------------------------------------
//  leaf shapes
// -----------------------------------------------------------------------------

/// The built-in leaf outlines, each `(w, h) => point list` in a y-UP frame
/// with its origin at the bottom left.
#let sprig-shapes = (
  "round": (w, h, r) => {
    let rr = calc.min(r, calc.min(w, h) / 2)
    let c1 = _arc-pts((w - rr, rr), rr, 270, 360, n: 8)
    let c2 = _arc-pts((w - rr, h - rr), rr, 0, 90, n: 8)
    let c3 = _arc-pts((rr, h - rr), rr, 90, 180, n: 8)
    let c4 = _arc-pts((rr, rr), rr, 180, 270, n: 8)
    c1 + c2 + c3 + c4
  },
  "sharp": (w, h, r) => _rect-pts((0.0, 0.0), (w, h)),
  "pill": (w, h, r) => {
    let rr = h / 2
    let right = _arc-pts((w - rr, rr), rr, 270, 450, n: 14)
    right + _arc-pts((rr, rr), rr, 90, 270, n: 14)
  },
  "tag": (w, h, r) => {
    // a card with one corner cut, like a luggage label
    let c = calc.min(h * 0.34, w * 0.22)
    ((0.0, 0.0), (w, 0.0), (w, h - c), (w - c, h), (0.0, h))
  },
  "shield": (w, h, r) => {
    let rr = calc.min(r, w / 3)
    let top-arc = _arc-pts((w - rr, h - rr), rr, 0, 90, n: 8)
    let left-arc = _arc-pts((rr, h - rr), rr, 90, 180, n: 8)
    // ONE logical line: a continuation may not begin with `+`, or Typst
    // closes the expression at the break and reads a unary plus on an
    // array. Reported from deep inside `_leaf-draw`, far from the cause.
    let base = ((w / 2, -h * 0.16), (w, h * 0.18), (w, h - rr))
    base + top-arc + left-arc + ((0.0, h * 0.18),)
  },
  "cloud": (w, h, r) => {
    // a ring of overlapping arcs — a thought bubble
    let n = 13
    let rx = w / 2
    let ry = h / 2
    let bump = calc.min(rx, ry) * 0.30
    range(n * 6).map(i => {
      let a = 360deg * i / (n * 6)
      let lobe = calc.sin(a * n)
      (rx + (rx - bump) * calc.cos(a) + bump * lobe * calc.cos(a),
       ry + (ry - bump) * calc.sin(a) + bump * lobe * calc.sin(a))
    })
  },
  "banner": (w, h, r) => {
    // the dovetail ribbon of §26, as a leaf
    let d = h * 0.20
    ((0.0, 0.0), (d, h / 2), (0.0, h), (w, h), (w - d, h / 2), (w, 0.0))
  },
  // ---- added shapes ------------------------------------------------------
  "note": (w, h, r) => {
    // a sheet with its bottom-right corner turned up
    let c = calc.min(h * 0.30, w * 0.20)
    ((0.0, 0.0), (w - c, 0.0), (w, c), (w, h), (0.0, h))
  },
  "folder": (w, h, r) => {
    // a tab across the top left, as on a filing folder
    let tw = w * 0.42
    let th = calc.min(h * 0.20, 0.34)
    let rr = calc.min(r, h * 0.12)
    ((0.0, 0.0), (w, 0.0), (w, h - th), (tw + th, h - th),
     (tw, h), (0.0, h))
  },
  "hex": (w, h, r) => {
    let c = calc.min(w * 0.16, h / 2)
    ((c, 0.0), (w - c, 0.0), (w, h / 2), (w - c, h), (c, h), (0.0, h / 2))
  },
  "arrow": (w, h, r) => {
    // a card with a point on its leading edge
    let c = calc.min(w * 0.14, h / 2)
    ((0.0, 0.0), (w - c, 0.0), (w, h / 2), (w - c, h), (0.0, h))
  },
  "bubble": (w, h, r) => {
    // a speech balloon: rounded, with a tail below the left third
    let bh = h * 0.84
    let rr = calc.min(r * 1.4, calc.min(w, bh) / 2)
    let tail = ((w * 0.30, h * 0.16), (w * 0.24, 0.0), (w * 0.42, h * 0.16))
    let c1 = _arc-pts((w - rr, h - bh + rr), rr, 270, 360, n: 8)
    let c2 = _arc-pts((w - rr, h - rr), rr, 0, 90, n: 8)
    let c3 = _arc-pts((rr, h - rr), rr, 90, 180, n: 8)
    let c4 = _arc-pts((rr, h - bh + rr), rr, 180, 270, n: 8)
    c1 + c2 + c3 + c4 + tail
  },
  "cut": (w, h, r) => {
    // both leading corners chamfered — a plaque
    let c = calc.min(h * 0.26, w * 0.10)
    ((c, 0.0), (w - c, 0.0), (w, c), (w, h - c), (w - c, h), (c, h),
     (0.0, h - c), (0.0, c))
  },
  "torn": (w, h, r) => {
    // a strip torn along its foot
    let n = 22
    let amp = calc.min(h * 0.06, 0.10)
    let jag = range(n + 1).map(i => {
      let t = i / n
      (w * t, if calc.rem(i, 2) == 0 { 0.0 } else { amp })
    })
    jag + ((w, h), (0.0, h))
  },
  "wave": (w, h, r) => {
    // a card whose top and bottom edges ripple
    let n = 26
    let amp = calc.min(h * 0.07, 0.12)
    let e-bot = range(n + 1).map(i => {
      let t = i / n
      (w * t, amp * calc.sin(t * 1080deg))
    })
    let e-top = range(n + 1).map(i => {
      let t = 1 - i / n
      (w * t, h - amp * calc.sin(t * 1080deg))
    })
    e-bot + e-top
  },
)

/// How much of a card's box its OUTLINE does not actually enclose.
///
/// Not every shape fills its rectangle. A speech balloon spends its bottom
/// sixth on the tail, a shield's flanks only start a fifth of the way up,
/// `torn` chews its foot into teeth, `banner` bites a dovetail out of each
/// end. Text laid out against the plain rectangle therefore spills into the
/// ornament and reads as a bug — which it was: the Arabic map below had two
/// cards with a line hanging out under the balloon.
///
/// So every shape declares the margin it eats, in cm, and the card both
/// GROWS by it and shifts its text inside it. A shape that fills its box
/// declares nothing and costs nothing.
///
/// Returns `(t, b, l, r)`.
#let _shape-pad(style, w, h) = {
  let z = (t: 0.0, b: 0.0, l: 0.0, r: 0.0)
  if type(style) == function { return z }
  let m = calc.min
  if style == "bubble" { return (t: 0.0, b: h * 0.19, l: 0.0, r: 0.0) }
  if style == "shield" { return (t: 0.0, b: h * 0.22, l: 0.04, r: 0.04) }
  if style == "torn" { return (t: 0.0, b: m(h * 0.06, 0.10) + 0.04,
    l: 0.0, r: 0.0) }
  if style == "wave" {
    let a = m(h * 0.07, 0.12) + 0.03
    return (t: a, b: a, l: 0.0, r: 0.0)
  }
  if style == "folder" { return (t: m(h * 0.20, 0.34), b: 0.0,
    l: 0.0, r: 0.0) }
  if style == "banner" {
    let d = h * 0.20
    return (t: 0.0, b: 0.0, l: d, r: d)
  }
  if style == "hex" {
    let c = m(w * 0.16, h / 2) * 0.7
    return (t: 0.0, b: 0.0, l: c, r: c)
  }
  if style == "arrow" { return (t: 0.0, b: 0.0, l: 0.0,
    r: m(w * 0.14, h / 2) * 0.8) }
  if style == "cloud" {
    return (t: h * 0.13, b: h * 0.13, l: w * 0.11, r: w * 0.11)
  }
  if style == "pill" { return (t: 0.0, b: 0.0, l: h * 0.16, r: h * 0.16) }
  if style == "cut" {
    let c = m(h * 0.26, w * 0.10) * 0.6
    return (t: 0.0, b: 0.0, l: c, r: c)
  }
  if style == "tag" { return (t: 0.0, b: 0.0, l: 0.0,
    r: m(h * 0.34, w * 0.22) * 0.45) }
  if style == "note" { return (t: 0.0, b: 0.0, l: 0.0,
    r: m(h * 0.30, w * 0.20) * 0.35) }
  z
}

/// A leaf's fill and outline, drawn to `w` x `h`.
///
///   style   a key of `sprig-shapes`, or a function `(w, h, radius) => pts`
#let _leaf-draw(
  style, w, h, radius,
  fill: white, stroke-paint: black, weight: 1.2pt,
  hand: none, seed: 1, roughness: 1.0, bowing: 0.6, shadow: none,
) = {
  let f = if type(style) == function { style }
          else { sprig-shapes.at(style, default: sprig-shapes.at("round")) }
  let pts = f(w, h, radius)
  let flip = h * 1cm
  let out = ()
  if shadow != none {
    out.push(place(top + left, dx: 2.5pt, dy: 3pt,
      _fill((pts,), flip: flip, fill: shadow)))
  }
  out.push(place(top + left, _fill((pts,), flip: flip, fill: fill)))
  if weight != 0pt and stroke-paint != none {
    let st = (paint: stroke-paint, thickness: weight, join: "round")
    if hand == none or hand == "none" {
      out.push(place(top + left, _lines((pts + (pts.first(),),),
        flip: flip, stroke: st)))
    } else if hand == "sketch" {
      out.push(place(top + left, _rough(pts, flip: flip, seed: seed,
        roughness: roughness * 0.7, stroke: st)))
    } else {
      out.push(place(top + left, _rough(pts, flip: flip, seed: seed,
        roughness: roughness, stroke: st)))
    }
  }
  out.join()
}

// -----------------------------------------------------------------------------
//  the map
// -----------------------------------------------------------------------------

/// A cross-link between two leaves: "this one implies that one".
///
/// A mind map is a tree, but the ideas in it rarely are. `link` draws the
/// association without breaking the hierarchy: a thin dashed curve, an
/// optional arrow head, and a label at its middle.
///
///   from, to   branch indices, 0-based, in the order they were given
///   via        "outside" bends the curve away from the hub, "inside"
///              towards it, `auto` picks whichever is shorter
#let link(from, to, label: none, colour: auto, dash: "dashed",
          arrow: true, bend: 0.28, via: auto, weight: 0.9pt) = (
  from: from, to: to, label: label, colour: colour, dash: dash,
  arrow: arrow, bend: bend, via: via, weight: weight,
)

/// An arrow head, as a filled triangle at `p` pointing along `dir`.
#let _head(p, dir, size) = {
  let (dx, dy) = dir
  let l = calc.max(0.0001, calc.sqrt(dx * dx + dy * dy))
  let (ux, uy) = (dx / l, dy / l)
  let (nx, ny) = (-uy, ux)
  ((p.at(0), p.at(1)),
   (p.at(0) - ux * size + nx * size * 0.42,
    p.at(1) - uy * size + ny * size * 0.42),
   (p.at(0) - ux * size - nx * size * 0.42,
    p.at(1) - uy * size - ny * size * 0.42))
}

/// One branch of the map.
///
///   body     the leaf's contents
///   title    an optional heading bar across the top of the leaf
///   colour   overrides the palette for this branch alone
///   shape    overrides the leaf shape for this branch alone
///   angle    overrides the branch's angle. NOT named `at`: `b.at(..)` is
///            how a dictionary is read in Typst, so a key called `at`
///            shadows the method and `b.at` returns the function itself —
///            reported far away as "expected content, found angle".
///   dist     overrides how far out the leaf sits, in cm — the branch's
///            LENGTH, which is what lets a row of leaves sit at different
///            depths below a hub
///   dx, dy   nudge the leaf off its ray, in cm, y UP. The stalk follows:
///            it still leaves from its own side of the polygon but now aims
///            at wherever the leaf actually is
///   children  further `branch(..)` values: the leaf becomes a hub of its
///             own and sprouts a second rank. They fan out AWAY from the
///             centre, so a sub-branch never grows back over the map.
///   at        a compass point — `"north"`, `"sw"`, `"sud-est"` … — placing
///             this leaf relative to its parent. A readable alternative to
///             `angle`, which it overrides.
///   children-at  the same, applied to the whole brood: `"south"` fans
///             them below the card whatever the parent's own bearing.
///   icon      content shown before the title — an emoji, a symbol, a small
///             image. The Arabic poster this module came from puts one on
///             every card, and it is what makes a busy map scannable.
// `..args` rather than a named `body`: a positional `branch[text]` must
// keep working, and a bare `branch(title: [x])` must not demand an empty
// bracket. A variadic sink accepts both.
#let branch(..args, title: none, icon: none, colour: auto, shape: auto,
            angle: auto, at: auto, dist: auto, width: auto,
            dx: 0.0, dy: 0.0, children: (), children-at: auto,
            spread: auto, child-dist: auto, child-width: auto) = (
  body: if args.pos().len() > 0 { args.pos().first() } else { [] },
  title: title, icon: icon, colour: colour, shape: shape,
  angle: angle, at: at, dist: dist, width: width, dx: dx, dy: dy,
  children: children, children-at: children-at, spread: spread,
  child-dist: child-dist, child-width: child-width,
)

/// A mind map.
///
/// THE RULE THE BRIEF ASKS FOR: the hub is a polygon with exactly as many
/// sides as there are branches, and each branch grows from the midpoint of
/// its own side. Everything else is a knob.
///
///   hub          the centre's contents
///   ..branches   `branch(..)` values, or plain content for a bare leaf
///
///   sides        `auto` = one per branch (the brief); or a number to
///                override, for a map that wants a fixed shape
///   palette      a name from `sprig-palettes`, or an array of colours
///   shape        the leaf outline: a key of `sprig-shapes` or a function
///   weight       the rule thickness on every leaf and on the hub
///   dir          `ltr` / `rtl` / `auto` (follows the surrounding text)
///   start        the angle of the first branch
///   spread       the arc the branches share; 360deg = all the way round
///   rough        hand-drawn mode, with `roughness` / `bowing` / `hand`
#let mindmap(
  hub,
  ..branches,
  links: (),
  sides: auto,
  hub-shape: auto,       // "box" | "rounded" | "circle" | "ellipse" | n | fn
  hub-ratio: 1.0,        // width : height, for the box and the ellipse
  hub-round: false,      // `true` inscribes the hub in a CIRCLE again
  radius: auto,
  leaf-width: 4.6,       // a MAXIMUM: a card shrinks to fit its contents
  min-width: 1.5,        // …but never below this, so a ring stays even
  dist: auto,
  palette: "poster",
  theme: auto,           // `auto` in colour, or "print" for paper
  shape: "round",
  weight: 1.2pt,
  hub-fill: auto,        // a colour, or "palette" to follow the scheme
  hub-ink: auto,
  hub-text: auto,
  leaf-fill: auto,
  leaf-ink: auto,
  tint: 88%,
  stalk: 0.34,
  stalk-tip: 0.11,
  bend: 0.0,
  wave: 0.045,
  waves: 1.6,
  start: 90deg,
  spread: 360deg,
  phase: 0deg,
  radius-leaf: 0.34,
  gap: 0.30,
  shadow: true,
  dir: auto,
  size: auto,
  seed: 3,
  rough: false,
  hand: none,
  roughness: 1.0,
  bowing: 0.6,
) = context {
  let items = branches.pos().map(b =>
    if type(b) == dictionary and "body" in b { b }
    else { branch(b) })
  let n = items.len()
  if n == 0 { return }

  let r2l = if dir != auto { dir == rtl } else { text.dir == rtl }
  let hd = if rough { if hand != none { hand } else { "roughjs" } } else { none }

  // THE BRIEF: as many sides as branches. Below three a polygon is not a
  // polygon, so the hub falls back to a circle — see `_hub-pts`.
  let ns = if sides != auto { sides } else { n }

  // `dist` and `radius` DEFAULT FROM THE BRANCH COUNT. A fixed 6.4 cm is
  // right for six branches and wrong for twelve: the leaves are spread
  // round a circle of circumference 2*pi*dist, so each gets 2*pi*dist/n of
  // arc and they collide as soon as that is narrower than a leaf. Solving
  // for the distance that gives every leaf its own width plus a margin is
  // what stops a busy map from overlapping — and it also stops a
  // three-branch map from being flung needlessly far apart.
  let lw0 = if leaf-width != auto { leaf-width } else { 4.6 }
  let need = if spread >= 360deg { n * lw0 * 1.12 / (2 * calc.pi) }
             else { calc.max(1.0, n - 1) * lw0 * 1.12 / calc.max(0.35,
               spread / 1rad) }
  // THE HUB FITS ITS TEXT TOO. A fixed radius cut `Missing Data Handling`
  // into a column one word wide. The title is measured unwrapped, and the
  // radius is whatever makes the polygon's INSCRIBED box hold it: for an
  // n-gon that box is `apothem * 1.34` across, so the radius needed is
  // `want / 1.34 / cos(pi/n)`. Still bounded, or one long word would blow
  // the hub up to fill the page.
  // THE HUB IS AN ELLIPSE, not a circle. A line of text is almost always
  // wider than it is tall; a circle grows in both directions at once, so
  // fitting a wide title into a circular polygon means making it tall
  // enough to hold that width — and most of the height is then empty.
  // Inscribing the same polygon in an ellipse of the TEXT'S OWN
  // proportions holds the words in a shape only as tall as it needs to be.
  //
  // `hub-round: true` gives the old circular hub back.
  let hw = measure(hub).width / 1cm
  let hh2 = measure(hub).height / 1cm
  let apf = if sides != auto and sides < 3 { 1.0 }
            else { calc.cos(180deg / calc.max(3, if sides != auto { sides } else { n })) }
  // A long title still wraps rather than forcing a very wide hub.
  // If the title is much wider than tall it will wrap, so the height it
  // needs is not its one-line height: aim for the width of a two-line
  // setting and budget two lines of height to match. Budgeting one line
  // for a title that then wrapped is what pushed the text out of the hub.
  let wraps = hw > hh2 * 2.6
  let want-w = if wraps { hw * 0.66 } else { hw }
  let want-h = if wraps { hh2 * 2.15 } else { hh2 }
  let sf = 1.34 * calc.max(0.5, apf)
  let need-x = want-w / sf + 0.16
  let need-y = calc.max(want-h * 1.30, want-h + 0.26) / sf + 0.12
  let rx0 = calc.max(1.05, calc.min(3.2, calc.max(0.38 * lw0, need-x)))
  let ry0 = calc.max(0.80, calc.min(2.6, need-y))
  // the aspect is capped: a very long title must not give a hub so flat
  // that the polygon stops reading as one
  // The flattening is capped. Below about two thirds the polygon stops
  // reading as one — a pentagon squashed flat is just a chevron — and the
  // stalks start meeting its long sides at a glancing angle.
  let ry0 = calc.max(ry0, rx0 * 0.62)
  let rad = if radius != auto { radius } else { rx0 }
  let rady = if radius != auto { radius }
             else if hub-round { rad } else { ry0 }
  // The ring must clear the hub, whatever size the hub turned out to be:
  // a title that grew the polygon has to push the leaves out with it, or
  // they end up sitting on top of it.
  let dd = if dist != auto { dist }
           else { calc.max(rad + lw0 * 0.70, need) }

  // Branch angles. `spread` < 360deg fans them instead of ringing them, and
  // the last one lands ON the far end rather than one step short of it.
  let ang(i) = {
    let sg = if r2l { -1.0 } else { 1.0 }
    if spread >= 360deg { start + sg * spread * i / n }
    else if n == 1 { start }
    else { start + sg * spread * (i / (n - 1) - 0.5) }
  }

  // ---- measure everything before drawing ----------------------------------
  // The canvas has to be big enough for the furthest leaf corner in every
  // direction, and leaves are NOT symmetric about their anchor: one on the
  // left hangs its whole width to the left. Measuring the real extent beats
  // guessing a square, which cropped the outer cards on a 3-branch map.
  let leaves = items.enumerate().map(p => {
    let (i, b) = p
    // `at:` (a compass name) wins over `angle:`, which wins over the ring
    let bat = _bearing(b.at("at", default: auto))
    let ai = if bat != auto { bat }
             else if b.angle != auto { b.angle } else { ang(i) }
    let d = if b.dist != auto { b.dist } else { dd }
    let col = if b.colour != auto { b.colour } else { _hue(palette, i) }
    let sh = if b.shape != auto { b.shape } else { shape }

    // THE CARD FITS ITS CONTENTS. `leaf-width` is a MAXIMUM, not a fixed
    // size: measuring the text unwrapped and taking the smaller of the two
    // is what stops a one-word leaf from being given 4.6 cm and breaking
    // `Évaporation` across two lines. A card is never wider than it needs
    // to be, and never wider than `leaf-width`.
    //
    // `measure` with no width constraint reports the text set on ONE line,
    // which is exactly the "how wide would this like to be?" question.
    let cap = if b.width != auto { b.width }
              else if leaf-width != auto { leaf-width } else { 4.6 }
    let want-body = measure(b.body).width / 1cm
    let ico0 = b.at("icon", default: none)
    // ONE logical line: a continuation may not begin with `+`.
    let icw = if ico0 != none { measure(ico0).width / 1cm + 0.20 } else { 0.0 }
    let want-head = if b.title != none { measure(b.title).width / 1cm + icw }
                    else { icw }
    let lw = if b.width != auto { b.width }
             else { calc.min(cap, calc.max(min-width,
               calc.max(want-body, want-head) + 2 * gap + 0.06)) }
    // The ornament's share of the box, so the text never sits in the
    // balloon's tail or between a torn edge's teeth.
    let pd0 = _shape-pad(sh, lw, 1.0)
    let inner = lw - 2 * gap - pd0.l - pd0.r
    let ico = ico0
    let head = if b.title != none or ico != none {
      let hb = if b.title != none { b.title } else { ico }
      calc.max(measure(box(width: inner * 1cm, hb)).height / 1cm,
        if ico != none { measure(box(ico)).height / 1cm } else { 0.0 }) + 0.30
    } else { 0.0 }
    let bh = measure(box(width: inner * 1cm, b.body)).height / 1cm
    // The height the CONTENTS need; the padding is added on top, and it is
    // itself a fraction of the height — one pass of substitution is enough
    // at these proportions.
    let h0 = bh + head + 2 * gap
    let pd = _shape-pad(sh, lw, h0)
    let lh = h0 + pd.t + pd.b
    let pd = _shape-pad(sh, lw, lh)
    let lh = h0 + pd.t + pd.b
    (i: i, a: ai, d: d, w: lw, h: lh, col: col, sh: sh, head: head, pad: pd,
     dx: b.dx, dy: b.dy, title: b.title, body: b.body,
     icon: b.at("icon", default: none),
     kids: b.at("children", default: ()),
     kspread: b.at("spread", default: auto),
     kat: _bearing(b.at("children-at", default: auto)),
     kdist: b.at("child-dist", default: auto),
     kwidth: b.at("child-width", default: auto))
  })

  // the centre of each leaf, and hence the canvas
  // Where a leaf actually ends up: its ray, plus the caller's nudge. Every
  // later step reads THESE, so the canvas, the stalk and the card can never
  // disagree about where the leaf is.
  let cx(l) = l.d * calc.cos(l.a) + l.dx
  let cy(l) = l.d * calc.sin(l.a) + l.dy
  // A SECOND RANK, if any leaf carries children. They are laid out around
  // their own parent, fanning OUTWARD — the arc is centred on the parent's
  // own bearing from the hub, so a sub-branch never grows back across the
  // map towards the middle.
  let kids-of(l) = {
    let n2 = l.kids.len()
    if n2 == 0 { return () }
    let kw = if l.kwidth != auto { l.kwidth } else { l.w * 0.72 }
    let kd = if l.kdist != auto { l.kdist }
             else { calc.max(l.w, l.h) * 0.70 + kw * 0.62 }
    // 150deg was too wide: the outermost child swung back past its parent
    // and landed on the neighbouring branch. A fan of 100deg keeps every
    // child in the outward half-plane, where there is nothing to collide
    // with.
    let arc = if l.kspread != auto { l.kspread } else { 100deg }
    // Which way the brood faces. By default it follows the parent's own
    // bearing from the hub, so the children spread outward; `children-at`
    // aims them at a compass point instead — `"south"` hangs them below
    // the card wherever that card happens to sit on the map.
    let base = if l.kat != auto { l.kat } else { l.a }
    range(n2).map(j => {
      let kb = l.kids.at(j)
      let t = if n2 == 1 { 0.0 } else { j / (n2 - 1) - 0.5 }
      let kat = _bearing(kb.at("at", default: auto))
      // a child's own `at:` pins it exactly; otherwise it takes its slot
      // in the fan
      let ka = if kat != auto { kat }
               else if kb.angle != auto { kb.angle } else { base + arc * t }
      let dd2 = if kb.dist != auto { kb.dist } else { kd }
      (p: (cx(l) + dd2 * calc.cos(ka) + kb.dx,
           cy(l) + dd2 * calc.sin(ka) + kb.dy),
       w: if kb.width != auto { kb.width } else { kw },
       col: if kb.colour != auto { kb.colour } else { l.col },
       sh: if kb.shape != auto { kb.shape } else { l.sh },
       title: kb.title, body: kb.body, icon: kb.at("icon", default: none),
       a: ka, kids: kb.at("children", default: ()),
       kspread: kb.at("spread", default: auto),
       kat: _bearing(kb.at("children-at", default: auto)),
       parent: l)
    })
  }
  let kids = ()
  for l in leaves { for k in kids-of(l) { kids.push(k) } }

  // A THIRD rank. The structure is already recursive — a child is declared
  // with the same `branch(..)` as its parent — so the only new thing is
  // laying it out. Each grandchild fans around its own parent, on the
  // bearing that parent has from ITS parent, so the tree keeps opening
  // outward and never folds back on itself.
  let grands = ()
  for k in kids {
    let gk = k.at("kids", default: ())
    let n3 = gk.len()
    if n3 == 0 { continue }
    let gw = k.w * 0.80
    let gd = calc.max(k.w, 1.2) * 0.62 + gw * 0.58
    let arc3 = if k.at("kspread", default: auto) != auto {
      k.kspread
    } else { 84deg }
    let base3 = if k.at("kat", default: auto) != auto { k.kat } else { k.a }
    for j in range(n3) {
      let gb = gk.at(j)
      let t = if n3 == 1 { 0.0 } else { j / (n3 - 1) - 0.5 }
      let gat = _bearing(gb.at("at", default: auto))
      let ga = if gat != auto { gat }
               else if gb.angle != auto { gb.angle } else { base3 + arc3 * t }
      let dd3 = if gb.dist != auto { gb.dist } else { gd }
      grands.push((
        p: (k.p.at(0) + dd3 * calc.cos(ga) + gb.dx,
            k.p.at(1) + dd3 * calc.sin(ga) + gb.dy),
        w: if gb.width != auto { gb.width } else { gw },
        col: if gb.colour != auto { gb.colour } else { k.col },
        sh: if gb.shape != auto { gb.shape } else { k.sh },
        title: gb.title, body: gb.body, icon: gb.at("icon", default: none),
        parent: k))
    }
  }

  let xs = leaves.map(l => (cx(l) - l.w / 2, cx(l) + l.w / 2)).flatten()
  let ys = leaves.map(l => (cy(l) - l.h / 2, cy(l) + l.h / 2)).flatten()
  // the children count towards the canvas too, or they fall off the edge
  let kh = 1.2
  let xs = xs + kids.map(k => (k.p.at(0) - k.w / 2, k.p.at(0) + k.w / 2)).flatten()
  let ys = ys + kids.map(k => (k.p.at(1) - kh, k.p.at(1) + kh)).flatten()
  let xs = xs + grands.map(g => (g.p.at(0) - g.w / 2, g.p.at(0) + g.w / 2)).flatten()
  let ys = ys + grands.map(g => (g.p.at(1) - kh, g.p.at(1) + kh)).flatten()
  let pad = 0.35
  let x0 = calc.min(-rad, ..xs) - pad
  let x1 = calc.max(rad, ..xs) + pad
  let y0 = calc.min(-rady, ..ys) - pad
  let y1 = calc.max(rady, ..ys) + pad
  let W = x1 - x0
  let Hh = y1 - y0
  let flip = Hh * 1cm
  // map a maths point (y up, origin at the hub) into the canvas
  let P(p) = (p.at(0) - x0, p.at(1) - y0)

  // `hub-fill: "palette"` takes the FIRST colour of the palette and darkens
  // it, so a recoloured map does not keep a navy hub bolted to the middle
  // of a warm scheme. The plain default stays navy, as the source is.
  // The PRINT theme: no flooded fills anywhere, everything carried by the
  // outline. A mind map is mostly coloured area, and a colour printer is
  // not always what the reader has — this is the same reasoning as
  // chalkdeck's `print` theme. Colours are not merely desaturated: a grey
  // wash still costs toner and still greys the text. They are REMOVED, and
  // the branches are told apart by their rules instead.
  let prt = theme == "print"
  let hf = if prt and hub-fill == auto { white }
           else if hub-fill == "palette" { _hue(palette, 0).darken(38%) }
           else if hub-fill != auto { hub-fill }
           else { rgb("#0B3C7A") }
  let hi = if hub-ink != auto { hub-ink }
           else if prt { rgb("#333333") } else { hf.lighten(24%) }
  // The hub's text has to READ on whatever the hub was set to. White on a
  // pale hub is invisible, so the default follows the fill's luminance
  // rather than being white come what may.
  let ht = if hub-text != auto { hub-text }
           else if prt { black }
           else if luma(hf).components().first() > 58% { hf.darken(62%) }
           else { white }
  let sh-col = rgb("#00000022")
  let shadow = if prt { false } else { shadow }
  // the label sits on the page, so it needs the page's own colour behind
  // it to punch a hole in the dashes
  let bg-of-page = white
  let hub-o-raw = _hub-pts(ns, rad, start: start, phase: phase,
    shape: hub-shape, ratio: hub-ratio, ry: rady)

  box(width: W * 1cm, height: Hh * 1cm, {
    // ---- stalks, drawn FIRST so every leaf and the hub cover their ends --
    for l in leaves {
      // The foot stays on the branch's OWN side of the polygon — that is
      // the brief's rule and a nudge must not break it — but the tip aims
      // at wherever the leaf really is. So a displaced leaf keeps its own
      // edge of the hub and the stalk simply leans across to reach it.
      // With a free-form hub the apothem is meaningless, so the foot is
      // the ray's actual crossing of the outline.
      // On an ellipse the apothem is no longer a single number, so the
      // foot is the ray's real crossing of the outline — the same solver
      // the free-form hubs already use.
      let foot = if hub-shape == auto and hub-round {
                   _hub-foot(ns, rad, l.a)
                 } else { _ray-hit(hub-o-raw, l.a, _hub-foot(ns, rad, l.a)) }
      let lc = (cx(l), cy(l))
      // Stop the stalk INSIDE the leaf, along the line it actually
      // travels: backing off along the RAY (as before) left the tip short
      // or through the card once the leaf had moved off its ray.
      let vx = lc.at(0) - foot.at(0)
      let vy = lc.at(1) - foot.at(1)
      let vl = calc.max(0.001, calc.sqrt(vx * vx + vy * vy))
      let back = calc.min(vl * 0.6, calc.min(l.w, l.h) * 0.30)
      let tip = (lc.at(0) - vx / vl * back, lc.at(1) - vy / vl * back)
      // A black cone at full width is far heavier than a coloured one of
      // the same size — the eye reads area, and black has all of it. In
      // print the stalk is thinned to a third.
      let sk = if prt { stalk * 0.34 } else { stalk }
      let skt = if prt { stalk-tip * 0.45 } else { stalk-tip }
      let pts = _stalk(P(foot), P(tip), sk, skt, bend: bend,
        wave: wave * (if calc.rem(l.i, 2) == 0 { 1.0 } else { -1.0 }),
        waves: waves)
      if shadow {
        place(top + left, dx: 2pt, dy: 2.5pt,
          _fill((pts,), flip: flip, fill: sh-col))
      }
      place(top + left, _fill((pts,), flip: flip,
        fill: if prt { rgb("#555555") } else { l.col }))
      // a paler core down the middle: a flat cone reads as a triangle
      let core = _stalk(P(foot), P(tip), sk * 0.42, skt * 0.42,
        bend: bend, wave: wave * (if calc.rem(l.i, 2) == 0 { 1.0 }
          else { -1.0 }), waves: waves)
      if not prt {
        place(top + left, _fill((core,), flip: flip,
          fill: white.transparentize(78%)))
      }
    }

    // ---- the third rank, under everything -------------------------------
    for g in grands {
      let k = g.parent
      let ddx = g.p.at(0) - k.p.at(0)
      let ddy = g.p.at(1) - k.p.at(1)
      let kh2 = 0.62
      let sdg = if calc.abs(ddx) * kh2 > calc.abs(ddy) * k.w / 2 {
                  if ddx > 0 { right } else { left }
                } else if ddy > 0 { top } else { bottom }
      let f = if sdg == left { (k.p.at(0) - k.w / 2, k.p.at(1)) }
              else if sdg == right { (k.p.at(0) + k.w / 2, k.p.at(1)) }
              else if sdg == top { (k.p.at(0), k.p.at(1) + kh2) }
              else { (k.p.at(0), k.p.at(1) - kh2) }
      let pts = _stalk(P(f), P(g.p), stalk * 0.40, stalk-tip * 0.6,
        wave: wave * 0.5, waves: waves)
      if pts.len() > 3 {
        place(top + left, _fill((pts,), flip: flip,
          fill: if prt { rgb("#777777") } else { g.col }))
      }
    }
    for g in grands {
      let gp0 = _shape-pad(g.sh, g.w, 1.0)
      let gin = (g.w - 2 * gap - gp0.l - gp0.r) * 1cm
      let m3 = measure(box(width: gin, g.body))
      let hd3 = if g.title != none {
        measure(box(width: gin, g.title)).height / 1cm + 0.20
      } else { 0.0 }
      let gh0 = m3.height / 1cm + hd3 + 2 * gap * 0.7
      let gp = _shape-pad(g.sh, g.w, gh0)
      let gh = gh0 + gp.t + gp.b
      let fillc = if leaf-fill != auto { leaf-fill }
                  else if prt { white } else { g.col.lighten(calc.min(96%, tint + 5%)) }
      let inkc = if leaf-ink != auto { leaf-ink }
                 else if prt { rgb("#333333") } else { g.col }
      place(top + left,
        dx: (g.p.at(0) - g.w / 2 - x0) * 1cm,
        dy: (Hh - (g.p.at(1) + gh / 2 - y0)) * 1cm,
        box(width: g.w * 1cm, height: gh * 1cm, {
          _leaf-draw(g.sh, g.w, gh, radius-leaf * 0.7,
            fill: fillc, stroke-paint: inkc, weight: weight * 0.7,
            hand: hd, seed: seed + 131, roughness: roughness,
            bowing: bowing, shadow: none)
          if g.title != none or g.icon != none {
            place(top + left, dx: (gap * 0.8 + gp.l) * 1cm,
              dy: (gap * 0.35 + gp.t) * 1cm,
              box(width: (g.w - 1.6 * gap - gp.l - gp.r) * 1cm,
                align(center, {
                  if g.icon != none { box(g.icon); h(0.3em) }
                  text(fill: if prt { black } else { inkc.darken(18%) },
                    weight: "bold", size: 0.86em, g.title)
                })))
          }
          place(top + left, dx: (gap * 0.8 + gp.l) * 1cm,
            dy: (gap * 0.7 + hd3 + gp.t) * 1cm,
            box(width: (g.w - 1.6 * gap - gp.l - gp.r) * 1cm,
              text(size: 0.86em, align(std.start, g.body))))
        }))
    }

    // ---- the second rank: stalks first, then the cards ------------------
    //
    // Drawn BEFORE the first-rank leaves so a child's stalk slips under its
    // own parent, exactly as a branch slips under a card it crosses.
    for k in kids {
      let l = k.parent
      // from the parent's edge, on the side facing the child
      let ddx = k.p.at(0) - cx(l)
      let ddy = k.p.at(1) - cy(l)
      let sdk = if calc.abs(ddx) * l.h > calc.abs(ddy) * l.w {
                  if ddx > 0 { right } else { left }
                } else if ddy > 0 { top } else { bottom }
      let f = if sdk == left { (cx(l) - l.w / 2, k.p.at(1)) }
              else if sdk == right { (cx(l) + l.w / 2, k.p.at(1)) }
              else if sdk == top { (k.p.at(0), cy(l) + l.h / 2) }
              else { (k.p.at(0), cy(l) - l.h / 2) }
      // clamp the start to the parent's own edge, then run into the child
      let f2 = if sdk == left or sdk == right {
        (f.at(0), calc.max(cy(l) - l.h / 2 + 0.22,
          calc.min(cy(l) + l.h / 2 - 0.22, f.at(1))))
      } else {
        (calc.max(cx(l) - l.w / 2 + 0.22,
          calc.min(cx(l) + l.w / 2 - 0.22, f.at(0))), f.at(1))
      }
      let pts = _stalk(P(f2), P(k.p), stalk * 0.55, stalk-tip * 0.7,
        wave: wave * 0.6, waves: waves)
      if pts.len() > 3 {
        place(top + left, _fill((pts,), flip: flip,
          fill: if prt { rgb("#666666") } else { k.col }))
      }
    }
    for k in kids {
      let kp0 = _shape-pad(k.sh, k.w, 1.0)
      let kin = (k.w - 2 * gap - kp0.l - kp0.r) * 1cm
      let m2 = measure(box(width: kin, k.body))
      let hd2 = if k.title != none {
        measure(box(width: kin, k.title)).height / 1cm + 0.24
      } else { 0.0 }
      let kh0 = m2.height / 1cm + hd2 + 2 * gap * 0.8
      let kp = _shape-pad(k.sh, k.w, kh0)
      let khh = kh0 + kp.t + kp.b
      let fillc = if leaf-fill != auto { leaf-fill }
                  else if prt { white } else { k.col.lighten(tint) }
      let inkc = if leaf-ink != auto { leaf-ink }
                 else if prt { rgb("#333333") } else { k.col }
      place(top + left,
        dx: (k.p.at(0) - k.w / 2 - x0) * 1cm,
        dy: (Hh - (k.p.at(1) + khh / 2 - y0)) * 1cm,
        box(width: k.w * 1cm, height: khh * 1cm, {
          _leaf-draw(k.sh, k.w, khh, radius-leaf * 0.8,
            fill: fillc, stroke-paint: inkc, weight: weight * 0.85,
            hand: hd, seed: seed + 71, roughness: roughness, bowing: bowing,
            shadow: if shadow { sh-col } else { none })
          if k.title != none {
            place(top + left, dx: (gap + kp.l) * 1cm,
              dy: (gap * 0.45 + kp.t) * 1cm,
              box(width: (k.w - 2 * gap - kp.l - kp.r) * 1cm,
                align(center, text(fill: if prt { black }
                  else { inkc.darken(18%) }, weight: "bold", size: 0.92em,
                  k.title))))
          }
          place(top + left, dx: (gap + kp.l) * 1cm,
            dy: (gap * 0.8 + hd2 + kp.t) * 1cm,
            box(width: (k.w - 2 * gap - kp.l - kp.r) * 1cm,
              text(size: 0.92em, align(std.start, k.body))))
        }))
    }

    // ---- leaves ---------------------------------------------------------
    for l in leaves {
      let lx = cx(l) - l.w / 2 - x0
      let ly = Hh - (cy(l) + l.h / 2 - y0)     // to page coordinates
      let fillc = if leaf-fill != auto { leaf-fill }
                  else if prt { white } else { l.col.lighten(tint) }
      let inkc = if leaf-ink != auto { leaf-ink }
                 else if prt { rgb("#333333") } else { l.col }
      place(top + left, dx: lx * 1cm, dy: ly * 1cm,
        box(width: l.w * 1cm, height: l.h * 1cm, {
          _leaf-draw(l.sh, l.w, l.h, radius-leaf,
            fill: fillc, stroke-paint: inkc, weight: weight,
            hand: hd, seed: seed + l.i * 13, roughness: roughness,
            bowing: bowing, shadow: if shadow { sh-col } else { none })
          // the title bar, in the branch's own colour
          if l.title != none or l.icon != none {
            place(top + left, dx: (gap + l.pad.l) * 1cm,
              dy: (gap * 0.55 + l.pad.t) * 1cm,
              box(width: (l.w - 2 * gap - l.pad.l - l.pad.r) * 1cm,
                align(center, {
                  if l.icon != none { box(l.icon); h(0.35em) }
                  text(fill: if prt { black } else { inkc.darken(18%) },
                    weight: "bold", l.title)
                })))
          }
          place(top + left, dx: (gap + l.pad.l) * 1cm,
            dy: (gap + l.head + l.pad.t) * 1cm,
            // NOT `align(start, ..)`: the `start` PARAMETER (the first
            // branch's angle) shadows the alignment of the same name, and
            // Typst reports it as "expected content, found angle" at the
            // call site. `std.start` reaches past the shadow.
            box(width: (l.w - 2 * gap - l.pad.l - l.pad.r) * 1cm,
              align(std.start, l.body)))
        }))
    }

    // ---- cross-links, over the cards but under the hub ------------------
    //
    // A mind map is a tree; the ideas in it rarely are. These are drawn
    // AFTER the cards so they read as an overlay rather than as part of
    // the skeleton, and dashed so they never compete with a branch.
    for lk in links {
      let a = leaves.find(m => m.i == lk.from)
      let b = leaves.find(m => m.i == lk.to)
      if a == none or b == none { continue }
      let pa = (cx(a), cy(a))
      let pb = (cx(b), cy(b))
      // start and end on the cards' edges, not their centres
      let trim(p, q, hw, hh) = {
        let dx0 = q.at(0) - p.at(0)
        let dy0 = q.at(1) - p.at(1)
        let t = calc.min(
          if calc.abs(dx0) > 0.001 { hw / calc.abs(dx0) } else { 9e9 },
          if calc.abs(dy0) > 0.001 { hh / calc.abs(dy0) } else { 9e9 })
        (p.at(0) + dx0 * t, p.at(1) + dy0 * t)
      }
      let p0 = trim(pa, pb, a.w / 2, a.h / 2)
      let p1 = trim(pb, pa, b.w / 2, b.h / 2)
      // bow the curve away from the hub, so it hugs the outside of the ring
      let mx = (p0.at(0) + p1.at(0)) / 2
      let my = (p0.at(1) + p1.at(1)) / 2
      let ml = calc.max(0.001, calc.sqrt(mx * mx + my * my))
      let side = if lk.via == "inside" { -1.0 } else { 1.0 }
      let span = calc.sqrt(calc.pow(p1.at(0) - p0.at(0), 2) + calc.pow(p1.at(1) - p0.at(1), 2))
      let ctrl = (mx + mx / ml * lk.bend * span * side,
                  my + my / ml * lk.bend * span * side)
      let curve-pts = _smooth-pts((p0, ctrl, p1), samples: 16)
      let col = if lk.colour != auto { lk.colour }
                else if prt { rgb("#555555") } else { a.col.darken(12%) }
      let dsh = if lk.dash == none { none } else { lk.dash }
      place(top + left, _lines((curve-pts.map(p => P(p)),), flip: flip,
        stroke: (paint: col, thickness: lk.weight, dash: dsh,
          cap: "round")))
      if lk.arrow {
        let n2 = curve-pts.len()
        let q0 = curve-pts.at(n2 - 2)
        let q1 = curve-pts.last()
        place(top + left, _fill((_head(P(q1),
          (q1.at(0) - q0.at(0), q1.at(1) - q0.at(1)), 0.22).map(p => p),),
          flip: flip, fill: col))
      }
      if lk.label != none {
        let lm = curve-pts.at(int(curve-pts.len() / 2))
        place(top + left,
          dx: (lm.at(0) - x0 - 0.9) * 1cm,
          dy: (Hh - (lm.at(1) - y0) - 0.24) * 1cm,
          box(width: 1.8cm, align(center,
            box(fill: if prt { white } else { bg-of-page },
              inset: (x: 2pt, y: 1pt), radius: 2pt,
              text(size: 0.78em, fill: col, lk.label)))))
      }
    }

    // ---- the hub, last: it sits over every stalk root -------------------
    let hub-o = hub-o-raw.map(p => P(p))
    let hub-i = _hub-pts(ns, rad * 0.88, start: start, phase: phase,
      shape: hub-shape, ratio: hub-ratio, ry: rady * 0.88).map(p => P(p))
    if shadow {
      place(top + left, dx: 3pt, dy: 4pt,
        _fill((hub-o,), flip: flip, fill: sh-col))
    }
    // the outer band, then the plate: two rings make it read as a frame
    if prt {
      place(top + left, _fill((hub-o,), flip: flip, fill: hf))
    } else {
      place(top + left, _fill((hub-o,), flip: flip, fill: hi))
      place(top + left, _fill((hub-i,), flip: flip, fill: hf))
    }
    if weight != 0pt {
      let st = (paint: hi.darken(22%), thickness: weight, join: "round")
      if hd == none {
        place(top + left, _lines((hub-o + (hub-o.first(),),),
          flip: flip, stroke: st))
      } else if hd == "sketch" {
        place(top + left, _rough(hub-o, flip: flip, seed: seed,
          roughness: roughness * 0.7, stroke: st))
      } else {
        // The hub must wobble too, or a hand-drawn map has one machined
        // part in the middle of it and the whole illusion goes.
        place(top + left, _rough(hub-o, flip: flip, seed: seed,
          roughness: roughness, stroke: st))
      }
    }
    // the hub's text, in a box that fits INSIDE the polygon: a regular
    // n-gon's inscribed square has side apothem*sqrt(2), which is what
    // stops long titles from spilling over the corners.
    // The text box is the polygon's inscribed RECTANGLE, which on an
    // ellipse has two different half-axes — using one number for both was
    // what made a wide title wrap in a tall hub.
    let apx = if hub-shape != auto { rad * 0.80 }
              else if ns < 3 { rad } else { rad * calc.cos(180deg / ns) }
    let apy = if hub-shape != auto { rady * 0.80 }
              else if ns < 3 { rady } else { rady * calc.cos(180deg / ns) }
    let bw2 = apx * 1.34
    let bh2 = apy * 1.34
    place(top + left,
      dx: (P((0.0, 0.0)).at(0) - bw2 / 2) * 1cm,
      dy: (Hh - P((0.0, 0.0)).at(1) - bh2 / 2) * 1cm,
      box(width: bw2 * 1cm, height: bh2 * 1cm,
        align(center + horizon, text(fill: ht, hub))))
  })
}

// -----------------------------------------------------------------------------
//  routing: getting a branch past the leaves in its way
// -----------------------------------------------------------------------------
//
//  A radial map never needs this — every leaf sits at the end of its own
//  clear ray. A map with a FIXED LAYOUT does: put nine cards in a 3 x 3
//  grid and the branch to the bottom row has two other cards across its
//  path. It has to go round them.
//
//  The method is the classic one for this problem, and it is exact rather
//  than a heuristic: build a VISIBILITY GRAPH over the corners of the
//  obstacles, then run Dijkstra on it. The shortest obstacle-avoiding path
//  between two points in a plane of polygons always runs from corner to
//  corner, so a graph of corners contains it; nothing is approximated and
//  no path can clip a card by bad luck.

/// Do segments `p1-p2` and `p3-p4` properly cross?
#let _seg-cross(p1, p2, p3, p4) = {
  let d(a, b, c) = (b.at(0) - a.at(0)) * (c.at(1) - a.at(1)) - (b.at(1) - a.at(1)) * (c.at(0) - a.at(0))
  let d1 = d(p3, p4, p1)
  let d2 = d(p3, p4, p2)
  let d3 = d(p1, p2, p3)
  let d4 = d(p1, p2, p4)
  ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0))
}

/// Does the segment `p-q` hit the rectangle `r = (x0, y0, x1, y1)`?
///
/// The cheap rejection first — if both ends are on the same outer side of
/// the box there is nothing to test — then the four edges, then the case of
/// a segment lying wholly inside.
#let _seg-rect(p, q, r) = {
  let (x0, y0, x1, y1) = r
  if (p.at(0) <= x0 and q.at(0) <= x0) or (p.at(0) >= x1 and q.at(0) >= x1) { return false }
  if (p.at(1) <= y0 and q.at(1) <= y0) or (p.at(1) >= y1 and q.at(1) >= y1) { return false }
  let c = ((x0, y0), (x1, y0), (x1, y1), (x0, y1))
  for i in range(4) {
    if _seg-cross(p, q, c.at(i), c.at(calc.rem(i + 1, 4))) { return true }
  }
  // both ends inside
  (p.at(0) > x0 and p.at(0) < x1 and p.at(1) > y0 and p.at(1) < y1)
}

/// Is the straight line `p-q` clear of every rectangle in `rects`?
#let _clear(p, q, rects) = {
  for r in rects { if _seg-rect(p, q, r) { return false } }
  true
}

/// The four corners of a rectangle, pushed out by `m`.
///
/// The corners have to sit OUTSIDE the obstacle or every one of them is
/// itself blocked and the graph has no edges at all.
#let _corners(r, m) = {
  let (x0, y0, x1, y1) = r
  ((x0 - m, y0 - m), (x1 + m, y0 - m), (x1 + m, y1 + m), (x0 - m, y1 + m))
}

/// Dijkstra over a node list, with visibility computed on demand.
///
/// The node count here is small — four corners per card plus the two ends —
/// so an O(n^2) scan for the nearest unvisited node beats carrying a heap
/// around, and it keeps the code readable.
#let _route(src, dst, rects, nodes, used: (), toll: 0.0) = {
  let pts = (src,) + nodes + (dst,)
  let n = pts.len()
  let INF = 1e9
  let dist2(a, b) = calc.sqrt(calc.pow(a.at(0) - b.at(0), 2) + calc.pow(a.at(1) - b.at(1), 2))
  // How close this edge runs to a path already drawn. Shortest-path alone
  // sends every branch down the SAME clear corridor — they came out as one
  // thick rope in the first render. A toll on ground already taken spreads
  // them out, and because it is a cost rather than a ban the routing still
  // succeeds when there is only one way through.
  let crowd(a, b) = {
    if used.len() == 0 or toll == 0.0 { return 0.0 }
    // Sample ALONG the edge, not just its midpoint: a long edge that runs
    // beside an existing path for most of its length has a midpoint that
    // may sit nowhere near it, and it slipped through untolled.
    let total = 0.0
    let m = 5
    for k in range(m) {
      let t = (k + 0.5) / m
      let px = a.at(0) + (b.at(0) - a.at(0)) * t
      let py = a.at(1) + (b.at(1) - a.at(1)) * t
      let worst = 0.0
      for u in used {
        let d = calc.sqrt(calc.pow(px - u.at(0), 2) + calc.pow(py - u.at(1), 2))
        let c = calc.max(0.0, 1.0 - d / 0.9)
        if c > worst { worst = c }
      }
      total = total + worst
    }
    total / m * toll * calc.sqrt(calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2))
  }
  // adjacency, built once
  let adj = range(n).map(i => range(n).map(j => {
    if i == j { 0.0 }
    else if _clear(pts.at(i), pts.at(j), rects) {
      dist2(pts.at(i), pts.at(j)) + crowd(pts.at(i), pts.at(j))
    }
    else { INF }
  }))
  let dist = range(n).map(i => if i == 0 { 0.0 } else { INF })
  let prev = range(n).map(_ => -1)
  let seen = range(n).map(_ => false)
  for _ in range(n) {
    let u = -1
    let best = INF
    for i in range(n) {
      if not seen.at(i) and dist.at(i) < best { best = dist.at(i); u = i }
    }
    if u < 0 { break }
    seen.at(u) = true
    if u == n - 1 { break }
    for v in range(n) {
      if not seen.at(v) {
        let w = adj.at(u).at(v)
        if w < INF and dist.at(u) + w < dist.at(v) {
          dist.at(v) = dist.at(u) + w
          prev.at(v) = u
        }
      }
    }
  }
  if dist.at(n - 1) >= INF { return (src, dst) }   // nothing found: go direct
  let path = (n - 1,)
  let cur = n - 1
  while prev.at(cur) >= 0 { cur = prev.at(cur); path.push(cur) }
  path.rev().map(i => pts.at(i))
}

/// A tapered stalk along a POLYLINE, rather than between two points.
///
/// Same construction as `_stalk`: the centreline first, then each edge
/// offset along the LOCAL tangent so the width survives the corners.
#let _stalk-path(pts, w0, w1, smooth: 14) = {
  let mid = if pts.len() > 2 and smooth > 0 {
    _smooth-pts(pts, samples: smooth)
  } else if pts.len() == 2 {
    range(25).map(i => {
      let t = i / 24
      (pts.at(0).at(0) + (pts.at(1).at(0) - pts.at(0).at(0)) * t,
       pts.at(0).at(1) + (pts.at(1).at(1) - pts.at(0).at(1)) * t)
    })
  } else { pts }
  let n = mid.len() - 1
  if n < 1 { return () }
  // cumulative length, so the taper follows DISTANCE travelled and not the
  // sample index: a smoothed path is sampled unevenly round its corners
  let cum = (0.0,)
  for i in range(1, mid.len()) {
    let a = mid.at(i - 1)
    let b = mid.at(i)
    cum.push(cum.at(i - 1) + calc.sqrt(calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2)))
  }
  let total = calc.max(0.001, cum.last())
  let half(t) = (w0 + (w1 - w0) * calc.pow(t, 0.62)) / 2
  let side(sg) = range(mid.len()).map(i => {
    let a = mid.at(calc.max(0, i - 1))
    let b = mid.at(calc.min(n, i + 1))
    let tx = b.at(0) - a.at(0)
    let ty = b.at(1) - a.at(1)
    let tl = calc.max(0.0001, calc.sqrt(tx * tx + ty * ty))
    let (mx, my) = mid.at(i)
    let w = half(cum.at(i) / total)
    (mx - ty / tl * sg * w, my + tx / tl * sg * w)
  })
  side(1.0) + side(-1.0).rev()
}

// -----------------------------------------------------------------------------
//  31. mindgrid — a mind map on a FIXED layout, with routed branches
// -----------------------------------------------------------------------------

/// One placed leaf: same as `branch`, plus where it goes.
///
///   col, row   its cell in the grid (0-based), or
///   x, y       an absolute position in cm, y UP, hub at the origin
#let node(body, title: none, icon: none, colour: auto, shape: auto,
          width: auto, col: none, row: none, x: none, y: none,
          side: auto) = (
  body: body, title: title, icon: icon, colour: colour, shape: shape,
  width: width, col: col, row: row, x: x, y: y, side: side,
)

/// A mind map whose leaves keep a layout you choose, with every branch
/// ROUTED round the cards in its way.
///
/// The radial `mindmap` gives each leaf a clear ray. This one does not: on
/// a 3 x 3 grid the branch to a bottom corner has two other cards across
/// its path, so the stalks are routed on a visibility graph instead of
/// being drawn straight (see `_route`).
///
///   cols, rows    the grid; `gap-x`, `gap-y` the space between cards
///   hub-at        which cell the hub occupies, or `none` to place it by
///                 `hub-x` / `hub-y`
///   clearance     how far a branch keeps off a card, in cm
#let mindgrid(
  hub,
  ..nodes,
  cols: 3,
  rows: auto,
  cell: 5.4,
  cell-h: auto,
  gap-x: 0.9,       // ALSO the width of the corridors the branches use
  gap-y: 0.8,
  hub-at: auto,
  hub-x: 0.0,
  hub-y: 0.0,
  sides: auto,
  hub-shape: auto,
  hub-ratio: 1.0,
  radius: auto,
  palette: "poster",
  theme: auto,
  shape: "round",
  weight: 1.2pt,
  hub-fill: auto,
  hub-ink: auto,
  hub-text: auto,
  leaf-fill: auto,
  leaf-ink: auto,
  tint: 88%,
  stalk: 0.30,
  stalk-tip: 0.10,
  wave: 0.045,
  waves: 1.6,
  route: false,          // `true` bends the branches round the cards
  clearance: 0.34,
  radius-leaf: 0.34,
  gap: 0.30,
  shadow: true,
  dir: auto,
  seed: 3,
  rough: false,
  hand: none,
  roughness: 1.0,
  bowing: 0.6,
) = context {
  let items = nodes.pos().map(b =>
    if type(b) == dictionary and "body" in b { b } else { node(b) })
  let n = items.len()
  if n == 0 { return }
  let r2l = if dir != auto { dir == rtl } else { text.dir == rtl }
  let hd = if rough { if hand != none { hand } else { "roughjs" } } else { none }
  let prt = theme == "print"
  let ns = if sides != auto { sides } else { n }
  let rad = if radius != auto { radius } else { calc.max(1.3, 0.30 * cell) }

  // ---- lay the cells out -------------------------------------------------
  let nrows = if rows != auto { rows } else {
    calc.ceil((n + (if hub-at != auto { 1 } else { 0 })) / cols)
  }
  let ch = if cell-h != auto { cell-h } else { cell * 0.62 }
  let step-x = cell + gap-x
  let step-y = ch + gap-y
  // the grid is centred on the hub, so a cell index maps straight to cm
  let cx0 = -(cols - 1) * step-x / 2
  let cy0 = (nrows - 1) * step-y / 2
  let cell-pos(c, r) = (cx0 + c * step-x, cy0 - r * step-y)

  // where the hub sits
  let hub-pos = if hub-at != auto { cell-pos(hub-at.first(), hub-at.last()) }
                else { (hub-x, hub-y) }

  // ---- place every leaf, measuring its height ----------------------------
  let auto-cells = ()
  for r in range(nrows) {
    for c in range(cols) {
      if hub-at == auto or not (c == hub-at.first() and r == hub-at.last()) {
        auto-cells.push((c, r))
      }
    }
  }
  let k = 0
  let leaves = ()
  for (i, b) in items.enumerate() {
    let pos = if b.x != none { (b.x, if b.y != none { b.y } else { 0.0 }) }
              else if b.col != none {
                cell-pos(b.col, if b.row != none { b.row } else { 0 })
              } else {
                let cc = auto-cells.at(calc.min(k, auto-cells.len() - 1))
                k = k + 1
                cell-pos(cc.first(), cc.last())
              }
    // In a GRID the cell size is the point — the cards line up — so the
    // width stays fixed here rather than shrinking to its contents the way
    // a radial leaf does.
    let lw = if b.width != auto { b.width } else { cell }
    let sh0 = if b.shape != auto { b.shape } else { shape }
    // An ornamented shape does not fill its box — see `_shape-pad`. The
    // WIDTH is fixed here, so the text is simply inset; the HEIGHT is free,
    // so the card grows instead, exactly as in `mindmap`.
    let pd0 = _shape-pad(sh0, lw, 1.0)
    let inner = lw - 2 * gap - pd0.l - pd0.r
    let ico = b.at("icon", default: none)
    let head = if b.title != none or ico != none {
      let hb = if b.title != none { b.title } else { ico }
      calc.max(measure(box(width: inner * 1cm, hb)).height / 1cm,
        if ico != none { measure(box(ico)).height / 1cm } else { 0.0 }) + 0.30
    } else { 0.0 }
    let bh = measure(box(width: inner * 1cm, b.body)).height / 1cm
    let h0 = bh + head + 2 * gap
    let pd = _shape-pad(sh0, lw, h0)
    let lh = h0 + pd.t + pd.b
    let pd = _shape-pad(sh0, lw, lh)
    let lh = h0 + pd.t + pd.b
    leaves.push((i: i, p: pos, w: lw, h: lh, head: head, pad: pd,
      col: if b.colour != auto { b.colour } else { _hue(palette, i) },
      sh: if b.shape != auto { b.shape } else { shape },
      side: b.side, title: b.title, body: b.body,
      icon: b.at("icon", default: none)))
  }

  // ---- the canvas --------------------------------------------------------
  let pad = 0.30
  let xs = leaves.map(l => (l.p.at(0) - l.w / 2, l.p.at(0) + l.w / 2)).flatten()
  let ys = leaves.map(l => (l.p.at(1) - l.h / 2, l.p.at(1) + l.h / 2)).flatten()
  let x0 = calc.min(hub-pos.at(0) - rad, ..xs) - pad
  let x1 = calc.max(hub-pos.at(0) + rad, ..xs) + pad
  let y0 = calc.min(hub-pos.at(1) - rad, ..ys) - pad
  let y1 = calc.max(hub-pos.at(1) + rad, ..ys) + pad
  let W = x1 - x0
  let Hh = y1 - y0
  let flip = Hh * 1cm
  let P(p) = (p.at(0) - x0, p.at(1) - y0)

  // ---- the obstacles: every card, grown by the clearance -----------------
  // The clearance is capped at just under HALF the gutter. Grow the boxes
  // by more than that and the two halves of a corridor meet in the middle:
  // the gap seals shut, the visibility graph finds no way through, and
  // every branch falls back to a straight line across the cards. That was
  // the failure the first renders showed, and it looks like the router is
  // ignoring the obstacles when in fact it can no longer reach anything.
  let clearance = calc.min(clearance, calc.min(gap-x, gap-y) * 0.42)
  let boxes = leaves.map(l => (
    l.p.at(0) - l.w / 2 - clearance, l.p.at(1) - l.h / 2 - clearance,
    l.p.at(0) + l.w / 2 + clearance, l.p.at(1) + l.h / 2 + clearance))

  let hf = if prt and hub-fill == auto { white }
           else if hub-fill == "palette" { _hue(palette, 0).darken(38%) }
           else if hub-fill != auto { hub-fill } else { rgb("#0B3C7A") }
  let hi = if hub-ink != auto { hub-ink }
           else if prt { rgb("#333333") } else { hf.lighten(24%) }
  let ht = if hub-text != auto { hub-text }
           else if prt { black }
           else if luma(hf).components().first() > 58% { hf.darken(62%) }
           else { white }
  let sh-col = rgb("#00000022")
  let shadow = if prt { false } else { shadow }

  // ---- the stalks --------------------------------------------------------
  //
  // No routing here any more, and that is the point. A branch runs STRAIGHT
  // from the hub to its card and simply passes BEHIND whatever is in the
  // way: the cards are drawn afterwards, so they cover it. That is what a
  // real diagram does — the line is understood to continue under the box —
  // and it keeps the stalks smooth and waving instead of sending them on
  // long detours round the grid.
  //
  // `_route` and the visibility graph stay in the file: `mindgrid(route:
  // true)` still bends the branches round the cards for a caller who wants
  // no crossings at all.
  let hub-o-raw = _hub-pts(ns, rad, start: 90deg, shape: hub-shape,
    ratio: hub-ratio)
  let routes = ()
  let taken = ()
  for l in leaves {
    let a = calc.atan2(l.p.at(0) - hub-pos.at(0), l.p.at(1) - hub-pos.at(1))
    let foot0 = if hub-shape == auto { _hub-foot(ns, rad, a) }
                else { _ray-hit(hub-o-raw, a, _hub-foot(ns, rad, a)) }
    // Fan the feet along the side they share: several cards can face the
    // same edge of the polygon — the whole bottom row does on a 3 x 3 grid
    // — and with one foot per side they all set off from the same point.
    let same = leaves.filter(m => {
      let am = calc.atan2(m.p.at(0) - hub-pos.at(0), m.p.at(1) - hub-pos.at(1))
      calc.abs(calc.rem(((am - a) / 1deg) + 540.0, 360.0) - 180.0) < 180.0 / ns
    })
    let k2 = same.len()
    let idx = same.sorted(key: m => m.p.at(0)).position(m => m.i == l.i)
    let sidelen = if ns < 3 { rad } else { 2 * rad * calc.sin(180deg / ns) }
    // Spread the feet across the side they share. 0.72 of the side was too
    // timid once three cards faced the same face — the stalks left as a
    // bundle and only parted later. 0.92 uses nearly the whole edge and
    // still leaves the polygon's corners clear.
    let spanf = if k2 <= 1 { 0.0 } else { (idx / (k2 - 1) - 0.5) * sidelen * 0.92 }
    let foot = (hub-pos.at(0) + foot0.at(0) - calc.sin(a) * spanf,
                hub-pos.at(1) + foot0.at(1) + calc.cos(a) * spanf)

    // where it meets the card: the middle of the edge facing the hub
    let dxs = l.p.at(0) - hub-pos.at(0)
    let dys = l.p.at(1) - hub-pos.at(1)
    let sd = if l.side != auto { l.side }
             else if calc.abs(dxs) * l.h > calc.abs(dys) * l.w {
               if dxs > 0 { left } else { right }
             } else if dys > 0 { bottom } else { top }
    // WHERE ON THE EDGE the stalk lands. Aiming at the MIDDLE of the edge
    // is what made the branches converge: every stalk on the same side of
    // the map is pulled towards one point and they meet before they get
    // there. Sliding the dock along the edge to face the foot instead
    // keeps the stalks roughly parallel, and two branches only touch if
    // their cards do.
    //
    // `inset` keeps the dock off the very corner, where a stalk would
    // graze the card's rounded edge.
    let slide(lo, hi, v) = calc.max(lo, calc.min(hi, v))
    let inset = 0.30
    let dock = if sd == left or sd == right {
      let x = l.p.at(0) + (if sd == left { -1.0 } else { 1.0 }) * l.w / 2
      (x, slide(l.p.at(1) - l.h / 2 + inset, l.p.at(1) + l.h / 2 - inset,
                foot.at(1)))
    } else {
      let y = l.p.at(1) + (if sd == top { 1.0 } else { -1.0 }) * l.h / 2
      (slide(l.p.at(0) - l.w / 2 + inset, l.p.at(0) + l.w / 2 - inset,
             foot.at(0)), y)
    }
    // run a little INTO the card, so the join is hidden under its edge
    let vx = dock.at(0) - foot.at(0)
    let vy = dock.at(1) - foot.at(1)
    let vl = calc.max(0.001, calc.sqrt(vx * vx + vy * vy))
    let tip = (dock.at(0) + vx / vl * 0.18, dock.at(1) + vy / vl * 0.18)

    if route {
      let others = ()
      for (j, bx) in boxes.enumerate() { if j != l.i { others.push(bx) } }
      others.push((hub-pos.at(0) - rad * 0.80, hub-pos.at(1) - rad * 0.80,
                   hub-pos.at(0) + rad * 0.80, hub-pos.at(1) + rad * 0.80))
      let corners = ()
      for bx in others { for c in _corners(bx, 0.06) { corners.push(c) } }
      let p0 = _route(foot, dock, others, corners, used: taken, toll: 3.5)
      routes.push((l: l, path: p0, straight: false))
      for i in range(p0.len() - 1) {
        let p = p0.at(i)
        let q = p0.at(i + 1)
        for t in (0.25, 0.5, 0.75) {
          taken.push((p.at(0) + (q.at(0) - p.at(0)) * t,
                      p.at(1) + (q.at(1) - p.at(1)) * t))
        }
      }
    } else {
      routes.push((l: l, path: (foot, tip), straight: true))
    }
  }

  box(width: W * 1cm, height: Hh * 1cm, {
    for rt in routes {
      let l = rt.l
      let pts = if rt.straight {
        // the waving stalk of `mindmap`, alternating side by side
        _stalk(P(rt.path.first()), P(rt.path.last()), stalk,
          if prt { stalk-tip * 0.5 } else { stalk-tip },
          wave: wave * (if calc.rem(l.i, 2) == 0 { 1.0 } else { -1.0 }),
          waves: waves)
      } else {
        _stalk-path(rt.path.map(p => P(p)), stalk,
          if prt { stalk-tip * 0.5 } else { stalk-tip })
      }
      if pts.len() > 3 {
        if shadow {
          place(top + left, dx: 2pt, dy: 2.5pt,
            _fill((pts,), flip: flip, fill: sh-col))
        }
        place(top + left, _fill((pts,), flip: flip,
          fill: if prt { rgb("#555555") } else { l.col }))
      }
    }

    // ---- the cards -------------------------------------------------------
    for l in leaves {
      let lx = l.p.at(0) - l.w / 2 - x0
      let ly = Hh - (l.p.at(1) + l.h / 2 - y0)
      let fillc = if leaf-fill != auto { leaf-fill }
                  else if prt { white } else { l.col.lighten(tint) }
      let inkc = if leaf-ink != auto { leaf-ink }
                 else if prt { rgb("#333333") } else { l.col }
      place(top + left, dx: lx * 1cm, dy: ly * 1cm,
        box(width: l.w * 1cm, height: l.h * 1cm, {
          _leaf-draw(l.sh, l.w, l.h, radius-leaf,
            fill: fillc, stroke-paint: inkc, weight: weight,
            hand: hd, seed: seed + l.i * 13, roughness: roughness,
            bowing: bowing, shadow: if shadow { sh-col } else { none })
          if l.title != none or l.icon != none {
            place(top + left, dx: (gap + l.pad.l) * 1cm,
              dy: (gap * 0.55 + l.pad.t) * 1cm,
              box(width: (l.w - 2 * gap - l.pad.l - l.pad.r) * 1cm,
                align(center, {
                  if l.icon != none { box(l.icon); h(0.35em) }
                  text(fill: if prt { black } else { inkc.darken(18%) },
                    weight: "bold", l.title)
                })))
          }
          place(top + left, dx: (gap + l.pad.l) * 1cm,
            dy: (gap + l.head + l.pad.t) * 1cm,
            box(width: (l.w - 2 * gap - l.pad.l - l.pad.r) * 1cm,
              align(std.start, l.body)))
        }))
    }

    // ---- the hub ---------------------------------------------------------
    let hub-o = hub-o-raw
      .map(p => P((hub-pos.at(0) + p.at(0), hub-pos.at(1) + p.at(1))))
    let hub-i = _hub-pts(ns, rad * 0.88, start: 90deg, shape: hub-shape,
      ratio: hub-ratio)
      .map(p => P((hub-pos.at(0) + p.at(0), hub-pos.at(1) + p.at(1))))
    if shadow {
      place(top + left, dx: 3pt, dy: 4pt,
        _fill((hub-o,), flip: flip, fill: sh-col))
    }
    if prt {
      place(top + left, _fill((hub-o,), flip: flip, fill: hf))
    } else {
      place(top + left, _fill((hub-o,), flip: flip, fill: hi))
      place(top + left, _fill((hub-i,), flip: flip, fill: hf))
    }
    if weight != 0pt {
      let st = (paint: hi.darken(22%), thickness: weight, join: "round")
      if hd == none {
        place(top + left, _lines((hub-o + (hub-o.first(),),),
          flip: flip, stroke: st))
      } else {
        place(top + left, _rough(hub-o, flip: flip, seed: seed, roughness: roughness, stroke: st))
      }
    }
    let ap = if ns < 3 { rad } else { rad * calc.cos(180deg / ns) }
    let sq = ap * 1.34
    place(top + left,
      dx: (P(hub-pos).at(0) - sq / 2) * 1cm,
      dy: (Hh - P(hub-pos).at(1) - sq / 2) * 1cm,
      box(width: sq * 1cm, height: sq * 1cm,
        align(center + horizon, text(fill: ht, hub))))
  })
}
