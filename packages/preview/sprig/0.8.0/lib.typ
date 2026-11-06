// =============================================================================
//  sprig — mind maps for Typst
//
//  A hub, branches that grow out of it, and a card at the end of each one.
//  The hub is a polygon with exactly as many sides as there are branches —
//  each branch leaves from the MIDPOINT OF ITS OWN SIDE, so the stalk meets
//  a flat edge square-on — or any other shape you name.
//
//  Five genres share that one grammar:
//
//    `mindmap`    the radial tree, on a ring or stacked in columns
//    `blossom`    the flower: one solid petal per branch, no sub-leaves
//    `mindgrid`   the fixed layout, branches routed behind the cards
//    `sticky`     the wall of post-its: cells, not a ring, and felt-tip arrows
//    `tikzmap`    the concept map, in the manner of TikZ's `mindmap` library
//
//  The maps use Typst's own `curve`; the optional calligraphic Buzan stroke
//  engine is nibart from Typst Universe.
// =============================================================================

// The calligraphic branch renderer uses the official Typst Universe package.
// It is also kept behind `stroke-engine:` in `buzan` so a project that wants
// the original sampled contour can opt back into it.
#import "@preview/nibart:0.3.0" as nib

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

/// Convert a bare centimetre value or a Typst length to centimetres.
#let _cm(v) = if type(v) == length { v / 1cm } else { v }

/// Normalise optional dimensional limits. `none` means unbounded.
#let _limit(v, fallback: none) = if v == auto or v == none { fallback } else { _cm(v) }

/// Fit a content-driven width/height pair inside caller-supplied bounds.
/// `height-at(w)` measures the *real wrapped content* at width `w`. If the
/// maximum height is tight, the width is expanded (up to its maximum) before
/// the function gives up: it never silently clips a leaf's text.
#let _fit-dimensions(want-w, min-w, max-w, min-h, max-h, height-at,
                     what: "leaf") = {
  if max-w < min-w {
    panic("sprig: " + what + " has min-width greater than max-width")
  }
  if max-h != none and max-h < min-h {
    panic("sprig: " + what + " has min-height greater than max-height")
  }
  let w = calc.max(min-w, calc.min(max-w, want-w))
  if max-h != none and height-at(w) > max-h + 0.001 {
    if height-at(max-w) > max-h + 0.001 {
      panic("sprig: " + what + " cannot fit within max-height at max-width; "
        + "increase max-width/max-height or shorten its content")
    }
    let lo = w
    let hi = max-w
    for _ in range(28) {
      let mid = (lo + hi) / 2
      if height-at(mid) > max-h { lo = mid } else { hi = mid }
    }
    w = hi
  }
  let needed-h = height-at(w)
  let h = calc.max(min-h, needed-h)
  if max-h != none and h > max-h + 0.001 {
    panic("sprig: " + what + " cannot fit between min-height and max-height")
  }
  (w: w, h: h)
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
  // The paper box, for `sticky`: what a drawer of post-its actually holds.
  // Saturated enough to read as coloured paper from the back of a classroom,
  // pale enough for a pen to stay legible on it.
  sticky: (rgb("#FCE28A"), rgb("#C3E3A2"), rgb("#F6B6CE"), rgb("#A8D5F2"),
           rgb("#FBCF9A"), rgb("#CDBAEA"), rgb("#A6E0CF"), rgb("#F7A48E")),
)

/// Pick colour `i` from a palette, cycling if there are more branches than
/// colours — a map with ten branches must not run out on the ninth.
// `children:` accepts one `branch(..)` as well as an array of them; every
// place that reads it goes through here, so a lone child is a one-child brood
// and not a dictionary that happens to have a length.
#let _kids(v) = if type(v) == dictionary { (v,) } else { v }

// `upper` is also the name of a knob below, and inside `buzan` that parameter
// shadows the global function — so the capitaliser lives out here.
#let _caps(t) = upper(t)

#let _hue(pal, i) = {
  let p = if type(pal) == array { pal }
          else { sprig-palettes.at(pal, default: sprig-palettes.poster) }
  // a palette written with hex strings is a normal thing to type, and a
  // string cannot be lightened, mixed or handed to `fill` — settle it here,
  // once, so every genre below may treat its colours as colours
  let c = p.at(calc.rem(i, p.len()))
  if type(c) == str { rgb(c) } else { c }
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
  // A named or custom hub contour has its own geometry and does not depend on
  // the branch count. The default polygon still uses one side per branch.
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
            else if type(shape) == int { (rr, ph) => _ngon(calc.max(3, shape), rr, phase: ph) }
            else { (rr, ph) => _ngon(calc.max(3, n), rr, phase: ph) }
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
// -----------------------------------------------------------------------------
//  the lumpy cloud: the asymmetric recipe of the PGF world, ported
// -----------------------------------------------------------------------------

/// The `random()` of PGF, made deterministic.
///
/// Typst has no random number generator and a document may not change between
/// two compilations of the same file, so this is the arithmetic the TeX world
/// uses anyway: mix the seed with the index, reduce it modulo a Mersenne prime,
/// read it back in [-1, 1]. Nothing about it is cryptographic. Everything about
/// it is *varied*, which is all a cloud needs.
#let _pgf-rnd(seed, i) = {
  let m = 2147483647
  let x = calc.rem(seed * 374761393 + i * 668265263, m)
  let y = calc.rem(x * 2654435761 + i * 40503, m)
  (y * 1.0 / m) * 2.0 - 1.0
}

/// A cloud that is NOT symmetrical, which is what a cloud is.
///
/// ```typst
/// #buzan(
///   hub-shape: sprig-cloud(puffs: 8, lump: 0.3, seed: 1242),
///   [Idée], branch[mot-clé], branch[image], branch[saute-soleil])
/// ```
///
/// Ported from the generative answer to "Asymmetric cloud shape in TikZ"
/// (tex.stackexchange.com/q/45404), and it is that recipe and no other: sample
/// `puffs` points along an ellipse with the ANGULAR PARAMETER jittered, squash
/// the lower half of the ellipse by `squash` so one side of the cloud comes in
/// flatter than the other, then join every two neighbours by a curve whose
/// tangent angles are read off the CHORD (TikZ's `relative=true`) and bow to
/// the right of travel — a pinch between two lumps, which is the whole trick of
/// the silhouette. `bump` is that answer's `looseness`, `angle` its
/// `random angle`, `jitter` its `random pos`, and `seed` its `\pgfmathsetseed`.
///
/// `puffs` is truncated to a whole number, `squash` is kept inside (0.05, 1],
/// and a `squash` of 1 gives the symmetric ring the question was unhappy with.
///
/// Four departures, each deliberate:
///   * the split between the two halves comes from the SIGN OF THE SINE, not
///     from `i > puffs/2` as in the source, so that a jittered parameter cannot
///     straddle the division and tear the outline open;
///   * `lump:` varies each lump's RADIUS. PGF puts them all on the ellipse and
///     varies only where they fall, and a ring of equal bubbles reads as a gear
///     — a hand's cloud has a big lobe beside a small one;
///   * `ramp:` blends the two halves' scales over a band around the axis instead
///     of switching at it, which is what keeps a needle from standing up where
///     the flat belly meets the round back;
///   * the ring of lumps is normalised into the box it is asked for, scaled
///     apart on the two axes so that a wide hub is filled by a wide cloud and
///     the words stay inside it — but never more than 1.5:1 apart, and with the
///     depth of each pinch bounded by its neighbours, so nothing can burst
///     through the box afterwards. PGF needs neither: it draws an ellipse of
///     whatever axes it is handed and lets the picture be as big as that.
///
/// Like every shape here it is a function `(w, h, r) => contour`, centimetres,
/// y UP, origin at the bottom left: use it as `sprig-shapes."cumulus"`, as
/// `shape:` on any leaf, or as `hub-shape:` on a `buzan` map — and
/// `out-angle:` / `in-angle:` are the two tangent angles of every join (both
/// negative in the source, which is what bows them to the right of travel);
/// opening them toward `-90deg` and `-90deg` straightens the curl when a seed
/// comes out looking like a whirlpool rather than a cloud. `in` alone is not a
/// legal name in Typst, hence the spelled-out ones.
#let sprig-cloud(
  seed: 7,
  puffs: 12,
  squash: 0.62,
  bump: 2.6,
  lump: 0.22,
  ramp: 0.5,
  tilt: 0deg,
  jitter: 240deg,
  angle: 35deg,
  out-angle: -48deg,
  in-angle: -62deg,
) = (w, h, r) => {
  // `\pgfmathtruncatemacro\puffs` and `360 / cloud puffs` are TWO numbers in
  // PGF, and the difference between them is the asymmetry the shape is famous
  // for: the count of lobes is truncated while the angle they step is divided
  // by the raw value, so an even `puffs` closes the ring exactly and a fractional
  // one leaves it a fraction of a step short — one join then takes up the slack
  // and that lump comes out fatter than its neighbours. `calc.floor` is the
  // truncation, `pf` the raw value, and an integer `puffs` is left exactly as it
  // was: 10 lumps, evenly shared, nothing to see.
  let pf = calc.max(3.0, puffs)
  let n = calc.max(3, calc.floor(pf))
  let sq = calc.max(0.05, calc.min(1.0, squash))
  let ax = w / 2
  let by = h / (1.0 + sq)
  let cf = calc.cos(tilt)
  let sf = calc.sin(tilt)
  let pts = ()
  let i = 0
  while i < n {
    let t = 360deg * (i + 0.5) / pf + jitter * _pgf-rnd(seed, i * 2) / pf
    let s = calc.sin(t)
    // the `squashiness` of the source, blended across the axis rather than
    // switched at it: `ramp: 0` is exactly PGF's `puff > puffs/2` test, and a
    // hard test leaves a needle at the join where the two halves meet, since
    // the neighbour across the axis is drawn at another scale altogether
    let k = if ramp <= 0.0 {
      if s >= 0.0 { 1.0 } else { sq }
    } else {
      1.0 - (1.0 - sq) * calc.min(1.0, calc.max(0.0, (1.0 - 2.0 * s / ramp) * 0.5 + 0.5))
    }
    // the lumps' sizes are kept within a third of the radius: past that a lobe
    // stops being a lobe and becomes a tail, and a cloud with a tail is a joke
    let g = 1.0 + calc.min(0.3, calc.max(-0.3, lump)) * _pgf-rnd(seed, i * 2 + 1)
    let ex = ax * calc.cos(t) * cf - by * s * sf * k * g
    let ey = ax * calc.cos(t) * sf + by * s * cf * k * g
    pts.push((w / 2 + ex, h / 2 + ey))
    i += 1
  }
  let rot(vx, vy, a) = (vx * calc.cos(a) - vy * calc.sin(a),
    vx * calc.sin(a) + vy * calc.cos(a))
  // the outline, exactly as the source draws it: one cubic per pair of
  // neighbours, each pair's own chord for reference, and both control points on
  // their tangent at a third of the chord times `bump`, which is TikZ's reading
  // of `looseness`
  let walk(q) = {
    // every join is measured against its two neighbours first: a pinch may be as
    // deep as its own chord wants when the chords on either side agree, and is
    // pulled back when they do not, which is what stops a lone long chord from
    // swinging out into a curl past the end of the cloud
    let chords = ()
    let k = 0
    while k < n {
      let p0 = q.at(k)
      let p1 = q.at(calc.rem(k + 1, n))
      let dx = p1.at(0) - p0.at(0)
      let dy = p1.at(1) - p0.at(1)
      chords.push(calc.max(0.001, calc.sqrt(dx * dx + dy * dy)))
      k += 1
    }
    let out = ()
    let j = 0
    while j < n {
      let p0 = q.at(j)
      let p1 = q.at(calc.rem(j + 1, n))
      let dx = p1.at(0) - p0.at(0)
      let dy = p1.at(1) - p0.at(1)
      let dl = chords.at(j)
      let ux = dx / dl
      let uy = dy / dl
      let nb = calc.min(chords.at(calc.rem(j - 1, n)), chords.at(calc.rem(j + 1, n)))
      let ao = out-angle - angle * (0.5 + 0.5 * _pgf-rnd(seed, 1000 + j * 3))
      let ai = in-angle - angle * (0.5 + 0.5 * _pgf-rnd(seed, 1000 + j * 3 + 1))
      let kk = bump / 3 * calc.min(dl, 0.75 * nb)
      let vo = rot(ux, uy, ao)
      let vi = rot(ux, uy, ai)
      let c1 = (p0.at(0) + kk * vo.at(0), p0.at(1) + kk * vo.at(1))
      let c2 = (p1.at(0) - kk * vi.at(0), p1.at(1) - kk * vi.at(1))
      let m = 0
      while m < 9 {
        let t = m / 9
        let u = 1 - t
        let bx = u*u*u*p0.at(0) + 3*u*u*t*c1.at(0) + 3*u*t*t*c2.at(0) + t*t*t*p1.at(0)
        let by = u*u*u*p0.at(1) + 3*u*u*t*c1.at(1) + 3*u*t*t*c2.at(1) + t*t*t*p1.at(1)
        out.push((bx, by))
        m += 1
      }
      j += 1
    }
    out
  }
  // the box the hub was measured in is the box the WORDS were measured in, so
  // the ring of lumps — not the outline, whose hooks and pinches would stretch
  // the fit and shrink the body — is what gets brought back into it, scaled
  // APART on the two axes since a wide hub has to be filled by a wide cloud and
  // its words have to stay inside it. But not more than three halves as far one
  // way as the other: a lobe stretched thinner than that is a wave, not a cloud.
  // The pinches themselves are already bounded, by the neighbour test above, so
  // they cannot burst through the box afterwards; and `ext` leaves the canvas a
  // quarter of a centimetre of air all round, in case a curl reaches that far.
  let xs = pts.map(q => q.at(0))
  let ys = pts.map(q => q.at(1))
  let mx = (calc.min(..xs) + calc.max(..xs)) / 2
  let my = (calc.min(..ys) + calc.max(..ys)) / 2
  let sx = calc.max(0.05, calc.max(..xs) - calc.min(..xs))
  let sy = calc.max(0.05, calc.max(..ys) - calc.min(..ys))
  let pad = 0.05
  let fx = (w - 2 * pad) / sx
  let fy = (h - 2 * pad) / sy
  let gx = calc.min(fx, fy * 1.5)
  let gy = calc.min(fy, gx * 1.5)
  let q = pts.map(u => (w / 2 + (u.at(0) - mx) * gx, h / 2 + (u.at(1) - my) * gy))
  walk(q)
}

#let sprig-shapes = (
  // No outline at all: the card is bare words. It is what a wall of paper
  // notes does with a keyword, and what a board like Mural does with the last
  // rank — a label with nothing round it.
  "none": (w, h, r) => (),
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
    // A soft, asymmetrical cumulus outline, sampled from broad rounded lobes.
    // The central body stays wide and calm; the scallops live at the edge so
    // text has a real, generous place to sit instead of meeting a gear tooth.
    let anchors = (
      (0.20, 0.17), (0.12, 0.20), (0.08, 0.29), (0.08, 0.39),
      (0.12, 0.48), (0.19, 0.52), (0.20, 0.62), (0.27, 0.69),
      (0.35, 0.69), (0.40, 0.79), (0.50, 0.86), (0.60, 0.82),
      (0.64, 0.70), (0.72, 0.69), (0.78, 0.63), (0.80, 0.53),
      (0.88, 0.51), (0.93, 0.44), (0.93, 0.35), (0.89, 0.28),
      (0.82, 0.26), (0.81, 0.20), (0.74, 0.15), (0.65, 0.16),
      (0.59, 0.21), (0.51, 0.17), (0.42, 0.16), (0.34, 0.20),
      (0.26, 0.16),
    ).map(p => (p.at(0) * w, p.at(1) * h))
    _smooth-pts(anchors, samples: 8, closed: true)
  },

  "asym": (w, h, r) => {
    // Source: https://tex.stackexchange.com/a/448414 (vi pa, CC BY-SA 4.0)
    // \AsymCloud path: 6 cubic beziers, asymmetric blob, text at midpoint of asy1-asy2
    // Normalised to (w,h) box, origin bottom-left, y up
    let segs = (
      ((-1.6, -0.7), (-2.3, -1.1), (-2.7, 0.3), (-1.7, 0.3)),
      ((-1.7, 0.3), (-1.6, 0.7), (-1.2, 0.9), (-0.8, 0.7)),
      ((-0.8, 0.7), (-0.5, 1.5), (0.6, 1.3), (0.7, 0.5)),
      ((0.7, 0.5), (1.5, 0.4), (1.2, -1.0), (0.4, -0.6)),
      ((0.4, -0.6), (0.2, -1.0), (-0.2, -1.0), (-0.5, -0.7)),
      ((-0.5, -0.7), (-0.9, -1.0), (-1.3, -1.0), (-1.6, -0.7)),
    )
    let pts = ()
    for seg in segs {
      let p0 = seg.at(0)
      let c1 = seg.at(1)
      let c2 = seg.at(2)
      let p1 = seg.at(3)
      let k = 0
      while k < 12 {
        let t = k / 12
        let u = 1 - t
        let x = u*u*u*p0.at(0) + 3*u*u*t*c1.at(0) + 3*u*t*t*c2.at(0) + t*t*t*p1.at(0)
        let y = u*u*u*p0.at(1) + 3*u*u*t*c1.at(1) + 3*u*t*t*c2.at(1) + t*t*t*p1.at(1)
        pts.push((x, y))
        k += 1
      }
    }
    let xs = pts.map(p => p.at(0))
    let ys = pts.map(p => p.at(1))
    let minx = calc.min(..xs)
    let maxx = calc.max(..xs)
    let miny = calc.min(..ys)
    let maxy = calc.max(..ys)
    let bw = calc.max(0.01, maxx - minx)
    let bh = calc.max(0.01, maxy - miny)
    let mx = (minx + maxx) / 2
    let my = (miny + maxy) / 2
    let pad = 0.06
    let sx = (w - 2*pad) / bw
    let sy = (h - 2*pad) / bh
    let sc = calc.min(sx, sy) * 0.92
    let scx = calc.min(sx, sc*1.25)
    let scy = calc.min(sy, sc*1.25)
    pts.map(p => (w/2 + (p.at(0)-mx)*scx, h/2 + (p.at(1)-my)*scy))
  },
  // the asymmetric cloud, under its own name: a thought bubble drawn by a hand
  // rather than by a compass. `sprig-cloud(..)` is the same thing with its knobs
  // exposed, for a hub that wants more lumps or a flatter belly.
  "cumulus": (w, h, r) => sprig-cloud(puffs: 11.4, lump: 0.25)(w, h, r),
  "banner": (w, h, r) => {
    // the dovetail ribbon of §26, as a leaf
    let d = h * 0.20
    ((0.0, 0.0), (d, h / 2), (0.0, h), (w, h), (w - d, h / 2), (w, 0.0))
  },
  // ---- added shapes ------------------------------------------------------
  // Two more, for `tikzmap`: a CONCEPT in the manner of TikZ's mind map is
  // an ellipse or a circle round its words, and both have to be reachable by
  // name from `shape:` like every other outline.
  "ellipse": (w, h, r) => range(65).map(i => {
    let a = 360deg * i / 64
    (w / 2 + w / 2 * calc.cos(a), h / 2 + h / 2 * calc.sin(a))
  }),
  "circle": (w, h, r) => {
    let d = calc.min(w, h) / 2
    range(65).map(i => {
      let a = 360deg * i / 64
      (w / 2 + d * calc.cos(a), h / 2 + d * calc.sin(a))
    })
  },
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
  "diamond": (w, h, r) =>
    ((w / 2, 0.0), (w, h / 2), (w / 2, h), (0.0, h / 2)),
  "parallelogram": (w, h, r) => {
    let c = calc.min(w * 0.16, h * 0.32)
    ((c, 0.0), (w, 0.0), (w - c, h), (0.0, h))
  },
  "bookmark": (w, h, r) => {
    let c = h * 0.22
    ((0.0, 0.0), (w, 0.0), (w, h - c), (w / 2, h), (0.0, h - c))
  },
  "ticket": (w, h, r) => {
    let c = calc.min(h * 0.10, w * 0.08)
    ((0.0, 0.0), (w, 0.0), (w, h / 2 - c),
     (w - c, h / 2), (w, h / 2 + c), (w, h), (0.0, h),
     (0.0, h / 2 + c), (c, h / 2), (0.0, h / 2 - c))
  },
  "document": (w, h, r) => {
    let c = calc.min(h * 0.18, w * 0.18)
    ((0.0, 0.0), (w, 0.0), (w, h - c), (w - c, h), (0.0, h))
  },
  "leaf": (w, h, r) => {
    let n = 24
    let side = range(n + 1).map(i => {
      let t = i / n
      let bulge = calc.sin(calc.pi * t)
      (w * t, h / 2 + h * 0.44 * bulge)
    })
    let other = range(n + 1).map(i => {
      let t = 1 - i / n
      let bulge = calc.sin(calc.pi * t)
      (w * t, h / 2 - h * 0.44 * bulge)
    })
    side + other
  },
)

/// A hub may take any LEAF contour BY NAME — `"banner"`, `"cumulus"`,
/// `"shield"`, and the rest. The five cases `_hub-pts` handles directly are
/// the ones that need the hub's own radii; this converts any other contour name
/// into the hub geometry instead of falling back to the default polygon. It turns a name into
/// the `(radius, phase) => contour` function `_hub-pts` does accept, sized like
/// the box hub is (`ratio` is width over height) and re-centred on the origin,
/// which is what a hub is drawn around.
///
/// It lives down here, not next to `_hub-pts`, because Typst scopes a function
/// at its *definition*: a lookup of `sprig-shapes` from above it is an
/// "unknown variable" error, not a late binding.
#let _hub-shape-fn(shape, ratio) = if type(shape) == type("") and shape in sprig-shapes {
  let f = sprig-shapes.at(shape)
  (rr, ph) => {
    let w2 = rr * calc.sqrt(2.0) * ratio
    let h2 = rr * calc.sqrt(2.0) / ratio
    f(w2, h2, calc.min(w2, h2) * 0.3)
      .map(q => (q.at(0) - w2 / 2, q.at(1) - h2 / 2))
  }
} else { shape }

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
    // The inner writing panel stays in the broad middle of the cloud: away
    // from the shoulder scallops and the lower puffs, even after wrapping.
    return (t: h * 0.38, b: h * 0.20, l: w * 0.22, r: w * 0.22)
  }
  // the lumpy cloud fills its box the way a rectangle does, so the words need
  // air from the lobes themselves — more under the belly, which is where the
  // squash leaves the flattest edge to press against
  if style == "cumulus" {
    return (t: h * 0.13, b: h * 0.17, l: w * 0.07, r: w * 0.07)
  }
  if style == "pill" { return (t: 0.0, b: 0.0, l: h * 0.16, r: h * 0.16) }
  if style == "cut" {
    let c = m(h * 0.26, w * 0.10) * 0.6
    return (t: 0.0, b: 0.0, l: c, r: c)
  }
  if style == "diamond" {
    let c = m(w * 0.22, h * 0.38)
    return (t: h * 0.06, b: h * 0.06, l: c, r: c)
  }
  if style == "parallelogram" {
    let c = m(w * 0.16, h * 0.32) * 0.75
    return (t: 0.0, b: 0.0, l: c, r: c)
  }
  if style == "bookmark" { return (t: 0.0, b: h * 0.17, l: 0.0, r: 0.0) }
  if style == "ticket" {
    let c = m(h * 0.10, w * 0.08) * 0.75
    return (t: 0.0, b: 0.0, l: c, r: c)
  }
  if style == "document" {
    let c = m(h * 0.18, w * 0.18) * 0.45
    return (t: 0.0, b: 0.0, l: 0.0, r: c)
  }
  if style == "leaf" {
    // A pointed leaf is narrow at both ends. Keep the text in its middle
    // oval rather than measuring it against the full rectangular bounding box.
    return (t: h * 0.18, b: h * 0.18, l: w * 0.18, r: w * 0.18)
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
  // `"none"` is an empty contour: the words are the card, there is nothing
  // to paint and nothing to stroke, and no stroke of an empty path either
  if pts.len() == 0 { return [] }
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
///   width    a fixed text-column target; the four min/max width and height
///            limits below override the map's limits for this leaf
///   min-width, max-width, min-height, max-height
///            the leaf's own dimensional bounds, in cm or Typst lengths
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
            min-width: auto, max-width: auto,
            min-height: auto, max-height: auto,
            dx: 0.0, dy: 0.0, children: (), children-at: auto,
            spread: auto, child-dist: auto, child-width: auto) = (
  body: if args.pos().len() > 0 { args.pos().first() } else { [] },
  title: title, icon: icon, colour: colour, shape: shape,
  angle: angle, at: at, dist: dist, width: width,
  min-width: min-width, max-width: max-width,
  min-height: min-height, max-height: max-height,
  dx: dx, dy: dy,
  children: children, children-at: children-at, spread: spread,
  child-dist: child-dist, child-width: child-width,
)

