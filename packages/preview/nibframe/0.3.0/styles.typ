// nibframe — the styles (geometry + drawing). See lib.typ for the public API.
#import "@preview/nibart:0.3.0" as nib

#let _pt(x) = if type(x) == length { x.pt() } else if type(x) == int or type(x) == float { float(x) } else { panic("nibframe: expected a length, got " + repr(x)) }
#let _P(x, y) = (x * 1pt, y * 1pt)

// ───────────────────────────────────────────────────────────────── options
#let frame-styles = ("classic", "celtic", "guilloche", "braces", "pearls", "arabesque", "islamic", "greek", "scallop", "deco", "chain", "braid", "banknote",
  "baroque", "triquetra", "solomon", "zellige", "seigaiha", "kilim", "laurel", "flowers", "stamp", "film", "photo", "neon", "illumination",
  "bill-lens", "bill-fan", "bill-ribbon", "bill-shell", "bill-wave", "bill-frill", "bill-net", "bill-swell", "bill-plait", "bill-rosette",
  "bill-wavy", "bill-diploma", "bill-lattice", "bill-weave",
  "airmail", "checker", "stars", "hearts", "eggdart", "vitruvian", "arches", "tapa", "stripes", "herringbone",
  "knot-cartouche", "knot-eights", "knot-lozenge", "knot-ring", "daisy", "sakura", "lotus", "palmette", "ogee", "rinceau", "girih", "hexastar", "strap", "certificate", "certificate-ribbon", "stepped", "deckle", "label", "diamond-chain", "lace-grid", "diploma-shell", "medallion", "rosette-ribbon", "fleur-edge", "filigree",
  "knot-rope", "knot-triple", "knot-weave", "knot-blocks",
  "dedication", "plank", "torn", "coil")

#let _bands = (classic: 6.5mm, celtic: 6.5mm, braid: 7mm, chain: 6.5mm, arabesque: 7mm, islamic: 6.5mm, greek: 6mm, scallop: 6.5mm,
  deco: 5.5mm, braces: 7mm, pearls: 5mm, guilloche: 6.5mm, banknote: 6.5mm,
  baroque: 7.5mm, triquetra: 7mm, solomon: 7mm, zellige: 7mm, seigaiha: 7mm, kilim: 5.5mm, laurel: 7mm, flowers: 7mm, stamp: 5.5mm, film: 6.5mm,
  photo: 7mm, neon: 5mm, illumination: 7mm,
  "bill-lens": 6.5mm, "bill-fan": 6.5mm, "bill-ribbon": 6.5mm, "bill-shell": 6.5mm, "bill-wave": 6.5mm, "bill-frill": 6.5mm, "bill-net": 6.5mm, "bill-swell": 6.5mm, "bill-plait": 6.5mm, "bill-rosette": 6.5mm,
  "bill-wavy": 7mm, "bill-diploma": 7mm, "bill-lattice": 6.5mm, "bill-weave": 7mm,
  airmail: 5.5mm, checker: 5.5mm, stars: 6.5mm, hearts: 6.5mm, eggdart: 7mm, vitruvian: 7mm, arches: 7.5mm, tapa: 6.5mm, stripes: 5.5mm, herringbone: 6mm,
  "knot-cartouche": 7mm, "knot-eights": 7mm, "knot-lozenge": 7mm, "knot-ring": 7mm, daisy: 7mm, sakura: 7mm, lotus: 7mm, palmette: 7mm, ogee: 7mm, rinceau: 7mm,
  girih: 6.5mm, hexastar: 6.5mm, strap: 6.5mm, certificate: 7.5mm, "certificate-ribbon": 7.5mm, stepped: 7mm, deckle: 6.5mm, label: 5.5mm, "diamond-chain": 6.5mm, "lace-grid": 6.5mm, "diploma-shell": 7mm, medallion: 7mm, "rosette-ribbon": 7mm, "fleur-edge": 7mm, filigree: 7mm,
  "knot-rope": 7mm, "knot-triple": 7mm, "knot-weave": 7mm, "knot-blocks": 7mm,
  dedication: 7mm, plank: 6mm, torn: 7mm, coil: 7mm)

#let _defaults = (
  style: "classic",
  band: auto,              // width of the decorative band (auto: depends on the style, see _bands)
  inset: 4mm,              // distance between the page edge and the outside of the band
  color: rgb("#2f628c"),   // main colour
  accent: rgb("#b07a1c"),  // second colour
  ink: rgb("#2b2622"),     // outlines
  paper: white,            // colour of the page (used by styles that hide overlaps: seigaiha, kilim, photo)
  line: 0.6pt,             // thin rules
  radius: auto,            // corner radius of the band (auto: depends on the style)
  period: auto,            // length of one repeat of the pattern (celtic, guilloche)
  strands: auto,           // number of strands (celtic, guilloche)
  rules: true,             // thin rules along both edges of the band
  texture: none,           // background texture inside the frame: "scales", "waves", "rosettes"
  texture-color: auto,     // colour of the texture (auto: a pale accent)
  seal: false,             // a guilloché seal (rosette) in the bottom-right corner of the page
  corners: true,           // corner ornaments (false: the continuous contour only)
  corner-color: auto,      // colour of the corner ornaments of the bill-* styles (auto: a lighter accent)
  binding: "left",         // coil only: side of the wire rings ("left", "right", "top", "bottom", "none")
)

#let _cfg(style, opts) = {
  let c = _defaults
  c.style = style
  for (k, v) in opts.named() {
    assert(k in c, message: "nibframe: unknown option `" + k + "` (known: " + c.keys().join(", ") + ")")
    c.insert(k, v)
  }
  assert(c.style in frame-styles, message: "nibframe: unknown style \"" + c.style + "\" (known: " + frame-styles.join(", ") + ")")
  if c.band == auto { c.band = _bands.at(c.style) }
  c
}

// ───────────────────────────────────────────────────────────────── geometry of a rounded rectangle
// `pos(s)` → (x, y, tx, ty): position and unit tangent at arc length `s`, counter-clockwise from the bottom edge.
#let _perimeter(x0, y0, x1, y1, r) = {
  let W = x1 - x0
  let H = y1 - y0
  let r = calc.max(0.01, calc.min(r, W / 2 - 0.01, H / 2 - 0.01))
  let a = W - 2 * r
  let b = H - 2 * r
  let q = r * calc.pi / 2
  let L = 2 * a + 2 * b + 4 * q
  // pieces: (length, kind, data)
  let pieces = (
    (a, 0, (x0 + r, y0, 0deg)),
    (q, 1, (x1 - r, y0 + r, -90deg)),
    (b, 0, (x1, y0 + r, 90deg)),
    (q, 1, (x1 - r, y1 - r, 0deg)),
    (a, 0, (x1 - r, y1, 180deg)),
    (q, 1, (x0 + r, y1 - r, 90deg)),
    (b, 0, (x0, y1 - r, -90deg)),
    (q, 1, (x0 + r, y0 + r, 180deg)),
  )
  let pos(s) = {
    let s = calc.rem(calc.rem(s, L) + L, L)
    let acc = 0.0
    for (len, kind, d) in pieces {
      if s <= acc + len or (len, kind, d) == pieces.last() {
        let u = s - acc
        if kind == 0 {
          let (c, sn) = (calc.cos(d.at(2)), calc.sin(d.at(2)))
          return (d.at(0) + c * u, d.at(1) + sn * u, c, sn)
        } else {
          let th = d.at(2) + u / r * 1rad
          return (d.at(0) + r * calc.cos(th), d.at(1) + r * calc.sin(th), -calc.sin(th), calc.cos(th))
        }
      }
      acc += len
    }
  }
  (pos: pos, length: L, radius: r)
}

#let _rrect(x0, y0, x1, y1, r) = nib.round-corners(((x0 * 1pt, y0 * 1pt), (x1 * 1pt, y0 * 1pt), (x1 * 1pt, y1 * 1pt), (x0 * 1pt, y1 * 1pt)), r: calc.max(0.01, calc.min(r, (x1 - x0) / 2 - 0.01, (y1 - y0) / 2 - 0.01)) * 1pt, cycle: true)
#let _rule(p, w, col) = nib.stroke-items(p, pen: nib.pencircle(w * 1pt), fill: col)

/// A closed path that follows the perimeter, displaced along the normal by `f(s)` (positive = inwards).
#let _wavy(per, n, f) = nib.mp-path-pts(range(n).map(i => {
  let s = per.length * i / n
  let (x, y, tx, ty) = (per.pos)(s)
  let o = f(s)
  _P(x - ty * o, y + tx * o)
}), cycle: true)

// ───────────────────────────────────────────────────────────────── the styles
// All styles work in a y-up frame: (0, 0) is the bottom-left corner of the box, (w, h) the top-right one.

#let _ell(pts, cycle: false) = nib.mp-path-pts(pts.map(q => _P(..q)), cycle: cycle)
#let _poly(pts, cycle: false) = nib.polyline(pts.map(q => _P(..q)), cycle: cycle)
#let _pen(c, w) = nib.pencircle(w * 1pt)
#let _stroke(p, w, col) = nib.stroke-items(p, pen: nib.pencircle(w * 1pt), fill: col)
/// broad nib at a fixed page angle: the thick/thin contrast is the same everywhere, as with a real pen
#let _calli(p, w, col, ang: 40deg) = nib.stroke-items(p, pen: nib.penellipse(w * 1pt, w * 0.28 * 1pt, angle: ang), fill: col)
#let _edge-rules(c, w, h, m, B, r, thick: 1.6, thin: 1.0) = {
  let lw = _pt(c.line)
  let rr(a, rad) = nib.round-corners(((a * 1pt, a * 1pt), ((w - a) * 1pt, a * 1pt), ((w - a) * 1pt, (h - a) * 1pt), (a * 1pt, (h - a) * 1pt)), r: rad * 1pt, cycle: true)
  _stroke(rr(m, r), lw * thick, c.ink) + _stroke(rr(m + B, calc.max(r - B, 0.5)), lw * thin, c.ink)
}

#let _classic(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let r = if c.radius == auto { B * 0.3 } else { _pt(c.radius) }
  let d = B * 0.2                          // distance between the two rules
  let items = ()
  items += _rule(_rrect(m, m, w - m, h - m, r), lw * 3.4, c.color)
  items += _rule(_rrect(m + d, m + d, w - m - d, h - m - d, calc.max(r - d, 0.5)), lw * 1.1, c.color)
  // a volute hanging in every corner (a broad nib gives the thick/thin contrast), a bead in the middle of every side
  let corner(sx, sy, cx, cy) = {
    let n = 22
    let pts = range(n + 1).map(i => {
      let u = i / n
      let th = -135deg + 1.6 * 360deg * u
      let rho = B * 0.5 * (1 - 0.86 * u)
      _P(rho * calc.cos(th), rho * calc.sin(th))
    })
    let q = nib.transformed(nib.mp-path-pts(pts), sx, 0, 0, sy, e: cx * 1pt, f: cy * 1pt)
    nib.stroke-items(q, pen: nib.penellipse(B * 0.2 * 1pt, B * 0.05 * 1pt, angle: if sx * sy > 0 { 45deg } else { -45deg }), fill: c.accent)
  }
  let k = d + B * 0.55
  if c.corners {
    items += corner(1, 1, m + k, m + k)
    items += corner(-1, 1, w - m - k, m + k)
    items += corner(-1, -1, w - m - k, h - m - k)
    items += corner(1, -1, m + k, h - m - k)
  }
  for (x, y) in ((w / 2, m + d / 2), (w / 2, h - m - d / 2), (m + d / 2, h / 2), (w - m - d / 2, h / 2)) {
    items.push(nib.mp-dot(_P(x, y), pen: nib.pencircle(d * 0.75 * 1pt), fill: c.accent))
  }
  items
}

#let _celtic(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let r = if c.radius == auto { B * 0.9 } else { _pt(c.radius) }
  let ns = if c.strands == auto { 2 } else { c.strands }
  assert(ns in (2, 3), message: "nibframe: celtic needs strands: 2 or 3")
  let ol = B * 0.05
  let sw = B * (if ns == 2 { 0.27 } else { 0.22 })
  let amp = (B - sw) / 2 - ol - B * 0.06
  let per = _perimeter(m + B / 2, m + B / 2, w - m - B / 2, h - m - B / 2, r)
  let period = if c.period == auto { B * 1.45 } else { _pt(c.period) }
  let K = int(calc.max(4, calc.round(per.length / period)))
  let spp = 10
  let strands = range(ns).map(j => _wavy(per, K * spp, s => amp * calc.sin(2 * calc.pi * K * s / per.length + j * 2 * calc.pi / ns)))
  let cols = range(ns).map(j => if calc.even(j) { c.color } else { c.accent })
  let items = ()
  if c.rules {
    items += _rule(_rrect(m, m, w - m, h - m, r + B / 2), lw * 1.6, c.ink)
    items += _rule(_rrect(m + B, m + B, w - m - B, h - m - B, calc.max(r - B / 2, 0.5)), lw * 1.6, c.ink)
  }
  items += nib.knot(strands, style: "weave", width: sw * 1pt, fill: cols, outline: ol * 1pt, outline-fill: c.ink)
  items
}

#let _guilloche(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let r = if c.radius == auto { B * 0.8 } else { _pt(c.radius) }
  let ns = if c.strands == auto { 7 } else { c.strands }
  let amp = B * 0.42
  let per = _perimeter(m + B / 2, m + B / 2, w - m - B / 2, h - m - B / 2, r)
  let period = if c.period == auto { B * 2.2 } else { _pt(c.period) }
  let K = int(calc.max(4, calc.round(per.length / period)))
  let items = ()
  if c.rules {
    items += _rule(_rrect(m, m, w - m, h - m, r + B / 2), lw * 2.2, c.ink)
    items += _rule(_rrect(m + B, m + B, w - m - B, h - m - B, calc.max(r - B / 2, 0.5)), lw * 1.0, c.ink)
  }
  for j in range(ns) {
    let q = _wavy(per, K * 16, s => amp * calc.sin(2 * calc.pi * K * s / per.length + j * calc.pi / ns))
    items += _rule(q, lw * 1.25, if calc.even(j) { c.color } else { c.accent })
  }
  items
}

#let _braces(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let g = B * 1.1                         // gap left at each corner
  let (x0, y0, x1, y1) = (m + B, m + B, w - m - B, h - m - B)
  let amp = B * 0.92
  let d(a, b) = nib.delimiter(_P(..a), _P(..b), kind: "brace", amplitude: amp * 1pt, light: lw * 1.2 * 1pt, heavy: B * 0.26 * 1pt, fill: c.color)
  let items = ()
  // clockwise: the brace bulges to the left of the travel direction, i.e. outwards
  items += d((x0, y0 + g), (x0, y1 - g))
  items += d((x0 + g, y1), (x1 - g, y1))
  items += d((x1, y1 - g), (x1, y0 + g))
  items += d((x1 - g, y0), (x0 + g, y0))
  let k = B * 0.17
  for (x, y) in (if c.corners { ((x0, y0), (x1, y0), (x1, y1), (x0, y1)) } else { () }) {
    let sx = if x < w / 2 { -1 } else { 1 }
    let sy = if y < h / 2 { -1 } else { 1 }
    let (cx, cy) = (x + sx * B * 0.42, y + sy * B * 0.42)
    items.push(nib.mp-fill(nib.polyline(((cx - k * 2.2, cy), (cx, cy - k * 2.2), (cx + k * 2.2, cy), (cx, cy + k * 2.2)).map(p => _P(..p)), cycle: true), fill: c.accent))
    items.push(nib.mp-dot(_P(cx, cy), pen: nib.pencircle(k * 1.3 * 1pt), fill: c.ink))
  }
  if c.rules { items += _edge-rules(c, w, h, m, B, B * 0.35, thick: 1.0, thin: 0.6) }
  items
}

