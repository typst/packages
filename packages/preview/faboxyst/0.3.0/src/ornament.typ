// ===========================================================================
//  faboxyst/ornament.typ — a library of vector ornaments.
//
//  Every motif is drawn with `curve` / `polygon` / `circle` — no image
//  assets — so it recolours from a palette, scales to any size and costs
//  a handful of primitives. The repertoire is the geometric vocabulary of
//  Maghrebi textbooks: the eight-pointed star (khatam), the gold rosette,
//  the zellij star-and-cross tile, the palmette, the arabesque scroll.
//
//  A motif is a small dictionary:
//
//    (aspect: (w, h), draw: (size, palette) => content)
//
//  `draw` returns a box of `size × aspect` (so a square motif at 5 mm is a
//  5 mm box). The frame engine only ever needs `aspect` and `draw`, which
//  is what lets user-made motifs — glyphs from an ornament font and SVGs
//  read as text — take the place of the built-in ones.
// ===========================================================================

// ---------------------------------------------------------------------------
//  geometry
// ---------------------------------------------------------------------------

/// Inner/outer radius ratio of two crossed squares — the true khatam star.
#let STAR8 = 0.7654

#let _pt(c, r, a) = (c.at(0) + r * calc.cos(a), c.at(1) + r * calc.sin(a))

/// The vertices of an `n`-pointed star round `c`.
#let star-points(c, R, r, n: 8, rot: -90deg) = range(2 * n).map(i => _pt(
  c, if calc.even(i) { R } else { r }, rot + i * 180deg / n))

/// The vertices of a regular `n`-gon round `c`.
#let ngon-points(c, R, n, rot: -90deg) = range(n).map(i => _pt(
  c, R, rot + i * 360deg / n))

/// An arc as a polyline (`from` → `to`, anticlockwise on screen).
#let arc-points(c, R, from, to, n: 24) = range(n + 1).map(i => _pt(
  c, R, from + (to - from) * i / n))

/// A spiral: radius grows from `r0` to `r1` over `turns` turns.
#let spiral-points(c, r0, r1, turns, rot: 0deg, n: 60) = range(n + 1).map(i => {
  let t = i / n
  _pt(c, r0 + (r1 - r0) * t, rot + turns * 360deg * t)
})

/// Place a polygon by absolute points (negative coordinates allowed).
#let poly(pts, ..style) = {
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  let x0 = calc.min(..xs)
  let y0 = calc.min(..ys)
  place(top + left, dx: x0, dy: y0,
    polygon(..style, ..pts.map(p => (p.at(0) - x0, p.at(1) - y0))))
}

/// Place an open polyline by absolute points.
#let polyline(pts, ..style) = {
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  let x0 = calc.min(..xs)
  let y0 = calc.min(..ys)
  let rel = pts.map(p => (p.at(0) - x0, p.at(1) - y0))
  place(top + left, dx: x0, dy: y0,
    curve(..style, curve.move(rel.first()), ..rel.slice(1).map(p => curve.line(p))))
}

/// Place a circle by its centre.
#let disc(c, r, ..style) = place(top + left, dx: c.at(0) - r, dy: c.at(1) - r,
  circle(radius: r, ..style))

/// A leaf / petal from `c` out to radius `R` along `a`, `w` wide.
#let petal(c, a, R, w, base: 0.0, ..style) = {
  let root = _pt(c, R * base, a)
  let tip = _pt(c, R, a)
  let m = _pt(c, R * (0.5 + base / 2), a)
  let px = -calc.sin(a) * w
  let py = calc.cos(a) * w
  let pts = (root, (m.at(0) + px, m.at(1) + py), tip, (m.at(0) - px, m.at(1) - py))
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  let x0 = calc.min(..xs)
  let y0 = calc.min(..ys)
  let r(p) = (p.at(0) - x0, p.at(1) - y0)
  place(top + left, dx: x0, dy: y0, curve(..style,
    curve.move(r(root)),
    curve.quad(r(pts.at(1)), r(tip)),
    curve.quad(r(pts.at(3)), r(root)),
    curve.close()))
}

/// A hairline between two absolute points.
#let hair(a, b, ..style) = {
  let x0 = calc.min(a.at(0), b.at(0))
  let y0 = calc.min(a.at(1), b.at(1))
  place(top + left, dx: x0, dy: y0,
    line(start: (a.at(0) - x0, a.at(1) - y0), end: (b.at(0) - x0, b.at(1) - y0), ..style))
}