/// A mind map.
///
/// By default, the hub polygon has one side per branch, and each branch grows
/// from the midpoint of its corresponding side. The remaining parameters
/// control the map's appearance and layout.
///
///   hub          the centre's contents
///   ..branches   `branch(..)` values, or plain content for a bare leaf
///
///   sides        `auto` = one per branch; or a number to override the
///                polygon's side count
///   palette      a name from `sprig-palettes`, or an array of colours
///   shape        the leaf outline: a key of `sprig-shapes` or a function
///   weight       the rule thickness on every leaf and on the hub
///   dir          `ltr` / `rtl` / `auto` (follows the surrounding text)
///   start        the angle of the first branch
///   spread       the arc the branches share; 360deg = all the way round
///   rough        hand-drawn mode, with `roughness` / `bowing` / `hand`
///   leaf-width   the WIDTH of every card: a length fixes its text-column
///                target; `auto` lets each card hug its own words
///   min-width, max-width, min-height, max-height
///                dimensional limits for every leaf, with `branch(..)` values
///                overriding the map. If the height ceiling is tight, a leaf
///                widens to its width ceiling before it refuses to clip text
#let mindmap(
  hub,
  ..branches,
  links: (),
  sides: auto,
  hub-shape: auto,       // "box" | "rounded" | "circle" | "ellipse" | n | fn
  hub-ratio: 1.0,        // width : height, for the box and the ellipse
  hub-round: false,      // `true` inscribes the hub in a CIRCLE again
  radius: auto,
  leaf-width: auto,        // legacy fixed width for every first-rank leaf
  min-width: 1.5,         // default content-fit floor, in cm
  max-width: 9.0,         // default content-fit ceiling, in cm
  min-height: 0.0,
  max-height: auto,
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
  body-align: auto,   // auto : droite en RTL, gauche en LTR
  dir: auto,
  layout: "radial",   // brainroot-style : both / right / left / down / up
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
  let min-width = if min-width == auto or min-width == none { 1.5 } else { _cm(min-width) }
  let max-width = if max-width == auto or max-width == none { 9.0 } else { _cm(max-width) }
  let min-height = if min-height == auto or min-height == none { 0.0 } else { _cm(min-height) }
  let max-height = if max-height == auto or max-height == none { none } else { _cm(max-height) }

  let r2l = if dir != auto { dir == rtl } else { text.dir == rtl }
  // THEME POSTER : fonds blancs, sous-hubs en pastilles pleines
  let pst = theme == "poster"
  let bdir = if r2l { rtl } else { ltr }
  let bal = if body-align != auto { body-align }
            else if r2l { right } else { left }
  let hd = if rough { if hand != none { hand } else { "roughjs" } } else { none }

  // The default polygon has one side per branch. Below three sides, use a
  // circle instead — see `_hub-pts`.
  let ns = if sides != auto { sides } else { n }

  // `dist` and `radius` DEFAULT FROM THE BRANCH COUNT. A fixed 6.4 cm is
  // right for six branches and wrong for twelve: the leaves are spread
  // round a circle of circumference 2*pi*dist, so each gets 2*pi*dist/n of
  // arc and they collide as soon as that is narrower than a leaf. Solving
  // for the distance that gives every leaf its own width plus a margin is
  // what stops a busy map from overlapping — and it also stops a
  // three-branch map from being flung needlessly far apart.
  let lw0 = if leaf-width != auto { _cm(leaf-width) }
            else { calc.min(_cm(max-width), 4.6) }
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

  let cmz(v) = _cm(v)
  let bound(v, fallback) = if v == auto or v == none { fallback } else { cmz(v) }
  // Measure the same title/icon/body stack that is drawn. The shape's own
  // insets participate in the measurement, including ornaments that consume
  // a fraction of the final height (bubble, shield, banner, etc.).
  let card-at(b, w, sh, scale: 1.0) = {
    let hguess = 1.0
    let out = none
    for _ in range(6) {
      let pd0 = _shape-pad(sh, w, hguess)
      let inner = calc.max(0.20, w - 2 * gap - pd0.l - pd0.r)
      let head-body = {
        if b.icon != none { box(b.icon); if b.title != none { h(0.35em) } }
        if b.title != none { text(weight: "bold", size: scale * 1em, b.title) }
      }
      let hd = if b.title != none or b.icon != none {
        measure(box(width: inner * 1cm, align(center, head-body))).height / 1cm + 0.30
      } else { 0.0 }
      let body-box = text(size: scale * 1em, dir: bdir, b.body)
      let bh = measure(box(width: inner * 1cm, body-box)).height / 1cm
      let h0 = bh + hd + 2 * gap
      let pd1 = _shape-pad(sh, w, h0)
      let h1 = h0 + pd1.t + pd1.b
      let pd2 = _shape-pad(sh, w, h1)
      let hh = h0 + pd2.t + pd2.b
      out = (h: hh, head: hd, pad: pd2,
        inner: calc.max(0.20, w - 2 * gap - pd2.l - pd2.r))
      hguess = hh
    }
    out
  }
  let fit-card(b, fallback-max, fixed-width: auto, sh: shape,
               scale: 1.0, what: "mindmap leaf") = {
    let fixed = if b.at("width", default: auto) != auto {
      b.width
    } else { fixed-width }
    let minw = bound(b.at("min-width", default: auto), _cm(min-width))
    let max-default = if fixed != auto { calc.max(minw, _cm(fixed)) }
                      else { _cm(fallback-max) }
    let maxw = bound(b.at("max-width", default: auto), max-default)
    let minh = bound(b.at("min-height", default: auto), _cm(min-height))
    let maxh = bound(b.at("max-height", default: auto),
      if max-height == auto or max-height == none { none } else { _cm(max-height) })
    let raw-body = measure(text(size: scale * 1em, dir: bdir, b.body)).width / 1cm
    let raw-head = if b.title != none or b.at("icon", default: none) != none {
      let hbox = {
        if b.at("icon", default: none) != none {
          box(b.icon); if b.title != none { h(0.35em) }
        }
        if b.title != none { text(weight: "bold", size: scale * 1em, b.title) }
      }
      measure(hbox).width / 1cm
    } else { 0.0 }
    let p0 = _shape-pad(sh, calc.max(minw, 1.0), 1.0)
    let wanted = calc.max(raw-body, raw-head) + 2 * gap + p0.l + p0.r + 0.06
    let target = if fixed != auto { _cm(fixed) } else { wanted }
    let sizes = _fit-dimensions(target, minw, maxw, minh, maxh,
      w => card-at(b, w, sh, scale: scale).h, what: what)
    let met = card-at(b, sizes.w, sh, scale: scale)
    (w: sizes.w, h: calc.max(sizes.h, minh), head: met.head,
     pad: met.pad, inner: met.inner, minw: minw, maxw: maxw,
     minh: minh, maxh: maxh)
  }
  let source-of(bd) = if type(bd) == dictionary and "src" in bd { bd.src } else { bd }

  // ---- measure everything before drawing ----------------------------------
  // The canvas has to be big enough for the furthest leaf corner in every
  // direction, and leaves are NOT symmetric about their anchor: one on the
  // left hangs its whole width to the left. Measuring the real extent beats
  // guessing a square, which cropped the outer cards on a 3-branch map.
  let leaves = items.enumerate().map(p => {
    let (i, b) = p
    // `at:` (a compass name) wins over `angle:`, which wins over the ring.
    let bat = _bearing(b.at("at", default: auto))
    let ai = if bat != auto { bat }
             else if b.angle != auto { b.angle } else { ang(i) }
    let d = if b.dist != auto { b.dist } else { dd }
    let col = if b.colour != auto { b.colour } else { _hue(palette, i) }
    let sh = if b.shape != auto { b.shape } else { shape }
    let fitted = fit-card(b, max-width, fixed-width: leaf-width,
      sh: sh, what: "mindmap leaf " + str(i + 1))
    (i: i, a: ai, d: d, w: fitted.w, h: fitted.h, col: col, sh: sh,
     head: fitted.head, pad: fitted.pad, minw: fitted.minw,
     maxw: fitted.maxw, minh: fitted.minh, maxh: fitted.maxh,
     dx: b.dx, dy: b.dy, title: b.title, body: b.body, icon: b.icon, src: b,
     kids: _kids(b.at("children", default: ())),
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
    let kw = if l.kwidth != auto { l.kwidth }
             else { calc.max(_cm(min-width), l.w * 0.72) }
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
      let ksh = if kb.shape != auto { kb.shape } else { l.sh }
      let fixed-k = if l.kwidth != auto { l.kwidth } else { auto }
      let fitted = fit-card(kb, kw, fixed-width: fixed-k, sh: ksh,
        scale: 0.92, what: "mindmap child leaf")
      (p: (cx(l) + dd2 * calc.cos(ka) + kb.dx,
           cy(l) + dd2 * calc.sin(ka) + kb.dy),
       w: fitted.w, h: fitted.h, head: fitted.head, pad: fitted.pad,
       inner: fitted.inner, minw: fitted.minw, maxw: fitted.maxw,
       minh: fitted.minh, maxh: fitted.maxh, src: kb,
       col: if kb.colour != auto { kb.colour } else { l.col },
       sh: ksh, title: kb.title, body: kb.body, icon: kb.at("icon", default: none),
       a: ka, kids: _kids(kb.at("children", default: ())),
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
    let gw = calc.max(_cm(min-width), k.w * 0.80)
    let gd = calc.max(k.w, k.h, 1.2) * 0.62 + gw * 0.58
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
      let gsh = if gb.shape != auto { gb.shape } else { k.sh }
      let fitted = fit-card(gb, gw, sh: gsh, scale: 0.86,
        what: "mindmap grandchild leaf")
      grands.push((
        p: (k.p.at(0) + dd3 * calc.cos(ga) + gb.dx,
            k.p.at(1) + dd3 * calc.sin(ga) + gb.dy),
        w: fitted.w, h: fitted.h, head: fitted.head, pad: fitted.pad,
        inner: fitted.inner, minw: fitted.minw, maxw: fitted.maxw,
        minh: fitted.minh, maxh: fitted.maxh, src: gb,
        col: if gb.colour != auto { gb.colour } else { k.col },
        sh: gsh, title: gb.title, body: gb.body, icon: gb.at("icon", default: none),
        parent: k))
    }
  }

  // ---- dispositions empilées (both, right, left, down, up) ---------------
  // Les branches s'organisent en rangs directionnels tout en conservant les
  // tiges, formes, palettes et thèmes de la carte.
  if not (layout == "radial" or layout in ("both", "right", "left", "down", "up")) {
    panic("mindmap: unknown layout " + str(layout))
  }
  let res = if layout != "radial" {
    let vgap = 0.8
    let colgap = 1.0
    // The ring-and-column ESTIMATE below still wants a number to space by,
    // `auto` or not: 4.6 cm is the widest card the default table allows.
    let cmz(v) = if type(v) == length { v / 1cm } else { v }
    let lw-cap = leaf-width
    // CHAQUE CARTE S'AJUSTE À SON CONTENU, comme dans l'anneau : la largeur
    // demandée est celle du texte posé sur une ligne, bornée par un maximum
    // réglable — `width:` sur la branche, `child-width:` sur le parent,
    // `leaf-width:` sinon. Couper les mots n'est jamais un réglage.
    let sh-of(bd, fall) = if bd.at("shape", default: auto) != auto { bd.shape } else { fall }
    let cap-of(bd, fall) = if bd.at("width", default: auto) != auto { bd.width } else { fall }
    let capk-of(bd, fall) = if bd.at("kwidth", default: auto) != auto { bd.kwidth }
      else if bd.at("child-width", default: auto) != auto { bd.at("child-width") } else { fall }
    // The stacked layouts use exactly the same per-leaf limits as the radial
    // one; `width` remains a legacy fixed target, while min/max bounds fit
    // intrinsic content and never clip it.
    let fitw(bd, cap, shp, scale: 1.0) = {
      let src = source-of(bd)
      let fall = if cap == auto { max-width } else { cap }
      let fixed = if cap == auto { auto } else { cap }
      fit-card(src, fall, fixed-width: fixed, sh: shp, scale: scale).w
    }
    let cardh(bd, w, shp, scale: 1.0) = {
      let src = source-of(bd)
      fit-card(src, w, fixed-width: w, sh: shp, scale: scale).h
    }
    let stackh(bd, w, shp, capk) = {
      let ks = bd.at("kids", default: bd.at("children", default: ()))
      let own = cardh(bd, w, shp)
      if ks.len() == 0 { return own }
      let s = 0.0
      for k in ks {
        let ksh = sh-of(k, shp)
        s += stackh(k, fitw(k, cap-of(k, capk), ksh), ksh, capk-of(k, lw-cap))
      }
      calc.max(own, s + vgap * calc.max(1, ks.len() - 1))
    }
    let trans(p, m) = {
      let (x, y) = p
      if m == "right" { (x, y) }
      else if m == "left" { (-x, y) }
      else if m == "down" { (y, -x) }
      else { (-y, x) }
    }
    let place-col(idx-list, m) = {
      let out-l = ()
      let out-k = ()
      let out-g = ()
      let tot = 0.0
      for i in idx-list {
        let l = leaves.at(i)
        tot += stackh(l, l.w, l.sh, capk-of(l, lw-cap))
      }
      tot += vgap * calc.max(0, idx-list.len() - 1)
      let cur = tot / 2
      for i in idx-list {
        let l = leaves.at(i)
        let H2 = stackh(l, l.w, l.sh, capk-of(l, lw-cap))
        let y1 = cur - H2 / 2
        cur -= H2 + vgap
        let t1 = trans((dd, y1), m)
        let nl = l + (a: calc.atan2(t1.at(0), t1.at(1)),
          d: calc.sqrt(t1.at(0) * t1.at(0) + t1.at(1) * t1.at(1)))
        out-l.push(nl)
        let ks = l.kids
        let capk = capk-of(l, lw-cap)
        // la colonne des enfants s'aligne sur le plus large d'entre eux
        let kws = ks.map(k => fitw(k, cap-of(k, capk), sh-of(k, l.sh)))
        let kwcol = if kws.len() > 0 { calc.max(..kws) } else { 0.0 }
        let tot2 = 0.0
        for j in range(ks.len()) {
          let k = ks.at(j)
          tot2 += stackh(k, kws.at(j), sh-of(k, l.sh), capk-of(k, lw-cap))
        }
        tot2 += vgap * calc.max(0, ks.len() - 1)
        let cur2 = y1 + tot2 / 2
        let x2 = dd + l.w / 2 + colgap + kwcol / 2
        for j in range(ks.len()) {
          let k = ks.at(j)
          let ksh = sh-of(k, l.sh)
          let kcap = cap-of(k, capk)
          let kfit = fit-card(k, if kcap == auto { max-width } else { kcap },
            fixed-width: if kcap == auto { auto } else { kcap },
            sh: ksh, scale: 0.92, what: "mindmap child leaf")
          let kw = kfit.w
          let kh2 = stackh(k, kw, ksh, capk-of(k, lw-cap))
          let y2 = cur2 - kh2 / 2
          cur2 -= kh2 + vgap
          let t2 = trans((x2, y2), m)
          let nk = (p: t2, w: kw, h: kfit.h, head: kfit.head,
            pad: kfit.pad, inner: kfit.inner, src: k,
            minw: kfit.minw, maxw: kfit.maxw, minh: kfit.minh, maxh: kfit.maxh,
            col: if k.colour != auto { k.colour } else { l.col },
            sh: ksh,
            title: k.title, body: k.body,
            icon: k.at("icon", default: none),
            a: 0deg, kids: _kids(k.at("children", default: ())),
            kspread: auto, kat: auto, kdist: auto, kwidth: auto,
            parent: nl)
          out-k.push(nk)
          let gs = k.at("children", default: ())
          let capg = capk-of(k, lw-cap)
          let gws = gs.map(g => fitw(g, cap-of(g, capg), sh-of(g, ksh)))
          let gwcol = if gws.len() > 0 { calc.max(..gws) } else { 0.0 }
          let tot3 = 0.0
          for q in range(gs.len()) {
            tot3 += cardh(gs.at(q), gws.at(q), sh-of(gs.at(q), ksh))
          }
          tot3 += vgap * calc.max(0, gs.len() - 1)
          let cur3 = y2 + tot3 / 2
          let x3 = x2 + kw / 2 + colgap + gwcol / 2
          for q in range(gs.len()) {
            let g = gs.at(q)
            let gcap = cap-of(g, capg)
            let gsh = sh-of(g, ksh)
            let gfit = fit-card(g, if gcap == auto { max-width } else { gcap },
              fixed-width: if gcap == auto { auto } else { gcap },
              sh: gsh, scale: 0.86, what: "mindmap grandchild leaf")
            let gw = gfit.w
            let gh2 = gfit.h
            let y3 = cur3 - gh2 / 2
            cur3 -= gh2 + vgap
            let t3 = trans((x3, y3), m)
            out-g.push((p: t3, w: gw, h: gh2, head: gfit.head,
              pad: gfit.pad, inner: gfit.inner, src: g,
              minw: gfit.minw, maxw: gfit.maxw, minh: gfit.minh, maxh: gfit.maxh,
              col: if g.colour != auto { g.colour } else { nk.col },
              sh: gsh, title: g.title, body: g.body,
              icon: g.at("icon", default: none),
              a: 0deg, parent: nk))
          }
        }
      }
      (out-l, out-k, out-g)
    }
    let all = range(leaves.len()).map(i => i)
    if layout == "both" {
      let ri = ()
      let li = ()
      let rw = 0.0
      let lw2 = 0.0
      for i in all {
        let l = leaves.at(i)
        let hh = stackh(l, l.w, l.sh, capk-of(l, lw-cap))
        if rw <= lw2 { ri.push(i); rw += hh } else { li.push(i); lw2 += hh }
      }
      let (a1, b1, c1) = place-col(ri, "right")
      let (a2, b2, c2) = place-col(li, "left")
      (a1 + a2, b1 + b2, c1 + c2)
    } else {
      place-col(all, layout)
    }
  } else {
    (leaves, kids, grands)
  }
  let leaves = res.at(0)
  let kids = res.at(1)
  let grands = res.at(2)

  let xs = leaves.map(l => (cx(l) - l.w / 2, cx(l) + l.w / 2)).flatten()
  let ys = leaves.map(l => (cy(l) - l.h / 2, cy(l) + l.h / 2)).flatten()
  // All ranks contribute their actual measured dimensions to the canvas.
  let xs = xs + kids.map(k => (k.p.at(0) - k.w / 2, k.p.at(0) + k.w / 2)).flatten()
  let ys = ys + kids.map(k => (k.p.at(1) - k.h / 2, k.p.at(1) + k.h / 2)).flatten()
  let xs = xs + grands.map(g => (g.p.at(0) - g.w / 2, g.p.at(0) + g.w / 2)).flatten()
  let ys = ys + grands.map(g => (g.p.at(1) - g.h / 2, g.p.at(1) + g.h / 2)).flatten()
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
  // a name is not a polygon: `"banner"`, `"cumulus"`, `"shield"` are leaf
  // contours, and the hub is drawn from the very same one a leaf would use
  let hub-sty = _hub-shape-fn(hub-shape, hub-ratio)
  let hub-o-raw = _hub-pts(ns, rad, start: start, phase: phase,
    shape: hub-sty, ratio: hub-ratio, ry: rady)

  box(width: W * 1cm, height: Hh * 1cm, {
    // ---- stalks, drawn FIRST so every leaf and the hub cover their ends --
    for l in leaves {
      // Keep the foot on the branch's assigned side of the polygon, while the
      // tip aims at the leaf's measured position. A displaced leaf therefore
      // keeps its hub anchor and the stalk leans across to reach it.
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
      let gp = g.pad
      let gh = g.h
      let fillc = if leaf-fill != auto { leaf-fill }
                  else if prt or pst { white } else { g.col.lighten(calc.min(96%, tint + 5%)) }
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
              box(width: g.inner * 1cm,
                align(center, {
                  if g.icon != none { box(g.icon); if g.title != none { h(0.3em) } }
                  if g.title != none { text(fill: if prt { black } else { inkc.darken(18%) },
                    weight: "bold", size: 0.86em, g.title) }
                })))
          }
          place(top + left, dx: (gap * 0.8 + gp.l) * 1cm,
            dy: (gap * 0.7 + g.head + gp.t) * 1cm,
            box(width: g.inner * 1cm,
              text(size: 0.86em, dir: bdir, align(bal, g.body))))
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
      let kp = k.pad
      let khh = k.h
      let fillc = if leaf-fill != auto { leaf-fill }
                  else if prt or pst { white } else { k.col.lighten(tint) }
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
          if k.title != none or k.icon != none {
            place(top + left, dx: (gap + kp.l) * 1cm,
              dy: (gap * 0.45 + kp.t) * 1cm,
              box(width: k.inner * 1cm,
                align(center, {
                  if k.icon != none { box(k.icon); if k.title != none { h(0.35em) } }
                  if k.title != none { text(fill: if prt { black }
                    else { inkc.darken(18%) }, weight: "bold", size: 0.92em,
                    k.title) }
                })))
          }
          place(top + left, dx: (gap + kp.l) * 1cm,
            dy: (gap * 0.8 + k.head + kp.t) * 1cm,
            box(width: k.inner * 1cm,
              text(size: 0.92em, dir: bdir, align(bal, k.body))))
        }))
    }

    // ---- leaves ---------------------------------------------------------
    for l in leaves {
      let lx = cx(l) - l.w / 2 - x0
      let ly = Hh - (cy(l) + l.h / 2 - y0)     // to page coordinates
      // POSTER : une feuille portant des enfants est un sous-hub plein
      let ishub = l.kids.len() > 0
      let fillc = if leaf-fill != auto { leaf-fill }
                  else if pst and ishub { l.col }
                  else if prt or pst { white } else { l.col.lighten(tint) }
      let inkc = if leaf-ink != auto { leaf-ink }
                 else if prt { rgb("#333333") } else { l.col }
      place(top + left, dx: lx * 1cm, dy: ly * 1cm,
        box(width: l.w * 1cm, height: l.h * 1cm, {
          _leaf-draw(l.sh, l.w, l.h, if pst and ishub { 0.5 } else { radius-leaf },
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
                  text(fill: if prt { black }
                    else if pst and ishub { white } else { inkc.darken(18%) },
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
              align(bal, text(dir: bdir, l.body))))
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
      shape: hub-sty, ratio: hub-ratio, ry: rady * 0.88).map(p => P(p))
    // `hub-shape: "none"` is a real request — the hub is then its words alone,
    // which is how a ribbon or a scroll draws itself over a band of paper. An
    // empty contour is not a paintable thing: the fills and the rule are simply
    // skipped, and `first()` on it would have crashed the page.
    let hub-has = hub-o.len() > 0
    if shadow and hub-has {
      place(top + left, dx: 3pt, dy: 4pt,
        _fill((hub-o,), flip: flip, fill: sh-col))
    }
    // the outer band, then the plate: two rings make it read as a frame
    if hub-has and prt {
      place(top + left, _fill((hub-o,), flip: flip, fill: hf))
    } else if hub-has {
      place(top + left, _fill((hub-o,), flip: flip, fill: hi))
      place(top + left, _fill((hub-i,), flip: flip, fill: hf))
    }
    if weight != 0pt and hub-has {
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
//  blossom — the flower map
// -----------------------------------------------------------------------------
//
//  A different genre on the same root: not stalked cards hanging off a hub
//  but a FLOWER — a circular plate in the middle, one solid petal per
//  branch, every petal carrying its number, its icon, a title and a few
//  lines of text set straight into the colour. The posters this comes from
//  are teaching aids: eight wedges round a centre, each a saturated colour
//  with the paragraph printed on it, numbered clockwise from the top.
//
//  THE RULE, as asked: as many petals as branches — never a fixed count,
//  three at the absolute minimum — and NO sub-leaves. A petal is a leaf
//  that carries text, not a node that carries children; for a second rank,
//  `mindmap` is the tool.

// The `numbering` PARAMETER shadows the built-in of the same name inside
// `blossom`; keep a handle on the real one so a pattern ("01", "a", "i")
// can be passed straight through to it.
#let _std-numbering = numbering

/// A flower map: a circular hub, one petal per branch.
///
///   hub          the centre's contents
///   ..branches   `branch(..)` values, or plain content for a bare petal
///
///   petal        `"wedge"` — a sector with flat radial sides, the poster
///                look — or `"petal"`, which narrows to its heel, swells
///                out and rounds over the tip like a teardrop
///   numbering    `true` → 01, 02, … padded to the count's own width —
///                WESTERN digits, even under `rtl`; a numbering pattern such
///                as `"01"` or `"a"`; an ARRAY of symbols cycled round the
///                flower; a function `(i, n) => content`; `false` / `none`
///                hides the numbers altogether
///   palette      a name from `sprig-palettes`, or an array of colours
///   tint         how much white is mixed into a petal's fill; a high tint
///                gives the pastel look, a low one the saturated poster
///   gap          angular breathing room between neighbouring petals
///   inner        the ring of background between the plate and the heels
///   radius       the outer radius; `auto` lets the contents decide
///   length       the petal's radial length (outer radius minus the plate),
///                in cm; `auto` lets the contents decide. A flower whose
///                petals you want shorter or longer than the text demands.
///   petal-width  a MAXIMUM for a petal's text column, as `leaf-width` is
///                for a card
///   min-width, max-width, min-height, max-height
///                limits for each petal, overridable on a `branch(..)`
///   hub-radius   the plate's radius; `auto` fits the title
///   dir          `ltr` / `rtl` / `auto`; under `rtl` the reading runs
///                right-to-left round the flower: petal 02 lands on the
///                RIGHT, i.e. the numbering turns clockwise
///   theme        `"print"`: no flooded fills, everything by the outline
///
/// A petal takes its `title:`, `icon:` and body text through the same
/// `branch(..)` the tree map uses, and `colour:` overrides its hue. There
/// are deliberately no sub-leaves and no cross-links: a blossom is one
/// rank deep, all face.
#let blossom(
  hub,
  ..branches,
  palette: "poster",
  petal: "wedge",
  numbering: false,
  hub-fill: auto, hub-ink: auto, hub-text: auto,
  petal-fill: auto, petal-ink: auto, petal-text: auto,
  tint: 24%,
  gap: 4deg,
  inner: auto,
  hub-radius: auto,
  radius: auto,
  length: auto,
  petal-width: auto,
  min-width: 1.0,
  max-width: auto,
  min-height: 0.6,
  max-height: auto,
  start: 90deg,
  body-align: auto,
  dir: auto,
  theme: auto,
  weight: 1.1pt,
  shadow: true,
  seed: 3,
  rough: false, hand: none, roughness: 1.0,
) = context {
  // Distances travel as bare CENTIMETRES here, as they do through the rest
  // of sprig — but a `2.1cm` slipped in by muscle memory should work too,
  // not blow up three lines down where it is first added.
  let cm(v) = if type(v) == length { v / 1cm } else { v }
  let hub-radius = if hub-radius != auto and hub-radius != none { cm(hub-radius) } else { auto }
  let radius = if radius != auto and radius != none { cm(radius) } else { auto }
  let length = if length != auto and length != none { cm(length) } else { auto }
  let petal-width = if petal-width != auto and petal-width != none { cm(petal-width) } else { auto }
  let min-width = if min-width == auto or min-width == none { 1.0 } else { cm(min-width) }
  let max-width = if max-width == auto or max-width == none { auto } else { cm(max-width) }
  let min-height = if min-height == auto or min-height == none { 0.6 } else { cm(min-height) }
  let max-height = if max-height == auto or max-height == none { none } else { cm(max-height) }
  let inner = if inner != auto and inner != none { cm(inner) } else { auto }
  if petal != "wedge" and petal != "petal" {
    panic("blossom: unknown petal \"" + petal + "\" — \"wedge\" or \"petal\"")
  }
  let items = branches.pos().map(b =>
    if type(b) == dictionary and "body" in b { b }
    else { branch(b) })
  let n = items.len()
  // THE MINIMUM: below three petals a flower is two eyesores and a hub; a
  // two-branch map is a line, and mindmap() already draws lines.
  if n < 3 {
    panic("blossom: a flower needs at least three petals — got " + str(n)
      + ". For one or two branches, mindmap() is the honest shape.")
  }
  for b in items {
    if b.children.len() > 0 {
      panic("blossom: a petal carries no sub-leaves — give it a title, an "
        + "icon and body text, or use mindmap(), which nests.")
    }
  }

  let r2l = if dir != auto { dir == rtl } else { text.dir == rtl }
  let pst = theme == "poster"
  let bdir = if r2l { rtl } else { ltr }
  let bal = if body-align != auto { body-align } else { center }
  let hd = if rough { if hand != none { hand } else { "roughjs" } } else { none }
  let prt = theme == "print"
  let sg = if r2l { -1.0 } else { 1.0 }

  // The hub is a CIRCLE this time — the posters this comes from are round
  // — sized from its title the same way mindmap sizes its polygon: an
  // inscribed square of side r·√2, budgeted for a wrap.
  let hw = measure(hub).width / 1cm
  let hh2 = measure(hub).height / 1cm
  let wraps = hw > hh2 * 2.6
  let want-w = if wraps { hw * 0.66 } else { hw }
  let want-h = if wraps { hh2 * 2.15 } else { hh2 }
  let hr = if hub-radius != auto { hub-radius } else {
    calc.max(1.15, calc.min(2.7,
      calc.max(want-w, want-h * 1.5) / 1.30 + 0.14))
  }
  let r0 = hr + if inner != auto { inner } else { 0.08 }

  // ONE PETAL PER BRANCH, each centred on its own spoke. `gap` shaves a
  // little angle off each side so neighbouring petals read as separate.
  // Under `rtl` the order runs anticlockwise — the reading goes
  // right-to-left round the flower, exactly as it does round the ring.
  let ang(i) = start + sg * 360deg * i / n
  let half = calc.max(180deg / n - gap / 2, 3deg)
  let halfn = half / 1deg

  // A numbering, resolved once: `true` pads to the count's own width —
  // eight petals get 01..08, twelve get 01..12 — a pattern goes to the
  // real `numbering`, and a function is called with Typst's own (i, n),
  // one-based, so `(i, n) => numbering("١", i)` works too.
  let num-of = if numbering == false or numbering == none { none }
    else if numbering == true {
      (i) => {
        let s = str(i + 1)
        let w = calc.max(2, str(n).len())
        while s.len() < w { s = "0" + s }
        s
      }
    }
    else if type(numbering) == array {
      (i) => numbering.at(calc.rem(i, numbering.len()))
    }
    else if type(numbering) == str {
      (i) => _std-numbering(numbering, i + 1)
    }
    else { (i) => numbering(i + 1, n) }

  // Colours settled BEFORE measuring, so the measured stack is the drawn
  // stack — a bold face runs wider than its plain twin, and measuring one
  // to draw the other is how text ends up touching the rim.
  let hub-f = if prt and hub-fill == auto { white }
    else if hub-fill == "palette" { _hue(palette, 0).darken(38%) }
    else if hub-fill != auto { hub-fill } else { rgb("#0B3C7A") }
  let hub-i = if hub-ink != auto { hub-ink }
    else if prt { rgb("#333333") } else { hub-f.lighten(24%) }
  let hub-t = if hub-text != auto { hub-text }
    else if prt { black }
    else if luma(hub-f).components().first() > 58% { hub-f.darken(62%) }
    else { white }

  // ---- measure every petal, then size the flower to the largest --------
  let geometric-cap = if petal-width != auto { petal-width } else {
    calc.max(1.4, calc.min(5.0, 2.2 * (r0 + 1.1) * calc.sin(half)))
  }
  let global-cap = if max-width != auto { calc.min(geometric-cap, max-width) }
                   else { geometric-cap }
  let sh-col = rgb("#00000022")
  let shadow = if prt { false } else { shadow }

  // A petal's local top points outwards. The label turns with the petal,
  // then folds by half a turn when needed so words on the lower half remain
  // readable instead of appearing upside down.
  let text-rotation(a) = {
    let wrapped = calc.rem(a / 1deg - 90 + 180, 360)
    let signed = (if wrapped < 0 { wrapped + 360 } else { wrapped }) - 180
    let upright = if signed > 90 { signed - 180 }
                  else if signed < -90 { signed + 180 }
                  else { signed }
    upright * 1deg
  }
  let petal-heel = 0.42
  let petal-tip = 0.62
  let petal-share(t) = {
    let sm(u) = u * u * (3 - 2 * u)
    if t < 0.58 {
      petal-heel + (1 - petal-heel) * sm(t / 0.58)
    } else {
      petal-tip + (1 - petal-tip) * (1 - sm((t - 0.58) / 0.42))
    }
  }

  // Does the ROTATED w × h text block, centred at radius `rc2` on spoke `a`,
  // sit inside the wedge at radius `r1`? Test all four transformed corners
  // against the inner and outer arcs and both radial sides. The same test
  // works for every bearing, including the sideways petals.
  let fits-at(a, rc2, r1, w, h, rot) = {
    let c = (rc2 * calc.cos(a), rc2 * calc.sin(a))
    let cr = calc.cos(rot)
    let sr = calc.sin(rot)
    let ok = true
    for sx in (-1, 1) {
      for sy in (-1, 1) {
        let px = c.at(0) + sx * w / 2 * cr - sy * h / 2 * sr
        let py = c.at(1) + sx * w / 2 * sr + sy * h / 2 * cr
        let rr = calc.sqrt(px * px + py * py)
        let dd = calc.rem((calc.atan2(px, py) - a) / 1deg, 360.0)
        if dd < 0 { dd += 360 }
        let ad = if dd > 180 { 360 - dd } else { dd }
        let t = calc.clamp((rr - r0) / (r1 - r0), 0.0, 1.0)
        let cap = if petal == "wedge" { halfn }
                  else { halfn * petal-share(t) }
        if rr < r0 + 0.08 or rr > r1 - 0.18 or ad > cap - 2.0 {
          ok = false
        }
      }
    }
    ok
  }
  // The block belongs near the OUTER end of its petal, where the wedge has
  // opened up. For a given radius, search from the rim inward and keep the
  // first position whose rotated corners clear the outline.
  let slide(a, r1, w, h, rot) = {
    let lo = r0 + h / 2 + 0.06
    let hi = r1 - h / 2 - 0.14
    if hi < lo { return none }
    for k in range(25) {
      let rc2 = hi - (hi - lo) * k / 24
      if fits-at(a, rc2, r1, w, h, rot) { return rc2 }
    }
    none
  }
  // The smallest outer radius that holds the rotated block: step out until
  // some position clears. Refuse an impossible fit rather than let text
  // cross a petal boundary.
  let solve(a, w, h, rot) = {
    let r1 = r0 + 0.55
    let rtop = if radius != auto { radius }
               else if length != auto { r0 + length }
               else { r0 + 12.0 }
    while r1 <= rtop + 1e-9 {
      let pos = slide(a, r1, w, h, rot)
      if pos != none { return (r1: r1, rho: pos) }
      r1 += 0.05
    }
    panic("blossom: a petal's text will not fit at any radius — give it "
      + "less to say, a bigger `petal-width`, or fewer petals.")
  }

  let petals = items.enumerate().map(p => {
    let (i, b) = p
    let col = if b.colour != auto { b.colour } else { _hue(palette, i) }
    let fillc = if petal-fill != auto { petal-fill }
      else if prt or pst { white } else { col.lighten(tint) }
    let inkc = if petal-ink != auto { petal-ink }
      else if prt { rgb("#333333") } else { col.darken(10%) }
    // Text that READS on the fill rather than on the palette: a pale petal
    // takes ink, a saturated one takes white — the hub's own rule.
    let txtc = if petal-text != auto { petal-text }
      else if prt { black }
      else if luma(fillc).components().first() > 58% { col.darken(52%) }
      else { white }
    let num = if num-of != none { text(weight: "bold", size: 0.86em,
      fill: if prt { black } else { inkc.darken(6%) }, num-of(i)) }
      else { none }

    // The stack: number over icon-and-title over body, set in the petal's
    // own column. The width is a MAXIMUM here too — a one-word petal gets
    // a one-word petal, not the full column, same rule as a leaf.
    let ttl = b.title
    let ico = b.icon
    let bdy = b.body
    let head = if ttl != none or ico != none { align(center, {
      if ico != none { box(ico); h(0.3em) }
      if ttl != none { text(weight: "bold", size: 1.02em, fill: txtc, ttl) }
    }) } else { none }
    let want = calc.max(
      if num != none { measure(box(num)).width / 1cm } else { 0.0 },
      if head != none { measure(box(head)).width / 1cm } else { 0.0 },
      if bdy != [] { measure(text(size: 0.9em, dir: bdir, bdy)).width / 1cm }
      else { 0.0 })
    let cnt = []
    if num != none { cnt += box(width: 100%, align(center, num)) }
    if head != none {
      if num != none { cnt += linebreak() }
      cnt += box(width: 100%, head)
    }
    if bdy != [] {
      if num != none or head != none { cnt += linebreak() }
      cnt += box(width: 100%, align(bal,
        text(size: 0.9em, fill: txtc, dir: bdir, bdy)))
    }
    let minw = if b.at("min-width", default: auto) != auto { cm(b.at("min-width")) } else { min-width }
    let maxw = if b.at("max-width", default: auto) != auto { calc.min(global-cap, cm(b.at("max-width"))) } else { global-cap }
    let minh = if b.at("min-height", default: auto) != auto { cm(b.at("min-height")) } else { min-height }
    let maxh = if b.at("max-height", default: auto) != auto { cm(b.at("max-height")) } else { max-height }
    let fixed = if b.at("width", default: auto) != auto { cm(b.width) } else { auto }
    let target = if fixed != auto { fixed } else { want + 0.30 }
    let sizes = _fit-dimensions(target, minw, maxw, minh, maxh,
      w => measure(box(width: w * 1cm, cnt)).height / 1cm + 0.10,
      what: "blossom petal " + str(i + 1))
    let wid = sizes.w
    let hgt = sizes.h
    let angle = ang(i)
    let rot = text-rotation(angle)
    let sv = solve(angle, wid, hgt, rot)
    (i: i, a: angle, rotation: rot, col: col, fillc: fillc,
      inkc: inkc, txtc: txtc, num: num, cnt: cnt,
      wid: wid, hgt: hgt, rho: sv.rho, r1: sv.r1)
  })

  // ONE flower, one radius: the widest requirement sets it for everyone,
  // the way `dist` does for the ring.
  let needed-radius = calc.max(..petals.map(p => p.r1))
  let R = if radius != auto { radius }
    else if length != auto { r0 + length }
    else { needed-radius }
  let pad = 0.30
  let W = 2 * (R + pad)
  let x0 = -R - pad
  let y0 = -R - pad
  let flip = W * 1cm
  let P(p) = (p.at(0) - x0, p.at(1) - y0)
  let d-arc(r, aa0, aa1, nn) = _arc-pts((0.0, 0.0), r, aa0, aa1, n: nn)

  // The two silhouettes. A WEDGE is two arcs and two radial sides — the
  // sector of the posters. A PETAL narrows to its heel, swells to its
  // widest two thirds of the way out and rounds over the tip: `f(t)` is
  // the share of the half-angle the side sits at as it runs heel to rim.
  let contour(a) = {
    if petal == "wedge" {
      let inner-arc = d-arc(r0, a - halfn, a + halfn, 10)
      let outer-arc = d-arc(R, a + halfn, a - halfn, 30)
      inner-arc + outer-arc
    } else {
      let side(s2) = range(17).map(j => {
        let t = j / 16
        let r = r0 + (R - r0) * t
        let aa = a + s2 * halfn * petal-share(t)
        (r * calc.cos(aa * 1deg), r * calc.sin(aa * 1deg))
      })
      let tip = d-arc(R, a - halfn * petal-tip, a + halfn * petal-tip, 12)
      let heel = d-arc(r0, a + halfn * petal-heel, a - halfn * petal-heel, 6)
      side(-1) + tip + side(1).rev() + heel
    }
  }

  box(width: W * 1cm, height: W * 1cm, {
    for p in petals {
      let c = contour(p.a / 1deg).map(pt => P(pt))
      if shadow {
        place(top + left, dx: 2pt, dy: 2.5pt,
          _fill((c,), flip: flip, fill: sh-col))
      }
      place(top + left, _fill((c,), flip: flip, fill: p.fillc))
      if weight != 0pt {
        let st = (paint: p.inkc, thickness: weight, join: "round")
        if hd == none {
          place(top + left, _lines((c + (c.first(),),), flip: flip,
            stroke: st))
        } else {
          place(top + left, _rough(c, flip: flip, seed: seed + p.i * 17,
            roughness: roughness, stroke: st))
        }
      }
    }
    // The text follows each petal's rotation and sits toward its outer tip.
    // Place the rotated panel by its true visual bounds, not by its unturned
    // width and height; this keeps the label centred on its spoke.
    for p in petals {
      let cs = calc.abs(calc.cos(p.rotation))
      let sn = calc.abs(calc.sin(p.rotation))
      let rw = cs * p.wid + sn * p.hgt
      let rh = sn * p.wid + cs * p.hgt
      let cx = p.rho * calc.cos(p.a)
      let cy = p.rho * calc.sin(p.a)
      let panel = box(width: p.wid * 1cm, height: p.hgt * 1cm,
        align(center + horizon, p.cnt))
      let turned = rotate(p.rotation, origin: center, panel)
      place(top + left,
        dx: (cx - rw / 2 - x0) * 1cm,
        dy: (W - (cy + rh / 2 - y0)) * 1cm,
        box(width: rw * 1cm, height: rh * 1cm,
          align(center + horizon, turned)))
    }
    // the hub, last, over every heel: a ring and a plate, as the map's is
    let o = _circle-pts((0.0, 0.0), hr, n: 64).map(pt => P(pt))
    let inn = _circle-pts((0.0, 0.0), hr * 0.88, n: 64).map(pt => P(pt))
    if shadow {
      place(top + left, dx: 3pt, dy: 4pt, _fill((o,), flip: flip,
        fill: sh-col))
    }
    if prt {
      place(top + left, _fill((o,), flip: flip, fill: hub-f))
    } else {
      place(top + left, _fill((o,), flip: flip, fill: hub-i))
      place(top + left, _fill((inn,), flip: flip, fill: hub-f))
    }
    if weight != 0pt {
      let st = (paint: hub-i.darken(22%), thickness: weight, join: "round")
      if hd == none {
        place(top + left, _lines((o + (o.first(),),), flip: flip,
          stroke: st))
      } else {
        place(top + left, _rough(o, flip: flip, seed: seed,
          roughness: roughness * 0.7, stroke: st))
      }
    }
    let bw = hr * 1.32
    place(top + left,
      dx: (P((0.0, 0.0)).at(0) - bw / 2) * 1cm,
      dy: (W - P((0.0, 0.0)).at(1) - bw / 2) * 1cm,
      box(width: bw * 1cm, height: bw * 1cm,
        align(center + horizon, text(fill: hub-t, hub))))
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
// `hold` is the share of the walk along which the stroke keeps its FULL
// width, and only then runs out: a marker line under a word stays fat until
// the word is over. Without it the taper starts at the very base, which is what
// made a keyword read as written BESIDE a narrowing scratch instead of ON a
// stroke. 0 is the old behaviour, so the other genres are untouched.
#let _stalk-path(pts, w0, w1, smooth: 14, hold: 0.0) = {
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
  let total = calc.max(0.001, cum.at(mid.len() - 1))
  let half(t) = {
    // measured from `hold` onward, so the whole of the fat part is spent
    // carrying the word and the run-out is all tail
    let u = if hold > 0.0 {
      calc.pow(calc.max(0.0, (t - hold) / calc.max(0.02, 1.0 - hold)), 0.62)
    } else { calc.pow(t, 0.62) }
    (w0 + (w1 - w0) * u) / 2
  }
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
/// A centreline that makes for the straight line but is not drawn with a ruler.
///
/// `arc` is a single bow, `amp` a small undulation with a `step`-long period;
/// both are wrapped in a `sin(pi t)` envelope so the two ENDS stay exactly on
/// the ray — a stroke may wave, it may not come loose from the cloud it grows
/// out of, nor from the fork at its own tip. The wobble is measured against the
/// stroke's thickness, which is where a hand actually gets it: a marker of 3 mm
/// wanders by a fifth of 3 mm, and a pen line of 0,6 mm by a fifth of that, so
/// one knob fits both without turning the twigs into worms.
#let _wave-line(p0, p1, amp: 0.0, step: 1.15, arc: 0.0, phase: 0.0) = {
  let dx = p1.at(0) - p0.at(0)
  let dy = p1.at(1) - p0.at(1)
  let ln = calc.sqrt(dx * dx + dy * dy)
  if ln < 0.05 { return (p0, p1) }
  let ux = dx / ln
  let uy = dy / ln
  let n = calc.max(8, calc.ceil(ln / 0.16))
  let out = ()
  let i = 0
  while i <= n {
    let t = i / n
    let env = calc.sin(calc.pi * t)
    let o = arc * env + amp * env * calc.sin(
      2 * calc.pi * ln * t / calc.max(0.2, step) + phase)
    out.push((p0.at(0) + dx * t - uy * o, p0.at(1) + dy * t + ux * o))
    i += 1
  }
  out
}


// -----------------------------------------------------------------------------
//  31. mindgrid — a mind map on a FIXED layout, with routed branches
// -----------------------------------------------------------------------------

/// One placed leaf: same as `branch`, plus where it goes.
///
///   col, row   its cell in the grid (0-based), or
///   x, y       an absolute position in cm, y UP, hub at the origin
///   width      a text-column target; `min-width`, `max-width`, `min-height`
///              and `max-height` bound this node's box
#let node(body, title: none, icon: none, colour: auto, shape: auto,
          width: auto, min-width: auto, max-width: auto,
          min-height: auto, max-height: auto,
          col: none, row: none, x: none, y: none,
          side: auto) = (
  body: body, title: title, icon: icon, colour: colour, shape: shape,
  width: width, min-width: min-width, max-width: max-width,
  min-height: min-height, max-height: max-height,
  col: col, row: row, x: x, y: y, side: side,
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
///   cell          the column pitch: a length fixes it, `auto` takes the
///                 widest card's own words — one number still serves the whole
///                 rank, while each card may be narrower inside it
///   min-width, max-width, min-height, max-height
///                 board-wide bounds; each `node(..)` can set its own
#let mindgrid(
  hub,
  ..nodes,
  cols: 3,
  rows: auto,
  cell: auto,        // `auto` = as wide as the widest card
  cell-h: auto,
  min-width: 1.5,
  max-width: 9.0,
  min-height: 0.0,
  max-height: auto,
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
  body-align: auto,
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
  let cmz(v) = _cm(v)
  let min-width = if min-width == auto or min-width == none { 1.5 } else { cmz(min-width) }
  let max-width = if max-width == auto or max-width == none { 9.0 } else { cmz(max-width) }
  let min-height = if min-height == auto or min-height == none { 0.0 } else { cmz(min-height) }
  let max-height = if max-height == auto or max-height == none { none } else { cmz(max-height) }
  let gap-x = cmz(gap-x)
  let gap-y = cmz(gap-y)
  let gap = cmz(gap)
  // `cell` is the column pitch and default maximum width. Individual cards
  // hug their own content inside that shared gutter, so the grid stays aligned.
  let cell = if cell != auto { cmz(cell) } else {
    let want(bd) = {
      let ic = bd.at("icon", default: none)
      let tt = bd.at("title", default: none)
      let iw = if ic != none { measure(ic).width / 1cm + 0.20 } else { 0.0 }
      let hw = if tt != none { measure(tt).width / 1cm + iw } else { iw }
      let raw = calc.max(measure(bd.body).width / 1cm, hw) + 2 * gap + 0.46
      let lo = if bd.at("min-width", default: auto) != auto {
        cmz(bd.at("min-width")) } else { min-width }
      calc.min(max-width, calc.max(lo, raw))
    }
    calc.max(..items.map(want))
  }
  let r2l = if dir != auto { dir == rtl } else { text.dir == rtl }
  let pst = theme == "poster"
  let bdir = if r2l { rtl } else { ltr }
  let bal = if body-align != auto { body-align }
            else if r2l { right } else { left }
  let hd = if rough { if hand != none { hand } else { "roughjs" } } else { none }
  let prt = theme == "print"
  let ns = if sides != auto { sides } else { n }
  let rad = if radius != auto { radius } else { calc.max(1.3, 0.30 * cell) }
  let bound(v, fallback) = if v == auto or v == none { fallback } else { cmz(v) }
  let card-at(b, w, sh) = {
    let hguess = 1.0
    let out = none
    for _ in range(6) {
      let pd0 = _shape-pad(sh, w, hguess)
      let inner = calc.max(0.20, w - 2 * gap - pd0.l - pd0.r)
      let head-content = {
        if b.icon != none { box(b.icon); if b.title != none { h(0.35em) } }
        if b.title != none { text(weight: "bold", b.title) }
      }
      let head = if b.title != none or b.icon != none {
        measure(box(width: inner * 1cm, align(center, head-content))).height / 1cm + 0.30
      } else { 0.0 }
      let body-h = measure(box(width: inner * 1cm,
        text(dir: bdir, b.body))).height / 1cm
      let h0 = body-h + head + 2 * gap
      let pd1 = _shape-pad(sh, w, h0)
      let h1 = h0 + pd1.t + pd1.b
      let pd2 = _shape-pad(sh, w, h1)
      out = (h: h0 + pd2.t + pd2.b, head: head, pad: pd2,
        inner: calc.max(0.20, w - 2 * gap - pd2.l - pd2.r))
      hguess = out.h
    }
    out
  }
  let fit-node(b, sh, i) = {
    let minw = bound(b.at("min-width", default: auto), min-width)
    let local-max = bound(b.at("max-width", default: auto),
      if b.at("width", default: auto) != auto { calc.max(minw, cmz(b.width)) }
      else { calc.min(cell, max-width) })
    let maxw = calc.min(cell, local-max)
    let minh = bound(b.at("min-height", default: auto), min-height)
    let maxh = bound(b.at("max-height", default: auto), max-height)
    let raw-b = measure(text(dir: bdir, b.body)).width / 1cm
    let raw-h = if b.title != none or b.icon != none {
      let head-content = {
        if b.icon != none { box(b.icon); if b.title != none { h(0.35em) } }
        if b.title != none { text(weight: "bold", b.title) }
      }
      measure(head-content).width / 1cm
    } else { 0.0 }
    let p0 = _shape-pad(sh, calc.max(minw, 1.0), 1.0)
    let raw-w = calc.max(raw-b, raw-h) + 2 * gap + p0.l + p0.r + 0.06
    let target = if b.at("width", default: auto) != auto { cmz(b.width) } else { raw-w }
    let size = _fit-dimensions(target, minw, maxw, minh, maxh,
      w => card-at(b, w, sh).h, what: "mindgrid leaf " + str(i + 1))
    let m = card-at(b, size.w, sh)
    (w: size.w, h: calc.max(size.h, minh), head: m.head,
     pad: m.pad, inner: m.inner)
  }

  // ---- cells and columns -------------------------------------------------
  let nrows = if rows != auto { rows } else {
    calc.ceil((n + (if hub-at != auto { 1 } else { 0 })) / cols)
  }
  let ch = if cell-h != auto { cmz(cell-h) } else { cell * 0.62 }
  let step-x = cell + gap-x
  let cx0 = -(cols - 1) * step-x / 2
  let cell-x(c) = cx0 + c * step-x
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
    let cc = if b.col != none { (b.col, if b.row != none { b.row } else { 0 }) }
      else if b.x != none { (none, none) }
      else { let q = auto-cells.at(calc.min(k, auto-cells.len() - 1))
             k = k + 1; q }
    let absolute = b.x != none
    let x = if absolute { cmz(b.x) } else { cell-x(cc.first()) }
    let y = if absolute and b.y != none { cmz(b.y) } else { 0.0 }
    let row = if absolute { none } else { cc.last() }
    let sh0 = if b.shape != auto { b.shape } else { shape }
    let sz = fit-node(b, sh0, i)
    leaves.push((i: i, p: (x, y), row: row, absolute: absolute,
      w: sz.w, h: sz.h, head: sz.head, pad: sz.pad, inner: sz.inner,
      col: if b.colour != auto { b.colour } else { _hue(palette, i) },
      sh: sh0, side: b.side, title: b.title, body: b.body,
      icon: b.at("icon", default: none), src: b))
  }

  // Each row grows to its tallest leaf, or to the hub when the hub occupies
  // that row. `cell-h` is a minimum pitch, not a clipping box.
  let row-h = range(nrows).map(r => {
    let hs = leaves.filter(l => l.row == r).map(l => l.h)
    let cards = if hs.len() == 0 { ch } else { calc.max(ch, ..hs) }
    if hub-at != auto and hub-at.last() == r { calc.max(cards, 2 * rad) }
    else { cards }
  })
  let total-h = row-h.sum() + gap-y * calc.max(0, nrows - 1)
  let row-y = ()
  let cursor = total-h / 2
  for r in range(nrows) {
    let rh = row-h.at(r)
    row-y.push(cursor - rh / 2)
    cursor -= rh + gap-y
  }
  let leaves = leaves.map(l => l + (p: (l.p.at(0),
    if l.absolute { l.p.at(1) } else { row-y.at(calc.clamp(l.row, 0, nrows - 1)) })))
  let hub-pos = if hub-at != auto {
    (cell-x(hub-at.first()), row-y.at(calc.clamp(hub-at.last(), 0, nrows - 1)))
  } else { (cmz(hub-x), cmz(hub-y)) }

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
  let hub-sty = _hub-shape-fn(hub-shape, hub-ratio)
  let hub-o-raw = _hub-pts(ns, rad, start: 90deg, shape: hub-sty,
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
                  else if prt or pst { white } else { l.col.lighten(tint) }
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
                  if l.icon != none { box(l.icon); if l.title != none { h(0.35em) } }
                  if l.title != none { text(fill: if prt { black } else { inkc.darken(18%) },
                    weight: "bold", l.title) }
                })))
          }
          place(top + left, dx: (gap + l.pad.l) * 1cm,
            dy: (gap + l.head + l.pad.t) * 1cm,
            box(width: (l.w - 2 * gap - l.pad.l - l.pad.r) * 1cm,
              align(bal, text(dir: bdir, l.body))))
        }))
    }

    // ---- the hub ---------------------------------------------------------
    let hub-o = hub-o-raw
      .map(p => P((hub-pos.at(0) + p.at(0), hub-pos.at(1) + p.at(1))))
    let hub-i = _hub-pts(ns, rad * 0.88, start: 90deg, shape: hub-sty,
      ratio: hub-ratio)
      .map(p => P((hub-pos.at(0) + p.at(0), hub-pos.at(1) + p.at(1))))
    let hub-has = hub-o.len() > 0
    if shadow and hub-has {
      place(top + left, dx: 3pt, dy: 4pt,
        _fill((hub-o,), flip: flip, fill: sh-col))
    }
    if hub-has and prt {
      place(top + left, _fill((hub-o,), flip: flip, fill: hf))
    } else if hub-has {
      place(top + left, _fill((hub-o,), flip: flip, fill: hi))
      place(top + left, _fill((hub-i,), flip: flip, fill: hf))
    }
    if weight != 0pt and hub-has {
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

// -----------------------------------------------------------------------------
//  sticky — the wall of notes
// -----------------------------------------------------------------------------
//
//  A third genre, and a deliberately stubborn one: not a hub with stalks but
//  a BOARD of post-its, pinned in a loose grid around a central sheet and
//  joined to it with arrows drawn in felt tip. The nine-note posters this
//  comes from — a lesson on the continuity of a function, one idea per sheet,
//  a numbered title ruled underneath — are the commonest thing a teacher puts
//  on a wall and the least well served by a tree package, because a wall is
//  not a ring and a sheet of paper does not grow to fit its sentence.
//
//  THE RULE, therefore: the notes keep the GRID they are given, but each sheet
//  fits its own text inside the shared column pitch; a row is as tall as its
//  tallest sheet. The lean, lifted corner and arrow are decoration, never
//  layout: `tilt: 0deg` and `arrows: false` leave an honest grid.

/// One sheet on the board.
///
///   body     what is written on it
///   title    the heading: bold, centred, ruled underneath
///   icon     a mark before the title
///   number   overrides the board's `numbering` for this sheet alone —
///            `[3. ·]`, or `none` to drop the number the others carry
///   tilt     this sheet's own lean; `auto` takes the board's
///   colour   the paper's colour
///   fill     the sheet's fill, which need not be its colour
///   col,row  the cell it is pinned to (0-based, top left is (0, 0)), or
///   x,y      an absolute position in cm, y UP, the hub at the origin
///   width    a fixed sheet width; the four min/max limits fit each note's
///            own box, inside the board's column pitch
#let note(..args, title: none, icon: none, number: auto, tilt: auto,
          colour: auto, fill: auto, shape: auto, width: auto,
          min-width: auto, max-width: auto,
          min-height: auto, max-height: auto,
          col: none, row: none, x: none, y: none) = (
  body: if args.pos().len() > 0 { args.pos().first() } else { [] },
  title: title, icon: icon, number: number, tilt: tilt, colour: colour,
  fill: fill, shape: shape, width: width,
  min-width: min-width, max-width: max-width,
  min-height: min-height, max-height: max-height,
  col: col, row: row, x: x, y: y,
)