#let _pearls(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let r = if c.radius == auto { B * 0.6 } else { _pt(c.radius) }
  let items = ()
  items += _rule(_rrect(m, m, w - m, h - m, r + B / 2), lw * 2.0, c.color)
  items += _rule(_rrect(m + B, m + B, w - m - B, h - m - B, calc.max(r - B / 2, 0.5)), lw * 1.0, c.color)
  let per = _perimeter(m + B / 2, m + B / 2, w - m - B / 2, h - m - B / 2, r)
  let step = if c.period == auto { B * 0.62 } else { _pt(c.period) }
  let n = int(calc.max(8, calc.round(per.length / step)))
  for i in range(n) {
    let (x, y, tx, ty) = (per.pos)(per.length * i / n)
    items.push(nib.mp-dot(_P(x, y), pen: nib.pencircle(B * 0.26 * 1pt), fill: if calc.even(i) { c.color } else { c.accent }))
  }
  items
}

// ───────────────────────────────────────────────────────────────── motif bands
// Frames made of a repeated motif drawn in a local frame: u along the side (0…p), v across (−B/2 outside … +B/2 inside).
// `pl(path)` maps a local path to the page. Corners get their own motif, drawn in a local frame centred on the corner
// of the band (mirrored for the four corners).
#let _spiral(cx, cy, r0, r1, a0, turns, dir) = {
  let n = int(calc.ceil(turns * 10))
  _ell(range(n + 1).map(i => {
    let u = i / n
    let th = a0 + dir * turns * 360deg * u
    let rho = r0 + (r1 - r0) * u
    (cx + rho * calc.cos(th), cy + rho * calc.sin(th))
  }))
}
/// leaf (pointed almond) from (x, y), length `len`, width `wid`, pointing at angle `ang`
#let _leaf(x, y, len, wid, ang) = {
  let (ca, sa) = (calc.cos(ang), calc.sin(ang))
  let q(u, v) = (x + u * ca - v * sa, y + u * sa + v * ca)
  let a = q(0, 0)
  let b = q(len, 0)
  nib.path-join-all((
    nib.cubic(_P(..a), _P(..q(len * 0.15, wid)), _P(..q(len * 0.6, wid)), _P(..b)),
    nib.cubic(_P(..b), _P(..q(len * 0.6, -wid)), _P(..q(len * 0.15, -wid)), _P(..a)),
  ), cycle: true)
}
#let _motif-band(c, w, h, period, side, corner, idx: false) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let sides = (
    (m + B, m + B / 2, 1, 0, w - 2 * m - 2 * B),
    (w - m - B / 2, m + B, 0, 1, h - 2 * m - 2 * B),
    (w - m - B, h - m - B / 2, -1, 0, w - 2 * m - 2 * B),
    (m + B / 2, h - m - B, 0, -1, h - 2 * m - 2 * B),
  )
  let p0 = if c.period == auto { period * B } else { _pt(c.period) }
  let items = ()
  for (ox, oy, tx, ty, len) in sides {
    // an even number of cells; the second half is the mirror image of the first: every side is symmetric
    let n = 2 * int(calc.max(1, calc.round(len / (2 * p0))))
    let pp = len / n
    for i in range(n) {
      let pl = if 2 * i < n {
        path => nib.transformed(path, tx, ty, -ty, tx, e: (ox + i * pp * tx) * 1pt, f: (oy + i * pp * ty) * 1pt)
      } else {
        path => nib.transformed(path, -tx, -ty, -ty, tx, e: (ox + (i + 1) * pp * tx) * 1pt, f: (oy + (i + 1) * pp * ty) * 1pt)
      }
      items += if idx { side(c, B, pp, pl, calc.min(i, n - 1 - i)) } else { side(c, B, pp, pl) }
    }
  }
  for (cx, cy, sx, sy) in (if not c.corners { () } else { ((m + B / 2, m + B / 2, 1, 1), (w - m - B / 2, m + B / 2, -1, 1), (w - m - B / 2, h - m - B / 2, -1, -1), (m + B / 2, h - m - B / 2, 1, -1)) }) {
    let pl = path => nib.transformed(path, sx, 0, 0, sy, e: cx * 1pt, f: cy * 1pt)
    items += corner(c, B, pl)
  }
  items
}

// ── arabesque: a vine with tendrils and leaves, calligraphic
#let _arabesque(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let side(c, B, p, pl) = {
    let n = 8
    let stem = _ell(range(n + 1).map(i => (p * i / n, 0.17 * B * calc.sin(i / n * 360deg))))
    let R0 = 0.13 * B
    let items = ()
    items += _calli(pl(stem), B * 0.14, c.color)
    items += _calli(pl(_spiral(p / 4, 0.17 * B + R0, R0, 0.25 * R0, -90deg, 1.5, 1)), B * 0.11, c.color)
    items += _calli(pl(_spiral(3 * p / 4, -0.17 * B - R0, R0, 0.25 * R0, 90deg, 1.5, -1)), B * 0.11, c.color)
    items.push(nib.mp-fill(pl(_leaf(p / 2, 0.03 * B, 0.3 * B, 0.07 * B, 90deg)), fill: c.accent))
    items.push(nib.mp-fill(pl(_leaf(p / 2, -0.03 * B, 0.3 * B, 0.07 * B, -90deg)), fill: c.accent))
    items.push(nib.mp-fill(pl(_leaf(0.02 * B, 0, 0.24 * B, 0.06 * B, 35deg)), fill: c.accent))
    items.push(nib.mp-fill(pl(_leaf(p - 0.02 * B, 0, 0.24 * B, 0.06 * B, 145deg)), fill: c.accent))
    items
  }
  // the corner motif is centred on the corner, so use pl for it (see below)
  let corner2(c, B, pl) = {
    let items = ()
    for k in range(8) {
      let ang = k * 45deg
      items.push(nib.mp-fill(pl(_leaf(0.05 * B * calc.cos(ang), 0.05 * B * calc.sin(ang), 0.42 * B, 0.1 * B, ang)), fill: if calc.even(k) { c.accent } else { c.color }))
    }
    items.push(nib.mp-fill(pl(_poly(range(8).map(k => (0.085 * B * calc.cos(k * 45deg), 0.085 * B * calc.sin(k * 45deg))), cycle: true)), fill: c.ink))
    items
  }
  _edge-rules(c, w, h, m, B, B * 0.5, thick: 1.4, thin: 0.9) + _motif-band(c, w, h, 2.0, side, corner2)
}

// ── islamic: interlaced eight-pointed stars (two squares woven together)
#let _islamic(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let star(pl, cu, cv, R, col) = {
    let sq(a0) = pl(_poly(range(4).map(k => (cu + R * calc.cos(a0 + k * 90deg), cv + R * calc.sin(a0 + k * 90deg))), cycle: true))
    nib.knot((sq(0deg), sq(45deg)), style: "weave", width: R * 0.15 * 1pt, fill: (col, c.accent), outline: R * 0.045 * 1pt, outline-fill: c.ink)
  }
  let side(c, B, p, pl) = {
    let items = star(pl, p / 2, 0, B * 0.47, c.color)
    items.push(nib.mp-fill(pl(_poly(((0, 0.0), (0.09 * B, 0.09 * B), (0, 0.18 * B), (-0.09 * B, 0.09 * B)).map(q => (q.at(0) + p, q.at(1) - 0.09 * B)), cycle: true)), fill: c.accent))
    items
  }
  let corner(c, B, pl) = star(pl, 0, 0, B * 0.43, c.accent)
  _edge-rules(c, w, h, m, B, B * 0.45) + _motif-band(c, w, h, 1.2, side, corner)
}

// ── greek key: hooks on a rail
#let _greek(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let side(c, B, p, pl) = {
    let k = B
    let hook = _poly(((0, -0.5), (0, 0.5), (0.74, 0.5), (0.74, -0.2), (0.22, -0.2), (0.22, 0.22), (0.48, 0.22)).map(q => (q.at(0) * k, q.at(1) * k)))
    let rail = _poly(((0, -0.5 * B), (p, -0.5 * B)))
    _stroke(pl(hook), B * 0.09, c.color)
  }
  let corner(c, B, pl) = {
    let sp = _poly(((-0.5, -0.5), (0.5, -0.5), (0.5, 0.5), (-0.5, 0.5), (-0.5, -0.5 + 0.22), (0.28, -0.28), (0.28, 0.28), (-0.28, 0.28), (-0.28, -0.06), (0.06, -0.06)).map(q => (q.at(0) * B, q.at(1) * B)))
    _stroke(pl(sp), B * 0.09, c.accent)
  }
  // the outer rail is continuous all the way round, the meander hangs from it
  let rr(a, rad) = nib.round-corners(((a * 1pt, a * 1pt), ((w - a) * 1pt, a * 1pt), ((w - a) * 1pt, (h - a) * 1pt), (a * 1pt, (h - a) * 1pt)), r: rad * 1pt, cycle: true)
  _stroke(rr(m, if c.corners { 0.5 } else { B * 0.3 }), B * 0.09, c.color) + _stroke(rr(m + B, 0.5), lw * 0.7, c.ink) + _motif-band(c, w, h, 1.4, side, corner)
}

// ── scallop: rows of concentric arcs (lace), fans in the corners
#let _scallop(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let arc(cu, cv, r, a0, a1) = _ell(range(0, 7).map(i => { let t = a0 + (a1 - a0) * i / 6; (cu + r * calc.cos(t), cv + r * calc.sin(t)) }))
  let side(c, B, p, pl) = {
    let items = ()
    for (k, (r, col, wd)) in ((0.5, c.color, 2.0), (0.37, c.accent, 1.5), (0.24, c.color, 1.5)).enumerate() {
      let rr = r * p
      items += _stroke(pl(arc(p / 2, -0.5 * B, calc.min(rr, B * 0.98), 0deg, 180deg)), lw * wd, col)
    }
    items.push(nib.mp-fill(pl(_ell(range(8).map(k => (p / 2 + 0.06 * B * calc.cos(k * 45deg), -0.5 * B + 0.12 * p + 0.06 * B * calc.sin(k * 45deg))), cycle: true)), fill: c.accent))
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for (k, (r, col, wd)) in ((1.0, c.color, 2.0), (0.78, c.accent, 1.5), (0.56, c.color, 1.5), (0.34, c.accent, 1.5)).enumerate() {
      items += _stroke(pl(arc(-0.5 * B, -0.5 * B, r * B, 0deg, 90deg)), lw * wd, col)
    }
    items
  }
  let rules = _edge-rules(c, w, h, m, B, 0.6 * B, thick: 1.4, thin: 0.7)
  rules + _motif-band(c, w, h, 0.9, side, corner)
}

// ── art deco: stepped rules, ticks, corner fans
#let _deco(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let side(c, B, p, pl) = {
    let items = ()
    let ticks = 5
    for i in range(ticks) {
      let u = p * (i + 0.5) / ticks
      let hh = if calc.even(i) { 0.3 } else { 0.18 }
      items += _stroke(pl(_poly(((u, -hh * B), (u, hh * B)))), lw * 1.3, if calc.even(i) { c.color } else { c.accent })
    }
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    // fan centred on the outer corner of the band
    for k in range(7) {
      let ang = k * 15deg
      items += _stroke(pl(_poly(((-0.5 * B + 0.12 * B * calc.cos(ang), -0.5 * B + 0.12 * B * calc.sin(ang)), (-0.5 * B + B * calc.cos(ang), -0.5 * B + B * calc.sin(ang))))), lw * 0.9, if calc.even(k) { c.color } else { c.accent })
    }
    for r in (0.35, 0.65, 1.0) {
      items += _stroke(pl(_ell(range(0, 7).map(i => { let t = i * 15deg; (-0.5 * B + r * B * calc.cos(t), -0.5 * B + r * B * calc.sin(t)) }))), lw * 1.2, c.ink)
    }
    items
  }
  let rect(a, b2, col, wd) = _stroke(_poly(((a, a), (w - a, a), (w - a, h - a), (a, h - a)), cycle: true), wd, col)
  rect(m, 0, c.ink, lw * 3) + rect(m + B, 0, c.ink, lw * 1.2) + rect(m + B * 0.12, 0, c.color, lw * 0.8) + _motif-band(c, w, h, 0.42, side, corner)
}

// ── chain: interlocked links
#let _chain(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let r = if c.radius == auto { B * 1.1 } else { _pt(c.radius) }
  let per = _perimeter(m + B / 2, m + B / 2, w - m - B / 2, h - m - B / 2, r)
  let step = if c.period == auto { B * 1.15 } else { _pt(c.period) }
  let n = int(calc.max(6, calc.round(per.length / step)))
  let sw = B * 0.13
  let ol = B * 0.035
  let a = B * 0.78
  let b = B * 0.5 - sw / 2 - ol - B * 0.03
  let link = range(8).map(k => (a * calc.cos(k * 45deg), b * calc.sin(k * 45deg)))
  let links = range(n).map(i => {
    let (x, y, tx, ty) = (per.pos)(per.length * i / n)
    nib.transformed(_ell(link, cycle: true), tx, ty, -ty, tx, e: x * 1pt, f: y * 1pt)
  })
  let cols = range(n).map(i => if calc.even(i) { c.color } else { c.accent })
  _edge-rules(c, w, h, m, B, r + B / 2) + nib.knot(links, style: "weave", width: sw * 1pt, fill: cols, outline: ol * 1pt, outline-fill: c.ink)
}

// ── braid: two side-by-side plaits (the Celtic double braid)
#let _braid(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let r = if c.radius == auto { B * 1.1 } else { _pt(c.radius) }
  let per = _perimeter(m + B / 2, m + B / 2, w - m - B / 2, h - m - B / 2, r)
  let period = if c.period == auto { B * 0.95 } else { _pt(c.period) }
  let K = int(calc.max(4, calc.round(per.length / period)))
  let sw = B * 0.115
  let ol = B * 0.03
  let amp = B * 0.25 - sw / 2 - ol - B * 0.012
  let strands = ()
  let cols = ()
  for (row, off) in ((0, -B * 0.25), (1, B * 0.25)) {
    for j in range(2) {
      strands.push(_wavy(per, K * 10, s => off + amp * calc.sin(2 * calc.pi * K * s / per.length + j * calc.pi + row * calc.pi / 2)))
      cols.push(if row == 0 { (c.color, c.accent).at(j) } else { (c.accent, c.color).at(j) })
    }
  }
  _edge-rules(c, w, h, m, B, r + B / 2) + nib.knot(strands, style: "weave", width: sw * 1pt, fill: cols, outline: ol * 1pt, outline-fill: c.ink)
}