// ---------------------------------------------------------------------------
//  the default palette
// ---------------------------------------------------------------------------

/// The colours every motif draws from. Boxes derive one from their own
/// `colour` / `gold` / `paper`; pass `palette:` to override any key.
#let default-palette = (
  ink:    rgb("#1F3A68"),   // the dark ground: navy, emerald, …
  gold:   rgb("#C9A24E"),   // the metallic accent
  paper:  rgb("#FCF9F2"),   // the page
  tile:   rgb("#1B7F8C"),   // zellij teal
  accent: rgb("#B5652E"),   // terracotta
  light:  rgb("#8EC5E6"),   // sky
)

/// The palette under the name the manual and the examples use.
#let ornament-palette = default-palette

/// Fill the gaps of a partial palette from the default one.
#let make-palette(..over) = default-palette + over.named()

// ---------------------------------------------------------------------------
//  the motifs
// ---------------------------------------------------------------------------

#let _sq(s, body) = box(width: s, height: s, body)

/// The eight-pointed star — two crossed squares, an inner star, a disc.
#let star8 = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let c = (s / 2, s / 2)
  let R = s * 0.49
  poly(star-points(c, R, R * STAR8), fill: pal.ink)
  poly(star-points(c, R * 0.66, R * 0.66 * STAR8, rot: -67.5deg), fill: pal.gold)
  poly(ngon-points(c, R * 0.30, 8, rot: -67.5deg), fill: pal.paper)
  disc(c, R * 0.12, fill: pal.ink)
}))

/// The same star, outline only — for hairline frames.
#let star8-line = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let c = (s / 2, s / 2)
  let R = s * 0.47
  poly(star-points(c, R, R * STAR8), stroke: 0.5pt + pal.ink)
  poly(ngon-points(c, R * 0.42, 8, rot: -67.5deg), stroke: 0.4pt + pal.gold)
  disc(c, R * 0.13, fill: pal.gold)
}))

/// A gold rosette: two rings of petals and a dark heart.
#let rosette = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let c = (s / 2, s / 2)
  for i in range(8) {
    petal(c, i * 45deg, s * 0.49, s * 0.11, fill: pal.gold.darken(18%))
  }
  for i in range(8) {
    petal(c, i * 45deg + 22.5deg, s * 0.37, s * 0.09, fill: pal.gold.lighten(12%))
  }
  disc(c, s * 0.11, fill: pal.ink)
  disc(c, s * 0.045, fill: pal.paper)
}))

/// A twelve-petal rosette in the dark colour, gold heart.
#let rosette-ink = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let c = (s / 2, s / 2)
  for i in range(12) {
    petal(c, i * 30deg, s * 0.49, s * 0.075, fill: pal.ink)
  }
  for i in range(6) {
    petal(c, i * 60deg + 30deg, s * 0.30, s * 0.07, fill: pal.gold)
  }
  disc(c, s * 0.075, fill: pal.paper)
}))

/// A khatam medallion: star, gold rim, a ring inside — the badge shape.
#let medallion = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let c = (s / 2, s / 2)
  let R = s * 0.485
  poly(star-points(c, R, R * STAR8), fill: pal.ink, stroke: 0.5pt + pal.gold)
  disc(c, R * 0.70, stroke: 0.45pt + pal.gold)
  disc(c, R * 0.62, stroke: 0.3pt + pal.gold.transparentize(50%))
}))

/// A zellij tile: a star at the centre, quarter-stars in the corners, the
/// cross-shaped ground between them. Tiles side by side continue the
/// star-and-cross tessellation.
#let tile-star8 = (aspect: (1, 1), draw: (s, pal) => box(
  width: s, height: s, clip: true, fill: pal.tile, {
    let c = (s / 2, s / 2)
    let R = s * 0.43
    for k in ((0pt, 0pt), (s, 0pt), (0pt, s), (s, s)) {
      poly(star-points(k, s * 0.29, s * 0.29 * STAR8, rot: -67.5deg), fill: pal.gold)
      poly(ngon-points(k, s * 0.10, 8), fill: pal.paper)
    }
    poly(star-points(c, R, R * STAR8), fill: pal.ink)
    poly(star-points(c, R * 0.78, R * 0.78 * STAR8), stroke: 0.4pt + pal.paper)
    poly(ngon-points(c, R * 0.34, 4), fill: pal.light)
    poly(ngon-points(c, R * 0.17, 4), fill: pal.paper)
  }))