/// The wall of post-its: notes on a board, arrows to the sheet in the middle.
///
///   hub          the central sheet's title
///   ..notes      `note(..)` values, or plain content for a bare sheet
///
///   cols, rows   the board; `rows: auto` makes room for every note
///   cell         the shared column pitch; each sheet may be narrower and
///                its height follows its contents, floored at `cell-h`
///   min-width, max-width, min-height, max-height
///                board-wide note limits; `note(..)` may override them
///   hub-at       the hub's cell, `(col, row)`; `auto` centres it
///   hub-span     how many columns the hub's sheet covers
///   numbering    `true` → `1.`, `2.`, … before every title; a pattern such
///                as `"01"`; an array of marks; a function `(i, n) => ..`
///   underline    rule under each title, as on the poster
///   tilt         how far a sheet may sit off the straight, in degrees — the
///                lean is drawn from `seed`, so a board never rearranges
///                itself between two compiles
///   fold         lift a corner: `true` on every sheet, `55%` on about half
///   tape, pin    a strip of masking tape, or a drawing pin, over the top
///   arrows       `true` joins every sheet to the hub with a felt-tip arrow,
///                `false` leaves the sheets to stand alone
///   palette      a name from `sprig-palettes`, or an array of colours;
///                `sticky` is the paper box
///   theme        `"print"`: white paper, black rule, no shadow
///   hub-shape    the hub sheet's OUTLINE, a key of `sprig-shapes`: a
///                `"pill"` or `"ellipse"` hub reads as the thing the notes hang
///                off. `note(shape:)` gives one sheet an outline of its own,
///                and `note(width:)` a width of its own
///   gap-x, gap-y the gutter between two columns, and between two ranks
///   hub-colour, hub-fill, hub-text
///                the hub's own paper, wash and words: `auto` keeps the
///                colour of the sheet it points at, its darkened twin and
///                white — the usual rule, turned about
///   ink, radius  the pen that rules the sheets, and their corner radius
///   arrow-colour, arrow-weight, arrow-head, arrow-bow
///                the felt-tip arrows: their colour and thickness, the size of
///                the head and how far the shaft bows; `gap` is the air the
///                head stops short of a sheet by
///
/// `weight`, `shadow`, `dir`, `body-align`, `rough`, `hand`, `roughness` and
/// `seed` mean what they mean on the other three maps.
#let sticky(
  hub,
  ..notes,
  cols: 4,
  rows: auto,
  cell: 5.0,
  cell-h: 3.4,
  min-width: 2.0,
  max-width: auto,
  min-height: auto,
  max-height: auto,
  gap-x: 0.95,
  gap-y: 0.85,
  hub-at: auto,
  hub-span: 1,
  hub-shape: auto,       // the hub's OUTLINE: a key of `sprig-shapes`
  hub-colour: auto,
  hub-fill: auto,
  hub-text: auto,
  palette: "sticky",
  theme: auto,
  numbering: true,
  underline: true,
  tilt: 1.25deg,
  fold: false,
  tape: false,
  pin: false,
  shadow: true,
  weight: 1.0pt,
  ink: auto,
  arrows: true,
  arrow-colour: auto,
  arrow-weight: 1.5pt,
  arrow-head: 0.26,
  arrow-bow: 0.05,
  gap: 0.32,
  radius: 0.05,
  body-align: auto,
  dir: auto,
  seed: 3,
  rough: false,
  hand: none,
  roughness: 1.0,
) = context {
  // Distances are bare CENTIMETRES through sprig; `5cm` still means the same
  // thing as `5`.
  let cm(v) = if type(v) == length { v / 1cm } else { v }
  let cell = cm(cell)
  let cell-h = cm(cell-h)
  let min-width = if min-width == auto or min-width == none { 2.0 } else { cm(min-width) }
  let max-width = if max-width == auto or max-width == none { cell } else { cm(max-width) }
  let min-height = if min-height == auto or min-height == none { none } else { cm(min-height) }
  let max-height = if max-height == auto or max-height == none { none } else { cm(max-height) }
  let gap-x = cm(gap-x)
  let gap-y = cm(gap-y)
  let gap = cm(gap)
  let radius = cm(radius)
  let arrow-head = cm(arrow-head)
  let tilt = if type(tilt) == angle { tilt } else { tilt * 1deg }

  let items = notes.pos().map(b =>
    if type(b) == dictionary and "body" in b { b } else { note(b) })
  let n = items.len()
  if n == 0 { return }

  let r2l = if dir != auto { dir == rtl } else { text.dir == rtl }
  let bdir = if r2l { rtl } else { ltr }
  let bal = if body-align != auto { body-align }
            else if r2l { right } else { left }
  let hd = if rough { if hand != none { hand } else { "roughjs" } } else { none }
  let prt = theme == "print"

  // A board is not a poster: what carries a post-it is the PEN, not the
  // paper, so the ink defaults to near-black rather than to a darkened
  // version of each sheet's own colour.
  let ink0 = if ink != auto { ink } else if prt { black } else { rgb("#22262B") }
  let sh-col = rgb("#00000026")
  let shadow = if prt { false } else { shadow }
  // Room for whatever overhangs the paper: the shadow, the tape, the pin.
  let margin = if shadow or tape != false or pin != false { 0.22 } else { 0.08 }

  // ---- the board ---------------------------------------------------------
  // The hub is a SHEET TOO and it eats cells: four columns, a hub two
  // columns wide and nine notes is precisely the 4 / 3 / 4 wall of the
  // poster, which is why `rows: auto` has to count the hub's cells as well.
  let hub-span = calc.max(1, hub-span)
  let nrows = if rows != auto { rows } else {
    calc.ceil((n + hub-span) / cols)
  }
  let hub-cell = if hub-at != auto { (hub-at.first(), hub-at.last()) }
                 else { (calc.floor((cols - hub-span) / 2),
                         calc.floor((nrows - 1) / 2)) }
  // ONE logical line: a continuation may not open with `and`, or Typst
  // closes the expression at the break and reads a dangling conjunction.
  let taken(c, r) = { r == hub-cell.at(1) and c >= hub-cell.at(0) and c < hub-cell.at(0) + hub-span }
  let free = ()
  for r in range(nrows) {
    let line = range(cols).filter(c => not taken(c, r))
    for c in (if r2l { line.rev() } else { line }) { free.push((c, r)) }
  }
  let step-x = cell + gap-x
  let board-w = cols * cell + (cols - 1) * gap-x
  let cx0 = -board-w / 2 + cell / 2
  let hub-w = hub-span * cell + (hub-span - 1) * gap-x

  // ---- the numbers, resolved once ---------------------------------------
  // Exactly the rule `blossom` uses for its petals: `true` is the plain
  // decimal with the dot the poster writes, a pattern goes to Typst's own
  // `numbering`, an array is cycled, a function is called one-based.
  let num-of = if numbering == false or numbering == none { none }
    else if numbering == true { (i) => str(i + 1) + "." }
    else if type(numbering) == array {
      (i) => numbering.at(calc.rem(i, numbering.len()))
    }
    else if type(numbering) == str { (i) => _std-numbering(numbering, i + 1) }
    else { (i) => numbering(i + 1, n) }

  // The heading of a sheet: number, icon, title, all bold, all in the
  // pen's colour, ruled underneath. The rule follows the TITLE rather than
  // the sheet — a two-word heading on a wide note wants a short underline,
  // which is what the poster does — and the block is then centred.
  let head-of(num, ico, ttl, iw, sz: 1em, edge: 1.1pt) = {
    if num == none and ico == none and ttl == none { return none }
    let inner = {
      if num != none { text(weight: "bold", size: sz, fill: ink0, num); h(0.28em) }
      if ico != none { box(ico); h(0.3em) }
      if ttl != none { text(weight: "bold", size: sz, fill: ink0, ttl) }
    }
    let wnat = calc.min(iw, measure(inner).width / 1cm + 0.02)
    box(width: wnat * 1cm,
      inset: (bottom: if underline { 0.12cm } else { 0cm }, x: 0cm, y: 0cm),
      stroke: if underline { (bottom: edge + if prt { black } else { ink0 }) }
              else { none },
      align(center, inner))
  }

  // A sheet fits its own words inside the board's column width. Short notes
  // can be narrower than the cell; longer ones wrap, and each row grows to
  // the tallest sheet. Explicit width is still a fixed target for compatibility.
  let size-of(b, i) = {
    let num = if b.number != auto { b.number }
              else if num-of != none { num-of(i) } else { none }
    let frand = _randoms(seed * 31 + i * 7, 3)
    let folded = if type(fold) == bool { fold }
      else if fold == none { false }
      else if type(fold) == float or type(fold) == int {
        let rate = if calc.abs(fold) <= 1.0 { fold } else { fold / 100.0 }
        frand.at(0) < rate
      }
      else { fold != 0 }
    let sty = if b.shape != auto { b.shape }
              else if folded { "note" } else if radius <= 0.02 { "sharp" } else { "round" }
    let minw = if b.min-width != auto and b.min-width != none { cm(b.min-width) }
               else { min-width }
    let maxw0 = if b.max-width != auto and b.max-width != none { cm(b.max-width) }
                else if b.width != auto and b.width != none { calc.max(minw, cm(b.width)) }
                else { max-width }
    let maxw = calc.min(cell, maxw0)
    let minh = if b.min-height != auto and b.min-height != none { cm(b.min-height) }
               else if min-height != none { min-height }
               else if b.max-height != auto and b.max-height != none { 0.0 }
               else if max-height != none { 0.0 }
               else { cell-h }
    let maxh = if b.max-height != auto and b.max-height != none { cm(b.max-height) }
               else { max-height }
    let head-content = {
      if num != none { text(weight: "bold", size: 1em, fill: ink0, num); h(0.28em) }
      if b.icon != none { box(b.icon); h(0.3em) }
      if b.title != none { text(weight: "bold", size: 1em, fill: ink0, b.title) }
    }
    let raw-head = if num != none or b.icon != none or b.title != none {
      measure(head-content).width / 1cm
    } else { 0.0 }
    let raw-body = if b.body != [] and b.body != none {
      measure(text(fill: ink0, dir: bdir, b.body)).width / 1cm
    } else { 0.0 }
    let pad0 = _shape-pad(sty, calc.max(minw, 1.0), 1.0)
    let wantw = calc.max(raw-head, raw-body) + 2 * gap + pad0.l + pad0.r + 0.08
    let target = if b.width != auto and b.width != none { cm(b.width) } else { wantw }
    let metrics(w) = {
      let hguess = 1.0
      let out = none
      for _ in range(6) {
        let pd0 = _shape-pad(sty, w, hguess)
        let iw = calc.max(0.6, w - 2 * gap - pd0.l - pd0.r)
        let head = head-of(num, b.icon, b.title, iw)
        let hh = if head != none { measure(box(width: iw * 1cm, head)).height / 1cm + 0.16 }
                 else { 0.0 }
        let bd = if b.body != [] and b.body != none {
          measure(box(width: iw * 1cm, text(fill: ink0, dir: bdir, b.body))).height / 1cm
        } else { 0.0 }
        let h0 = hh + bd + 2 * gap
        let pd1 = _shape-pad(sty, w, h0)
        let h1 = h0 + pd1.t + pd1.b
        let pd2 = _shape-pad(sty, w, h1)
        out = (h: h0 + pd2.t + pd2.b, pad: pd2, iw: iw, head: head, hd: hh)
        hguess = out.h
      }
      out
    }
    let sizes = _fit-dimensions(target, minw, maxw, minh, maxh,
      w => metrics(w).h, what: "sticky note " + str(i + 1))
    let m = metrics(sizes.w)
    (w: sizes.w, h: calc.max(sizes.h, minh), num: num, sty: sty,
     folded: folded, pad: m.pad, iw: m.iw, head: m.head, hd: m.hd,
     minw: minw, maxw: maxw, minh: minh, maxh: maxh)
  }

  // ---- the hub's sheet, first: a row has to hold it too ------------------
  let hub-col = if hub-colour != auto { hub-colour } else { _hue(palette, 0) }
  let hub-fillc = if hub-fill != auto { hub-fill }
                  else if prt { white } else { hub-col }
  let hub-t = if hub-text != auto { hub-text }
              else if prt { black }
              else if luma(hub-fillc).components().first() > 58% { ink0 }
              else { white }
  let hub-sty = if hub-shape != auto { hub-shape }
                else if fold != false and fold != none { "note" }
                else if radius <= 0.02 { "sharp" } else { "round" }
  let hub-pd = _shape-pad(hub-sty, hub-w, 1.0)
  let hub-iw = calc.max(0.6, hub-w - 2 * gap - hub-pd.l - hub-pd.r)
  let hub-head = head-of(none, none, hub, hub-iw, sz: 1.06em, edge: 1.3pt)
  let hub-h = calc.max(cell-h * 1.1,
    measure(box(width: hub-iw * 1cm, hub-head)).height / 1cm + 2 * gap + 0.14)

  // ---- place every sheet, then measure it -------------------------------
  let sheets = ()
  let k = 0
  for (i, raw-b) in items.enumerate() {
    // A `node(..)`, from `mindgrid`, is a legal sheet as well: it simply
    // carries no number, no lean and no fill of its own.
    let b = (number: auto, tilt: auto, fill: auto) + raw-b
    let at = if b.x != none { (none, none) }
             else if b.col != none { (b.col, if b.row != none { b.row } else { 0 }) }
             else { let cc = free.at(calc.min(k, calc.max(0, free.len() - 1)))
                    k = k + 1
                    cc }
    let sz = size-of(b, i)
    let sw = sz.w
    let x = if b.x != none { cm(b.x) } else { cx0 + at.at(0) * step-x }
    sheets.push((i: i, b: b, x: x, r: at.at(1), absolute: b.x != none,
      y: if b.y != none { cm(b.y) } else { 0.0 },
      col: if b.colour != auto { b.colour } else { _hue(palette, i) }) + sz)
  }

  // ---- the rows, sized to the tallest sheet in each --------------------
  // Post-its are not all the same height: one carries three lines, the next
  // eight. A fixed pitch is how a board ends up with one card sitting on top
  // of another, so the row grows to its tallest sheet and the pitch follows.
  let row-h = range(nrows).map(r => {
    let hs = sheets.filter(s => s.r == r).map(s => s.h)
    let all = if r == hub-cell.at(1) { hs + (hub-h,) } else { hs }
    if all.len() == 0 { cell-h } else { calc.max(cell-h, ..all) }
  })
  let tot-h = 0.0
  for h in row-h { tot-h = tot-h + h }
  tot-h = tot-h + gap-y * calc.max(0, nrows - 1)
  let row-y = ()
  let cur = tot-h / 2
  for r in range(nrows) {
    let h = row-h.at(r)
    row-y.push(cur - h / 2)
    cur -= h + gap-y
  }
  let hub-x = cx0 + (hub-cell.at(0) + (hub-span - 1) / 2) * step-x
  let hub-y = if hub-cell.at(1) >= 0 and hub-cell.at(1) < nrows {
    row-y.at(hub-cell.at(1))
  } else { 0.0 }
  let sheets = sheets.map(s => s + (y: if s.absolute { s.y }
    else if s.r != none { row-y.at(calc.clamp(s.r, 0, calc.max(0, nrows - 1))) }
    else { 0.0 }))

  // ---- the canvas --------------------------------------------------------
  // The canvas is the union of the sheets' boxes, hub included. A wall of
  // tilted paper has to leave room at the edges for the lean, hence the
  // 0.2 before the pad — a sheet turned by a degree is a hair wider.
  let boxes = ((hub-x, hub-y, hub-w, hub-h),) + sheets.map(s => (s.x, s.y, s.w, s.h))
  let xs = boxes.map(b => (b.at(0) - b.at(2) / 2 - 0.2, b.at(0) + b.at(2) / 2 + 0.2)).flatten()
  let ys = boxes.map(b => (b.at(1) - b.at(3) / 2 - 0.2, b.at(1) + b.at(3) / 2 + 0.2)).flatten()
  let pad = 0.34
  let x0 = calc.min(..xs) - pad
  let x1 = calc.max(..xs) + pad
  let y0 = calc.min(..ys) - pad
  let y1 = calc.max(..ys) + pad
  let W = x1 - x0
  let Hh = y1 - y0
  let flip = Hh * 1cm
  let P(p) = (p.at(0) - x0, p.at(1) - y0)

  // ---- one sheet: paper, edge, corner, tape, pin, and the writing ------
  // All of it inside ONE box a little larger than the paper, all of it turned
  // by the same angle. Rotating the paper and the writing separately would
  // turn them about two different centres, and a couple of degrees is enough
  // for the text to walk off its own sheet.
  let card(cx2, cy2, w, h, fillc, colr, tl, sty, folded, writing, i) = {
    let bw = w + 2 * margin
    let bh = h + 2 * margin
    let edge = if prt { rgb("#333333") } else { colr.darken(30%) }
    let flap = {
      // the underside of a lifted corner, in a darker shade of the same paper
      if folded {
        let c = calc.min(h * 0.30, w * 0.20)
        place(top + left, dx: margin * 1cm, dy: margin * 1cm,
          _fill((((w - c, 0.0), (w, 0.0), (w, c)),), flip: h * 1cm,
            fill: colr.darken(16%)))
      }
    }
    let tape-bit = {
      if tape != false {
        let tr = _randoms(seed * 13 + i * 5, 1).at(0)
        place(top + left, dx: (margin + w / 2 - 0.62) * 1cm,
          dy: (margin - 0.19) * 1cm,
          rotate((2 * tr - 1) * 8deg, origin: center,
            box(width: 1.24cm, height: 0.38cm, fill: rgb("#FFFFFFBB"),
              stroke: (paint: rgb("#0000001A"), thickness: 0.4pt),
              inset: 0pt)))
      }
    }
    let pin-bit = {
      if pin != false {
        let pc = if type(pin) == color { pin } else { rgb("#C0392B") }
        place(top + left, dx: (margin + w / 2 - 0.16) * 1cm,
          dy: (margin - 0.30) * 1cm,
          _fill((_circle-pts((0.16, 0.16), 0.14),), flip: 0.32 * 1cm,
            fill: pc))
      }
    }
    place(top + left,
      dx: (cx2 - bw / 2 - x0) * 1cm,
      dy: (Hh - (cy2 + bh / 2 - y0)) * 1cm,
      rotate(tl, origin: center, box(width: bw * 1cm, height: bh * 1cm, {
        place(top + left, dx: margin * 1cm, dy: margin * 1cm,
          box(width: w * 1cm, height: h * 1cm,
            _leaf-draw(sty, w, h, radius, fill: if fillc == none { none }
              else { fillc }, stroke-paint: edge, weight: if weight == 0pt
                and not prt { 0pt } else { weight },
              hand: hd, seed: seed + i * 17, roughness: roughness,
              bowing: 0.6, shadow: if shadow { sh-col } else { none })))
        flap
        place(top + left, dx: margin * 1cm, dy: margin * 1cm,
          box(width: w * 1cm, height: h * 1cm, writing))
        tape-bit
        pin-bit
      })))
  }

  // Where the ray from one rectangle's centre towards the other's leaves the
  // first. An arrow drawn from the hub's CENTRE would be covered up by the
  // hub, which is drawn after it, so it starts on the rim instead.
  let rim(ox, oy, hw, hh, tx, ty) = {
    let dx = tx - ox
    let dy = ty - oy
    let sx = if calc.abs(dx) > 1e-6 { hw / calc.abs(dx) } else { 1e9 }
    let sy = if calc.abs(dy) > 1e-6 { hh / calc.abs(dy) } else { 1e9 }
    let t = calc.min(sx, sy)
    (ox + dx * t, oy + dy * t)
  }
  let tilt-of(i, v) = if v != auto { v } else {
    (2 * _randoms(seed * 31 + i * 7, 2).at(1) - 1) * tilt
  }

  box(width: W * 1cm, height: Hh * 1cm, {
    for s in sheets {
      let pd = s.pad
      let iw = s.iw
      let body = {
        if s.head != none {
          place(top + left, dx: (gap + pd.l) * 1cm, dy: gap * 1cm,
            box(width: s.iw * 1cm,
              align(center, s.head)))
        }
        if s.b.body != [] and s.b.body != none {
          place(top + left, dx: (gap + pd.l) * 1cm,
            dy: (gap + s.hd) * 1cm,
            box(width: s.iw * 1cm,
              align(bal, text(fill: ink0, dir: bdir, s.b.body))))
        }
      }
      card(s.x, s.y, s.w, s.h, if s.b.fill != auto { s.b.fill }
        else if prt { white } else { s.col }, s.col,
        tilt-of(s.i, if type(s.b.tilt) == angle { s.b.tilt }
          else if s.b.tilt != auto { s.b.tilt * 1deg } else { auto }),
        s.sty, s.folded, body, s.i)
    }

    // the hub, last of the paper: it is where every arrow starts, so its
    // sheet has to sit over their roots
    card(hub-x, hub-y, hub-w, hub-h, hub-fillc, hub-col,
      tilt-of(99, auto) * 0.6, hub-sty, hub-sty == "note",
      align(center + horizon, box(width: hub-iw * 1cm, hub-head)), 0)

    if arrows != false {
      let acol = if arrow-colour != auto { arrow-colour }
                 else if prt { black } else { rgb("#1D2126") }
      for s in sheets {
        let a0 = rim(hub-x, hub-y, hub-w / 2, hub-h / 2, s.x, s.y)
        let a1 = rim(s.x, s.y, s.w / 2 + 0.03, s.h / 2 + 0.03, hub-x, hub-y)
        let vx = a1.at(0) - a0.at(0)
        let vy = a1.at(1) - a0.at(1)
        let ln = calc.max(0.001, calc.sqrt(vx * vx + vy * vy))
        let sg = if calc.rem(s.i, 2) == 0 { 1.0 } else { -1.0 }
        let bow = cm(arrow-bow)
        let mid = ((a0.at(0) + a1.at(0)) / 2 - vy / ln * bow * ln * sg,
                   (a0.at(1) + a1.at(1)) / 2 + vx / ln * bow * ln * sg)
        let path = _smooth-pts((P(a0), P(mid), P(a1)), samples: 16)
        place(top + left, _lines((path,), flip: flip,
          stroke: (paint: acol, thickness: arrow-weight, cap: "round")))
        let q0 = path.at(path.len() - 2)
        let q1 = path.last()
        place(top + left, _fill((_head(q1,
          (q1.at(0) - q0.at(0), q1.at(1) - q0.at(1)), arrow-head),),
          flip: flip, fill: acol))
      }
    }
  })
}