// ── banknote guilloché: rosettes of fine lines on wavy ribbons
#let _banknote(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let rosette(pl, cu, cv, R, lobes, col, n: 9) = {
    let items = ()
    for j in range(n) {
      let ph = j * 2 * calc.pi / n
      let q = _ell(range(48).map(i => {
        let t = i / 48 * 360deg
        let rho = R * (0.8 + 0.2 * calc.cos(lobes * t + ph * 1rad))
        (cu + rho * calc.cos(t), cv + rho * calc.sin(t))
      }), cycle: true)
      items += _stroke(pl(q), lw * 0.5, col)
    }
    items
  }
  let side(c, B, p, pl) = {
    let items = rosette(pl, p / 2, 0, 0.44 * B, 12, c.color, n: 7)
    items.push(nib.mp-fill(pl(_ell(range(8).map(k => (0.07 * B * calc.cos(k * 45deg), 0.07 * B * calc.sin(k * 45deg))), cycle: true)), fill: c.accent))
    items
  }
  let corner(c, B, pl) = rosette(pl, 0, 0, 0.5 * B, 16, c.accent, n: 8) + rosette(pl, 0, 0, 0.3 * B, 10, c.color, n: 5)
  _edge-rules(c, w, h, m, B, B * 0.5, thick: 1.8, thin: 1.0) + _motif-band(c, w, h, 1.12, side, corner)
}

// ═════════════════════════════════════════════════════════════════ more styles (0.3)
// ── helpers
#let _circle-pts(cu, cv, r, n: 12) = range(n).map(k => (cu + r * calc.cos(k * 360deg / n), cv + r * calc.sin(k * 360deg / n)))
#let _lozenge(cu, cv, a, b) = ((cu - a, cv), (cu, cv - b), (cu + a, cv), (cu, cv + b))
#let _trefoil-pts(cu, cv, s) = range(30).map(i => {
  let t = i / 30 * 360deg
  (cu + s * (calc.sin(t) + 2 * calc.sin(2 * t)), cv + s * (calc.cos(t) - 2 * calc.cos(2 * t)) + s * 0.2)
})
#let _star(pl, cu, cv, R, nsq, cols, c, wd: 0.15) = {
  let sq(k) = {
    let a0 = k * 90deg / nsq
    pl(_poly(range(4).map(j => (cu + R * calc.cos(a0 + j * 90deg), cv + R * calc.sin(a0 + j * 90deg))), cycle: true))
  }
  nib.knot(range(nsq).map(sq), style: "weave", width: R * wd * 1pt, fill: cols, outline: R * wd * 0.3 * 1pt, outline-fill: c.ink)
}

// ── baroque: calligraphic scrolls on a wavy stem, with leaf tufts
#let _baroque(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let scroll(pl, cu, cv, R, a0, dir) = {
    let items = _calli(pl(_spiral(cu, cv, R, 0.3 * R, a0, 1.15, dir)), B * 0.09, c.color)
    // a leaf at the base and one at the tip of the scroll
    let t = a0 + dir * 360deg * 1.15
    let tip = (cu + 0.3 * R * calc.cos(t), cv + 0.3 * R * calc.sin(t))
    items.push(nib.mp-fill(pl(_leaf(cu + R * calc.cos(a0), cv + R * calc.sin(a0), 0.3 * B, 0.07 * B, if dir == 1 { 0deg } else { 180deg })), fill: c.accent))
    items.push(nib.mp-fill(pl(_leaf(cu + 0.7 * R * calc.cos(a0 + dir * 180deg), cv + 0.7 * R * calc.sin(a0 + dir * 180deg), 0.26 * B, 0.06 * B, if dir == 1 { 180deg } else { 0deg })), fill: c.accent))
    items
  }
  let side(c, B, p, pl) = {
    let n = 8
    let stem = _ell(range(n + 1).map(i => (p * i / n, -0.04 * B * calc.cos(i / n * 360deg))))
    let items = _calli(pl(stem), B * 0.09, c.color)
    items += scroll(pl, p * 0.25, 0.04 * B + 0.2 * B, 0.2 * B, -90deg, 1)
    items += scroll(pl, p * 0.75, 0.04 * B + 0.2 * B, 0.2 * B, -90deg, -1)
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for k in range(8) {
      let t = k * 45deg
      items.push(nib.mp-fill(pl(_leaf(0.08 * B * calc.cos(t), 0.08 * B * calc.sin(t), 0.4 * B, 0.09 * B, t)), fill: if calc.rem(k, 2) == 0 { c.color } else { c.accent }))
    }
    items.push(nib.mp-fill(pl(_ell(_circle-pts(0, 0, 0.1 * B, n: 10), cycle: true)), fill: c.paper))
    items
  }
  _edge-rules(c, w, h, m, B, B * 0.4, thick: 1.3, thin: 0.8) + _motif-band(c, w, h, 2.3, side, corner)
}

// ── triquetra: a trefoil knot per period
#let _triquetra(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let tre(pl, cu, cv, s, col) = nib.knot(pl(_ell(_trefoil-pts(cu, cv, s), cycle: true)), style: "weave", width: s * 0.55 * 1pt, fill: col, outline: s * 0.17 * 1pt, outline-fill: c.ink)
  let side(c, B, p, pl) = tre(pl, p / 2, 0, B * 0.16, c.color)
  let corner(c, B, pl) = tre(pl, 0, 0, B * 0.16, c.accent)
  _edge-rules(c, w, h, m, B, B * 0.45) + _motif-band(c, w, h, 1.12, side, corner)
}

// ── solomon: Solomon's knots (two crossed loops, woven)
#let _solomon(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let sup(cu, cv, a, b) = range(16).map(k => {
    let t = k * 22.5deg
    let (ct, st) = (calc.cos(t), calc.sin(t))
    (cu + a * (if ct < 0 { -1 } else { 1 }) * calc.pow(calc.abs(ct), 0.55), cv + b * (if st < 0 { -1 } else { 1 }) * calc.pow(calc.abs(st), 0.55))
  })
  let sol(pl, cu, cv, k, col) = nib.knot((pl(_ell(sup(cu, cv, 0.62 * k, 0.24 * k), cycle: true)), pl(_ell(sup(cu, cv, 0.24 * k, 0.62 * k), cycle: true))), style: "weave", width: k * 0.15 * 1pt, fill: (col, c.accent), outline: k * 0.045 * 1pt, outline-fill: c.ink)
  let side(c, B, p, pl) = sol(pl, p / 2, 0, B * 0.78, c.color)
  let corner(c, B, pl) = sol(pl, 0, 0, B * 0.78, c.accent)
  _edge-rules(c, w, h, m, B, B * 0.45) + _motif-band(c, w, h, 1.3, side, corner)
}

// ── zellige: twelve-pointed stars (three woven squares)
#let _zellige(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let side(c, B, p, pl) = _star(pl, p / 2, 0, B * 0.47, 3, (c.color, c.accent, c.color), c, wd: 0.17)
  let corner(c, B, pl) = _star(pl, 0, 0, B * 0.47, 3, (c.accent, c.color, c.accent), c, wd: 0.17)
  _edge-rules(c, w, h, m, B, B * 0.45) + _motif-band(c, w, h, 1.12, side, corner)
}

// ── seigaiha: Japanese waves (overlapping scales; needs `paper`)
#let _seigaiha(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let half(cu, cv, r) = _ell(range(0, 13).map(i => { let t = i * 15deg; (cu + r * calc.cos(t), cv + r * calc.sin(t)) }) + ((cu - r, cv),), cycle: true)
  let wave(pl, cu, cv, r, col) = {
    let items = (nib.mp-fill(pl(half(cu, cv, r)), fill: c.paper),)
    for (k, f) in (1.0, 0.68, 0.36).enumerate() {
      items += _stroke(pl(_ell(range(0, 13).map(i => { let t = i * 15deg; (cu + r * f * calc.cos(t), cv + r * f * calc.sin(t)) }))), lw * (if k == 0 { 1.5 } else { 1.0 }), if k == 1 { c.accent } else { col })
    }
    items
  }
  let side(c, B, p, pl) = {
    let items = ()
    let r = p / 2
    // far row first, near row (outer edge) last
    for (j, off) in ((2, 0.0), (1, 0.0), (0, 0.0)) {
      let cv = -0.5 * B + j * 0.25 * B
      for (u, col) in ((p * (0.5 - 0.5 * calc.rem(j, 2)), c.color), (p * (1.0 - 0.5 * calc.rem(j, 2)), c.color)) {
        items += wave(pl, u, cv, r, col)
      }
    }
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for (k, (r, col, wd)) in ((1.0, c.color, 1.5), (0.76, c.accent, 1.0), (0.52, c.color, 1.0), (0.28, c.accent, 1.0)).enumerate() {
      items += _stroke(pl(_ell(range(0, 7).map(i => { let t = i * 15deg; (-0.5 * B + r * B * calc.cos(t), -0.5 * B + r * B * calc.sin(t)) }))), lw * wd, col)
    }
    items
  }
  _motif-band(c, w, h, 0.8, side, corner) + _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.4, thin: 0.6)
}

// ── kilim: a chain of nested lozenges
#let _kilim(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let loz(pl, cu, cv, a, b, col, col2) = {
    let items = _stroke(pl(_poly(_lozenge(cu, cv, a, b), cycle: true)), lw * 1.8, col)
    items.push(nib.mp-fill(pl(_poly(_lozenge(cu, cv, a * 0.5, b * 0.5), cycle: true)), fill: col2))
    items.push(nib.mp-fill(pl(_poly(_lozenge(cu, cv, a * 0.16, b * 0.16), cycle: true)), fill: c.paper))
    items
  }
  let side(c, B, p, pl) = {
    let items = loz(pl, p / 2, 0, p * 0.46, B * 0.46, c.color, c.accent)
    items.push(nib.mp-fill(pl(_poly(_lozenge(0, 0, 0.08 * B, 0.08 * B), cycle: true)), fill: c.ink))
    items
  }
  let corner(c, B, pl) = {
    let items = _stroke(pl(_poly(_lozenge(0, 0, 0.5 * B, 0.5 * B), cycle: true)), lw * 1.8, c.accent)
    items += loz(pl, 0, 0, 0.32 * B, 0.32 * B, c.color, c.accent)
    items
  }
  _edge-rules(c, w, h, m, B, B * 0.2, thick: 1.6, thin: 1.0) + _motif-band(c, w, h, 1.0, side, corner)
}

// ── laurel: a garland of leaves and berries
#let _laurel(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let side(c, B, p, pl) = {
    let items = _stroke(pl(_poly(((0, 0), (p, 0)))), lw * 1.3, c.ink)
    for (i, u) in (0.12, 0.58).enumerate() {
      for sgn in (1, -1) {
        items.push(nib.mp-fill(pl(_leaf(p * u, 0, 0.45 * B, 0.085 * B, sgn * 38deg)), fill: c.color))
      }
    }
    for u in (0.4, 0.86) { items.push(nib.mp-fill(pl(_ell(_circle-pts(p * u, 0, 0.09 * B, n: 8), cycle: true)), fill: c.accent)) }
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for k in range(8) {
      let ang = k * 45deg
      items.push(nib.mp-fill(pl(_leaf(0.05 * B * calc.cos(ang), 0.05 * B * calc.sin(ang), 0.44 * B, 0.09 * B, ang)), fill: if calc.even(k) { c.color } else { c.accent }))
    }
    items.push(nib.mp-fill(pl(_ell(_circle-pts(0, 0, 0.09 * B, n: 8), cycle: true)), fill: c.ink))
    items
  }
  _edge-rules(c, w, h, m, B, B * 0.4, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 0.85, side, corner)
}

// ── flowers: daisies on a wavy stem
#let _flowers(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let flower(pl, cu, cv, R, n, col, col2) = {
    let items = ()
    for k in range(n) {
      let ang = k * 360deg / n
      items.push(nib.mp-fill(pl(_leaf(cu + 0.08 * R * calc.cos(ang), cv + 0.08 * R * calc.sin(ang), R, R * 0.36, ang)), fill: col))
    }
    items.push(nib.mp-fill(pl(_ell(_circle-pts(cu, cv, R * 0.22, n: 8), cycle: true)), fill: col2))
    items
  }
  let side(c, B, p, pl) = {
    let items = ()
    let stem = _ell(range(9).map(i => (p * i / 8, 0.1 * B * calc.sin(i / 8 * 360deg + 90deg))))
    items += _stroke(pl(stem), lw * 1.3, c.ink)
    items += flower(pl, p / 2, 0.1 * B * calc.sin(270deg), 0.4 * B, 6, c.accent, c.color)
    for sgn in (1, -1) { items.push(nib.mp-fill(pl(_leaf(0.02 * p, 0.1 * B, 0.3 * B, 0.07 * B, sgn * 55deg)), fill: c.color)) }
    items
  }
  let corner(c, B, pl) = flower(pl, 0, 0, 0.5 * B, 8, c.color, c.accent) + flower(pl, 0, 0, 0.3 * B, 8, c.accent, c.ink)
  _edge-rules(c, w, h, m, B, B * 0.4, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.35, side, corner)
}

// ── stamp: a perforated edge
#let _stamp(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let rb = B * 0.2
  let step = B * 0.52
  // one side, from (ax, ay) to (bx, by); `nx, ny` is the inward normal
  let side(ax, ay, bx, by, nx, ny) = {
    let len = calc.sqrt(calc.pow(bx - ax, 2) + calc.pow(by - ay, 2))
    let (tx, ty) = ((bx - ax) / len, (by - ay) / len)
    let n = calc.max(1, calc.round((len - 2 * rb) / step))
    let st = (len - 2 * rb) / n
    let pts = ()
    for i in range(int(n)) {
      let cu = rb + st * (i + 0.5)
      for k in range(0, 9) {
        let t = 180deg - k * 22.5deg      // half circle bulging inwards
        let (du, dv) = (rb * calc.cos(t), rb * calc.sin(t))
        pts.push((ax + (cu + du) * tx + dv * nx, ay + (cu + du) * ty + dv * ny))
      }
    }
    pts
  }
  let (x0, y0, x1, y1) = (m, m, w - m, h - m)
  let pts = ((x0, y0),) + side(x0, y0, x1, y0, 0, 1) + ((x1, y0),) + side(x1, y0, x1, y1, -1, 0) + ((x1, y1),) + side(x1, y1, x0, y1, 0, -1) + ((x0, y1),) + side(x0, y1, x0, y0, 1, 0)
  _stroke(_poly(pts, cycle: true), lw * 1.6, c.color) + _stroke(_poly(((m + B, m + B), (w - m - B, m + B), (w - m - B, h - m - B), (m + B, h - m - B)), cycle: true), lw * 1.0, c.accent)
}