/// The same tile with the colours swapped — an alternating course.
#let tile-star8-alt = (aspect: (1, 1), draw: (s, pal) => (tile-star8.draw)(
  s, pal + (tile: pal.ink, ink: pal.tile)))

/// A small square tile with a four-lobed knot — the plain course.
#let tile-knot = (aspect: (1, 1), draw: (s, pal) => box(
  width: s, height: s, clip: true, fill: pal.paper, stroke: 0.4pt + pal.tile, {
    let c = (s / 2, s / 2)
    poly(star-points(c, s * 0.44, s * 0.20, n: 4), fill: pal.tile)
    poly(star-points(c, s * 0.44, s * 0.20, n: 4, rot: -45deg), fill: pal.gold)
    poly(ngon-points(c, s * 0.16, 4), fill: pal.ink)
    disc(c, s * 0.06, fill: pal.paper)
  }))

/// A lozenge with a lozenge inside — the smallest link of a chain.
#let lozenge = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let c = (s / 2, s / 2)
  poly(ngon-points(c, s * 0.48, 4), fill: pal.gold)
  poly(ngon-points(c, s * 0.28, 4), fill: pal.paper)
  disc(c, s * 0.09, fill: pal.ink)
}))

/// A palmette: a heart-shaped leaf with a three-dot crown and a stem —
/// drawn upright, point down. Aspect 1 : 1.45.
#let palmette = (aspect: (1, 1.45), draw: (s, pal) => {
  let w = s
  let h = s * 1.45
  box(width: w, height: h, {
    let P(x, y) = (x * w, y * h)
    let st = (paint: pal.ink, thickness: 0.55pt, cap: "round", join: "round")
    let heart(k, dy, ..style) = {
      // a heart scaled by `k` about its own centre (0.5, 0.42)
      let Q(x, y) = P(0.5 + (x - 0.5) * k, 0.42 + dy + (y - 0.42) * k)
      place(top + left, curve(..style,
        curve.move(Q(0.5, 0.26)),
        curve.cubic(Q(0.5, 0.10), Q(0.06, 0.10), Q(0.06, 0.34)),
        curve.cubic(Q(0.06, 0.52), Q(0.40, 0.60), Q(0.5, 0.76)),
        curve.cubic(Q(0.60, 0.60), Q(0.94, 0.52), Q(0.94, 0.34)),
        curve.cubic(Q(0.94, 0.10), Q(0.5, 0.10), Q(0.5, 0.26)),
        curve.close()))
    }
    heart(1.0, 0.0, stroke: st, fill: pal.paper)
    heart(0.62, 0.0, stroke: (paint: pal.ink, thickness: 0.4pt))
    poly(ngon-points(P(0.5, 0.42), w * 0.09, 4), fill: pal.gold)
    // the crown
    disc(P(0.5, 0.045), w * 0.055, fill: pal.gold)
    disc(P(0.34, 0.10), w * 0.04, fill: pal.ink)
    disc(P(0.66, 0.10), w * 0.04, fill: pal.ink)
    // the stem and its bead
    hair(P(0.5, 0.76), P(0.5, 0.93), stroke: st)
    disc(P(0.5, 0.955), w * 0.045, fill: pal.gold)
  })
})

/// A horizontal finial: bead — hairline — lozenge — hairline — leaf,
/// pointing to +x. Aspect 2.6 : 1.
#let finial = (aspect: (2.6, 1), draw: (s, pal) => {
  let w = s * 2.6
  let h = s
  box(width: w, height: h, {
    let P(x, y) = (x * w, y * h)
    let st = (paint: pal.ink, thickness: 0.5pt, cap: "round")
    disc(P(0.04, 0.5), h * 0.07, fill: pal.gold)
    hair(P(0.06, 0.5), P(0.40, 0.5), stroke: st)
    poly(ngon-points(P(0.50, 0.5), h * 0.20, 4), fill: pal.gold)
    poly(ngon-points(P(0.50, 0.5), h * 0.09, 4), fill: pal.ink)
    hair(P(0.60, 0.5), P(0.82, 0.5), stroke: st)
    petal(P(0.80, 0.5), 0deg, w * 0.19, h * 0.14, fill: pal.ink)
    disc(P(0.86, 0.5), h * 0.05, fill: pal.gold)
  })
})