// -----------------------------------------------------------------------------
//  tikzmap — the concept map, in the manner of TikZ's `mindmap` library
// -----------------------------------------------------------------------------
//
//  The genre LaTeX taught everyone else: a ROOT drawn as a filled disc, one
//  curved branch per child that swells where it leaves its parent and thins
//  where it reaches its concept, every concept a circle or an ellipse sized to
//  the words inside it, and a colour that belongs to a whole first-rank
//  SUBTREE rather than to a single card. Two things set it apart from
//  `mindmap`. The tree nests as deep as the caller writes, so it is not a ring
//  of cards with two ranks bolted on. And the layout is bought by the
//  SUBTREES: a branch carrying nine ideas is given nine times the angle of one
//  carrying a single idea, which is what stops a deep tree from folding back
//  over itself. That proportionality is TikZ's `grow cyclic`, counted the way
//  the library counts it, and it costs one recursion here.
//
//  For LaTeX's other mind map — `edge from parent fork down`, the one that
//  reads as an organigram — name `grow:` `"down"`, `"up"`, `"left"` or
//  `"right"`: the same allocation runs along a line instead of round an arc,
//  and a branch turns twice between a parent and a child.

/// One concept of the map, and the ideas growing out of it.
///
///   body     what the concept says
///   title    a bold line above it
///   icon     a mark above the title
///   colour   the hue of this whole subtree; `auto` takes the palette slot of
///            the first-rank branch it hangs under, as `concept color` does
///   shape    this concept's outline, overriding the map's
///   angle    the bearing it leaves its parent on, overriding the layout
///   dist     centre to centre, in cm, overriding `level-dist`
///   width    how wide its text may run before it wraps
///   min-width, max-width, min-height, max-height
///            bounds for this concept's own box, in cm or Typst lengths
///   dx, dy   nudge it off where the layout put it, in cm, y UP
///   children more `concept(..)` values, at any depth
///
/// `..args` rather than a named `body`, exactly as in `branch`: a concept
/// written as `concept[A]` must keep working, and one written as
/// `concept(title: [A])` must not be asked to produce an empty bracket.
#let concept(..args, title: none, icon: none, colour: auto, shape: auto,
             angle: auto, dist: auto, width: auto,
             min-width: auto, max-width: auto,
             min-height: auto, max-height: auto,
             dx: 0.0, dy: 0.0, children: ()) = (
  body: if args.pos().len() > 0 { args.pos().first() } else { [] },
  title: title, icon: icon, colour: colour, shape: shape,
  angle: angle, dist: dist, width: width,
  min-width: min-width, max-width: max-width,
  min-height: min-height, max-height: max-height,
  dx: dx, dy: dy, children: children,
)