// ── film: sprocket holes
#let _film(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let hole(pl, cu, cv, a, b) = _stroke(pl(nib.round-corners(((cu - a, cv - b), (cu + a, cv - b), (cu + a, cv + b), (cu - a, cv + b)).map(q => _P(..q)), r: 0.35 * a * 1pt, cycle: true)), lw * 1.2, c.color)
  let side(c, B, p, pl) = hole(pl, p / 2, -0.26 * B, 0.17 * B, 0.12 * B) + hole(pl, p / 2, 0.26 * B, 0.17 * B, 0.12 * B)
  let corner(c, B, pl) = _stroke(pl(_ell(_circle-pts(0, 0, 0.2 * B, n: 10), cycle: true)), lw * 1.2, c.accent)
  _edge-rules(c, w, h, m, B, B * 0.25, thick: 3.0, thin: 1.4) + _motif-band(c, w, h, 0.55, side, corner)
}

// ── photo corners
#let _photo(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let L = B * 1.5
  let items = ()
  for (cx, cy, sx, sy) in (if c.corners { ((m, m, 1, 1), (w - m, m, -1, 1), (w - m, h - m, -1, -1), (m, h - m, 1, -1)) } else { () }) {
    let tri = _poly(((cx, cy), (cx + sx * L, cy), (cx, cy + sy * L)), cycle: true)
    items.push(nib.mp-fill(tri, fill: c.color))
    items += _stroke(_poly(((cx + sx * L * 0.12, cy + sy * L * 0.12), (cx + sx * L * 0.62, cy + sy * L * 0.12), (cx + sx * L * 0.12, cy + sy * L * 0.62)), cycle: true), lw, c.paper)
  }
  items += _edge-rules(c, w, h, m, B, B * 0.2, thick: 1.0, thin: 0.7)
  items
}

// ── neon: a glowing tube
#let _neon(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let r = B * 1.4
  let tube(a, col, wd) = {
    let q = nib.round-corners(((a * 1pt, a * 1pt), ((w - a) * 1pt, a * 1pt), ((w - a) * 1pt, (h - a) * 1pt), (a * 1pt, (h - a) * 1pt)), r: calc.max(r - (a - m), 0.5) * 1pt, cycle: true)
    _stroke(q, wd * 3.4, col.transparentize(88%)) + _stroke(q, wd * 2.2, col.transparentize(70%)) + _stroke(q, wd * 1.3, col.transparentize(35%)) + _stroke(q, wd * 0.55, col.lighten(70%))
  }
  tube(m + B * 0.35, c.color, B * 0.12) + tube(m + B * 0.8, c.accent, B * 0.09)
}

// ── illumination: a manuscript border (gold rules, quatrefoil frieze, sunburst medallions)
#let _illumination(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let side(c, B, p, pl) = {
    let items = ()
    for (dx, dy) in ((1, 0), (-1, 0), (0, 1), (0, -1)) {
      items += _stroke(pl(_ell(_circle-pts(p / 2 + dx * 0.17 * B, dy * 0.17 * B, 0.17 * B, n: 10), cycle: true)), lw * 1.3, c.color)
    }
    items.push(nib.mp-fill(pl(_ell(_circle-pts(p / 2, 0, 0.07 * B, n: 8), cycle: true)), fill: c.accent))
    items.push(nib.mp-fill(pl(_poly(_lozenge(0, 0, 0.1 * B, 0.1 * B), cycle: true)), fill: c.accent))
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for k in range(16) {
      let ang = k * 22.5deg
      items.push(nib.mp-fill(pl(_leaf(0.2 * B * calc.cos(ang), 0.2 * B * calc.sin(ang), 0.3 * B, 0.05 * B, ang)), fill: if calc.even(k) { c.color } else { c.accent }))
    }
    items += _stroke(pl(_ell(_circle-pts(0, 0, 0.5 * B, n: 16), cycle: true)), lw * 1.6, c.accent)
    items += _stroke(pl(_ell(_circle-pts(0, 0, 0.2 * B, n: 12), cycle: true)), lw * 1.2, c.color)
    items.push(nib.mp-fill(pl(_ell(_circle-pts(0, 0, 0.08 * B, n: 8), cycle: true)), fill: c.ink))
    items
  }
  let rr(a, rad) = nib.round-corners(((a * 1pt, a * 1pt), ((w - a) * 1pt, a * 1pt), ((w - a) * 1pt, (h - a) * 1pt), (a * 1pt, (h - a) * 1pt)), r: rad * 1pt, cycle: true)
  _stroke(rr(m, B * 0.2), lw * 3.4, c.accent) + _stroke(rr(m, B * 0.2), lw * 0.7, c.ink) + _stroke(rr(m + B, B * 0.05), lw * 1.6, c.accent) + _stroke(rr(m + B, B * 0.05), lw * 0.6, c.ink) + _motif-band(c, w, h, 1.15, side, corner)
}

// ── bill-*: security-print guilloché borders. Every hairline is a closed loop that runs all the way round the
//    page (continuous contour); the pattern is mirror-symmetric left/right and top/bottom; corners are optional.
#let _gl-ring(cu, cv, R, lobes, col, lw, n: 4) = {
  let items = ()
  for j in range(n) {
    let ph = j * 2 * calc.pi / n
    let q = _ell(range(48).map(i => {
      let t = i / 48 * 360deg
      let rho = R * (0.8 + 0.2 * calc.cos(lobes * t + ph * 1rad))
      (cu + rho * calc.cos(t), cv + rho * calc.sin(t))
    }), cycle: true)
    items += _stroke(q, lw, col)
  }
  items
}
// pf: length of one period (in bands); fams: ((n, f, "color"|"accent"), …), f(s, th, B) -> offset, EVEN in th;
// rings: none or (step-degrees, offset, radius-in-bands): small rosettes along the contour.
#let _gl(pf, fams, rings: none, per: 14, rules: true, ornament: true, poly: false) = (c, w, h) => {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line) * 0.55
  let Rc = 0.62 * B
  let (xl, xr, yt, yb) = (m + B / 2, w - m - B / 2, m + B / 2, h - m - B / 2)
  let (Lx, Ly) = (xr - xl - 2 * Rc, yb - yt - 2 * Rc)
  let even(L) = 2 * int(calc.max(1, calc.round(L / (2 * pf * B))))
  let (Nx, Ny) = (even(Lx), even(Ly))
  let tp(N, f, s) = range(N * per + 1).map(j => (j / (N * per), f(s, 360deg * j / per - 180deg * N, B)))
  let arc(cx, cy, a0, r) = range(1, 6).map(k => (cx + r * calc.cos(a0 + k * 15deg), cy + r * calc.sin(a0 + k * 15deg)))
  let items = ()
  for fam in fams {
    let (n, f, key) = fam.slice(0, 3)
    let wm = if fam.len() > 3 { fam.at(3) } else { 1 }
    let col = if key == "accent" { c.accent } else { c.color }
    for i in range(n) {
      let s = if n > 1 { i / (n - 1) } else { 0 }
      let v0 = f(s, 0deg, B)
      let pts = tp(Nx, f, s).map(((t, v)) => (xl + Rc + t * Lx, yt + v))
      pts += arc(xr - Rc, yt + Rc, -90deg, Rc - v0)
      pts += tp(Ny, f, s).map(((t, v)) => (xr - v, yt + Rc + t * Ly))
      pts += arc(xr - Rc, yb - Rc, 0deg, Rc - v0)
      pts += tp(Nx, f, s).map(((t, v)) => (xr - Rc - t * Lx, yb - v))
      pts += arc(xl + Rc, yb - Rc, 90deg, Rc - v0)
      pts += tp(Ny, f, s).map(((t, v)) => (xl + v, yb - Rc - t * Ly))
      pts += arc(xl + Rc, yt + Rc, 180deg, Rc - v0)
      items += _stroke(if poly { _poly(pts, cycle: true) } else { _ell(pts, cycle: true) }, lw * wm, col)
    }
  }
  if rings != none {
    let (step, off, rr) = rings
    for (N, L) in ((Nx, Lx), (Ny, Ly)) {
      let k = 1
      while -180 * N + step * k < 180 * N - 0.01 {
        let t = (step * k) / (360 * N)
        let u = t * L
        let cs = if N == Nx { ((xl + Rc + u, yt + off), (xr - Rc - u, yb - off)) } else { ((xr - off, yt + Rc + u), (xl + off, yb - Rc - u)) }
        for (cu, cv) in cs { items += _gl-ring(cu, cv, rr * B, 10, c.accent, lw, n: 3) }
        k += 1
      }
    }
  }
  if c.corners and ornament {
    let cc = if c.corner-color == auto { c.accent.lighten(25%) } else { c.corner-color }
    let d = 0.293 * Rc
    for (cx, cy) in ((xl + d, yt + d), (xr - d, yt + d), (xr - d, yb - d), (xl + d, yb - d)) {
      items += _gl-ring(cx, cy, 0.46 * B, 12, cc, lw * 1.2, n: 6) + _gl-ring(cx, cy, 0.28 * B, 8, cc, lw * 1.2, n: 4)
    }
  }
  (if rules { _edge-rules(c, w, h, m, B, Rc + B / 2, thick: 1.2, thin: 0.7) } else { () }) + items
}
#let _cs(a) = calc.cos(a)
#let _bill-lens = _gl(2.0, (
  (13, (s, th, B) => B * 0.44 * (2 * s - 1) * _cs(th), "color"),
  (13, (s, th, B) => B * 0.44 * (2 * s - 1) * _cs(2 * th), "accent")))
#let _bill-fan = _gl(1.3, ((22, (s, th, B) => B * (-0.40 + 0.80 * s) + B * 0.14 * (1 - s) * calc.abs(_cs(th / 2)), "color"),), rings: (360, -0.08, 0.17))
#let _bill-ribbon = _gl(1.7, (
  (22, (s, th, B) => B * 0.44 * _cs(th + s * 180deg), "color"),
  (22, (s, th, B) => B * 0.44 * _cs(th - s * 180deg), "accent")))
#let _bill-shell = _gl(1.0, (
  (22, (s, th, B) => B * (-0.44 + 0.84 * s * (0.3 + 0.7 * calc.abs(_cs(th / 2)))), "color"),
  (3, (s, th, B) => B * (0.40 + 0.06 * s), "accent")))
#let _bill-wave = _gl(2.2, ((24, (s, th, B) => B * (-0.39 + 0.54 * s) + B * (0.04 + 0.26 * s) * _cs(th), "color"),))
#let _bill-frill = _gl(0.9, (
  (24, (s, th, B) => B * (-0.27 + 0.63 * s) + B * 0.12 * (1 - s) * _cs(3 * th) + B * 0.05 * _cs(th), "color"),
  (2, (s, th, B) => B * (0.41 + 0.05 * s), "accent")))
#let _bill-net = _gl(1.8, (
  (16, (s, th, B) => B * 0.34 * (1 + 0.25 * _cs(th / 2)) * _cs(th + s * 360deg), "color"),
  (16, (s, th, B) => B * 0.34 * (1 + 0.25 * _cs(th / 2)) * _cs(th - s * 360deg), "accent")))
#let _bill-swell = _gl(2.0, ((22, (s, th, B) => B * 0.18 * _cs(th) + B * 0.25 * (2 * s - 1) * (0.4 + 0.6 * _cs(th)), "color"),))
#let _bill-plait = _gl(1.0, (
  (11, (s, th, B) => B * 0.43 * _cs(th + s * 360deg), "color"),
  (11, (s, th, B) => B * 0.43 * _cs(th - s * 360deg), "accent")), per: 12)
#let _bill-rosette = _gl(1.9, ((11, (s, th, B) => B * 0.44 * (2 * s - 1) * _cs(th), "color"),), rings: (180, 0, 0.3))

#let _tri(a) = { let t = calc.rem(calc.abs(a / 180deg), 2); if t < 1 { 1 - 2 * t } else { 2 * t - 3 } }
#let _bill-wavy = _gl(2.0, (
  (16, (s, th, B) => B * (0.17 * _cs(th) + 0.26 * (2 * s - 1)), "color"),
  (16, (s, th, B) => B * (0.17 * _cs(th) + 0.26 * (2 * s - 1) * _cs(2 * th)), "accent")), rules: false)
#let _bill-diploma = _gl(2.2, (
  (18, (s, th, B) => B * (-0.40 + 0.06 * _cs(th) + 0.6 * s * (0.55 + 0.45 * _cs(th))), "color"),
  (2, (s, th, B) => B * (0.38 + 0.04 * _cs(th) + 0.05 * s), "accent")), rules: false)
#let _bill-lattice = _gl(2.2, (
  (12, (s, th, B) => B * 0.42 * _tri(th + s * 180deg), "color"),
  (12, (s, th, B) => B * 0.42 * _tri(th - s * 180deg), "accent")))
#let _bill-weave = _gl(2.0, (
  (14, (s, th, B) => B * (0.1 * _cs(th) + 0.3 * _cs(th + s * 120deg)), "color"),
  (14, (s, th, B) => B * (0.1 * _cs(th) + 0.3 * _cs(th - s * 120deg)), "accent")), rules: false)

// ── texture and seal (any style)
#let _extras(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line) * 0.45
  let tc = if c.texture-color == auto { c.accent.lighten(30%) } else { c.texture-color }
  let (x0, y0, x1, y1) = (m + B + 1.5 * _pt(1mm), m + B + 1.5 * _pt(1mm), w - m - B - 1.5 * _pt(1mm), h - m - B - 1.5 * _pt(1mm))
  let (W, H) = (x1 - x0, y1 - y0)
  let under = ()
  let over = ()
  if c.texture == "scales" {
    let R = calc.max(_pt(3.5mm), calc.sqrt(W * H / 900))
    let nx = int(calc.floor(W / (2 * R)))
    let ny = int(calc.floor((H - R) / R))
    let xs = x0 + (W - nx * 2 * R) / 2
    let ys = y0 + (H - (ny + 1) * R) / 2
    for j in range(ny) {
      for i in range(nx - (if calc.odd(j) { 1 } else { 0 })) {
        let (cu, cv) = (xs + R + i * 2 * R + (if calc.odd(j) { R } else { 0 }), ys + j * R)
        under += _stroke(_ell(range(0, 9).map(k => (cu + R * calc.cos(k * 22.5deg), cv + R * calc.sin(k * 22.5deg)))), lw, tc)
      }
    }
  } else if c.texture == "waves" {
    let gap = calc.max(_pt(2mm), H / 110)
    let n = int(calc.floor(H / gap))
    let lam = _pt(9mm)
    let nn = int(calc.floor(W / lam * 8))
    for fam in (1, -1) {
      for k in range(n + 1) {
        under += _stroke(_ell(range(nn + 1).map(j => { let x = W * j / nn; (x0 + x, y0 + k * gap + gap * 0.9 * calc.sin(x / W * 360deg * (W / lam) + fam * k * 14deg)) })), lw, tc)
      }
    }
  } else if c.texture == "rosettes" {
    let S = calc.max(_pt(14mm), calc.sqrt(W * H / 160))
    let nx = int(calc.floor(W / S))
    let ny = int(calc.floor(H / S))
    for j in range(ny) {
      for i in range(nx) {
        let (cu, cv) = (x0 + (W - nx * S) / 2 + (i + 0.5) * S, y0 + (H - ny * S) / 2 + (j + 0.5) * S)
        under += _gl-ring(cu, cv, 0.48 * S, 12, tc, lw, n: 3)
      }
    }
  } else { assert(c.texture == none, message: "nibframe: texture must be none, \"scales\", \"waves\" or \"rosettes\"") }
  if c.seal {
    let R = _pt(11mm)
    let (cu, cv) = (x1 - R - _pt(3mm), y0 + R + _pt(3mm))
    let sc = if c.texture-color == auto { c.color } else { c.texture-color }
    over.push(nib.mp-fill(_ell(_circle-pts(cu, cv, R * 1.12, n: 32), cycle: true), fill: c.paper))
    over += _gl-ring(cu, cv, R, 14, sc, lw * 1.4, n: 5) + _gl-ring(cu, cv, R * 0.62, 10, c.accent, lw * 1.4, n: 4)
    over += _stroke(_ell(_circle-pts(cu, cv, R * 1.1, n: 32), cycle: true), lw * 1.6, sc)
  }
  (under, over)
}