/// An arabesque scroll for a corner — drawn for the TOP-LEFT corner, the
/// spiral curling into the angle and a leaf running out along each rule.
#let scroll = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let st = (paint: pal.gold.darken(8%), thickness: 0.6pt, cap: "round", join: "round")
  let thin = (paint: pal.gold.darken(8%), thickness: 0.45pt, cap: "round")
  // the main stem: a spiral opening from the centre towards the far corner
  let c = (s * 0.36, s * 0.36)
  polyline(spiral-points(c, s * 0.03, s * 0.30, 1.75, rot: 200deg), stroke: st)
  // two tendrils leaving the spiral, one along each edge
  place(top + left, curve(stroke: thin,
    curve.move((s * 0.60, s * 0.20)),
    curve.cubic((s * 0.78, s * 0.06), (s * 0.90, s * 0.10), (s * 0.98, s * 0.02))))
  place(top + left, curve(stroke: thin,
    curve.move((s * 0.20, s * 0.60)),
    curve.cubic((s * 0.06, s * 0.78), (s * 0.10, s * 0.90), (s * 0.02, s * 0.98))))
  // leaves
  petal((s * 0.62, s * 0.62), 45deg, s * 0.36, s * 0.10, fill: pal.ink)
  petal((s * 0.80, s * 0.12), 10deg, s * 0.17, s * 0.05, fill: pal.gold)
  petal((s * 0.12, s * 0.80), 80deg, s * 0.17, s * 0.05, fill: pal.gold)
  // beads
  disc((s * 0.36, s * 0.36), s * 0.045, fill: pal.ink)
  disc((s * 0.98, s * 0.02), s * 0.03, fill: pal.gold)
  disc((s * 0.02, s * 0.98), s * 0.03, fill: pal.gold)
}))

/// A corner wisp — a quarter arc bowed into the angle carrying a small
/// rosette, a leaf at each foot. Drawn for the TOP-LEFT corner.
#let wisp = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let st = (paint: pal.gold, thickness: 0.55pt, cap: "round")
  let c = (s, s)
  polyline(arc-points(c, s * 0.82, 180deg, 270deg), stroke: st)
  polyline(arc-points(c, s * 0.70, 195deg, 255deg), stroke: (paint: pal.gold, thickness: 0.35pt))
  let m = _pt(c, s * 0.82, 225deg)
  place(top + left, dx: m.at(0) - s * 0.19, dy: m.at(1) - s * 0.19,
    (rosette.draw)(s * 0.38, pal))
  petal((s * 0.18, s), 250deg, s * 0.24, s * 0.06, fill: pal.ink)
  petal((s, s * 0.18), 200deg, s * 0.24, s * 0.06, fill: pal.ink)
  disc((s * 0.18, s), s * 0.035, fill: pal.gold)
  disc((s, s * 0.18), s * 0.035, fill: pal.gold)
}))

/// A corner wedge — quarter rounds nesting into the angle, gold over ink.
/// Drawn for the TOP-LEFT corner; the engine mirrors it into the others.
#let wedge = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let quarter(r, ..style) = poly(((0pt, 0pt),) + arc-points((0pt, 0pt), r, 0deg, 90deg), ..style)
  quarter(s * 0.98, fill: pal.gold)
  quarter(s * 0.70, fill: pal.ink)
  quarter(s * 0.46, fill: pal.gold.lighten(14%))
  quarter(s * 0.22, fill: pal.paper)
  disc((s * 0.055, s * 0.055), s * 0.05, fill: pal.ink)
  disc((s * 0.055, s * 0.055), s * 0.02, fill: pal.gold)
}))

/// A notched corner — three diagonal bands nesting into the angle.
/// Drawn for the TOP-LEFT corner.
#let notch = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let band(k0, k1, ..style) = poly((
    (0pt, s * k1), (s * k1, 0pt), (s * k0, 0pt), (0pt, s * k0)), ..style)
  band(0.86, 0.98, fill: pal.gold.darken(8%))
  band(0.46, 0.68, fill: pal.ink)
  band(0.16, 0.30, fill: pal.gold)
  disc((s * 0.075, s * 0.075), s * 0.055, fill: pal.ink)
  disc((s * 0.075, s * 0.075), s * 0.025, fill: pal.paper)
}))