/// TikZ's own mind map scale table, from `tikzlibrarymindmap.code.tex`.
///
/// `mindmap` in the library is not a layout algorithm but a *table of styles*:
/// `root concept` and `level k concept` each carry a `minimum size`, a
/// `text width`, a `level distance`, a `sibling angle` and a font, and
/// `small mindmap`, `large mindmap` and `huge mindmap` re-list the whole table.
/// Every array below runs by RANK, the root in slot 0; `level-dist` and
/// `sibling-angle` start at rank 1 (slot 0 is unused). Beyond the fourth rank
/// the last column holds, as it does in LaTeX.
///
/// The numbers are the library's, in cm and relative `em` — which is why a
/// TikZ mind map's ranks shrink as they run out: `\tiny` at the third rank is
/// 0.5 em there, and the discs do not grow to suit.
#let sprig-mindmap-sizes = (
  small: (
    min-size: (2.3, 1.5, 1.1, 1.1, 1.1),
    text-width: (2.1, 1.4, 1.1, 1.1, 1.1),
    level-dist: (0.0, 2.8, 2.2, 2.2, 2.2),
    sibling-angle: (0deg, 75deg, 60deg, 30deg, 30deg),
    font: (0.8em, 0.7em, 0.5em, 0.5em, 0.5em),
    inner: 0.035, clearance: 0.0, sibling-dist: 0.9, weight: 2pt),
  mindmap: (
    min-size: (4.0, 2.25, 1.75, 1.15, 0.9),
    text-width: (3.5, 2.0, 1.5, 1.0, 0.7),
    level-dist: (0.0, 5.0, 2.9, 2.4, 1.85),
    sibling-angle: (0deg, 60deg, 60deg, 30deg, 30deg),
    font: (1.2em, 0.9em, 0.8em, 0.5em, 0.5em),
    inner: 0.035, clearance: 0.0, sibling-dist: 1.6, weight: 0.8pt),
  large: (
    min-size: (5.6, 3.2, 2.45, 1.63, 1.27),
    text-width: (4.5, 2.8, 2.2, 1.4, 1.0),
    level-dist: (0.0, 7.0, 4.0, 3.38, 2.6),
    sibling-angle: (0deg, 60deg, 60deg, 30deg, 30deg),
    font: (1.44em, 1.0em, 0.9em, 0.7em, 0.5em),
    inner: 0.04, clearance: 0.0, sibling-dist: 2.2, weight: 2pt),
  huge: (
    min-size: (8.0, 4.5, 3.5, 2.3, 1.7),
    text-width: (7.0, 4.0, 3.0, 2.0, 1.4),
    level-dist: (0.0, 10.0, 5.8, 4.8, 3.7),
    sibling-angle: (0deg, 60deg, 60deg, 30deg, 30deg),
    font: (2.07em, 1.2em, 1.0em, 0.8em, 0.7em),
    inner: 0.04, clearance: 0.0, sibling-dist: 3.0, weight: 3pt),
)