// ── more styles: airmail, checker, stars, hearts, eggdart, vitruvian, arches, tapa, stripes, herringbone
#let _rect(u0, v0, u1, v1) = _poly(((u0, v0), (u1, v0), (u1, v1), (u0, v1)), cycle: true)
#let _star-pts(cu, cv, R, n, ratio, a0) = range(2 * n).map(k => {
  let t = a0 + k * 180deg / n
  let r = if calc.even(k) { R } else { R * ratio }
  (cu + r * calc.cos(t), cv + r * calc.sin(t))
})
#let _heart-pts(cu, cv, k, rot) = range(40).map(i => {
  let t = i / 40 * 360deg
  let x = 16 * calc.pow(calc.sin(t), 3)
  let y = 13 * calc.cos(t) - 5 * calc.cos(2 * t) - 2 * calc.cos(3 * t) - calc.cos(4 * t)
  (cu + k * (x * calc.cos(rot) - y * calc.sin(rot)), cv + k * (x * calc.sin(rot) + y * calc.cos(rot)))
})
#let _fillp(pl, pts, col) = nib.mp-fill(pl(_poly(pts, cycle: true)), fill: col)

#let _airmail(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let side(c, B, p, pl) = {
    let (s, hh) = (0.17 * B, 0.5 * B)
    (_fillp(pl, ((0, -hh), (0.5 * p - s, -hh), (0.5 * p, hh), (s, hh)), c.color),
     _fillp(pl, ((0.5 * p, -hh), (p - s, -hh), (p, hh), (0.5 * p + s, hh)), c.accent))
  }
  let corner(c, B, pl) = (_fillp(pl, ((-B / 2, -B / 2), (B / 2, -B / 2), (-B / 2, B / 2)), c.color), _fillp(pl, ((B / 2, -B / 2), (B / 2, B / 2), (-B / 2, B / 2)), c.accent))
  _motif-band(c, w, h, 0.9, side, corner) + _edge-rules(c, w, h, m, B, B * 0.1, thick: 1.0, thin: 1.0)
}
#let _checker(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let side(c, B, p, pl) = (_fillp(pl, ((0, -B / 2), (p / 2, -B / 2), (p / 2, 0), (0, 0)), c.color), _fillp(pl, ((p / 2, -B / 2), (p, -B / 2), (p, 0), (p / 2, 0)), c.accent),
    _fillp(pl, ((0, 0), (p / 2, 0), (p / 2, B / 2), (0, B / 2)), c.accent), _fillp(pl, ((p / 2, 0), (p, 0), (p, B / 2), (p / 2, B / 2)), c.color))
  let corner(c, B, pl) = (_fillp(pl, ((-B / 2, -B / 2), (0, -B / 2), (0, 0), (-B / 2, 0)), c.color), _fillp(pl, ((0, -B / 2), (B / 2, -B / 2), (B / 2, 0), (0, 0)), c.accent),
    _fillp(pl, ((-B / 2, 0), (0, 0), (0, B / 2), (-B / 2, B / 2)), c.accent), _fillp(pl, ((0, 0), (B / 2, 0), (B / 2, B / 2), (0, B / 2)), c.color))
  _motif-band(c, w, h, 1.0, side, corner) + _edge-rules(c, w, h, m, B, B * 0.1, thick: 1.4, thin: 1.4)
}
#let _stars(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let side(c, B, p, pl) = {
    let items = (_fillp(pl, _star-pts(p / 2, 0, 0.4 * B, 5, 0.42, 90deg), c.color),)
    for u in (0, p) { items.push(nib.mp-fill(pl(_ell(_circle-pts(u, 0, 0.07 * B, n: 8), cycle: true)), fill: c.accent)) }
    items
  }
  let corner(c, B, pl) = (_fillp(pl, _star-pts(0, 0, 0.48 * B, 8, 0.5, 90deg), c.accent), _fillp(pl, _star-pts(0, 0, 0.22 * B, 8, 0.5, 90deg), c.color))
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.0, side, corner)
}
#let _hearts(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let side(c, B, p, pl) = {
    let items = (nib.mp-fill(pl(_ell(_heart-pts(p / 2, 0, 0.021 * B, 180deg), cycle: true)), fill: c.color),)
    for u in (0, p) { items.push(nib.mp-fill(pl(_ell(_circle-pts(u, 0, 0.06 * B, n: 8), cycle: true)), fill: c.accent)) }
    items
  }
  let corner(c, B, pl) = (nib.mp-fill(pl(_ell(_heart-pts(0, 0, 0.026 * B, 135deg), cycle: true)), fill: c.accent),)
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 0.95, side, corner)
}
#let _eggdart(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let side(c, B, p, pl) = {
    let egg = _ell(range(24).map(i => (p / 2 + 0.24 * p * calc.cos(i * 15deg), 0.03 * B + 0.33 * B * calc.sin(i * 15deg))), cycle: true)
    let items = (nib.mp-fill(pl(egg), fill: c.accent),)
    items += _stroke(pl(egg), lw * 1.3, c.color)
    items += _stroke(pl(_ell(range(0, 13).map(i => (p / 2 + 0.4 * p * calc.cos(180deg + i * 15deg), 0.03 * B + 0.44 * B * calc.sin(180deg + i * 15deg))))), lw * 1.6, c.color)
    items.push(_fillp(pl, ((0, -0.4 * B), (0.06 * B, 0), (0, 0.4 * B), (-0.06 * B, 0)), c.color))
    items
  }
  let corner(c, B, pl) = (_fillp(pl, ((0, -0.44 * B), (0.44 * B, 0), (0, 0.44 * B), (-0.44 * B, 0)), c.color), _fillp(pl, ((0, -0.24 * B), (0.24 * B, 0), (0, 0.24 * B), (-0.24 * B, 0)), c.accent))
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.05, side, corner)
}
#let _vitruvian(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let side(c, B, p, pl) = {
    let wave = _ell(range(13).map(i => (p * i / 12, -0.24 * B * calc.cos(i / 12 * 360deg + 90deg) )))
    let items = _stroke(pl(wave), B * 0.06, c.color)
    items += _stroke(pl(_spiral(0.25 * p, 0.02 * B, 0.22 * B, 0.05 * B, 90deg, 1.25, -1)), B * 0.06, c.accent)
    items
  }
  let corner(c, B, pl) = _stroke(pl(_spiral(0, 0, 0.4 * B, 0.06 * B, 0deg, 1.5, 1)), B * 0.06, c.accent)
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.2, side, corner)
}
#let _arches(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let arch(pl, p, sc, col, wd) = {
    let (x1, x2) = (p * (0.5 - 0.42 * sc), p * (0.5 + 0.42 * sc))
    let (W, y0) = (x2 - x1, -0.5 * B)
    let r = 0.85 * W
    let t = calc.acos((0.5 * W - r) / r)
    let n = 10
    let left = range(n + 1).map(i => { let a = 180deg - (180deg - t) * i / n; (x1 + r + r * calc.cos(a), y0 + r * calc.sin(a)) })
    let rt = range(n + 1).map(i => { let a = (180deg - t) * (1 - i / n); (x2 - r + r * calc.cos(a), y0 + r * calc.sin(a)) })
    let pts = left + rt
    _stroke(pl(_poly(pts)), wd, col)
  }
  let side(c, B, p, pl) = arch(pl, p, 1.0, c.color, lw * 2.0) + arch(pl, p, 0.62, c.accent, lw * 1.2) + (nib.mp-fill(pl(_ell(_circle-pts(p / 2, 0.36 * B, 0.06 * B, n: 8), cycle: true)), fill: c.accent),)
  let corner(c, B, pl) = (_fillp(pl, ((0, -0.42 * B), (0.42 * B, 0), (0, 0.42 * B), (-0.42 * B, 0)), c.color), _fillp(pl, ((0, -0.22 * B), (0.22 * B, 0), (0, 0.22 * B), (-0.22 * B, 0)), c.paper))
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.05, side, corner)
}
#let _herringbone(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let side(c, B, p, pl) = {
    let seg = _poly(((0.1 * p, -0.34 * B), (0.9 * p, 0.34 * B)))
    _stroke(pl(seg), B * 0.3, c.ink) + _stroke(pl(seg), B * 0.22, c.color)
  }
  let corner(c, B, pl) = {
    let ring = _ell(_circle-pts(0, 0, 0.3 * B, n: 12), cycle: true)
    (nib.mp-fill(pl(ring), fill: c.accent),) + _stroke(pl(ring), _pt(c.line) * 1.5, c.ink)
  }
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 0.42, side, corner)
}
#let _tapa = _gl(1.4, (
  (3, (s, th, B) => B * (0.17 * _tri(th) + (2 * s - 1) * 0.27), "color", 3.5),
  (2, (s, th, B) => B * (0.17 * _tri(th + 180deg) + (2 * s - 1) * 0.12), "accent", 2.0)), per: 2, poly: true)
#let _stripes = _gl(1.0, (
  (2, (s, th, B) => B * (-0.40 + 0.8 * s), "color", 4.0),
  (2, (s, th, B) => B * (-0.27 + 0.54 * s), "accent", 1.6),
  (2, (s, th, B) => B * (-0.17 + 0.34 * s), "color", 1.0),
  (1, (s, th, B) => 0 * B, "accent", 2.6)), per: 2, ornament: false)

// ── grid knots (Celtic knotwork from walls): strands run along the diagonals of a grid and bounce off the walls;
//    the crossings are the midpoints of the open cell edges. Coordinates are doubled: a cell is 2 × 2.
//    `extra`: array of edge midpoints (x, y) with a wall (x even: vertical edge; x odd: horizontal edge).
#let _gk(ncx, ncy, extra, dsp: 0.3) = {
  let walls = (:)
  for j in range(ncy) { walls.insert("0," + str(2 * j + 1), "v"); walls.insert(str(2 * ncx) + "," + str(2 * j + 1), "v") }
  for i in range(ncx) { walls.insert(str(2 * i + 1) + ",0", "h"); walls.insert(str(2 * i + 1) + "," + str(2 * ncy), "h") }
  for (x, y) in extra { walls.insert(str(x) + "," + str(y), if calc.even(x) { "v" } else { "h" }) }
  let seen = (:)
  let skey(p, q) = if p.at(0) < q.at(0) or (p.at(0) == q.at(0) and p.at(1) < q.at(1)) { str(p.at(0)) + "," + str(p.at(1)) + ":" + str(q.at(0)) + "," + str(q.at(1)) } else { str(q.at(0)) + "," + str(q.at(1)) + ":" + str(p.at(0)) + "," + str(p.at(1)) }
  let loops = ()
  for px in range(2 * ncx + 1) {
    for py in range(2 * ncy + 1) {
      if calc.even(px + py) { continue }
      for d in ((1, 1), (1, -1), (-1, 1), (-1, -1)) {
        let q = (px + d.at(0), py + d.at(1))
        if q.at(0) < 0 or q.at(0) > 2 * ncx or q.at(1) < 0 or q.at(1) > 2 * ncy { continue }
        if skey((px, py), q) in seen { continue }
        let p = (px, py)
        let dd = d
        let pts = ()
        let go = true
        let n = 0
        while go {
          let q = (p.at(0) + dd.at(0), p.at(1) + dd.at(1))
          seen.insert(skey(p, q), true)
          let wk = str(q.at(0)) + "," + str(q.at(1))
          if wk in walls {
            if walls.at(wk) == "v" { pts.push((q.at(0) - dd.at(0) * dsp, q.at(1))); dd = (-dd.at(0), dd.at(1)) }
            else { pts.push((q.at(0), q.at(1) - dd.at(1) * dsp)); dd = (dd.at(0), -dd.at(1)) }
          } else { pts.push((q.at(0) * 1.0, q.at(1) * 1.0)) }
          p = q
          n += 1
          if (p == (px, py) and dd == d) or n > 400 { go = false }
        }
        loops.push(pts)
      }
    }
  }
  loops
}


// ════════════════════════════════════════════════════════ 0.7.0: celtic knotwork, floral, arabesque, islamic
// ── celtic knotwork: one closed knot per tile, traced from walls with `_gk`
#let _gk-tile(c, ncx, ncy, extra, x0, sx, sy, pl, first: "color", poly: false, d: 0.3, wd: 0.32) = {
  let loops = _gk(ncx, ncy, extra, dsp: d)
  let paths = loops.map(pts => {
    let q = pts.map(p => (x0 + p.at(0) * sx / 2, (p.at(1) - ncy) * sy / 2))
    pl(if poly { _poly(q, cycle: true) } else { _ell(q, cycle: true) })
  })
  // colours by position (mirror-symmetric): rank of the distance of each loop to the tile axis, then of its height
  let cen = loops.map(pts => (calc.round(calc.abs(pts.map(p => p.at(0)).sum() / pts.len() - ncx) * 50), calc.round(pts.map(p => p.at(1)).sum() / pts.len() * 50)))
  let ds = cen.map(q => q.at(0)).dedup().sorted()
  let cs2 = if first == "color" { (c.color, c.accent) } else { (c.accent, c.color) }
  let cols = cen.map(q => {
    let ys = cen.filter(r => r.at(0) == q.at(0)).map(r => r.at(1)).dedup().sorted()
    cs2.at(calc.rem(ds.position(v => v == q.at(0)) + ys.position(v => v == q.at(1)), 2))
  })
  let u = calc.min(sx, sy)
  nib.knot(paths, style: "weave", width: u * wd * 1pt, fill: cols, outline: u * 0.055 * 1pt, outline-fill: c.ink)
}
#let _knotwork(ncx, extra, per, cextra: (), corner-first: "accent", poly: false, d: 0.3, wd: 0.32, cncx: 2) = (c, w, h) => {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let side(c, B, p, pl, j) = _gk-tile(c, ncx, 2, extra, 0, p / ncx, B / 2, pl, first: if calc.even(j) { "color" } else { "accent" }, poly: poly, d: d, wd: wd)
  let corner(c, B, pl) = _gk-tile(c, cncx, 2, cextra, -B / 2, B / cncx, B / 2, pl, first: corner-first, poly: poly, d: d, wd: wd)
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, per, side, corner, idx: true)
}
#let _knot-cartouche = _knotwork(6, ((1, 2), (11, 2)), 3.0)
#let _knot-eights = _knotwork(4, ((2, 1), (2, 3), (4, 1), (4, 3), (6, 1), (6, 3)), 2.0, cextra: ((1, 2), (3, 2)))
#let _knot-lozenge = _knotwork(6, ((2, 1), (2, 3), (3, 2), (9, 2), (10, 1), (10, 3)), 3.0)
#let _knot-ring = _knotwork(4, ((4, 1), (4, 3)), 2.0, cextra: ((2, 1), (2, 3)))