/// An L of two short rules meeting in a bead — the quietest corner.
#let bracket = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let st = (paint: pal.gold, thickness: 0.6pt, cap: "round")
  hair((s * 0.08, s * 0.08), (s * 0.95, s * 0.08), stroke: st)
  hair((s * 0.08, s * 0.08), (s * 0.08, s * 0.95), stroke: st)
  poly(ngon-points((s * 0.08, s * 0.08), s * 0.09, 4), fill: pal.ink)
}))

/// A crenellation tooth (merlon) — repeat it along a top edge.
#let merlon = (aspect: (1, 0.7), draw: (s, pal) => box(width: s, height: s * 0.7, {
  poly(((s * 0.15, s * 0.7), (s * 0.15, s * 0.25), (s * 0.5, 0pt),
        (s * 0.85, s * 0.25), (s * 0.85, s * 0.7)), fill: pal.ink)
  poly(((s * 0.30, s * 0.7), (s * 0.30, s * 0.32), (s * 0.5, s * 0.17),
        (s * 0.70, s * 0.32), (s * 0.70, s * 0.7)), fill: pal.gold)
}))

/// A bead — a dot with a halo; the simplest chain.
#let bead = (aspect: (1, 1), draw: (s, pal) => _sq(s, {
  let c = (s / 2, s / 2)
  disc(c, s * 0.40, stroke: 0.4pt + pal.gold)
  disc(c, s * 0.20, fill: pal.ink)
}))

/// A horizontal flourish — a lozenge heart between two S-scrolls with
/// beaded tips. For the middle of a side. Aspect 3 : 1.
#let flourish = (aspect: (3, 1), draw: (s, pal) => {
  let w = s * 3
  let h = s
  box(width: w, height: h, {
    let st = (paint: pal.ink, thickness: 0.6pt, cap: "round")
    let C(x, y) = (x * s, y * s)
    for sgn in (-1, 1) {
      place(top + left, curve(stroke: st,
        curve.move(C(1.5 + 0.30 * sgn, 0.5)),
        curve.cubic(C(1.5 + 0.75 * sgn, 0.14), C(1.5 + 1.12 * sgn, 0.86),
          C(1.5 + 1.32 * sgn, 0.5))))
      disc(C(1.5 + 1.40 * sgn, 0.5), s * 0.06, fill: pal.gold)
      disc(C(1.5 + 1.40 * sgn, 0.5), s * 0.025, fill: pal.ink)
    }
    poly(ngon-points(C(1.5, 0.5), s * 0.27, 4), fill: pal.gold)
    poly(ngon-points(C(1.5, 0.5), s * 0.14, 4), fill: pal.ink)
    disc(C(1.5, 0.5), s * 0.055, fill: pal.paper)
  })
})

/// A motif built from a glyph of any font — the way to use an ornament
/// face (Fleurons, Dingbats, Noto Sans Symbols 2 …) in a frame.
///
///   glyph-motif("❦")
///   glyph-motif("\u{1F66A}", font: "Noto Sans Symbols 2", fill: pal => pal.gold)
///
/// The glyph is scaled to fill its `size × aspect` box exactly.
#let glyph-motif(ch, font: auto, fill: auto, weight: "regular", aspect: (1, 1)) = (
  aspect: aspect,
  draw: (s, pal) => box(width: s * aspect.at(0), height: s * aspect.at(1),
    align(center + horizon, context {
      let paint = if fill == auto { pal.ink } else if type(fill) == function { fill(pal) } else { fill }
      let t = text(
        font: if font == auto { text.font } else { font },
        fill: paint, weight: weight, size: s, dir: ltr, ch)
      let m = measure(t)
      let k = calc.min(
        s * aspect.at(0) / calc.max(m.width, 0.01pt),
        s * aspect.at(1) / calc.max(m.height, 0.01pt))
      scale(k * 100%, reflow: true, t)
    })),
)

/// Wrap arbitrary content (an image, a symbol, a drawing) as a motif.
#let content-motif(body, aspect: (1, 1)) = (
  aspect: aspect,
  draw: (s, pal) => box(width: s * aspect.at(0), height: s * aspect.at(1),
    align(center + horizon, body)),
)