/// A concept map: a root, curved branches, a concept at the end of each.
///
///   root           the central concept — plain content, or a `concept(..)`
///   ..branches     the first rank, each free to carry `children:` again
///
///   grow           `"cyclic"` rings the concepts round their parent, as
///                  TikZ's `grow cyclic`; `"down"`, `"up"`, `"left"`,
///                  `"right"` lay the ranks out in columns and join them with
///                  a fork, as `edge from parent fork down` does
///   start, spread  where the ring is centred, and how much of it the first
///                  rank shares
///   sibling-angle  give every branch the SAME angle instead of a share bought
///                  by its number of leaves; use a Typst angle such as `60deg`
///                  (bare degree counts remain accepted), so the map may open
///                  past 360deg rather than crushing its concepts together
///   min-angle      and the narrowest angle a single leaf may be given, under
///                  the proportional layout — the floor below which the ring
///                  opens into a fan instead of overlapping
///   level-dist     how far a concept sits from its parent, in cm — one
///                  number, or one per rank as `level 1/.style` does
///   shrink         and how much closer each rank comes than the one above
///   sibling-dist   the gap between neighbouring subtrees, for the forked
///                  growths, where the ranks line up along a line
///   clearance      the air a concept keeps from the branch that reaches it
///   shape          `"ellipse"` (the default under `cyclic`), `"circle"`,
///                  `"rounded"`, `"box"`, or a function `(w, h, r) => pts`
///   inner          `inner sep`: the paper a concept keeps round its words
///   text-width     `text width`: where those words start to wrap
///   min-width, max-width, min-height, max-height
///                  optional box limits, overridden by a `concept(..)`'s own
///                  bounds; a height cap widens the text column before refusal
///   fill           `false` leaves the concepts as outlines only
///   tint, tint-step a level-1 concept's wash, and how much paler every rank
///                  below it is, so a subtree fades as it runs out
///   branch-weight  where a branch starts, in cm, as `stalk` is; `taper`
///                  how much thinner the rank
///                  below; `line-tip` how narrow on arrival; `curve` the bow
///                  of a `curve:`-bowed stalk; `fork` how far a fork runs down
///                  the axis before it turns, in cm — `auto` is HALF the level
///                  distance, which is exactly `edge from parent fork down`,
///                  `-- +(0pt,-.5\tikzleveldistance) -| (child)`; `corner` is
///                  how round the two turns are
///   separators     TikZ's `circle separators`: a ring where every first-rank
///                  branch leaves the root
///   scale          a concept's font shrinks by this per rank, as in a mind map
///   palette        a name from `sprig-palettes`, or an array of colours: the
///                  disc and each branch take one in turn, and a concept is
///                  washed in its own at `tint`
///   root-fill, root-ink, root-text
///                  the disc's wash, rule and words — `auto` is the branch
///                  colour, its darkened twin, and white
///   theme          `"print"` for paper: no washes, everything by the rule
///   weight, shadow the rule round a concept, and the soft drop beneath it
///   size           one of `sprig-mindmap-sizes` — `"small"`, `"mindmap"`,
///                  `"large"`, `"huge"` — or your own table of the same shape:
///                  it fills in `min-size`, `text-width`, `level-dist`,
///                  `sibling-angle`, `font` and `inner` per rank, exactly as
///                  `root concept` and `level k concept` do in TikZ
///   min-size       the smallest DISC a concept may be drawn in, in cm, per
///                  rank: pgf's `minimum size`, which is what makes a one-word
///                  concept a plate rather than a button
///   font           the size of a concept's words per rank, as `0.7em` — the
///                  library's `\large`/`\small`/`\footnotesize`/`\tiny` ladder
///   spin           `"cw"` or `"ccw"`: TikZ's `clockwise from=` /
///                  `counterclockwise from=`, where the FIRST child sits on
///                  `start` itself and the rest follow at the sibling angle,
///                  instead of the rank being centred on it
///   bar-angle      TikZ's `segment angle`: how far round each disc the bar
///                  hugs its rim before it straightens out — 20deg, so the
///                  weld covers a 40deg arc
///   bar-thick      and the bar's thickness as a share of the smaller disc:
///                  TikZ's `0.175`
///   shade-branch   `false` paints a whole branch in the parent's colour;
///                  `true` gives TikZ's `circle connection bar switch color`,
///                  which runs the parent's colour into the child's
///   weight, shadow the rule round a concept, and the soft drop beneath it
///   dir, body-align, rough, hand, roughness, seed
///                  as on the other three maps: under `rtl` the fan is
///                  mirrored and the words of a concept run right-to-left
///
/// The branch is TikZ's `circle connection bar`, to the point: a bar of
/// CONSTANT thickness — 0.175 × the smaller of the two radii — whose ends swell
/// along a 40deg arc of each disc and weld onto its rim, filled and never
/// stroked. It is not a taper: set `curve:` above 0 to get sprig's own
/// tapering stalk instead, and `branch-weight:` then rules it.
#let tikzmap(
  root,
  ..branches,
  size: "small",
  grow: "cyclic",
  spin: auto,
  start: 90deg,
  spread: 360deg,
  sibling-angle: auto,
  min-angle: 10deg,
  level-dist: auto,
  shrink: 1.0,
  sibling-dist: auto,
  clearance: auto,
  shape: "auto",
  min-size: auto,
  min-width: auto,
  max-width: auto,
  min-height: auto,
  max-height: auto,
  inner: auto,
  text-width: auto,
  font: auto,
  palette: "poster",
  tint: 0%,
  tint-step: 12%,
  fill: true,
  bar-angle: 20deg,
  bar-thick: 0.175,
  shade-branch: true,
  root-fill: auto,
  root-ink: auto,
  root-text: auto,
  weight: auto,
  branch-weight: 0.11,
  taper: 0.74,
  line-tip: 0.42,
  curve: 0.0,
  fork: auto,
  corner: 0.16,
  scale: 1.0,
  separators: false,
  theme: auto,
  dir: auto,
  body-align: auto,
  shadow: false,
  seed: 3,
  rough: false,
  hand: none,
  roughness: 1.0,
) = context {
  let cm(v) = if type(v) == length { v / 1cm } else { v }
  let cyclic = grow == "cyclic"

  // ---- the scale table, and the ranks' share of it ----------------------
  // `size` carries what `root concept` and `level k concept` carry in the
  // library, so every one of its columns is still a knob of its own: name it
  // and it wins over the table, leave it `auto` and the table speaks.
  let sz = if type(size) == dictionary { size }
           else if size in sprig-mindmap-sizes { sprig-mindmap-sizes.at(size) }
           else { panic("tikzmap: unknown size " + str(size)
             + " — one of " + str(sprig-mindmap-sizes.keys())) }
  let rank(a, d, arr) = {
    let v = if a == auto { arr } else { a }
    if type(v) == array { cm(v.at(calc.min(d, v.len() - 1))) } else { cm(v) }
  }
  let dim-limit(v) = if v == auto or v == none { none } else { cm(v) }
  let map-minw = dim-limit(min-width)
  let map-maxw = dim-limit(max-width)
  let map-minh = dim-limit(min-height)
  let map-maxh = dim-limit(max-height)
  // The colours of a `circle connection bar switch color`: pgf shades the bar
  // from the parent's concept colour to the child's, componentwise.
  let mixc(c1, c2, t) = {
    // `t` walks from one colour to the other along a bar; a bar of zero
    // length, or a child parked on its parent, would divide by nothing
    let t = calc.clamp(t, 0.0, 1.0)
    let a1 = c1.components()
    let a2 = c2.components()
    if a1.len() < 3 or a2.len() < 3 { c1 } else {
      rgb(a1.at(0) + (a2.at(0) - a1.at(0)) * t,
          a1.at(1) + (a2.at(1) - a1.at(1)) * t,
          a1.at(2) + (a2.at(2) - a1.at(2)) * t)
    }
  }
  let inner = rank(inner, 0, sz.inner)
  let clearance = rank(clearance, 0, sz.clearance)
  let sibling-dist = rank(sibling-dist, 0, sz.sibling-dist)
  let twd(d) = rank(text-width, d, sz.text-width)
  let msz(d) = rank(min-size, d, sz.min-size)
  // `sibling-angle` is documented as an angle (for example, `60deg`), while
  // accepting a bare degree count keeps older numeric calls working. `cm()`
  // alone cannot accept an angle: multiplying its result by `1deg` would make
  // `60deg` an angle-times-angle error when `spin` is set.
  let siba(d) = if sibling-angle != auto {
    if type(sibling-angle) == angle { calc.abs(sibling-angle) }
    else { calc.abs(cm(sibling-angle) * 1deg) }
  } else { calc.abs(sz.sibling-angle.at(calc.min(d, sz.sibling-angle.len() - 1))) }
  let fnt(d) = if font != auto { font }
               else if type(font) == array { font.at(calc.min(d, font.len() - 1)) }
               else { sz.font.at(calc.min(d, sz.font.len() - 1)) }
  let weight = if weight != auto { weight } else { sz.weight }
  let sdir = if spin == "cw" { -1.0 } else { 1.0 }
  if not (spin == auto or spin in ("cw", "ccw")) {
    panic("tikzmap: unknown spin " + str(spin) + " — \"cw\", \"ccw\" or auto")
  }
  if not (cyclic or grow in ("down", "up", "left", "right")) {
    panic("tikzmap: unknown grow " + str(grow) + " — one of \"cyclic\", "
      + "\"down\", \"up\", \"left\", \"right\"")
  }
  let r2l = if dir != auto { dir == rtl } else { text.dir == rtl }
  let bdir = if r2l { rtl } else { ltr }
  let bal = if body-align != auto { body-align }
            else if r2l { right } else { left }
  let hd = if rough { if hand != none { hand } else { "roughjs" } } else { none }
  let prt = theme == "print"
  let sg = if r2l { -1.0 } else { 1.0 }
  // `concept` in the library is `circle, draw, fill` — a DISC, never an
  // ellipse: `minimum size` sets both of the box's sides at once. The ellipse
  // is sprig's own, for a rank of long titles.
  let shp = if shape == "auto" { if cyclic { "circle" } else { "rounded" } }
            else { shape }
  let items = branches.pos().map(b =>
    if type(b) == dictionary and "body" in b { b } else { concept(b) })
  let rootb = if type(root) == dictionary and "body" in root { root }
              else { concept(root) }
  // A root written as `concept([Root], children: (...))` owns its first
  // rank. Keep those embedded children, while still allowing additional
  // first-rank concepts as positional arguments to `tikzmap`.
  let root-kids = _kids(rootb.at("children", default: ())).map(b =>
    if type(b) == dictionary and "body" in b { b } else { concept(b) })

  // A concept's words have to READ on its wash, which is the hub's own rule
  // turned around: a pale ellipse takes the darkened branch colour, a
  // saturated root takes white.
  let ink-on(wash, col) = if wash == none { col.darken(58%) }
    else if luma(wash).components().first() > 58% { col.darken(58%) }
    else { white }

  // ---- one pass, bottom up: the size of a concept, and of its subtree ---
  // `wt` is the number of leaves below a concept, the only thing a ring cares
  // about; `ex` is how far its subtree reaches ACROSS the growth axis, the
  // same argument in centimetres for the forked growths. Both are settled on
  // the way up, once, so no later step has to measure anything twice.
  let stack-of(b) = {
    if b.icon != none { box(b.icon); linebreak() }
    if b.title != none { text(weight: "bold", b.title); linebreak() }
    b.body
  }
  let bound(v, fallback) = if v == auto or v == none { fallback } else { cm(v) }
  let sized(b, depth) = {
    let sty = if b.shape != auto { b.shape } else { shp }
    let fsize = if depth == 0 { 1.05em }
                else { 1em * calc.pow(scale, depth - 1) }
    let content = text(size: fsize, dir: bdir, stack-of(b))
    let raw = measure(content)
    let raw-w = raw.width / 1cm
    let minw0 = bound(b.at("min-width", default: auto), map-minw)
    let maxw0 = bound(b.at("max-width", default: auto), map-maxw)
    let minh0 = bound(b.at("min-height", default: auto), map-minh)
    let maxh = bound(b.at("max-height", default: auto), map-maxh)
    let minw = if minw0 == none { 0.0 } else { minw0 }
    let minh = if minh0 == none { 0.0 } else { minh0 }
    let text-cap = if b.width != auto and b.width != none { cm(b.width) }
      else if text-width == none { raw-w + 0.04 }
      else { twd(depth) }
    let inner-w = 2 * inner
    let max-text = if maxw0 != none { calc.max(0.2, calc.min(text-cap, maxw0 - inner-w)) }
                   else { text-cap }
    let start-text = calc.max(0.2, calc.min(max-text, raw-w + 0.04))
    let m = msz(depth)
    let dims-at(tw) = {
      let text-w = calc.min(tw, raw-w + 0.04)
      let bb = measure(box(width: tw * 1cm,
        align(center, text(size: fsize, dir: bdir, stack-of(b)))))
      let aw = text-w + inner-w
      let ah = bb.height / 1cm + inner-w
      let raw-dims = if sty == "circle" {
        let d = calc.max(aw, ah, m, minw, minh)
        (d, d)
      } else {
        (calc.max(aw, m, minw), calc.max(ah, m, minh))
      }
      (w: raw-dims.at(0), h: raw-dims.at(1), text-w: tw)
    }
    let first = dims-at(start-text)
    let final-tw = if maxh != none and first.h > maxh + 0.001 {
      let last = dims-at(max-text)
      if last.h > maxh + 0.001 {
        panic("tikzmap: concept at rank " + str(depth)
          + " cannot fit within max-height; increase max-width or max-height")
      }
      let lo = start-text
      let hi = max-text
      for _ in range(28) {
        let mid = (lo + hi) / 2
        if dims-at(mid).h > maxh { lo = mid } else { hi = mid }
      }
      hi
    } else { start-text }
    let dims = dims-at(final-tw)
    // With no explicit cap, the widest measured shape is its own maximum.
    let maxw = if maxw0 == none { dims-at(max-text).w } else { maxw0 }
    let checked = _fit-dimensions(dims.w, minw, maxw, minh, maxh,
      _ => dims.h, what: "tikzmap concept at rank " + str(depth))
    let kids = if type(b.children) == dictionary { (b.children,) }
               else { b.children }
    (b: b, depth: depth, w: checked.w, h: checked.h,
     kids: kids.map(k => sized(k, depth + 1)))
  }
  let across(t) = if grow == "down" or grow == "up" { t.w } else { t.h }
  let along(t) = if grow == "down" or grow == "up" { t.h } else { t.w }
  let prep(t) = {
    let ks = t.kids.map(prep)
    let w = if ks.len() == 0 { 1 } else { ks.map(k => k.w).sum() }
    let own = across(t) + clearance
    let ex = if ks.len() == 0 { own } else {
      calc.max(own, ks.map(k => k.ex).sum() + sibling-dist * (ks.len() - 1))
    }
    (b: t.b, depth: t.depth, w: t.w, h: t.h, kids: ks, wt: w, ex: ex)
  }
  // The root is a concept like any other, with the whole first rank for
  // children — one tree, one pass over it, no special case in the layout.
  let tree = prep(sized(concept(rootb.body, title: rootb.title,
    icon: rootb.icon, colour: rootb.colour, shape: rootb.shape,
    width: rootb.width, min-width: rootb.min-width,
    max-width: rootb.max-width, min-height: rootb.min-height,
    max-height: rootb.max-height, children: root-kids + items), 0))
  let ld(d) = calc.max(0.35, rank(level-dist, d, sz.level-dist)
    * calc.pow(shrink, calc.max(0.0, d - 1)))
  // `clearance: 0` — the table's own value — asks for TikZ's spacing to the
  // letter: `level distance` is measured CENTRE to CENTRE, with nothing added
  // for the two nodes' sizes, and the ranks are then as close as the library
  // draws them. Name a clearance and sprig's safety valve comes back: the ring
  // is pushed out until no two neighbours touch.
  let snug = clearance <= 0.0

  // ---- one pass, top down: the wedge every subtree is bought ------------
  // A concept sits in the MIDDLE of the wedge its parent gave it, and that
  // wedge is then divided among its own children in proportion to the leaves
  // they carry. Nothing else is needed to keep a deep tree open: the sides of
  // a wedge are the two lines no part of that subtree may cross, because
  // every member of it was placed inside it in turn.
  let edges-of(a, b) = (a: a, b: b, col: b.col)
  let arrange(t, p, bearing, wedge, col) = {
    let me = (p: (p.at(0) + t.b.dx, p.at(1) + t.b.dy), t: t, a: bearing,
      col: if t.b.colour != auto { t.b.colour } else { col })
    let kids = t.kids
    let nk = kids.len()
    if nk == 0 { return ((me,), ()) }
    let tot = kids.map(k => k.wt).sum()
    // ANGLE PER LEAF. The ring is shared out by weight, but never finer than
    // `min-angle`: below that a leaf is a slot too narrow for any word, and
    // the honest answer is a fan wider than 360deg — which is what TikZ's own
    // `sibling angle` gives you, and why a big mind map is drawn with `x=0.8`.
    let unit = if spin != auto { siba(t.depth) / 1deg }
      else if sibling-angle != auto { calc.abs(sibling-angle) / 1deg }
      else { calc.max(calc.abs(min-angle) / 1deg,
        calc.abs(wedge) / 1deg / calc.max(1, tot)) }
    // The radius a rank has to sit at so that no two of its neighbours
    // touch: two boxes `dθ` apart, on a circle of radius r, are 2r·sin(dθ/2)
    // apart, and they need half of each's width plus the clearance. Solving
    // for r is the whole rule — the cone test this first used asked a LEAF to
    // fit inside its own wedge and flung a deep tree three times too far out.
    let rmin = {
      let out = 0.0
      for j in range(calc.max(0, nk - 1)) {
        let p1 = kids.at(j)
        let p2 = kids.at(calc.rem(j + 1, nk))
        let dth = unit * (calc.max(1, p1.wt) + calc.max(1, p2.wt)) / 2 * 1deg
        let wsum = calc.max(p1.w, p1.h) / 2 + calc.max(p2.w, p2.h) / 2 + clearance
        out = calc.max(out, wsum / (2 * calc.sin(calc.max(1.5deg, dth / 2))))
      }
      out
    }
    let node-out = (me,)
    let edges = ()
    let acc = 0
    let run = 0.0
    let spread-e = kids.map(k => k.ex).sum() + sibling-dist * (nk - 1)
    for (j, k) in kids.enumerate() {
      let kk = calc.max(1, k.wt)
      let kcol = if k.depth == 1 { _hue(palette, j) } else { col }
      if cyclic {
        // The fan is CENTRED on the concept's own bearing, so a subtree
        // always opens outward along the line it lies on itself.
        let step = unit * kk * 1deg
        // `clockwise from=` / `counterclockwise from=`: the FIRST child sits on
        // `start` itself and the rest follow at the rank's sibling angle,
        // instead of the rank being centred on the bearing. Below the root the
        // fan still opens about its own parent's ray, so a subtree points out
        // the way `grow cyclic` turns it.
        let base = if spin != auto and t.depth == 0 { start }
                   else if spin != auto { bearing - sg * wedge / 2 }
                   else { bearing - sg * wedge / 2 + sg * 1deg * unit * tot / 2 }
        let a = if spin != auto { base + sdir * sg * 1deg * unit * acc }
                else { bearing + sg * 1deg * unit * (acc + kk / 2 - tot / 2) }
        let grow2 = (calc.max(t.w, t.h) + calc.max(k.w, k.h)) / 2
        let want = rmin
        let d = if k.b.dist != auto { cm(k.b.dist) } else if snug { ld(k.depth) }
                else { calc.max(ld(k.depth), want) + grow2 }
        let aa = if k.b.angle != auto { k.b.angle } else { a }
        let q = (me.p.at(0) + d * calc.cos(aa), me.p.at(1) + d * calc.sin(aa))
        let sub = arrange(k, q, aa, step, kcol)
        let sn = sub.at(0)
        node-out = node-out + sn
        // ONE logical line: a continuation may not open with `+`.
        edges = (edges + (edges-of(me, sn.at(0)),)) + sub.at(1)
        acc += kk
      } else {
        // The ranks line up along a line: each child is handed a BAND across
        // the axis as wide as its subtree reaches, and centres itself in it.
        let base = if grow == "down" or grow == "up" { me.p.at(0) } else { me.p.at(1) }
        let mid = base - spread-e / 2 + run + k.ex / 2
        run += k.ex + sibling-dist
        let d = if k.b.dist != auto { cm(k.b.dist) } else {
          calc.max(ld(k.depth), (along(t) + along(k)) / 2 + clearance)
        }
        let q = if grow == "right" { (me.p.at(0) + d, mid) }
                else if grow == "left" { (me.p.at(0) - d, mid) }
                else if grow == "up" { (mid, me.p.at(1) + d) }
                else { (mid, me.p.at(1) - d) }
        let sub = arrange(k, q, calc.atan2(q.at(1) - me.p.at(1),
          q.at(0) - me.p.at(0)), wedge, kcol)
        let sn = sub.at(0)
        node-out = node-out + sn
        edges = (edges + (edges-of(me, sn.at(0)),)) + sub.at(1)
      }
    }
    (node-out, edges)
  }
  let laid = arrange(tree, (0.0, 0.0), start,
    if sibling-angle != auto {
      calc.abs(sibling-angle) * calc.max(1, tree.kids.map(k => k.wt).sum())
    } else { spread }, rgb("#0B3C7A"))
  let nds = laid.at(0)
  let eds = laid.at(1)
  let hub = nds.at(0)

  // ---- the canvas --------------------------------------------------------
  let boxes = nds.map(x => (x.p.at(0) - x.t.w / 2, x.p.at(0) + x.t.w / 2,
    x.p.at(1) - x.t.h / 2, x.p.at(1) + x.t.h / 2))
  let pad = 0.55
  let x0 = calc.min(..boxes.map(b => b.at(0))) - pad
  let x1 = calc.max(..boxes.map(b => b.at(1))) + pad
  let y0 = calc.min(..boxes.map(b => b.at(2))) - pad
  let y1 = calc.max(..boxes.map(b => b.at(3))) + pad
  let W = x1 - x0
  let Hh = y1 - y0
  let flip = Hh * 1cm
  let P(p) = (p.at(0) - x0, p.at(1) - y0)

  // Where a ray leaving a concept's centre meets its outline. A concept is a
  // SHAPE round words rather than a card with a stalk pinned to its corner,
  // so this is the box's rim — good enough for an ellipse, exact for a box,
  // and a couple of millimetres either way under a filled outline.
  // Two points set a `corner` back from a corner, towards its two neighbours.
  let bend(q, i, o, corner) = {
    let li = calc.max(0.001, calc.sqrt(calc.pow(i.at(0) - q.at(0), 2)
      + calc.pow(i.at(1) - q.at(1), 2)))
    let lo = calc.max(0.001, calc.sqrt(calc.pow(o.at(0) - q.at(0), 2)
      + calc.pow(o.at(1) - q.at(1), 2)))
    let r = calc.min(corner, calc.min(li, lo) * 0.44)
    ((q.at(0) + (i.at(0) - q.at(0)) / li * r, q.at(1) + (i.at(1) - q.at(1)) / li * r),
     (q.at(0) + (o.at(0) - q.at(0)) / lo * r, q.at(1) + (o.at(1) - q.at(1)) / lo * r))
  }
  let face(c, hw, hh) = {
    if grow == "right" { (c.at(0) + hw, c.at(1)) }
    else if grow == "left" { (c.at(0) - hw, c.at(1)) }
    else if grow == "up" { (c.at(0), c.at(1) + hh) }
    else { (c.at(0), c.at(1) - hh) }
  }
  let face-to(c, hw, hh) = {
    if grow == "right" { (c.at(0) - hw, c.at(1)) }
    else if grow == "left" { (c.at(0) + hw, c.at(1)) }
    else if grow == "up" { (c.at(0), c.at(1) - hh) }
    else { (c.at(0), c.at(1) + hh) }
  }
  let rim(c, q, hw, hh) = {
    let dx = q.at(0) - c.at(0)
    let dy = q.at(1) - c.at(1)
    let sx = if calc.abs(dx) > 1e-6 { hw / calc.abs(dx) } else { 1e9 }
    let sy = if calc.abs(dy) > 1e-6 { hh / calc.abs(dy) } else { 1e9 }
    let k = calc.min(1.0, calc.min(sx, sy))
    (c.at(0) + dx * k, c.at(1) + dy * k)
  }

  box(width: W * 1cm, height: Hh * 1cm, {
    // ---- the branches, under every concept ------------------------------
    for e in eds {
      // Concepts face each other along the growth axis when the map is
      // stacked, and look at each other across the ring when it is not.
      let a = if cyclic { rim(e.a.p, e.b.p, e.a.t.w / 2, e.a.t.h / 2) }
              else { face(e.a.p, e.a.t.w / 2, e.a.t.h / 2) }
      let b = if cyclic { rim(e.b.p, e.a.p, e.b.t.w / 2, e.b.t.h / 2) }
              else { face-to(e.b.p, e.b.t.w / 2, e.b.t.h / 2) }
      let vx = b.at(0) - a.at(0)
      let vy = b.at(1) - a.at(1)
      let ra = calc.max(0.08, calc.sqrt(calc.pow(a.at(0) - e.a.p.at(0), 2)
        + calc.pow(a.at(1) - e.a.p.at(1), 2)))
      let rb = calc.max(0.08, calc.sqrt(calc.pow(b.at(0) - e.b.p.at(0), 2)
        + calc.pow(b.at(1) - e.b.p.at(1), 2)))
      let ln = calc.max(0.001, calc.sqrt(vx * vx + vy * vy))
      let path = if cyclic {
        let bow = curve * ln
        (a, (a.at(0) + vx / 2 - vy / ln * bow, a.at(1) + vy / 2 + vx / ln * bow), b)
      } else {
        // `edge from parent fork down`, to the letter: out of the face the
        // growth points at, a fixed step along the axis, ACROSS to the
        // child's line, then in. The corner of the turn is on the PARENT's
        // dropped line, not halfway — a fixed 8pt is what keeps a fork
        // looking like a fork when the child is a long way off.
        let ux = if grow == "right" { 1.0 } else if grow == "left" { -1.0 } else { 0.0 }
        let uy = if grow == "down" { -1.0 } else if grow == "up" { 1.0 } else { 0.0 }
        // The step down is fixed, but it can never be more than HALF the air
        // between the two faces: a fork whose drop overshoots the child's own
        // line comes back on itself, and the corner turns into a knot.
        let avail = if grow == "right" or grow == "left" { calc.abs(b.at(0) - a.at(0)) }
                    else { calc.abs(b.at(1) - a.at(1)) }
        // …and it leaves a hair of air at the end: with a drop that lands
        // EXACTLY on the child's line the last segment has zero length, the
        // smoothing overshoots it, and the corner turns into a knot.
        let run = calc.max(0.0, calc.min(
          if fork != auto { cm(fork) } else { 0.5 * ld(e.b.t.depth) },
          avail / 2 - 0.06))
        let q1 = (a.at(0) + ux * run, a.at(1) + uy * run)
        let q2 = if grow == "right" or grow == "left" { (q1.at(0), b.at(1)) }
                 else { (b.at(0), q1.at(1)) }
        // The two corners are CHAMFERD, not smoothed: a Catmull-Rom run over
        // a right angle overshoots it and the ribbon curls into a knot,
        // which is exactly what the first renders of this showed above every
        // parent. Rounding the corner by hand costs four points and gives a
        // fork that bends instead of looping.
        let (c1a, c1b) = bend(q1, a, q2, corner)
        let (c2a, c2b) = bend(q2, q1, b, corner)
        (a, c1a, c1b, c2a, c2b, b)
      }
      let w0 = cm(branch-weight) * calc.pow(taper, e.b.t.depth - 1)
      let smooth = if cyclic { 16 } else { 0 }
      let col = if prt { rgb("#4A4A4A") } else { e.col }
      let pcol = if prt { rgb("#4A4A4A") } else { e.a.col }
      if not cyclic {
        // A fork is drawn with the PEN, as `edge from parent fork down` does:
        // no bar, no taper — two turns of a rounded join and that is all.
        place(top + left, _lines((path.map(q => P(q)),), flip: flip,
          stroke: (paint: col, thickness: weight), closed: false))
      } else if cm(curve) > 0 or rough {
        // sprig's own stalk, for a bowed or hand-drawn map: a ribbon that
        // tapers from `branch-weight` to `line-tip` of it, with a pale core.
        let body = _stalk-path(path.map(q => P(q)), w0, w0 * line-tip,
          smooth: smooth)
        if body.len() > 3 {
          place(top + left, _fill((body,), flip: flip, fill: col))
          if not prt and fill != false {
            let core = _stalk-path(path.map(q => P(q)), w0 * 0.40,
              w0 * line-tip * 0.40, smooth: smooth)
            place(top + left, _fill((core,), flip: flip,
              fill: white.transparentize(78%)))
          }
        }
      } else {
        // ---- `circle connection bar`, from tikzlibrarymindmap.code.tex -----
        // A bar of CONSTANT thickness — 0.175 × the smaller of the two disc
        // radii, the decoration's `amplitude` — whose ends swell along
        // `segment angle` of each disc and weld onto its rim: the fillet is a
        // cubic from the rim, its controls a quarter-radius along the tangent
        // and 1.25 radii along the bar, meeting the bar at 1.5 radii out. The
        // bar is FILLED and never stroked. pgf draws the middle as a plain
        // rectangle from half a radius to half a radius, which is why a long
        // branch is a bar, not a lens.
        let ax = e.a.p.at(0)
        let ay = e.a.p.at(1)
        let vx = e.b.p.at(0) - ax
        let vy = e.b.p.at(1) - ay
        let dd = calc.max(0.05, calc.sqrt(vx * vx + vy * vy))
        let ux = vx / dd
        let uy = vy / dd
        let amp = calc.max(0.025, cm(bar-thick) * calc.min(ra, rb))
        let aa = calc.abs(bar-angle)
        let g2(x, y) = P((ax + x * ux - y * uy, ay + x * uy + y * ux))
        let flr(r, sgn, x0, dir) = {
          let p0x = x0 + dir * r * calc.cos(aa)
          let p0y = sgn * r * calc.sin(aa)
          range(7).map(i => {
            let t = i / 6
            let s = 1 - t
            let c1x = p0x + dir * 0.25 * r * calc.sin(aa)
            let c1y = sgn * (r * calc.sin(aa) - 0.25 * r * calc.cos(aa))
            let c2x = x0 + dir * 1.25 * r
            let c2y = sgn * amp / 2
            let p1x = x0 + dir * 1.5 * r
            let p1y = sgn * amp / 2
            g2(s*s*s*p0x + 3*s*s*t*c1x + 3*s*t*t*c2x + t*t*t*p1x,
               s*s*s*p0y + 3*s*s*t*c1y + 3*s*t*t*c2y + t*t*t*p1y)
          })
        }
        let arc(r, x0, dir) = range(6).map(i => {
          let t = -aa + 2 * aa * i / 5
          g2(x0 + dir * r * calc.cos(t), dir * r * calc.sin(t))
        })
        let weldA = arc(ra, 0.0, 1.0) + flr(ra, 1.0, 0.0, 1.0) + (g2(1.5 * ra, -amp / 2),) + flr(ra, -1.0, 0.0, 1.0).rev()
        let weldB = arc(rb, dd, -1.0) + flr(rb, 1.0, dd, -1.0) + (g2(dd - 1.5 * rb, -amp / 2),) + flr(rb, -1.0, dd, -1.0).rev()
        let xa = 1.5 * ra - 0.02
        let xb = dd - 1.5 * rb + 0.02
        let body = (g2(xa, -amp / 2), g2(xb, -amp / 2), g2(xb, amp / 2),
          g2(xa, amp / 2))
        if xb <= xa + 0.02 {
          // When the discs nearly touch, the two rounded welds overlap. Filling
          // them separately can leave a star-shaped seam under a separator.
          // Use a straight core instead: the discs, drawn later, hide its ends.
          let short-bar = (g2(0.0, -amp / 2), g2(dd, -amp / 2),
            g2(dd, amp / 2), g2(0.0, amp / 2))
          if not shade-branch or pcol == col {
            place(top + left, _fill((short-bar,), flip: flip, fill: pcol))
          } else {
            let nshort = calc.min(72, calc.max(3, dd / 0.05))
            for i in range(72) {
              if i >= nshort { continue }
              let x0b = dd * i / nshort
              let x1b = dd * (i + 1) / nshort
              place(top + left, _fill(((g2(x0b - 0.012, -amp / 2),
                g2(x1b + 0.012, -amp / 2), g2(x1b + 0.012, amp / 2),
                g2(x0b - 0.012, amp / 2)),), flip: flip,
                fill: mixc(pcol, col,
                  if dd > 0.001 { (x0b + x1b) / 2 / dd } else { 0.5 })))
            }
          }
        } else if not shade-branch or pcol == col {
          place(top + left, _fill((weldA, body, weldB), flip: flip, fill: pcol))
        } else {
          // the shade, as the library builds it: solid caps at the two discs
          // in their own colours, the run of colour only BETWEEN them
          // whole slabs, about 5 mm each, at most 72 of them: `range` wants
          // integers, so the count is compared against the seventy-two
          // instead of being handed to it as a rounded length
          let ns = calc.min(72, calc.max(3, (xb - xa) / 0.05))
          for i in range(72) {
            if i >= ns { continue }
            let x0b = xa + (xb - xa) * i / ns
            let x1b = xa + (xb - xa) * (i + 1) / ns
            place(top + left, _fill(((g2(x0b - 0.012, -amp / 2),
              g2(x1b + 0.012, -amp / 2), g2(x1b + 0.012, amp / 2),
              g2(x0b - 0.012, amp / 2)),), flip: flip,
              fill: mixc(pcol, col,
                if dd > 0.001 { (x0b + x1b) / 2 / dd } else { 0.5 })))
          }
          place(top + left, _fill((weldA,), flip: flip, fill: pcol))
          place(top + left, _fill((weldB,), flip: flip, fill: col))
        }
      }
    }

    if separators != false {
      // `circle separators`: the small ring a branch passes through on its way
      // out of the root, so the root reads as a plate the branches grow
      // through rather than a box they are glued to.
      for x in nds {
        if x.t.depth != 1 { continue }
        // The ring sits ON the branch: a fixed step out from the root's rim
        // along the ray to its concept, wherever that concept turned out to
        // be. A share of the distance instead — as here first — let a nearby
        // concept strand its own separator in mid-air.
        let f = rim(hub.p, x.p, hub.t.w / 2, hub.t.h / 2)
        let rx = x.p.at(0) - hub.p.at(0)
        let ry = x.p.at(1) - hub.p.at(1)
        let rl = calc.max(0.001, calc.sqrt(rx * rx + ry * ry))
        let c = P((f.at(0) + rx / rl * 0.34, f.at(1) + ry / rl * 0.34))
        let ring = _circle-pts(c, 0.17, n: 30)
        place(top + left, _fill((ring,), flip: flip, fill: white))
        place(top + left, _lines((ring + (ring.at(0),),), flip: flip,
          stroke: (paint: if prt { rgb("#333333") } else { x.col.darken(24%) },
            thickness: 0.8pt)))
      }
    }

    // ---- the concepts ----------------------------------------------------
    for (xi, x) in nds.enumerate() {
      let t = x.t
      let b = t.b
      let d = t.depth
      let col = x.col
      // `fill` is the library's own `fill` key: `true` paints the disc in the
      // concept colour at the level's `tint`, `false` leaves an outline, and a
      // colour is that colour.
      let wash = if fill == false or prt { none }
        else if d == 0 { if root-fill != auto { root-fill } else { col.darken(6%) } }
        else if fill == auto or fill == true { col.lighten(tint + (d - 1) * tint-step) }
        else { fill }
      let edge = if d == 0 {
        if root-ink != auto { root-ink }
        else if prt { black } else { col.darken(24%) }
      } else if prt { rgb("#333333") } else { col.darken(12%) }
      let txt = if d == 0 {
        if root-text != auto { root-text }
        else if prt { black }
        else if luma(if wash == none { white } else { wash }).components().first() > 58% {
          col.darken(60%)
        } else { white }
      } else if prt { black } else { ink-on(wash, col) }
      let sty = if b.shape != auto { b.shape } else { shp }
      place(top + left,
        dx: (x.p.at(0) - t.w / 2 - x0) * 1cm,
        dy: (Hh - (x.p.at(1) + t.h / 2 - y0)) * 1cm,
        box(width: t.w * 1cm, height: t.h * 1cm, {
          _leaf-draw(sty, t.w, t.h, calc.min(t.w, t.h) * 0.22,
            fill: wash, stroke-paint: edge, weight: weight, hand: hd,
            seed: seed + xi * 23, roughness: roughness, bowing: 0.6,
            shadow: if shadow and d == 0 { rgb("#00000022") } else { none })
          place(top + left,
            box(width: t.w * 1cm, height: t.h * 1cm,
              align(center + horizon,
                text(size: if d == 0 { 1.05em }
                  else { 1em * calc.pow(scale, d - 1) },
                  fill: txt, dir: bdir, stack-of(b)))))
        }))
    }
  })
}