// ── floral helpers
#let _petal(c, pl, path, col) = (nib.mp-fill(pl(path), fill: col),) + _stroke(pl(path), _pt(c.line) * 0.5, c.ink)
#let _disc(c, pl, cu, cv, r, col) = {
  let pts = _circle-pts(cu, cv, r, n: 16)
  (nib.mp-fill(pl(_poly(pts, cycle: true)), fill: col),) + _stroke(pl(_poly(pts, cycle: true)), _pt(c.line) * 0.5, c.ink)
}

// ── daisy: a garland of round flowers on a stem with small leaves
#let _daisy(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let flower(c, pl, cu, cv, R, n) = {
    let items = ()
    for k in range(n) {
      let a = k * 360deg / n + 15deg
      items += _petal(c, pl, _leaf(cu + 0.13 * R * calc.cos(a), cv + 0.13 * R * calc.sin(a), 0.84 * R, 0.24 * R, a), if calc.even(k) { c.color } else { c.accent })
    }
    items + _disc(c, pl, cu, cv, 0.2 * R, c.ink)
  }
  let side(c, B, p, pl) = {
    let items = _stroke(pl(_poly(((0, 0.0), (p, 0.0)))), lw * 0.9, c.ink)
    for (x, a) in ((0, 30deg), (0, -30deg), (p, 150deg), (p, -150deg)) {
      items += _petal(c, pl, _leaf(x, 0, 0.34 * B, 0.08 * B, a), c.accent)
    }
    items + flower(c, pl, p / 2, 0, 0.48 * B, 8)
  }
  let corner(c, B, pl) = flower(c, pl, 0, 0, 0.48 * B, 8)
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.25, side, corner)
}

// ── sakura: five-petal blossoms (heart-shaped petals) on a branch, with sparkles
#let _sakura(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let blossom(c, pl, cu, cv, R, rot) = {
    let items = ()
    for k in range(5) {
      let a = rot + k * 72deg
      let k0 = 0.0125 * R / (0.47 * B) * B
      items += _petal(c, pl, _poly(_heart-pts(cu + 0.6 * R * calc.cos(a), cv + 0.6 * R * calc.sin(a), 0.03 * R, a - 90deg), cycle: true), c.accent)
    }
    items += _disc(c, pl, cu, cv, 0.12 * R, c.color)
    for k in range(5) {
      let a = rot + 36deg + k * 72deg
      items += (_fillp(pl, _circle-pts(cu + 0.32 * R * calc.cos(a), cv + 0.32 * R * calc.sin(a), 0.045 * R, n: 8), c.ink),)
    }
    items
  }
  let side(c, B, p, pl) = {
    let n = 8
    let stem = _ell(range(n + 1).map(i => (p * i / n, -0.07 * B * calc.sin(i / n * 360deg))))
    let items = _calli(pl(stem), B * 0.07, c.color)
    items += (_fillp(pl, _star-pts(0, 0, 0.17 * B, 4, 0.35, 45deg), c.color),)
    items += (_fillp(pl, _star-pts(p, 0, 0.17 * B, 4, 0.35, 45deg), c.color),)
    items + blossom(c, pl, p / 2, 0, 0.5 * B, -90deg)
  }
  let corner(c, B, pl) = blossom(c, pl, 0, 0, 0.48 * B, 90deg + 36deg)
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.2, side, corner)
}

// ── lotus: upright lotus flowers alternating with inverted buds (the ogee lotus-and-bud frieze)
#let _lotus(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lotus(c, pl, cu, cv, s, dir) = {
    let items = ()
    let up = dir * 90deg
    for (a, l, wd, col) in ((70deg, 0.55, 0.11, c.accent), (-70deg, 0.55, 0.11, c.accent), (36deg, 0.78, 0.14, c.color), (-36deg, 0.78, 0.14, c.color), (0deg, 0.92, 0.16, c.accent)) {
      items += _petal(c, pl, _leaf(cu, cv, l * s, wd * s, up + a * dir), col)
    }
    items
  }
  let side(c, B, p, pl) = {
    let items = lotus(c, pl, p / 2, 0.45 * B, B, -1)
    for x in (0, p) {
      items += _petal(c, pl, _leaf(x, -0.45 * B, 0.3 * B, 0.05 * B, 90deg + 52deg), c.accent)
      items += _petal(c, pl, _leaf(x, -0.45 * B, 0.3 * B, 0.05 * B, 90deg - 52deg), c.accent)
      items += _petal(c, pl, _leaf(x, -0.45 * B, 0.62 * B, 0.13 * B, 90deg), c.color)
    }
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for k in range(4) {
      let a = 45deg + k * 90deg
      items += _petal(c, pl, _leaf(0.06 * B * calc.cos(a), 0.06 * B * calc.sin(a), 0.44 * B, 0.1 * B, a), if calc.even(k) { c.color } else { c.accent })
    }
    items + _disc(c, pl, 0, 0, 0.07 * B, c.ink)
  }
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.3, side, corner)
}

// ── palmette: fans of leaves on a wavy stem, pointing alternately outwards and inwards
#let _palmette(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let fan(c, pl, cu, cv, dir, s) = {
    let items = ()
    for (k, (a, l)) in ((-64deg, 0.34), (-32deg, 0.42), (32deg, 0.42), (64deg, 0.34), (0deg, 0.46)).enumerate() {
      items += _petal(c, pl, _leaf(cu, cv, l * s, 0.1 * s, dir * 90deg + a * dir), if calc.even(k) { c.color } else { c.accent })
    }
    items
  }
  let side(c, B, p, pl) = {
    let n = 12
    let sv(u) = -0.045 * B * calc.sin(u / p * 360deg)
    let stem = _ell(range(n + 1).map(i => (p * i / n, sv(p * i / n))))
    let items = _calli(pl(stem), B * 0.07, c.color)
    items += fan(c, pl, p / 4, sv(p / 4), -1, B)
    items += fan(c, pl, 3 * p / 4, sv(3 * p / 4), 1, B)
    items += _calli(pl(_spiral(p / 2, -0.2 * B, 0.12 * B, 0.03 * B, 90deg, 1.3, -1)), B * 0.06, c.ink)
    items += _calli(pl(_spiral(p / 2, 0.2 * B, 0.12 * B, 0.03 * B, -90deg, 1.3, -1)), B * 0.06, c.ink)
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for k in range(5) { items += _petal(c, pl, _leaf(0, 0, (if k == 2 { 0.46 } else { 0.4 }) * B, 0.07 * B, 0deg + (k - 2) * 22.5deg + 45deg), if calc.even(k) { c.color } else { c.accent }) }
    items + _disc(c, pl, 0, 0, 0.07 * B, c.ink)
  }
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.7, side, corner)
}

// ── ogee lens: chain of almonds, each holding a scroll pair and a leaf
#let _ogee = (c, w, h) => {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let side(c, B, p, pl) = {
    let n = 10
    let hump(sg) = _ell(range(n + 1).map(i => (p * i / n, sg * 0.4 * B * calc.pow(calc.sin(i / n * 180deg), 0.8))))
    let items = _calli(pl(hump(1)), B * 0.11, c.color) + _calli(pl(hump(-1)), B * 0.11, c.color)
    for k in range(4) {
      items += _petal(c, pl, _leaf(p / 2, 0, (if calc.even(k) { 0.3 * B } else { 0.17 * p }), 0.07 * B, k * 90deg), if calc.even(k) { c.accent } else { c.color })
    }
    items += _disc(c, pl, p / 2, 0, 0.045 * B, c.ink)
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for k in range(4) {
      let a = 45deg + k * 90deg
      items += _petal(c, pl, _leaf(0.05 * B * calc.cos(a), 0.05 * B * calc.sin(a), 0.45 * B, 0.12 * B, a), if calc.even(k) { c.accent } else { c.color })
    }
    items + _disc(c, pl, 0, 0, 0.06 * B, c.ink)
  }
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.6, side, corner)
}

// ── rinceau: a large wave with leaf fans on the crests and discs on the nodes
#let _rinceau(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let fan(c, pl, cu, cv, dir) = {
    let items = ()
    for (k, (a, l)) in ((-50deg, 0.3), (50deg, 0.3), (0deg, 0.36)).enumerate() {
      items += _petal(c, pl, _leaf(cu, cv, l * B, 0.1 * B, dir * 90deg + a * dir), if k == 2 { c.accent } else { c.color })
    }
    items
  }
  let side(c, B, p, pl) = {
    let n = 16
    let sv(u) = 0.13 * B * calc.sin(u / p * 360deg)
    let items = _calli(pl(_ell(range(n + 1).map(i => (p * i / n, sv(p * i / n))))), B * 0.1, c.ink)
    items += fan(c, pl, p / 4, sv(p / 4), 1)
    items += fan(c, pl, 3 * p / 4, sv(3 * p / 4), -1)
    items += _calli(pl(_spiral(p / 4, -0.2 * B, 0.12 * B, 0.03 * B, 90deg, 1.3, 1)), B * 0.07, c.color)
    items += _calli(pl(_spiral(3 * p / 4, 0.2 * B, 0.12 * B, 0.03 * B, -90deg, 1.3, 1)), B * 0.07, c.color)
    for x in (0, p / 2, p) { items += _disc(c, pl, x, 0, 0.06 * B, c.accent) }
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for k in range(8) {
      let a = k * 45deg
      items += _petal(c, pl, _leaf(0.06 * B * calc.cos(a), 0.06 * B * calc.sin(a), (if calc.even(k) { 0.42 } else { 0.3 }) * B, 0.07 * B, a), if calc.even(k) { c.color } else { c.accent })
    }
    items + _disc(c, pl, 0, 0, 0.07 * B, c.ink)
  }
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.5, side, corner)
}

// ── islamic: girih (eight-pointed star outlines), hexagram seals, strapwork
#let _girih(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let star(c, pl, cu, cv, R) = {
    let items = ()
    let big = _star-pts(cu, cv, R, 8, 0.62, 0deg)
    let small = _star-pts(cu, cv, 0.5 * R, 8, 0.6, 22.5deg)
    items += (nib.mp-fill(pl(_poly(big, cycle: true)), fill: c.color),) + _stroke(pl(_poly(big, cycle: true)), lw * 0.7, c.ink)
    items += (nib.mp-fill(pl(_poly(small, cycle: true)), fill: c.accent),) + _stroke(pl(_poly(small, cycle: true)), lw * 0.5, c.ink)
    items + _disc(c, pl, cu, cv, 0.1 * R, c.ink)
  }
  let side(c, B, p, pl) = {
    let items = ()
    for x in (0, p) {
      items += (_fillp(pl, ((x - 0.07 * B, 0), (x, -0.12 * B), (x + 0.07 * B, 0), (x, 0.12 * B)), c.accent),)
    }
    items + star(c, pl, p / 2, 0, 0.48 * B)
  }
  let corner(c, B, pl) = star(c, pl, 0, 0, 0.44 * B)
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.0, side, corner)
}
#let _hexastar(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let seal(c, pl, cu, cv, R, a0, col) = {
    let tri(a) = pl(_poly(range(3).map(k => (cu + R * calc.cos(a + k * 120deg), cv + R * calc.sin(a + k * 120deg))), cycle: true))
    nib.knot((tri(a0), tri(a0 + 180deg)), style: "weave", width: R * 0.16 * 1pt, fill: (col, c.accent), outline: R * 0.05 * 1pt, outline-fill: c.ink)
  }
  let side(c, B, p, pl) = {
    let items = seal(c, pl, p / 2, 0, 0.44 * B, 90deg, c.color)
    for x in (0, p) { items += _disc(c, pl, x, 0, 0.055 * B, c.ink) }
    items
  }
  let corner(c, B, pl) = seal(c, pl, 0, 0, 0.42 * B, 90deg, c.accent)
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.1, side, corner)
}
#let _strap = _knotwork(4, (), 2.0, poly: true, d: 0.5, wd: 0.26, cextra: ())

#let _knot-rope = _knotwork(6, ((1, 2), (3, 2), (5, 2), (7, 2), (9, 2), (11, 2)), 3.0, cextra: ((1, 2), (3, 2)))
#let _knot-triple = _knotwork(6, ((3, 2), (4, 1), (4, 3), (5, 2), (7, 2), (8, 1), (8, 3), (9, 2)), 3.0)
#let _knot-weave = _knotwork(6, ((3, 2), (5, 2), (7, 2), (9, 2)), 3.0)
#let _knot-blocks = _knotwork(6, ((1, 2), (4, 1), (4, 3), (5, 2), (7, 2), (8, 1), (8, 3), (11, 2)), 3.0, cextra: ((2, 1), (2, 3)))