/// Wrap an SVG — read as text — as a motif, recoloured to the palette:
/// black becomes the ink, white the paper; grey shades are left alone.
/// The aspect is taken from the `viewBox` (or passed explicitly).
///
///   image-motif(read("assets/corner5.svg"))
///   image-motif(svg, ink: pal => pal.gold, aspect: (2, 1))
#let image-motif(src, aspect: auto, ink: auto, paper: auto, corner: "tl") = {
  let markup = if type(src) == bytes { str(src) } else if type(src) == str { src }
    else { panic("image-motif takes SVG markup — read the file as text") }
  let asp = if aspect != auto { aspect } else {
    let vb = markup.find(regex("viewBox=\"[^\"]+\""))
    if vb != none {
      let inner = vb.split("\"").at(1)
      let nums = inner.split(regex("[ ,]+")).filter(s => s != "").map(s => float(s))
      if nums.len() == 4 and nums.at(3) != 0 { ((nums.at(2) / nums.at(3)), 1) } else { (1, 1) }
    } else { (1, 1) }
  }
  let paint-of(v, pal, key) = if v == auto { pal.at(key) }
    else if type(v) == function { v(pal) } else { v }
  // every spelling of pure black and pure white an SVG may carry
  let blacks = (regex("rgb\(0%,\s?0%,\s?0%\)"), regex("#000000"), regex("#000\\b"),
    regex("(?i)\bblack\b"))
  let whites = (regex("rgb\(100%,\s?100%,\s?100%\)"), regex("#[fF]{6}"), regex("#[fF]{3}\\b"),
    regex("(?i)\bwhite\b"))
  (aspect: asp,
   // the corner the source artwork was drawn for; ornate mirrors motifs
   // assuming a top-left original, so a top-right original flips the set
   native-tr: corner == "tr",
   draw: (s, pal) => {
    let out = markup
    for pat in blacks { out = out.replace(pat, paint-of(ink, pal, "ink").to-hex()) }
    for pat in whites { out = out.replace(pat, paint-of(paper, pal, "paper").to-hex()) }
    box(width: s * asp.at(0), height: s * asp.at(1),
      image(bytes(out), format: "svg", width: 100%, height: 100%))
  })
}

/// The built-in motifs by name, for `edge: "rosette"` and friends.
#let motifs = (
  star8: star8,
  star8-line: star8-line,
  rosette: rosette,
  rosette-ink: rosette-ink,
  medallion: medallion,
  tile: tile-star8,
  tile-alt: tile-star8-alt,
  knot: tile-knot,
  lozenge: lozenge,
  palmette: palmette,
  finial: finial,
  scroll: scroll,
  wisp: wisp,
  wedge: wedge,
  notch: notch,
  bracket: bracket,
  merlon: merlon,
  bead: bead,
  flourish: flourish,
)

/// Turn whatever the user passed into a motif dictionary.
#let resolve-motif(m) = {
  if m == none { none }
  else if type(m) == str {
    if m in motifs { motifs.at(m) } else { panic("unknown motif: " + m) }
  }
  else if type(m) == dictionary and "draw" in m { m }
  else if type(m) == function { (aspect: (1, 1), draw: m) }
  else if type(m) == content { content-motif(m) }
  else { panic("a motif is a name, a (aspect, draw) dictionary, a function or content") }
}

/// Recolour a motif: `tint("rosette", ink: red)` draws with a patched
/// palette. Accepts anything `resolve-motif` takes.
#let tint(m, ..over) = {
  let mm = resolve-motif(m)
  (aspect: mm.aspect, draw: (s, pal) => (mm.draw)(s, pal + over.named()))
}

/// Rotate a motif by a fixed angle (its box stays the same).
#let turned(m, angle) = {
  let mm = resolve-motif(m)
  (aspect: mm.aspect, draw: (s, pal) => rotate(angle, (mm.draw)(s, pal)))
}

/// Draw a motif on its own — inline ornaments, dividers, list markers.
///
///   #ornament("rosette", size: 0.4cm)
#let ornament(m, size: 0.5cm, palette: (:), baseline: 20%) = {
  let mm = resolve-motif(m)
  box(baseline: baseline, (mm.draw)(size, make-palette(..palette)))
}