// -----------------------------------------------------------------------------
//  buzan — the keyword on the branch
// -----------------------------------------------------------------------------

/// A Buzan map: no cards and no grid — the WORD is the branch.
///
/// The rules a hand-drawn mind map follows, which is what this draws: one
/// keyword per branch, written *on* the stroke and not beside it; the stroke a
/// marker line, thick where it leaves the centre and narrowing to a point past
/// the word; every rank thinner, shorter and smaller-typed than the one above
/// it; a branch's children forking from the TAIL of its word, in a Y; a
/// picture at the tip, where the meaning is; and a cloud, not a box, at the
/// centre.
///
///   hub            the centre's words, inside the cloud
///   ..branches     `branch(..)` values, or plain content for a bare keyword
///
///   start, spread  where the fan opens, and how far round it runs
///   dist           the free length of a stroke: how much of it is a line, as
///                  opposed to the words sitting on it. `dist-step` shortens
///                  it at every rank, which is what makes the map close in
///                  towards its twigs
///   gap            the least air between two words of one rank
///   knot           a rank-one stroke's thickness as a share of its words'
///                  height — above 1, the words are written ON the colour;
///                  below, the stroke underlines them
///   taper          how much thinner each deeper rank is, and how much a
///                  stroke narrows from its base to its tip
///   bow            one swing across the whole stroke — 0 is the ruler. Rank
///                  one all swing the same way, which is the swirl of a drawn
///                  map; a deeper rank swings away from the branch it forks
///                  from, which is what opens a Y. Keep it small (0,05): the
///                  hand in a Buzan map is NOT a compass arc, and a keyword set
///                  on a bow stops lying along its own stroke
///   wave, wave-step
///                  the undulation of a stroke: how far the line wanders off
///                  straight, as a share of its OWN thickness — so a rank-one
///                  marker of 3,4 mm and a rank-three pen line of 0,6 mm wander
///                  by a fifth of what they are wide, which is the same wrist —
///                  and `wave-step`, the length of one undulation in cm (a fat
///                  stroke is stretched to 8 times its thickness at least, so it
///                  reads as a line that wavers and not as a band that swells).
///                  Both ends stay on the ray whatever these say
///   angle-label    turn the words with their stroke; `false` leaves them
///                  level at the tip, and the stroke becomes an underline
///   label-at       where the word sits. `"stroke"` (the default) centres it ON
///                  its stroke, as a drawn map does. `"tip"` ends the stroke at
///                  the branch's `icon:` and writes the word PAST the dot, which
///                  is how a hand labels the end of a line: a dot at the tip,
///                  then the idea. The row — dot, gap, word — is what the branch
///                  is measured by, so a long label still buys its own share of
///                  the fan and the neighbours still dodge it.
///   label-width    the width of the word alone: `auto` lets it hug its letters,
///                  a LENGTH wraps it to that width and the row is that wide.
///                  A branch may overrule the map with the width it already
///                  carries, `branch(width: 2.4cm)` — one knob, two levels.
///   min-width, max-width, min-height, max-height
///                  optional bounds on each branch's measured label row;
///                  branch-level bounds override these map-wide limits
///   label-box      `"none"` writes the word bare, as a keyword always is here;
///                  `"draw"` gives the word a leaf contour of its own, the shape
///                  a ribbon band asks for when labels must line up. Only the
///                  word is boxed, never the dot, or the tip reads as a cartouche
///   label-shape    that contour — a key of `sprig-shapes`, or a function
///   label-pad      the air between the word and the box drawn around it
///   shrink         how much smaller the words get at every rank
///   pad            the air inside a keyword's own box
///   a small line   a branch given BOTH a title and a plain body writes that
///                  body under the keyword, as a hand adds a date or a name:
///                  `branch([j+1, j+7], title: [répétition])` — the body is the
///                  positional content, since `branch` takes no `body:`
///   upper          capitals for every word of the map, the small line too
///   size           one scale for the whole map's words
///   leaf-ink       `auto` takes the branch's colour darkened until it reads
///                  as ink; a colour inks every word; `black` is the pen-only
///                  map, where the colour stays on the stroke alone
///   hub-shape      the centre's outline: `"cloud"`, the default, is a broad,
///                  rounded contour; `"cumulus"` selects the procedural
///                  `sprig-cloud` variant and its `hub-*` controls. Any other
///                  key of `sprig-shapes` or a `(w, h, r) => contour` function
///                  can be the hub instead
///   hub-puffs, hub-squash, hub-bump, hub-lump, hub-tilt
///                  the procedural `cumulus` cloud's knobs, handed to
///                  `sprig-cloud`: how many lobes — a FRACTION is legal —, how
///                  flat the belly is, the depth of the pinches, lobe variation,
///                  and the tilt. They do nothing to other hub shapes, which
///                  keep the contour of their own shape definition.
///   hub-ratio, hub-pad
///                  the hub's width-to-height ratio and the air between its
///                  edge and the words inside it
///   hub-fill, hub-text, hub-icon
///                  the hub's colour, its words' colour, and a picture over
///                  them
///   palette        one colour per rank-one branch — its children keep it
///   shade          how far the marker runs out: the stroke is darkest where it
///                  leaves the centre and lightened by this much at its tip —
///                  one flat ribbon is what made a branch look stuck on rather
///                  than drawn. `0%` is a flat colour, and `theme: "print"` is.
///   fit            `true` and `100%` scale the map DOWN to the room it is
///                  given — its width, and its height too when that is a fixed
///                  one — and never up; a LENGTH (`17cm`) makes it exactly that
///                  wide, growing when it has to. A fan is sized by the words it
///                  has to write, not by the page, so this is what keeps the
///                  last keyword off the edge of the sheet.
///   theme, dir, body-align
///                  `"print"` for paper, `rtl` for a mirrored fan, `body-align`
///                  to overrule the direction
///   weight, shadow the rule round the centre, and a soft drop under it
///   rough, hand, roughness, seed
///                  the drawn-by-hand CENTRE: a stroke is an aplat with no
///                  outline to tremble, so a BRANCH's hand is in `bow` and
///                  `taper` instead — `rough` shakes the cloud, not the rays
///   stroke-engine  `"nibart"` for nibart's variable-pen stroke, `"native"`
///                  for the original ribbon renderer; degenerate paths also
///                  fall back to the native renderer
///   pad            the air inside a keyword's own box
///
/// On the branch, where every `branch(..)` already carries the key:
///   angle          PIN the direction, in degrees: the ray is taken as given and
///                  claims no share of the fan (the rest still split the fan
///                  between them), but a pinned ray counts as a neighbour, so
///                  the words keep dodging it
///   spread         the fan under a pinned branch, for its own children
///   dx, dy         nudge where the branch starts, in centimetres
///   a small line   a branch given BOTH a title and a plain body writes that
///                  body under the keyword, as a hand adds a date or a name:
///                  `branch([j+1, j+7], title: [répétition])` — the body is the
///                  positional content, since `branch` takes no `body:`
///
/// The share of the circle a branch is handed is bought by the STROKE it will
/// take — the free line, the word, the run-out past it — itself and under it:
/// five twigs of one word each do not want the room of one long phrase. A word
/// too wide for the wedge it was given is pushed out along its own ray, as far
/// as its NEAREST neighbour needs and no further — and never past the parent's
/// own tail: dodging a neighbour may lengthen a stroke, it may not unstick a
/// twig from the tip it grew at.
///
/// A branch that carries no children runs its stroke out to a point, as a
/// lifted pen does; one that carries a brood ends flat, where the Y opens.
#let buzan(
  root,
  ..branches,
  start: 90deg,
  spread: 360deg,
  min-angle: 15deg,
  dist: 0.7,
  dist-step: 0.8,
  taper: 0.6,
  knot: 0.8,
  bow: 0.05,
  wave: 0.16,
  wave-step: 2.2,
  angle-label: true,
  label-at: "stroke",
  label-width: auto,
  min-width: auto,
  max-width: auto,
  min-height: auto,
  max-height: auto,
  label-box: "none",
  label-shape: "round",
  label-pad: 0.12,
  shade: 18%,
  fit: auto,
  shrink: 0.84,
  pad: 0.12,
  gap: 0.5,
  upper: false,
  size: 1.0,
  leaf-ink: auto,
  hub-shape: "cloud",
  hub-ratio: 1.25,
  hub-pad: 0.5,
  hub-puffs: 11.4,
  hub-squash: 0.62,
  hub-bump: 3.2,
  hub-lump: 0.25,
  hub-tilt: 0deg,
  hub-fill: auto,
  hub-text: auto,
  hub-icon: none,
  palette: "poster",
  theme: auto,
  dir: auto,
  body-align: auto,
  weight: 0.9pt,
  shadow: false,
  rough: false,
  hand: none,
  roughness: 1.0,
  stroke-engine: "nibart",
  seed: 7,
) = context {
  if stroke-engine != "nibart" and stroke-engine != "native" {
    panic("buzan: stroke-engine must be \"nibart\" or \"native\"")
  }
  let items = branches.pos().map(b =>
    if type(b) == dictionary and "body" in b { b } else { branch(b) })
  let prt = theme == "print"
  let r2l = if dir != auto { dir == rtl } else { text.dir == rtl }
  let bdir = if r2l { rtl } else { ltr }
  let bal = if r2l { right } else { left }
  let hd = if rough { if hand != none { hand } else { "roughjs" } } else { none }
  let cm(v) = _cm(v)
  let map-minw = _limit(min-width)
  let map-maxw = _limit(max-width)
  let map-minh = _limit(min-height)
  let map-maxh = _limit(max-height)
  let sgn(x) = if x >= 0 { 1.0 } else { -1.0 }
  let colx(x) = if type(x) == str { rgb(x) } else { x }
  let say(t) = if upper { _caps(t) } else { t }
  let words-of(b) = if b.title != none { b.title } else { b.body }

  // ---- the words, measured ------------------------------------------------
  // A keyword's box is this layout's only currency: the share of the circle a
  // branch is handed, the length of its stroke and the room its children get
  // are all bought with widths measured here, once.
  let fs(d) = 1em * size * calc.pow(shrink, d)
  let kids-of(b) = {
    let k = b.children
    if type(k) == dictionary { (k,) } else if type(k) == array { k } else { () }
  }
  // THE ONE WIDTH KNOB, read at two levels: `label-width` for the map, the
  // width a branch already carries for that branch. `auto` hugs the words.
  let lw-of(b) = {
    let v = if b.width != auto and b.width != none { b.width } else { label-width }
    if v == auto or v == none { none } else { v }
  }
  // the CENTRE is not a label: `label-width` wraps what hangs at the end of a
  // stroke, and the hub is the thing the strokes hang from — wrapping it to a
  // band's width would fold the title into four lines and inflate the shape
  let label-content(b, d, fill: auto) = {
    if fill == auto { text(size: fs(d), dir: bdir, say(words-of(b))) }
    else { text(size: fs(d), fill: fill, dir: bdir, say(words-of(b))) }
  }
  let mk-label(b, d, fill: auto, root: false, width: auto) = {
    if root { return(text(size: fs(d), fill: if fill == auto { black } else { fill },
      dir: bdir, say(words-of(b)))) }
    let kw = label-content(b, d, fill: fill)
    let legacy = lw-of(b)
    let lw = if width != auto { width } else { legacy }
    // a tip's word hangs past the dot — left-aligned (right for RTL) in its
    // own width so the dot and the first letter are only the `0.1cm` gutter
    // apart, not half the box. Banner is vertical: centred above leaf.
    let la = if hub-shape == "banner" and label-at == "tip" {
      center
    } else if label-at == "tip" { bal } else { center }
    if lw != none { box(width: cm(lw) * 1cm, inset: 0pt, align(la, kw)) } else { kw }
  }
  let meas(b, d, root: false) = {
    let rawkw = label-content(b, d)
    let ic = b.icon
    let rawm = measure(box(inset: 0pt, rawkw))
    let im = if ic != none { measure(ic) } else { none }
    let rawlabw = rawm.width / 1cm
    let iw = if im != none { im.width / 1cm } else { 0.0 }
    let is-banner-tip = hub-shape == "banner" and label-at == "tip" and ic != none
    let icon-extra = if im == none or is-banner-tip { 0.0 } else { iw + 0.1 }
    let note = if b.title != none and b.body != none and b.body != [] { b.body } else { none }
    let note-content = if note != none {
      text(size: 0.78 * fs(d), dir: bdir, say(note))
    } else { none }
    let raw-note = if note-content != none { measure(note-content) } else { none }
    let legacy = if root { none } else { lw-of(b) }
    let local-minw = _limit(b.at("min-width", default: auto), fallback: map-minw)
    let local-maxw = _limit(b.at("max-width", default: auto), fallback: map-maxw)
    let local-minh = _limit(b.at("min-height", default: auto), fallback: map-minh)
    let local-maxh = _limit(b.at("max-height", default: auto), fallback: map-maxh)
    let minw = if local-minw == none { 0.0 } else { local-minw }
    let minh = if local-minh == none { 0.0 } else { local-minh }
    let bounded = not root and (legacy != none or local-minw != none or local-maxw != none or local-minh != none or local-maxh != none)
    let raw-note-w = if raw-note != none { raw-note.width / 1cm } else { 0.0 }
    let natural = calc.max(rawlabw, raw-note-w)
    let legacy-w = if legacy != none { cm(legacy) } else { natural + 0.02 }
    let maxw = if local-maxw != none { local-maxw }
      else { calc.max(minw, legacy-w + icon-extra + 2 * pad) }
    let minlab = calc.max(0.2, minw - icon-extra - 2 * pad)
    let maxlab0 = calc.max(0.2, maxw - icon-extra - 2 * pad)
    let maxlab = if legacy != none { calc.min(maxlab0, legacy-w) } else { maxlab0 }
    let startlab = if legacy != none { calc.min(maxlab, legacy-w) }
      else { calc.max(minlab, calc.min(maxlab, rawlabw + 0.02)) }
    let row-at(w, build: false) = {
      let labw = if bounded { calc.max(0.2, calc.min(maxlab,
        calc.max(minlab, w - icon-extra - 2 * pad))) }
        else { rawlabw }
      let kw = if bounded { box(width: labw * 1cm, inset: 0pt,
        align(center, rawkw)) } else { rawkw }
      let m = measure(box(inset: 0pt, kw))
      let note-m = if note-content != none {
        if bounded { measure(box(width: labw * 1cm, note-content)) }
        else { raw-note }
      } else { none }
      let label-w = if is-banner-tip { calc.max(m.width / 1cm, iw) }
        else { m.width / 1cm + icon-extra }
      let label-h = if is-banner-tip {
        m.height / 1cm + (if im != none { im.height / 1cm + 0.08 } else { 0.0 })
      } else { calc.max(m.height / 1cm, if im != none { im.height / 1cm } else { 0.0 }) }
      let total-w = calc.max(label-w, if note-m != none { note-m.width / 1cm } else { 0.0 }) + 2 * pad
      let total-h = label-h + pad * 0.7 + (if note-m != none { note-m.height / 1cm + 0.04 } else { 0.0 })
      (w: total-w, h: total-h, labw: labw,
       note-width: if bounded and note-m != none { labw } else { none })
    }
    let note0 = if note != none { note } else { none }
    let m0 = if not bounded { row-at(rawlabw + icon-extra + 2 * pad) }
      else { row-at(startlab + icon-extra + 2 * pad) }
    let size = if bounded {
      _fit-dimensions(m0.w, minw, maxw, minh, local-maxh,
        w => row-at(w).h, what: "buzan branch at rank " + str(d))
    } else { (w: m0.w, h: m0.h) }
    let final = if bounded { row-at(size.w) } else { m0 }
    (b: b, depth: d, w: size.w, h: size.h,
      note: note0, icon: ic, kw: if bounded {
        mk-label(b, d, width: final.labw)
      } else { mk-label(b, d) },
      labw: final.labw, note-width: final.note-width, iw: iw,
      kids: kids-of(b).map(k => meas(k, d + 1)))
  }
  let hub-t = meas((body: root, title: none, icon: hub-icon, colour: auto,
    shape: auto, angle: auto, dist: auto, width: auto, dx: 0.0, dy: 0.0,
    children: items, children-at: auto, spread: auto, child-dist: auto,
    child-width: auto), 0, root: true)

  // the cloud's own outline, and how far its rim is in a given direction
  let hub-w0 = calc.max(hub-t.w, 1.6) * calc.max(1.0, hub-ratio * 0.85) + 2 * hub-pad
  let hub-h0 = hub-t.h + 2 * hub-pad
  // the cloud is not a box: its lumps stand proud of the ellipse they are drawn
  // on, and on a wide hub they stand proud of the WORDS too, which is what made
  // a keyword poke out of the sides of its own shape. So the contour is built
  // once at the words' box, measured, and the box grown to it — capped at twice
  // the words on each axis, so a `hub-puffs` of 3 and a fat `hub-lump` cannot
  // turn the centre of the map into a balloon. Any `hub-shape` is measured the
  // same way, which is what makes a hand-written contour safe to hand in
  let hub-sty0 = if type(hub-shape) == function { hub-shape } else if hub-shape == "cumulus" {
    sprig-cloud(seed: seed, puffs: hub-puffs, squash: hub-squash,
      bump: hub-bump, lump: hub-lump, tilt: hub-tilt)
  } else { hub-shape }
  let hub-box = {
    let q = if type(hub-sty0) == function {
      hub-sty0(hub-w0, hub-h0, calc.min(hub-w0, hub-h0) * 0.3) } else { () }
    if q.len() > 1 {
      let xs = q.map(u => u.at(0))
      let ys = q.map(u => u.at(1))
      // the cloud is free to be taller — and wider — than the box its words were
      // measured in, which is how TikZ draws one on a node of any shape: the
      // ring belongs to its own ellipse, and the hub reserves what the ring
      // takes. Capped at twice the words on each axis, so a `hub-puffs` of 3 and
      // an `arc` of 300deg cannot turn the centre of the map into a balloon
      (calc.max(hub-w0, calc.min(2.0 * hub-w0, calc.max(..xs) - calc.min(..xs))),
        calc.max(hub-h0, calc.min(2.0 * hub-h0, calc.max(..ys) - calc.min(..ys))))
    } else { (hub-w0, hub-h0) }
  }
  let hub-w = hub-box.at(0)
  let hub-h = hub-box.at(1)
  let hubrim(a) = {
    let rx = hub-w / 2
    let ry = hub-h / 2
    // not the ellipse's own rim but the box it is drawn in: a branch going
    // up must clear the cloud's width, or its words land inside the shape
    let c = calc.abs(calc.cos(a))
    let s = calc.abs(calc.sin(a))
    calc.min(rx / calc.max(0.02, c), ry / calc.max(0.02, s))
  }

  // ---- how the circle is shared --------------------------------------------
  // LEAD is the bare stroke in front of the word, and a drawn map does not pay
  // one at rank one: the keyword starts AT the centre, which is what makes the
  // colour read as the word's own body instead of a scratch left behind. Deeper
  // ranks do lead, because there the line is a stem the twig hangs off.
  let lead(d) = if d <= 1 { 0.12 } else {
    0.32 * dist * calc.pow(dist-step, d - 2) + 0.14 }
  // a tip's dot sits a little OFF the stroke — not glued to it — so the
  // stroke, the dot and the word read as three things, not as a lollipop
  let tip-gap = 0.14
  // the TAIL is where the brood opens; a tip with nothing under it still runs
  // out to a point
  let tail(t, d) = if t.kids.len() > 0 { calc.max(0.3, 0.34 * t.h + 0.3) }
                   else { calc.max(0.2, 0.28 * t.h + lead(d)) }
  let demand(t) = {
    let ws = t.kids.map(k => demand(k))
    if t.kids.len() == 0 and label-at == "tip" {
      // at a tip the row ENDS the branch — the dot, the word, and nothing past
      // it: what the branch pays for is the whole row and a hair, not the
      // lifted-pen tail a stroke running under a word would run out to
      // rank one ignores `dist` in `lead`, but a tip's free length IS `dist`,
      // plus the little air between the stroke and the dot
      let effd = if t.depth == 1 { dist } else { lead(t.depth) }
      effd + tip-gap + t.w + 0.12
    } else if t.kids.len() == 0 {
      // what a leaf needs is the STROKE it will take — the free line, the word,
      // the run-out past it — not the word alone: a long word on a short stroke
      // and a short word on a long one do not want the same share of the ring
      lead(t.depth) + t.w + tail(t, t.depth)
    } else { ws.sum() + gap * calc.max(0, t.kids.len() - 1) }
  }
  let wedges(ks, span) = {
    let n = ks.len()
    if n == 0 { () } else {
      let raw = ks.map(k => calc.max(0.001, demand(k)))
      let tot = raw.sum()
      let want = raw.map(v => calc.max(min-angle, span * (v / tot)))
      let got = want.sum()
      // if the floor pushed past the fan, the fan opens: a wedge is never
      // squashed back under it, which is what made two words share a ray
      if got > span { want } else { want.map(w => span * (w / got)) }
    }
  }

  // ---- the tree, in the plane ----------------------------------------------
  // `base` is where a stroke starts (the cloud's rim, or the tail of its
  // parent's word), `ang` is the direction it and its words take, `fan` is the
  // room left for the children at the far end, `side` is which way it bows.
  // LEAD is the bare stroke in front of the word, and a drawn map does not pay
  // one at rank one: the keyword starts AT the centre, which is what makes the
  // colour read as the word's own body instead of a scratch left behind. Deeper
  // ranks do lead, because there the line is a stem the twig hangs off.
  let grow(t, base, ang, fan, col, d, side) = {
    // `off` is the dodge push a parent adds when two neighbours would share a
    // ray: it lengthens the stroke instead of unsticking it from its tip
    let off0 = t.at("off", default: 0.0)
    // rank one normally starts at the centre (`lead` = 0.12) so the colour
    // reads as the word's body; at a tip the free length IS `dist`, otherwise
    // the stroke is a dot and the word floats past it
    let eff = if label-at == "tip" and d == 1 { dist } else { lead(d) }
    // at a tip the stroke stops BEFORE the dot — a little air between the
    // line and the pastille, so the dot is not glued to the stroke and there
    // is no left/right alignment problem
    let ln = eff + (if label-at == "tip" { 0.0 } else {
      t.w + tail(t, d) }) + off0
    let ux = calc.cos(ang)
    let uy = calc.sin(ang)
    let far = (base.at(0) + ln * ux, base.at(1) + ln * uy)
    let rib = if d == 0 { none } else {
      // rank one carries the words inside the colour; a deeper rank is a pen
      // line the words stand on, so it thins faster than the words do
      let th = calc.max(0.05, knot * t.h * calc.pow(taper, d - 1)
        * (if d >= 2 { 0.5 } else { 1.0 }))
      // The line goes for the keyword and waves on the way: `bow` is a single
      // bow (0 gives the ruler look, and the reference's rank-1 swirl is small,
      // not the arc of a compass), and `wave` is the undulation of a hand
      // dragging a marker, measured against the stroke's own thickness so a fat
      // rank and a thin one are both drawn by the same wrist
      let line = _wave-line(base, far,
        amp: wave * th, step: calc.max(wave-step, th * 8),
        arc: 0.8 * bow * ln * side,
        phase: seed * 1.7 + t.w * 2.3 + ang / 1deg * 0.07)
      // a branch that carries children ends flat, where the Y opens; one that
      // ends with its word runs out to a point, as a lifted pen does
      let end = calc.max(0.018, th * (
        if d > 1 { calc.min(0.5, taper) }
        else if t.kids.len() > 0 { 0.78 } else { calc.min(0.3, taper) }))
      // the FAT part is spent carrying the word: the taper starts where the
      // word ends, so no keyword stands on a narrowed stroke. A tip with
      // nothing on it still runs out to a point, because its tail is longer
      // than its hold
      let hd = calc.min(0.8, (eff + t.w) / calc.max(0.2, ln))
      (line, th, end, col, d, hd, ang)
    }
    // THE HUB SITS WHERE IT IS DRAWN. A branch's node is the centre of its word,
    // which is `base` plus half the row along its own ray — and the hub has a ray
    // too (`start:`), so the same arithmetic used to carry its node a couple of
    // centimetres DOWN the first branch's direction while the shape and its words
    // are drawn at the origin. The canvas is bounded by the nodes, so the top of
    // the hub — and every `hub-shape` taller than the words — was drawn OUTSIDE
    // the box the map reserved for itself, which `fit` then pushed over the edge
    // of the page: a banner lost its upper fold to a paragraph, and a radial map
    // got a whole lobe of slack on one side and none on the other. The centre of
    // the map is the centre of the map: no ray, no offset.
    let node = (x: if d == 0 { base.at(0) } else { base.at(0) + (eff + (if label-at == "tip" { tip-gap } else { 0.0 }) + t.w / 2 + off0) * ux },
      y: if d == 0 { base.at(1) } else { base.at(1) + (eff + (if label-at == "tip" { tip-gap } else { 0.0 }) + t.w / 2 + off0) * uy },
      w: t.w, h: t.h, ang: ang, col: col, depth: d, t: t,
      thick: if d == 0 { 0.0 } else {
        knot * t.h * calc.pow(taper, d - 1) * (if d >= 2 { 0.5 } else { 1.0 }) })
    let ks = t.kids
    // A branch may PIN its direction with `angle:` — how a hand puts one idea
    // exactly where it wants it. A pinned ray takes no share of the fan (the
    // rest split it between them) but it counts as a NEIGHBOUR all the same, so
    // the words keep dodging it; `spread:` on that branch decides the fan under
    // its own twigs, and `dx`/`dy` nudge its start, in centimetres.
    let pin(i) = {
      let v = ks.at(i).b.angle
      if v == auto or v == none { none } else { v }
    }
    let fre = range(ks.len()).filter(i => pin(i) == none)
    let span = if d == 0 { calc.max(spread, ks.len() * min-angle) } else {
      calc.max(fan, ks.len() * min-angle) }
    let ws = wedges(fre.map(i => ks.at(i)), span)
    let tot = if ws.len() == 0 { 0deg } else { ws.sum() }
    let angs = ()
    let fans = ()
    let acc = 0deg
    let fw = 0
    for i in range(ks.len()) {
      if pin(i) != none {
        angs.push(pin(i))
        let v = ks.at(i).b.spread
        fans.push(if v != auto and v != none { v } else {
          calc.max(2 * min-angle, span / calc.max(1, ks.len())) })
      } else {
        angs.push(ang + acc + ws.at(fw) / 2 - tot / 2)
        fans.push(ws.at(fw))
        acc = acc + ws.at(fw)
        fw += 1
      }
    }
    let subs = ()
    for (i, k) in ks.enumerate() {
      // the fan is CENTRED on the branch's own direction, so one keyword
      // alone goes straight out along `start`, and a full ring of them opens
      // symmetrically about it — which is how `grow cyclic` shares a circle
      let a = angs.at(i)
      let kcol = if d == 0 { colx(_hue(palette, i)) } else { col }
      // an only child has no neighbour to dodge, and that is most of the
      // children on a real map: what has to be cleared is the next ray over,
      // so the push is measured against it — and against nothing at all when
      // there is no other ray. Pushing by the whole wedge instead marched a
      // twig three hand-widths away from the branch it grew from.
      let sep = if ks.len() == 1 { 180deg } else {
        calc.min(..range(ks.len()).filter(j => j != i)
          .map(j => calc.abs(angs.at(j) - a)))
      }
      let need = (k.w / 2 + gap / 2) / calc.max(0.3, calc.sin(sep / 2))
      // capped, and the cap is the branch's own tail: dodging a neighbour may
      // lengthen a stroke, it may never unstick a twig from the tip it grew at
      // — an uncapped push is what left deep words floating in the margins
      // the cap is the parent's own reach: dodging may lengthen a stroke, it may
      // never unstick a twig from the tip it grew at. At a `tip` the parent's
      // reach is not its tail but its ROW — the dot and the wrapped label run
      // out to the end of the stroke, and a child has room to be pushed as far
      // as that, which is what keeps two labels from standing on each other
      let reach = if label-at == "tip" { 0.5 + t.w * 0.6 } else {
        0.4 + 0.7 * tail(t, d) }
      let eff-child = if label-at == "tip" and d + 1 == 1 { dist } else { lead(d + 1) }
      let off = calc.min(calc.max(0.0, need - eff-child - k.w / 2), reach)
      // the brood starts where the parent's stroke ENDS, past its words; the
      // hub is the one parent with no stroke, so its children start at its
      // centre and are pushed out to clear the cloud
      // the branch is let start a little INSIDE the cloud: the centre is
      // painted over it, so the stroke reads as growing out of the shape
      // `off` lengthens the stroke instead of unsticking it: the base stays
      // glued to the parent's tip (or inside the hub), the child carries the
      // extra as `off` in its own `ln`
      let out = if d == 0 { hubrim(a) - 0.15 } else { 0.0 }
      let fork = if d == 0 { (0.0, 0.0) } else { far }
      let b0 = (fork.at(0) + out * calc.cos(a) + k.b.dx,
        fork.at(1) + out * calc.sin(a) + k.b.dy)
      let k2 = k + (off: off,)
      let sub = grow(k2, b0, a, fans.at(i), kcol, d + 1, sgn(calc.sin(a - ang)))
      subs = subs + (sub,)
    }
    // `array.flatten` would also open the ribs' own tuples, so the subtrees
    // are joined by hand
    let ns = (node,)
    let rs = if rib == none { () } else { (rib,) }
    for p in subs {
      ns = ns + p.at(0)
      rs = rs + p.at(1)
    }
    (ns, rs)
  }
  let laid = grow(hub-t, (0.0, 0.0), if spread >= 360deg { start } else { start },
    spread, colx(_hue(palette, 0)), 0, 1.0)
  let nds = laid.at(0)
  let ribs = laid.at(1)

  // ---- the canvas ----------------------------------------------------------
  // The canvas is the words' own bounding box, TURNED: a keyword laid along a
  // ray at 70deg is nearly as tall as it is long, and a word standing off a
  // thin stroke (the lift) or carrying a picture past its end reaches further
  // still. Measuring the box flat instead is what clipped a branch at the page
  // edge on a map that had every right to be drawn.
  let ext(t) = {
    if t.depth == 0 { (hub-w / 2 + 0.2, hub-h / 2 + 0.2) } else {
      let ca = calc.abs(calc.cos(t.ang))
      let sa = calc.abs(calc.sin(t.ang))
      let li = if angle-label and t.thick < 0.92 * t.h {
        t.h / 2 + t.thick / 2 + 0.02 } else { 0.0 }
      // at a tip the picture is INSIDE the row `t.w` already measures, so
      // counting it again would leave the canvas a whole icon too wide
      let ic = if t.t.icon != none and label-at != "tip" {
        calc.max(measure(t.t.icon).width / 1cm, measure(t.t.icon).height / 1cm)
      } else { 0.0 }
      ((t.w * ca + t.h * sa) / 2 + li * sa + ic * ca + 0.28,
        (t.w * sa + t.h * ca) / 2 + li * ca + ic * sa + 0.28)
    }
  }
  // Both the words AND the strokes bound the canvas: a band's widest point
  // bulges half its thickness off its own centreline, and a canvas sized by the
  // words alone left the tip of a fat stroke — or a picture past a keyword —
  // hanging outside the box, which `fit` then pushed off the edge of the page.
  let xs = ()
  let ys = ()
  for t in nds {
    let e = ext(t)
    xs.push((t.x - e.at(0), t.x + e.at(0)))
    ys.push((t.y - e.at(1), t.y + e.at(1)))
  }
  for r in ribs {
    let hw = calc.max(r.at(1), r.at(2)) / 2 + 0.06
    for p in r.at(0) {
      xs.push((p.at(0) - hw, p.at(0) + hw))
      ys.push((p.at(1) - hw, p.at(1) + hw))
    }
  }
  let x0 = calc.min(..xs.map(p => p.at(0)))
  let x1 = calc.max(..xs.map(p => p.at(1)))
  let y0 = calc.min(..ys.map(p => p.at(0)))
  let y1 = calc.max(..ys.map(p => p.at(1)))
  let W = x1 - x0
  let Hh = y1 - y0
  let flip = Hh * 1cm
  let P(p) = (p.at(0) - x0, p.at(1) - y0)
  let root-col = if hub-fill != auto { colx(hub-fill) }
                 else if prt { white }
                 // a drawn map washes its centre, it does not ink it: the cloud
                 // is a paler kin of the first branch, not a twin of it
                 else { colx(_hue(palette, 0)).lighten(70%) }
  let root-txt = if hub-text != auto { hub-text }
    else if prt or luma(root-col).components().first() > 58% { black } else { white }

  // FIT: the fan is sized by the words it has to write, not by the page, so a
  // wide map can run past the margin. `fit: true` scales it DOWN to the width it
  // was given, and only down — a small map stays small, as a drawn one does;
  // `fit: 17cm` makes it exactly that wide, growing as well as shrinking.
  // measured against the region the map is dropped into — `layout` hands back
  // CONTENT, not a length, so the width comes from a 0pt box at 100%
  let canvas = box(width: W * 1cm, height: Hh * 1cm, {
    // The strokes, widest first so a fork reads as one line opening. nibart
    // receives the same sampled centreline and a variable pen that tapers to
    // the lifted-pen tip. Native ribbon drawing remains available explicitly,
    // and is used automatically for a degenerate path nibart cannot stroke.
    let nib-objects = ()
    for r in ribs {
      let pts = r.at(0).map(p => P(p))
      let c = if prt { rgb("#2A2A2A") } else { colx(r.at(3)) }
      let f = if prt or shade <= 0% { c } else {
        gradient.linear(c.darken(shade * 0.4), c.lighten(shade),
          angle: 0deg - r.at(6), relative: "self")
      }
      if stroke-engine == "nibart" and pts.len() >= 2 {
        let path = nib.mp-path-pts(pts.map(p => (p.at(0) * 1cm, p.at(1) * 1cm)))
        let pen = nib.nibpen(
          (at: 0%, width: r.at(1) * 1cm, thinness: 88%),
          (at: 100%, width: r.at(2) * 1cm, thinness: 88%),
          angle: 30deg, follow: true)
        nib-objects += nib.stroke-items(path, pen: pen, fill: f, tol: 0.025pt)
      } else {
        let body = _stalk-path(pts, r.at(1), r.at(2), smooth: 0, hold: r.at(5))
        if body.len() > 3 { place(top + left, _fill((body,), flip: flip, fill: f)) }
      }
    }
    if stroke-engine == "nibart" and nib-objects.len() > 0 {
      place(top + left, nib.mp-fig(..nib-objects,
        width: W * 1cm, height: Hh * 1cm, origin: (0pt, 0pt),
        pad: 0pt, baseline: 0pt))
    }

    // the centre: its words are inside the shape, not on top of it
    let hub-word = text(size: 1em * calc.max(1.0, size), fill: root-txt,
      dir: bdir, root)
    let hub-stack = if hub-icon != none {
      stack(dir: ttb, spacing: 0.08cm, align(center, hub-icon),
        align(center, hub-word))
    } else { align(center, hub-word) }
    // the cloud is not a name to look up but a thing to build: its lumps come
    // from the map's own `seed`, so two maps of the same words differ the way
    // two drawings of the same thought do, and re-compiling gives back the same
    // one. Any other key, or a function, goes to `_leaf-draw` untouched.
    let hub-sty = hub-sty0
    place(top + left, dx: (0.0 - x0 - hub-w / 2) * 1cm,
      dy: (Hh - (hub-h / 2 - y0)) * 1cm,
      box(width: hub-w * 1cm, height: hub-h * 1cm, {
        _leaf-draw(hub-sty, hub-w, hub-h, calc.min(hub-w, hub-h) * 0.3,
          fill: root-col, stroke-paint: if prt { black }
            else { colx(_hue(palette, 0)).darken(26%) },
          weight: weight, hand: hd, seed: seed, roughness: roughness,
          bowing: 0.9, shadow: if shadow { rgb("#00000020") } else { none })
        place(top + left, box(width: 100%, height: 100%,
          align(center + horizon, hub-stack)))
      }))

    // the keywords, on the stroke they belong to
    for x in nds {
      if x.depth == 0 { continue }
      let c = if leaf-ink != auto { leaf-ink } else if prt { black }
              else { colx(x.col).darken(46%) }
      let ux = calc.cos(x.ang)
      let uy = calc.sin(x.ang)
      // a branch pointing back over the map is written the other way round,
      // as a hand does it: the words stay readable, their tail still points
      // at the centre. The box is then turned through 180deg as well, which
      // is the whole of the trick — a word set on its head is not a keyword.
      let fl = angle-label and ux < 0
      let rot = if not angle-label { 0deg } else if fl { 180deg - x.ang }
                else { -x.ang }
      // a thin stroke is an underline, so its word stands above it; a fat one
      // carries the word inside it, which is the whole point of the map
      let nx = if fl { uy } else { -uy }
      let ny = if fl { -ux } else { ux }
      let lift = if angle-label and x.thick < 0.92 * x.h {
        x.h / 2 + x.thick / 2 + 0.02 } else { 0.0 }
      let kw = align(center, mk-label(x.t.b, x.depth, fill: c,
        root: x.depth == 0))
      let with-note = if x.t.note != none {
        stack(dir: ttb, spacing: 0.03cm, kw,
          align(center, if x.t.note-width != none {
            box(width: x.t.note-width * 1cm,
              text(size: 0.78 * fs(x.depth),
                fill: if prt { rgb("#555555") } else { c.darken(14%) },
                dir: bdir, say(x.t.note)))
          } else {
            text(size: 0.78 * fs(x.depth),
              fill: if prt { rgb("#555555") } else { c.darken(14%) },
              dir: bdir, say(x.t.note))
          }))
      } else { kw }
      // A rotated box is PLACED by the corners of the box it became, not of the
      // box it was: at 45deg a keyword grows a quarter of its own width in both
      // directions, and anchoring that by its old top-left slid every word down
      // the page and off the right edge of the canvas. So the turned box is
      // measured, and its own centre is what gets put where the ray says.
      // `"tip"` lays the row out in two cells — the dot, then the word — inside
      // the box the measure already paid for, so the wedge, the canvas and the
      // dodging all see one thing and draw another. The contour, when it is
      // asked for, goes BEHIND the word's cell and not behind the row: the dot
      // stays a dot, or the tip reads as a cartouche with a handle.
      // at a tip the word sits PAST the dot, left-aligned (right for RTL),
      // not centred — otherwise a fixed `label-width` leaves a gap between the
      // dot and the letters. Banner is vertical: dot above leaf, centred.
      let lab-align = if hub-shape == "banner" and label-at == "tip" {
        center + horizon
      } else if label-at == "tip" { bal + horizon } else { center + horizon }
      let labcell = if label-box == "draw" {
        box(width: x.t.labw * 1cm, height: x.h * 1cm, {
          _leaf-draw(label-shape, x.t.labw + 2 * label-pad, x.h + 2 * label-pad,
            calc.min(x.t.labw, x.h) * 0.3,
            fill: if prt { white } else { colx(x.col).lighten(72%) },
            stroke-paint: if prt { black } else { colx(x.col).darken(26%) },
            weight: weight, hand: hd, seed: seed, roughness: roughness,
            bowing: 0.9, shadow: none)
          place(top + left, box(width: 100%, height: 100%,
            align(lab-align, with-note)))
        })
      } else { box(width: x.t.labw * 1cm, height: x.h * 1cm,
        align(lab-align, with-note)) }
      // banner: dot at end of branch, above centre of leaf box — not glued,
      // so no left/right problem. RTL: dot on right side, LTR dot on left,
      // otherwise side-by-side.
      let row = if label-at == "tip" and x.t.icon != none {
        if hub-shape == "banner" {
          // vertical: dot above leaf, centred — dot at tip, leaf below
          stack(dir: ttb, spacing: 0.08cm,
            align(center + horizon, box(x.t.icon)),
            align(center + horizon, labcell))
        } else if r2l {
          grid(columns: (1fr, x.t.iw * 1cm), column-gutter: 0.1cm, inset: 0pt,
            rows: (x.h * 1cm,), align: center + horizon,
            labcell, box(x.t.icon))
        } else {
          grid(columns: (x.t.iw * 1cm, 1fr), column-gutter: 0.1cm, inset: 0pt,
            rows: (x.h * 1cm,), align: center + horizon,
            box(x.t.icon), labcell)
        }
      } else if label-at == "tip" { labcell } else { with-note }
      // a tip's row starts AFTER the stroke (tip-gap) — the dot is not glued
      // to the line, so there is no alignment problem left/right
      let row-align = if label-at == "tip" { bal + horizon } else { center + horizon }
      let turned = rotate(rot, origin: center,
        box(width: x.w * 1cm, height: x.h * 1cm, align(row-align, row)))
      let tm = measure(box(inset: 0pt, turned))
      place(top + left,
        dx: (x.x - x0 + nx * lift - (tm.width / 1cm) / 2) * 1cm,
        dy: (Hh - (x.y - y0 + ny * lift) - (tm.height / 1cm) / 2) * 1cm,
        turned)
      // the picture goes past the word, at the tip, where the meaning is —
      // unless the row already carries it, which is what `label-at: "tip"` did
      if x.t.icon != none and label-at != "tip" {
        // centred ON the point just past the word, in a box of the picture's
        // own size. Wrapping the picture in a box as wide as the keyword and
        // pushing it to one edge is what dropped it on top of the letters.
        let im = measure(box(inset: 0pt, x.t.icon))
        let iw = im.width / 1cm
        let ih = im.height / 1cm
        let il = x.w / 2 + iw / 2 + 0.06
        place(top + left,
          dx: (x.x - x0 + ux * il - iw / 2) * 1cm,
          dy: (Hh - (x.y - y0 + uy * il) - ih / 2) * 1cm,
          box(x.t.icon))
      }
    }
  })
  if fit == auto { canvas } else {
    // the region's own width only exists once the map is in the flow, so the
    // scaling is done inside `layout`, whose callback is handed that size — a
    // `measure` would run detached and read 100% as nothing at all. The box is
    // then DECLARED at the scaled size, or the drawing shrinks while the room
    // it reserves does not.
    layout(size => {
      let av = if type(fit) == length { fit } else if type(fit) == ratio {
        size.width * fit } else { size.width }
      // the region's HEIGHT counts as well, when it is a real one: on a page of
      // a fixed height a round map is clipped top and bottom, not only at the
      // right, and only the smaller of the two shares keeps it on the paper
      let want = calc.min(av / (calc.max(0.02, W) * 1cm),
        if type(size.height) == length {
          calc.min(8.0, size.height / (calc.max(0.02, Hh) * 1cm))
        } else { 8.0 })
      // `true` and a RATIO are clamped to shrinking, and that clamp is not
      // cosmetic: inside `measure` the region is unbounded, so a percentage may
      // be read as a width of several metres and a map would be blown up eight
      // times over before the caller shrank it again. Only an explicit length
      // promises to grow.
      let sc = if type(fit) == length { calc.min(8.0, calc.max(0.05, want)) }
               else { calc.min(1.0, calc.max(0.05, want)) }
      // ALIGNMENT NEUTRAL, and that matters: the canvas inside is still at its
      // natural width, so under a centred paragraph it would be centred IN the
      // scaled box — which slid the whole map a third of its overflow to the
      // right and put the last keyword off the edge of the page
      box(width: W * sc * 1cm, height: Hh * sc * 1cm, clip: false,
        align(left + top,
          scale(x: sc * 100%, y: sc * 100%, origin: top + left, canvas)))
    })
  }
}