// ── certificate: guilloché band with a beaded outer edge and acanthus flourishes in the corners (optional)
#let _flourish(c, B, pl, cc) = {
  let items = _calli(pl(_ell(((0.12 * B, 0.12 * B), (0.8 * B, 0.8 * B), (1.5 * B, 1.5 * B)))), 0.08 * B, c.color)
  let (r0, r1, turns) = (0.95 * B, 0.16 * B, 1.45)
  for swap in (false, true) {
    let q = if swap { path => pl(nib.transformed(path, 0, 1, 1, 0)) } else { pl }
    items += _calli(q(_spiral(1.5 * B, 1.5 * B - r0, r0, r1, 90deg, turns, -1)), 0.1 * B, c.color)
    for u in (0.08, 0.27, 0.46, 0.65, 0.84) {
      let th = 90deg - turns * 360deg * u
      let rho = r0 + (r1 - r0) * u
      items += _petal(c, q, _leaf(1.5 * B + rho * calc.cos(th) - 0 * B, 1.5 * B - r0 + rho * calc.sin(th), (0.66 - 0.4 * u) * B, (0.17 - 0.07 * u) * B, th), cc)
    }
    items += _petal(c, q, _leaf(0.2 * B, 0.2 * B, 0.55 * B, 0.09 * B, 45deg + 55deg), cc)
  }
  for a in (-28deg, 0deg, 28deg) {
    items += _petal(c, pl, _leaf(1.5 * B, 1.5 * B, (if a == 0deg { 1.0 } else { 0.75 }) * B, 0.13 * B, 45deg + a), cc)
  }
  items + _disc(c, pl, 1.5 * B, 1.5 * B, 0.09 * B, c.ink)
}
#let _certificate(gl) = (c, w, h) => {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let Rc = 0.62 * B
  let (xl, xr, yt, yb) = (m + B / 2, w - m - B / 2, m + B / 2, h - m - B / 2)
  let per = _perimeter(xl, yt, xr, yb, Rc)
  let nper = 4 * int(calc.max(2, calc.round(per.length / (0.52 * B) / 4)))
  let bead(ph) = _wavy(per, nper * 6, s => -0.41 * B + 0.06 * B * calc.sin(s / per.length * nper * 360deg + ph))
  let items = gl(c, w, h) + _stroke(bead(0deg), lw * 0.5, c.ink) + _stroke(bead(180deg), lw * 0.5, c.ink)
  if c.corners {
    let cc = if c.corner-color == auto { c.accent.lighten(35%) } else { c.corner-color }
    for (cx, cy, sx, sy) in ((xl, yt, 1, 1), (xr, yt, -1, 1), (xr, yb, -1, -1), (xl, yb, 1, -1)) {
      items += _flourish(c, B * calc.min(1.7, (calc.min(w, h) - 2 * (m + B)) / (7 * B)), path => nib.transformed(path, sx, 0, 0, sy, e: cx * 1pt, f: cy * 1pt), cc)
    }
  }
  items
}
#let _certificate-lens = _certificate(_gl(2.0, (
  (9, (s, th, B) => B * 0.3 * (2 * s - 1) * _cs(th), "color"),
  (9, (s, th, B) => B * 0.3 * (2 * s - 1) * _cs(2 * th), "accent")), ornament: false))
#let _certificate-ribbon = _certificate(_gl(1.7, (
  (12, (s, th, B) => B * 0.3 * _cs(th + s * 180deg), "color"),
  (12, (s, th, B) => B * 0.3 * _cs(th - s * 180deg), "accent")), ornament: false))

// ── more security-print / diploma models (0.9.0)
#let _polyfill(c, pl, pts, col) = (nib.mp-fill(pl(_poly(pts, cycle: true)), fill: col),) + _stroke(pl(_poly(pts, cycle: true)), _pt(c.line) * 0.5, c.ink)
#let _abs(x) = calc.abs(x)

// medallion: diamond-lattice band with large guilloché discs over the corners
#let _medallion-gl = _gl(2.0, (
  (9, (s, th, B) => B * 0.4 * _tri(th + s * 180deg), "color"),
  (9, (s, th, B) => B * 0.4 * _tri(th - s * 180deg), "accent")), ornament: false)
#let _medallion(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let items = _medallion-gl(c, w, h)
  if c.corners {
    let cc = if c.corner-color == auto { c.accent.lighten(25%) } else { c.corner-color }
    for (cx, cy) in ((m + B / 2, m + B / 2), (w - m - B / 2, m + B / 2), (w - m - B / 2, h - m - B / 2), (m + B / 2, h - m - B / 2)) {
      let disc = _ell(_circle-pts(cx, cy, 0.98 * B, n: 16), cycle: true)
      items.push(nib.mp-fill(disc, fill: c.paper))
      items += _stroke(disc, lw * 1.3, c.ink) + _stroke(_ell(_circle-pts(cx, cy, 0.86 * B, n: 16), cycle: true), lw * 0.6, c.color)
      items += _gl-ring(cx, cy, 0.78 * B, 14, c.color, lw * 0.5, n: 4) + _gl-ring(cx, cy, 0.5 * B, 9, cc, lw * 0.6, n: 4) + _gl-ring(cx, cy, 0.26 * B, 6, c.color, lw * 0.6, n: 3)
    }
  }
  items
}

// rosette-ribbon: a twisted ribbon of hairlines pinched at regular intervals, a rosette on every pinch
#let _rosette-ribbon = _gl(3.0, (
  (12, (s, th, B) => B * 0.36 * (2 * s - 1) * _abs(calc.sin(th / 2)), "color"),
  (2, (s, th, B) => B * 0.44 * (2 * s - 1) * _abs(calc.sin(th / 2)), "accent", 2.2)), rings: (360, 0, 0.3))

// fleur-edge: scalloped outer edge, four-pointed fleurons, diamond lattice inside
#let _fleur-edge(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let side(c, B, p, pl) = {
    let arc = _ell(range(9).map(i => (p / 2 - p / 2 * calc.cos(180deg * i / 8), -0.5 * B + 0.34 * p * calc.sin(180deg * i / 8))))
    let items = _stroke(pl(arc), lw * 0.9, c.color)
    items += _stroke(pl(_poly(((0, 0.42 * B), (p / 2, 0.12 * B), (p, 0.42 * B)))), lw * 0.8, c.color)
    items += _stroke(pl(_poly(((0, 0.12 * B), (p / 2, 0.42 * B), (p, 0.12 * B)))), lw * 0.8, c.accent)
    for x in (0, p) { items += _polyfill(c, pl, _star-pts(x, -0.2 * B, 0.24 * B, 4, 0.3, 90deg), c.accent) }
    items + _disc(c, pl, p / 2, -0.3 * B, 0.045 * B, c.color)
  }
  let corner(c, B, pl) = _polyfill(c, pl, _star-pts(0, 0, 0.5 * B, 8, 0.42, 0deg), c.accent) + _disc(c, pl, 0, 0, 0.1 * B, c.color)
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.0, side, corner)
}

// filigree: mirrored scrolls with leaves, a dense symmetric ornament
#let _filigree(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let side(c, B, p, pl) = {
    let items = _calli(pl(_poly(((0, 0.0), (p, 0.0)))), B * 0.05, c.ink)
    for (x, a, dr) in ((0.27, 90deg, -1), (0.73, 90deg, 1)) {
      items += _calli(pl(_spiral(x * p, -0.2 * B, 0.17 * B, 0.04 * B, a, 1.4, dr)), B * 0.08, c.color)
      items += _calli(pl(_spiral(x * p, 0.2 * B, 0.17 * B, 0.04 * B, -a, 1.4, -dr)), B * 0.08, c.color)
    }
    for sg in (1, -1) { items += _petal(c, pl, _leaf(p / 2, 0, 0.36 * B, 0.09 * B, sg * 90deg), c.accent) }
    for x in (0, p) { items += _disc(c, pl, x, 0, 0.05 * B, c.accent) }
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for k in range(8) {
      let a = k * 45deg
      items += _petal(c, pl, _leaf(0.06 * B * calc.cos(a), 0.06 * B * calc.sin(a), (if calc.even(k) { 0.44 } else { 0.32 }) * B, 0.08 * B, a), if calc.even(k) { c.color } else { c.accent })
    }
    items + _disc(c, pl, 0, 0, 0.07 * B, c.ink)
  }
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.4, side, corner)
}

// ── 0.10.0: classic diploma borders (diamond chain, bottom-and-top shell fans, lace grid)
#let _diamond-chain(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let dia(p, sc) = ((p / 2 - sc * p / 2, 0.0), (p / 2, -sc * 0.5 * B), (p / 2 + sc * p / 2, 0.0), (p / 2, sc * 0.5 * B))
  let side(c, B, p, pl) = {
    let items = ()
    for x in (0, p) {
      for sg in (1, -1) { items += _stroke(pl(_poly(((x - 0.3 * p, -sg * 0.5 * B), (x, -sg * 0.22 * B), (x + 0.3 * p, -sg * 0.5 * B)))), lw * 0.6, c.color) }
    }
    items += _polyfill(c, pl, dia(p, 1.0), c.accent.lighten(72%))
    items += _polyfill(c, pl, dia(p, 0.68), c.color.lighten(55%))
    items += _polyfill(c, pl, dia(p, 0.38), c.accent)
    items + _disc(c, pl, p / 2, 0, 0.05 * B, c.ink)
  }
  let corner(c, B, pl) = {
    let sq(sc) = ((-sc * 0.5 * B, 0.0), (0.0, -sc * 0.5 * B), (sc * 0.5 * B, 0.0), (0.0, sc * 0.5 * B))
    _polyfill(c, pl, sq(1.0), c.accent.lighten(72%)) + _polyfill(c, pl, sq(0.68), c.color.lighten(55%)) + _polyfill(c, pl, sq(0.38), c.accent) + _disc(c, pl, 0, 0, 0.05 * B, c.ink)
  }
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 0.9, side, corner)
}

#let _lace-grid(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let quatre(c, pl, cu, cv, s, col) = {
    let items = ()
    for k in range(4) { items += _petal(c, pl, _leaf(cu, cv, s, 0.36 * s, k * 90deg), col) }
    items
  }
  let side(c, B, p, pl) = {
    let items = ()
    for x in (0, p / 2, p) { items += _stroke(pl(_poly(((x, -0.5 * B), (x, 0.5 * B)))), lw * 0.5, c.color) }
    items += _stroke(pl(_poly(((0, 0.0), (p, 0.0)))), lw * 0.5, c.color)
    for (i, x) in (p / 4, 3 * p / 4).enumerate() {
      for (j, y) in (-0.25 * B, 0.25 * B).enumerate() {
        items += quatre(c, pl, x, y, 0.2 * B, if calc.even(i + j) { c.color } else { c.accent })
      }
    }
    for x in (0, p / 2, p) { items += _disc(c, pl, x, 0, 0.03 * B, c.ink) }
    items
  }
  let corner(c, B, pl) = {
    let items = ()
    for k in range(8) {
      let a = k * 45deg
      items += _petal(c, pl, _leaf(0.06 * B * calc.cos(a), 0.06 * B * calc.sin(a), (if calc.even(k) { 0.44 } else { 0.3 }) * B, 0.08 * B, a), if calc.even(k) { c.color } else { c.accent })
    }
    items + _disc(c, pl, 0, 0, 0.06 * B, c.ink)
  }
  _edge-rules(c, w, h, m, B, B * 0.3, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.0, side, corner)
}

// a guilloché shell fan on the middle of the top and bottom sides (over the contour; `corners: false` removes it)
#let _shell-wrap(gl) = (c, w, h) => {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let items = gl(c, w, h)
  if c.corners {
    let cc = if c.corner-color == auto { c.accent.lighten(25%) } else { c.corner-color }
    for (cx, cy, sy) in ((w / 2, m + B / 2, 1), (w / 2, h - m - B / 2, -1)) {
      let pl = path => nib.transformed(path, 1, 0, 0, sy, e: cx * 1pt, f: cy * 1pt)
      let R0 = calc.min(1.8 * B, 0.17 * calc.min(w, h))
      let arc(r, lobes, a0) = range(61).map(i => {
        let t = i / 60 * 180deg
        let rho = r * (1 + 0.045 * calc.cos(lobes * t + a0))
        (rho * calc.cos(t), rho * calc.sin(t))
      })
      let shape = arc(R0, 18, 0deg) + ((-0.8 * R0, -0.42 * B), (0.8 * R0, -0.42 * B))
      items.push(nib.mp-fill(pl(_poly(shape, cycle: true)), fill: c.paper))
      for j in range(7) {
        let r = R0 * (1 - j * 0.125)
        items += _stroke(pl(_ell(arc(r, 18 - 2 * j, 0deg))), lw * 0.8, if calc.even(j) { c.color } else { cc })
      }
      items += _stroke(pl(_poly(((-R0, 0.0), (R0, 0.0)))), lw * 0.7, c.color)
      items += _gl-ring(cx, cy, 0.42 * B, 12, c.color, lw * 0.6, n: 4)
    }
  }
  items
}
#let _diploma-shell = _shell-wrap(_bill-diploma)

// ── 0.11.0: stepped edge, deckled edge, label frame
#let _stepped(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let steps(cx, v0, dir, wd, cols, c, pl) = {
    let items = ()
    for (k, (ww, col)) in wd.zip(cols).enumerate() {
      let (y0, y1) = (v0 + dir * 0.22 * B * k, v0 + dir * 0.22 * B * (k + 1))
      items += _polyfill(c, pl, ((cx - ww, y0), (cx + ww, y0), (cx + ww, y1), (cx - ww, y1)), col)
    }
    items
  }
  let side(c, B, p, pl) = {
    let ws = (0.4 * p, 0.27 * p, 0.14 * p)
    let cols = (c.color, c.accent, c.color.lighten(40%))
    let items = steps(p / 2, -0.5 * B, 1, ws, cols, c, pl)
    for x in (0, p) { items += steps(x, 0.5 * B, -1, ws, cols, c, pl) }
    items
  }
  let corner(c, B, pl) = {
    let sq(sc) = ((-sc * 0.5 * B, -sc * 0.5 * B), (sc * 0.5 * B, -sc * 0.5 * B), (sc * 0.5 * B, sc * 0.5 * B), (-sc * 0.5 * B, sc * 0.5 * B))
    _polyfill(c, pl, sq(1.0), c.color) + _polyfill(c, pl, sq(0.66), c.accent) + _polyfill(c, pl, sq(0.33), c.color.lighten(40%))
  }
  _edge-rules(c, w, h, m, B, B * 0.15, thick: 1.2, thin: 0.7) + _motif-band(c, w, h, 1.4, side, corner)
}

// deckle: waves that fade from a deckled outer edge into straight lines
#let _deckle = _gl(1.3, (
  (7, (s, th, B) => B * (-0.46 + 0.62 * s + 0.15 * (1 - s) * _cs(th)), "color"),
  (2, (s, th, B) => B * (0.44 - 0.06 * s + 0.0 * _cs(th)), "accent", 1.6)), ornament: false)

// label: slim double rule, curls in the corners, a fleuron with curls in the middle of every side
#let _label(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let items = _edge-rules(c, w, h, m, B, B * 0.25, thick: 1.4, thin: 0.8)
  let K = 1.45
  if c.corners {
    for (cx, cy, sx, sy) in ((m + B / 2, m + B / 2, 1, 1), (w - m - B / 2, m + B / 2, -1, 1), (w - m - B / 2, h - m - B / 2, -1, -1), (m + B / 2, h - m - B / 2, 1, -1)) {
      let pl = path => nib.transformed(path, sx, 0, 0, sy, e: cx * 1pt, f: cy * 1pt)
      items += (nib.mp-fill(pl(_poly(_circle-pts(0, 0, 0.42 * B * K, n: 12), cycle: true)), fill: c.paper),)
      let sp = _spiral(0, 0.3 * B * K, 0.3 * B * K, 0.05 * B * K, -90deg, 1.3, 1)
      items += _calli(pl(sp), 0.1 * B * K, c.color) + _calli(pl(nib.transformed(sp, 0, 1, 1, 0)), 0.1 * B * K, c.color)
      items += _disc(c, pl, 0, 0, 0.07 * B * K, c.accent)
    }
  }
  if c.corners {
    for (cx, cy, tx, ty) in ((w / 2, m + B / 2, 1, 0), (w - m - B / 2, h / 2, 0, 1), (w / 2, h - m - B / 2, -1, 0), (m + B / 2, h / 2, 0, -1)) {
      let pl = path => nib.transformed(path, tx, ty, -ty, tx, e: cx * 1pt, f: cy * 1pt)
      let pm = path => pl(nib.transformed(path, -1, 0, 0, 1))
      items += (nib.mp-fill(pl(_poly(((-2.3 * B, -0.42 * B), (2.3 * B, -0.42 * B), (2.3 * B, 0.42 * B), (-2.3 * B, 0.42 * B)), cycle: true)), fill: c.paper),)
      let sp = _spiral(1.1 * B, 0.0, 0.4 * B, 0.07 * B, 180deg, 1.3, 1)
      items += _calli(pl(sp), 0.11 * B, c.color) + _calli(pm(sp), 0.11 * B, c.color)
      items += _polyfill(c, pl, _star-pts(0, 0, 0.7 * B, 4, 0.3, 90deg), c.accent)
    }
    // the rules, redrawn over the paper patches, keep the contour continuous
    items += _edge-rules(c, w, h, m, B, B * 0.25, thick: 1.4, thin: 0.8)
  }
  items
}

// ── 0.3.0: dedication, plank, torn, coil — "paper and craft" frames

// dedication: triple rule, a row of diamonds between the rules, an eight-petal rosette in every corner and in the middle of every side
#let _dedication(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let rr(a, rad) = nib.round-corners(((a * 1pt, a * 1pt), ((w - a) * 1pt, a * 1pt), ((w - a) * 1pt, (h - a) * 1pt), (a * 1pt, (h - a) * 1pt)), r: rad * 1pt, cycle: true)
  let pale = c.accent.lighten(45%)
  let items = _stroke(rr(m, B * 0.2), lw * 1.5, c.ink)
  items += _stroke(rr(m + 0.16 * B, B * 0.12), lw * 1.0, c.accent)
  items += _stroke(rr(m + B, B * 0.12), lw * 1.0, c.accent)
  items += _stroke(rr(m + 0.84 * B, B * 0.1), lw * 0.6, pale)
  let rosette(cx, cy, R, col1, col2) = {
    let pl = path => nib.transformed(path, 1, 0, 0, 1, e: cx * 1pt, f: cy * 1pt)
    let its = ()
    for k in range(8) {
      let a = k * 45deg
      its += _petal(c, pl, _leaf(0.16 * R * calc.cos(a), 0.16 * R * calc.sin(a), (if calc.even(k) { 1.0 } else { 0.72 }) * R, 0.2 * R, a), if calc.even(k) { col1 } else { col2 })
    }
    its + _disc(c, pl, 0, 0, 0.16 * R, c.ink)
  }
  let sprig(cx, cy, sx, sy, ang) = {
    // pairs of leaves opening away from the corner rosette, along one side
    let pl = path => nib.transformed(path, sx, 0, 0, sy, e: cx * 1pt, f: cy * 1pt)
    let r = ()
    for (u, len, sp) in ((1.45, 0.62, 38deg), (2.2, 0.5, 30deg)) {
      for sgn in (1, -1) {
        let a = sgn * sp
        let lf = if ang == 0 { _leaf(u * B, 0, len * B, 0.12 * B, a) } else { _leaf(0, u * B, len * B, 0.12 * B, 90deg - a) }
        r += _petal(c, pl, lf, c.color)
      }
    }
    r
  }
  let step = 0.62 * B
  let diamonds(x0, y0, tx, ty, len) = {
    let n = int(calc.floor(len / step))
    let its = ()
    for i in range(if len > 0 { n } else { 0 }) {
      let u = (i + 0.5) * len / n
      let (cx, cy) = (x0 + tx * u, y0 + ty * u)
      let d = 0.13 * B
      let pts = ((cx - d, cy), (cx, cy - d), (cx + d, cy), (cx, cy + d))
      its += (nib.mp-fill(_poly(pts, cycle: true), fill: if calc.even(i) { c.color } else { c.accent }),)
    }
    its
  }
  let k = m + B / 2
  let skip = 3.0 * B
  let mid = 1.0 * B
  // each half of a side is the mirror image of the other half
  items += diamonds(k + skip, k, 1, 0, w / 2 - mid - k - skip) + diamonds(w - k - skip, k, -1, 0, w / 2 - mid - k - skip)
  items += diamonds(k + skip, h - k, 1, 0, w / 2 - mid - k - skip) + diamonds(w - k - skip, h - k, -1, 0, w / 2 - mid - k - skip)
  items += diamonds(k, k + skip, 0, 1, h / 2 - mid - k - skip) + diamonds(k, h - k - skip, 0, -1, h / 2 - mid - k - skip)
  items += diamonds(w - k, k + skip, 0, 1, h / 2 - mid - k - skip) + diamonds(w - k, h - k - skip, 0, -1, h / 2 - mid - k - skip)
  if c.corners {
    for (cx, cy, sx, sy) in ((k, k, 1, 1), (w - k, k, -1, 1), (w - k, h - k, -1, -1), (k, h - k, 1, -1)) {
      items += sprig(cx, cy, sx, sy, 0) + sprig(cx, cy, sx, sy, 1)
    }
    for (cx, cy) in ((k, k), (w - k, k), (w - k, h - k), (k, h - k)) { items += rosette(cx, cy, 0.62 * B, c.color, c.accent) }
    for (cx, cy) in ((w / 2, k), (w / 2, h - k), (k, h / 2), (w - k, h / 2)) { items += rosette(cx, cy, 0.5 * B, c.accent, c.color) }
  }
  items
}

// a quadrilateral board with grain lines (a, b: outer edge; d, e: inner edge, a→d and b→e are the mitres)
#let _board(c, a, b, e, d, fillc, grain, seed) = {
  let lw = _pt(c.line)
  let lerp(p, q, t) = (p.at(0) + (q.at(0) - p.at(0)) * t, p.at(1) + (q.at(1) - p.at(1)) * t)
  let items = (nib.mp-fill(_poly((a, b, e, d), cycle: true), fill: fillc),)
  let n = 3
  for j in range(n) {
    let f = (j + 1) / (n + 1)
    let pts = range(21).map(i => {
      let t = i / 20
      let p = lerp(lerp(a, b, t), lerp(d, e, t), f)
      let (nx, ny) = (d.at(0) - a.at(0), d.at(1) - a.at(1))
      let wob = 0.05 * calc.sin(t * (5 + 2 * j) + seed + j * 1.7) + 0.03 * calc.sin(t * 13 + seed * 2)
      (p.at(0) + nx * wob, p.at(1) + ny * wob)
    })
    items += _stroke(_ell(pts), lw * 0.7, grain)
  }
  items + _stroke(_poly((a, b, e, d), cycle: true), lw * 1.3, c.ink)
}

// plank: four mitred boards with grain and a nail in every corner (a picture frame made of planks)
#let _plank(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let wood = c.accent.lighten(30%)
  let grain = c.accent.darken(25%)
  let (X0, Y0, X1, Y1) = (m, m, w - m, h - m)
  let items = ()
  items += _board(c, (X0, Y0), (X1, Y0), (X1 - B, Y0 + B), (X0 + B, Y0 + B), wood, grain, 1.0)
  items += _board(c, (X0, Y1), (X1, Y1), (X1 - B, Y1 - B), (X0 + B, Y1 - B), wood, grain, 1.0)
  items += _board(c, (X0, Y0), (X0, Y1), (X0 + B, Y1 - B), (X0 + B, Y0 + B), wood.darken(6%), grain, 2.3)
  items += _board(c, (X1, Y0), (X1, Y1), (X1 - B, Y1 - B), (X1 - B, Y0 + B), wood.darken(6%), grain, 2.3)
  if c.corners {
    for (cx, cy) in ((X0 + B * 0.3, Y0 + B * 0.3), (X1 - B * 0.3, Y0 + B * 0.3), (X1 - B * 0.3, Y1 - B * 0.3), (X0 + B * 0.3, Y1 - B * 0.3)) {
      let pl = path => path
      items += _disc(c, pl, cx, cy, 0.11 * B, c.ink.lighten(35%))
    }
  }
  items
}

// torn: a strip of torn paper (a ragged outer edge, a ragged inner edge, a soft shadow); the tear is the same on opposite sides
#let _torn(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let nz(x, y) = {
    let u = calc.abs(x - w / 2) + calc.abs(y - h / 2)
    0.5 + 0.5 * (0.45 * calc.sin(u * 0.21 + 1.3) + 0.3 * calc.sin(u * 0.47 + 0.2) + 0.25 * calc.sin(u * 1.13 + 2.1))
  }
  let ragged(a, amp, inward) = {
    let per = _perimeter(a, a, w - a, h - a, B * 0.2)
    let n = int(per.length / 2.2)
    nib.mp-path-pts(range(n).map(i => {
      let (x, y, tx, ty) = (per.pos)(per.length * i / n)
      let o = amp * nz(x, y) * (if inward { 1 } else { -1 })
      _P(x - ty * o, y + tx * o)
    }), cycle: true)
  }
  let paper = c.accent.lighten(78%)
  let outer = ragged(m + 0.1 * B, 0.2 * B, true)
  let inner = ragged(m + 0.82 * B, 0.2 * B, false)
  let items = (nib.mp-fill(nib.shifted(outer, 1.6pt, -1.6pt), fill: black.transparentize(82%)),)
  items.push(nib.mp-fill(outer, fill: paper))
  items.push(nib.mp-fill(nib.shifted(inner, 1.0pt, -1.0pt), fill: black.transparentize(88%)))
  items.push(nib.mp-fill(inner, fill: c.paper))
  items += _stroke(inner, lw * 0.5, c.accent.lighten(25%))
  // a fine rule inside the paper strip keeps the contour readable
  let rr(a, rad) = nib.round-corners(((a * 1pt, a * 1pt), ((w - a) * 1pt, a * 1pt), ((w - a) * 1pt, (h - a) * 1pt), (a * 1pt, (h - a) * 1pt)), r: rad * 1pt, cycle: true)
  items += _stroke(rr(m + 0.5 * B, B * 0.1), lw * 0.9, c.color)
  items
}

// coil: a rounded notebook border with wire rings along the binding side (`binding: "left"`, "right", "top", "bottom" or "none")
#let _coil(c, w, h) = {
  let (B, m) = (_pt(c.band), _pt(c.inset))
  let lw = _pt(c.line)
  let r = if c.radius == auto { B * 0.6 } else { _pt(c.radius) }
  let rr(a, rad) = nib.round-corners(((a * 1pt, a * 1pt), ((w - a) * 1pt, a * 1pt), ((w - a) * 1pt, (h - a) * 1pt), (a * 1pt, (h - a) * 1pt)), r: rad * 1pt, cycle: true)
  let items = _stroke(rr(m + 0.3 * B, r), B * 0.34, c.color)
  items += _stroke(rr(m + 0.02 * B, r + 0.28 * B), lw * 1.3, c.ink)
  items += _stroke(rr(m + 0.58 * B, calc.max(r - 0.28 * B, 0.5)), lw * 1.1, c.ink)
  items += _stroke(rr(m + 0.3 * B, r), B * 0.1, c.color.lighten(55%))
  let side = c.binding
  assert(side in ("left", "right", "top", "bottom", "none"), message: "nibframe: coil needs binding: \"left\", \"right\", \"top\", \"bottom\" or \"none\"")
  if side != "none" {
    let horizontal = side in ("top", "bottom")
    let len = if horizontal { w } else { h }
    let pitch = 0.95 * B
    let n = 2 * int(calc.max(1, calc.floor((len - 2 * (m + 2 * B)) / (2 * pitch))))
    for i in range(n) {
      let u = (i + 0.5) / n * (len - 2 * (m + 2 * B)) + m + 2 * B
      let (cx, cy, ang) = if side == "left" { (m + 0.4 * B, u, 0deg) } else if side == "right" { (w - m - 0.4 * B, u, 0deg) } else if side == "top" { (u, h - m - 0.4 * B, 90deg) } else { (u, m + 0.4 * B, 90deg) }
      let col = if calc.even(i) { c.accent } else { c.color.darken(25%) }
      let pts = range(17).map(k => {
        let t = k * 22.5deg
        let (x, y) = (0.85 * B * calc.cos(t), 0.21 * B * calc.sin(t))
        let tilt = 20deg
        let (xr, yr) = (x * calc.cos(tilt) - y * calc.sin(tilt), x * calc.sin(tilt) + y * calc.cos(tilt))
        (cx + (if horizontal { yr } else { xr }), cy + (if horizontal { xr } else { yr }))
      }).slice(0, 16)
      items += _stroke(_ell(pts, cycle: true), B * 0.13, c.ink) + _stroke(_ell(pts, cycle: true), B * 0.085, col)
    }
  }
  items
}

#let _new-styles = (
  stepped: _stepped, deckle: _deckle, label: _label,
  "diamond-chain": _diamond-chain, "lace-grid": _lace-grid, "diploma-shell": _diploma-shell,
  medallion: _medallion, "rosette-ribbon": _rosette-ribbon, "fleur-edge": _fleur-edge, filigree: _filigree,
  certificate: _certificate-lens, "certificate-ribbon": _certificate-ribbon,
  "knot-rope": _knot-rope, "knot-triple": _knot-triple, "knot-weave": _knot-weave, "knot-blocks": _knot-blocks,
  "knot-cartouche": _knot-cartouche, "knot-eights": _knot-eights, "knot-lozenge": _knot-lozenge, "knot-ring": _knot-ring,
  daisy: _daisy, sakura: _sakura, lotus: _lotus, palmette: _palmette, ogee: _ogee, rinceau: _rinceau,
  girih: _girih, hexastar: _hexastar, strap: _strap,
  dedication: _dedication, plank: _plank, torn: _torn, coil: _coil)

#let _draw = (classic: _classic, celtic: _celtic, guilloche: _guilloche, braces: _braces, pearls: _pearls,
  arabesque: _arabesque, islamic: _islamic, greek: _greek, scallop: _scallop, deco: _deco, chain: _chain, braid: _braid, banknote: _banknote,
  baroque: _baroque, triquetra: _triquetra, solomon: _solomon, zellige: _zellige, seigaiha: _seigaiha, kilim: _kilim, laurel: _laurel,
  flowers: _flowers, stamp: _stamp, film: _film, photo: _photo, neon: _neon, illumination: _illumination,
  "bill-lens": _bill-lens, "bill-fan": _bill-fan, "bill-ribbon": _bill-ribbon, "bill-shell": _bill-shell, "bill-wave": _bill-wave, "bill-frill": _bill-frill, "bill-net": _bill-net, "bill-swell": _bill-swell, "bill-plait": _bill-plait, "bill-rosette": _bill-rosette,
  "bill-wavy": _bill-wavy, "bill-diploma": _bill-diploma, "bill-lattice": _bill-lattice, "bill-weave": _bill-weave,
  airmail: _airmail, checker: _checker, stars: _stars, hearts: _hearts, eggdart: _eggdart, vitruvian: _vitruvian, arches: _arches, tapa: _tapa, stripes: _stripes, herringbone: _herringbone) + _new-styles
