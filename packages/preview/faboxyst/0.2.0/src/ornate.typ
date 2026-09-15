// ===========================================================================
//  faboxyst/ornate.typ — frames built from repeated ornaments.
//
//  The plates of a Maghrebi textbook: a cream page inside a pair of
//  hairlines, a rosette every few centimetres down the sides, a scroll in
//  each corner, a dark sash carrying the title. All of it is drawn from the
//  vector motifs in ornament.typ, so it recolours, scales and needs no
//  image assets.
//
//    #ornatebox(title: [Exercise 1])[…]
//    #ornatebox(edge: "palmette", corner: "scroll", radius: 0.3cm)[…]
//    #khatambox(title: [الحساب الجبري], badge: [1], badge-label: [تمرين])[…]
//    #zellijbox(title: [Roots])[…]
//    #arabesquebox(title: [Exercise 1])[…]
//    #mihrabbox(title: [Exercise 1])[…]
//    #mosaicbox[…]                       a tessellated course on four sides
//    #fleuronbox(title: [Preface])[…]    glyphs of an ornament font
//    #show: ornate-pages.with(preset: arabesquebox, margin: 1cm)
//
//  Layers, back to front: shadow · paper · rules · edge bands · edge
//  motifs · centre pieces · corners · title band · flank and end motifs ·
//  badge · body.
//
//  Direction-aware: "start" / "end" resolve against the surrounding
//  `text.dir`, so the badge, the sash caps and the title all move to the
//  right-hand edge under RTL. Corner specs accept logical keys too:
//  (bottom-end: "wedge") lands bottom-right in LTR, bottom-left in RTL.
// ===========================================================================

#import "fabox.typ": is-rtl
#import "watermark.typ": paint-watermark, resolve-wm-colour
#import "ornament.typ": (make-palette, resolve-motif, glyph-motif,
  ngon-points, star-points, STAR8, poly, disc, hair)

#let _cm(x) = if type(x) == length { x } else { x * 1cm }

/// A colour, a palette key ("gold"), or `auto` (= the ink).
#let _paint(p, pal, fallback: "ink") = {
  if p == auto { pal.at(fallback) }
  else if type(p) == str { pal.at(p) }
  else { p }
}

/// Normalise a side spec to physical side names.
#let _sides(spec, rtl) = {
  let list = if spec == none { () }
    else if spec == "all" or spec == auto { ("left", "right", "top", "bottom") }
    else if type(spec) == str { (spec,) }
    else { spec }
  list.map(s => {
    if s == "start" { if rtl { "right" } else { "left" } }
    else if s == "end" { if rtl { "left" } else { "right" } }
    else { s }
  })
}

/// (start, end) → (left, right) in physical order.
#let _lr(pair, rtl) = {
  let p = if type(pair) == array { pair } else { (pair, pair) }
  if rtl { (p.at(1), p.at(0)) } else { (p.at(0), p.at(1)) }
}

/// Split a per-corner spec into a (tl, tr, bl, br) dictionary of motifs.
///   "scroll"                        every corner
///   (top: "finial", bottom: "scroll")
///   (bottom-end: "wedge")           logical — follows the text direction
///   (tl: .., tr: .., bl: .., br: ..)
/// Physical keys win over logical ones, which win over top / bottom.
#let _corners(spec, rtl) = {
  let one(m) = resolve-motif(m)
  if spec == none { return (tl: none, tr: none, bl: none, br: none) }
  if type(spec) != dictionary or "draw" in spec {
    let m = one(spec)
    return (tl: m, tr: m, bl: m, br: m)
  }
  let out = (tl: none, tr: none, bl: none, br: none)
  if "top" in spec { let t = one(spec.at("top")); out = out + (tl: t, tr: t) }
  if "bottom" in spec { let b = one(spec.at("bottom")); out = out + (bl: b, br: b) }
  let logical = (
    "top-start":    if rtl { "tr" } else { "tl" },
    "top-end":      if rtl { "tl" } else { "tr" },
    "bottom-start": if rtl { "br" } else { "bl" },
    "bottom-end":   if rtl { "bl" } else { "br" },
  )
  for (k, v) in spec { if k in logical { out = out + (logical.at(k): one(v)) } }
  for k in ("tl", "tr", "bl", "br") { if k in spec { out = out + (k: one(spec.at(k))) } }
  out
}

/// Per-side spec → dictionary of motifs.
#let _per-side(spec, rtl) = {
  if spec == none { (:) }
  else if type(spec) == dictionary and spec.keys().any(k => k in ("top", "bottom", "left", "right", "start", "end")) {
    let out = (:)
    for (k, v) in spec {
      let side = _sides(k, rtl).first()
      out.insert(side, resolve-motif(v))
    }
    out
  } else {
    let m = resolve-motif(spec)
    (top: m, bottom: m, left: m, right: m)
  }
}

// ---------------------------------------------------------------------------
//  the sash — a band with shaped ends
// ---------------------------------------------------------------------------

/// The ops of a RIGHT-hand cap, from (xr - len, y0) down to (xr - len, y1).
/// Each op is ("line", p) or ("cubic", c1, c2, p), absolute coordinates.
#let _cap-ops(kind, xr, y0, y1, len) = {
  let h = y1 - y0
  let ym = (y0 + y1) / 2
  let xa = xr - len
  if kind == "flat" or len <= 0pt {
    (("line", (xr, y0)), ("line", (xr, y1)), ("line", (xa, y1)))
  } else if kind == "point" {
    (("line", (xr, ym)), ("line", (xa, y1)))
  } else if kind == "notch" {
    (("line", (xr, y0)), ("line", (xa, ym)), ("line", (xr, y1)), ("line", (xa, y1)))
  } else if kind == "arch" {
    // an ogival arch: two convex curves meeting at a tip
    (("cubic", (xa + len * 0.55, y0), (xr, y0 + h * 0.22), (xr, ym)),
     ("cubic", (xr, y1 - h * 0.22), (xa + len * 0.55, y1), (xa, y1)))
  } else if kind == "round" {
    let k = 0.5523
    (("cubic", (xa + len * k, y0), (xr, ym - h / 2 * k), (xr, ym)),
     ("cubic", (xr, ym + h / 2 * k), (xa + len * k, y1), (xa, y1)))
  } else if kind == "ogee" {
    // the top edge runs to the very end; the bottom edge sweeps up to meet it
    (("line", (xr, y0)),
     ("cubic", (xr - len * 0.42, y0), (xr - len * 0.58, y1), (xa, y1)))
  } else if kind == "swoosh" {
    // the reverse: the bottom edge runs on, the top edge sweeps down
    (("cubic", (xa + len * 0.42, y0), (xa + len * 0.58, y1), (xr, y1)),
     ("line", (xa, y1)))
  } else if kind == "step" {
    let s = h * 0.25
    (("line", (xa + len * 0.5, y0)), ("line", (xa + len * 0.5, y0 + s)),
     ("line", (xr, y0 + s)), ("line", (xr, y1 - s)),
     ("line", (xa + len * 0.5, y1 - s)), ("line", (xa + len * 0.5, y1)),
     ("line", (xa, y1)))
  } else if kind == "bevel" {
    (("line", (xr, y0 + h * 0.3)), ("line", (xr, y1 - h * 0.3)), ("line", (xa, y1)))
  } else {
    panic("unknown cap: " + repr(kind))
  }
}

/// Reverse a list of ops that started at `start`.
#let _rev-ops(start, ops) = {
  let ends = (start,) + ops.map(o => o.last())
  let out = ()
  for i in range(ops.len() - 1, -1, step: -1) {
    let o = ops.at(i)
    let target = ends.at(i)
    if o.at(0) == "line" { out.push(("line", target)) }
    else { out.push(("cubic", o.at(2), o.at(1), target)) }
  }
  out
}

/// The band as a `curve`, placed in absolute coordinates.
///   caps      (left-kind, right-kind)
///   cap-len   (left-len, right-len)
#let sash-shape(xl, xr, y0, y1, caps: ("flat", "flat"), cap-len: (0pt, 0pt), ..style) = {
  let (kl, kr) = caps
  let (ll, lr) = cap-len
  let ll = calc.min(ll, (xr - xl) / 2)
  let lr = calc.min(lr, (xr - xl) / 2)
  // right cap, as drawn
  let cap-r = _cap-ops(kr, xr, y0, y1, lr)
  // left cap: a right cap mirrored about the band's centre, then reversed
  let mx(p) = (xl + xr - p.at(0), p.at(1))
  let mirrored = _cap-ops(kl, xr, y0, y1, ll).map(o => {
    if o.at(0) == "line" { ("line", mx(o.at(1))) }
    else { ("cubic", mx(o.at(1)), mx(o.at(2)), mx(o.at(3))) }
  })
  let cap-l = _rev-ops((xr - ll, y0), mirrored).map(o => o)
  // the reversed mirrored cap starts at the mirror of the right cap's end,
  // i.e. (xl + ll, y1), and ends at (xl + ll, y0)
  let rel(p) = (p.at(0) - xl, p.at(1) - y0)
  let seg(o) = if o.at(0) == "line" { curve.line(rel(o.at(1))) }
               else { curve.cubic(rel(o.at(1)), rel(o.at(2)), rel(o.at(3))) }
  place(top + left, dx: xl, dy: y0, curve(..style,
    curve.move(rel((xl + ll, y0))),
    curve.line(rel((xr - lr, y0))),
    ..cap-r.map(seg),
    curve.line(rel((xl + ll, y1))),
    ..cap-l.map(seg),
    curve.close(mode: "straight")))
}

// ---------------------------------------------------------------------------
//  the badge
// ---------------------------------------------------------------------------

/// A khatam medallion carrying a number and a small label above it.
#let khatam-badge(number, label: none, size: 1.4cm, ink: rgb("#1F3A68"),
                  gold: rgb("#C9A24E"), paper: white, number-colour: auto,
                  label-colour: auto, star: true, label-font: auto) = {
  let c = (size / 2, size / 2)
  let R = size * 0.49
  box(width: size, height: size, {
    if star {
      poly(star-points(c, R, R * STAR8), fill: ink, stroke: 0.6pt + gold)
    } else {
      disc(c, R, fill: ink, stroke: 0.6pt + gold)
    }
    disc(c, R * 0.72, stroke: 0.5pt + gold)
    disc(c, R * 0.72, fill: paper.transparentize(88%))
    let num = text(fill: _paint(number-colour, (ink: ink, gold: gold, paper: paper), fallback: "paper"),
      size: size * 0.42, weight: "bold", number)
    let lab = if label == none { none } else {
      let ls = (fill: _paint(label-colour, (ink: ink, gold: gold, paper: paper), fallback: "gold"),
        size: size * 0.15)
      text(..(if label-font == auto { ls } else { ls + (font: label-font) }), label)
    }
    place(center + horizon, dy: if label == none { 0pt } else { size * 0.04 },
      stack(dir: ttb, spacing: -size * 0.02,
        ..(if lab != none { (align(center, lab),) } else { () }),
        align(center, num)))
  })
}

// ---------------------------------------------------------------------------
//  the frame
// ---------------------------------------------------------------------------

/// A frame built from repeated ornaments.
///
///   rules        the concentric hairlines, outermost first:
///                ((0.9pt, "ink"), (0.4pt, "gold")); a paint is a colour, a
///                palette key or auto (= ink)
///   rule-gap     the paper between two rules
///   radius       of the outer rule; inner rules follow
///   edge         the motif repeated along the sides — a name, a motif
///                dictionary, a function or content; none for plain rules
///   edge-sides   which sides carry it: ("start", "end") | "all" | ("bottom",)
///   edge-size    motif size; edge-gap the minimum space between two
///   edge-count   force the number per side (auto = as many as fit)
///   edge-shift   push motifs inward from the rule band (negative = outward)
///   edge-mask    hide the rules under each motif (auto = what the motif asks)
///   edge-band    a filled strip behind the motifs, e.g. 0.34cm (none = off)
///   edge-band-fill / edge-band-stroke  its paint and outline
///   edge-alternate  true mirrors every second motif; a motif replaces it
///   edge-pack    butt the motifs together instead of spreading them
///   edge-fit     resize them so a whole number closes the run exactly
///   edge-clear   free run between a corner and the first motif
///   corner       a motif for the corners, drawn for the top-left and
///                mirrored; (top: .., bottom: ..), (bottom-end: ..) or
///                (tl: .., ..) per corner
///   corner-size / corner-shift  size, and (dx, dy) pushed inward
///   centre       a motif at the middle of a side: "flourish" or
///                (bottom: "flourish", top: none)
///   title        content for the sash
///   title-style  "sash" | "tiles" | none
///   caps         the sash ends, (start, end): flat | point | notch | arch |
///                round | ogee | swoosh | step | bevel
///   cap-len      how long each cap runs; auto = 0.55 × band height
///   sash-inset   (start, end) — how far the band stops short of the rules
///   sash-gap     paper between the top rule and the band
///   sash-line    a gold hairline inside the band, this far from its foot
///   badge        content riding the leading end of the sash (a number)
///   badge-label  the small word above it
///   badge-shift  (fx, fy) — its centre, in fractions of its size, from the
///                band's leading end (auto = astride the end)
///   end-motif    a motif at each cap tip ("medallion")
///   flank        a motif between each cap and the side rule ("finial")
///   width        a length or a ratio of the available width
///   height       a minimum height — what page frames stretch to
#let ornatebox(
  body,
  title: none,
  // --- colours --------------------------------------------------------------
  colour: rgb("#1F3A68"),
  gold: rgb("#C9A24E"),
  paper: rgb("#FCF9F2"),
  palette: (:),
  fill: auto,               // the paper inside the frame; auto = `paper`
  // --- rules ----------------------------------------------------------------
  rules: ((0.9pt, "ink"), (0.4pt, "gold")),
  rule-gap: 0.09cm,
  radius: 0cm,
  outset: 0cm,              // room outside the outer rule for overhanging bits
  // --- edge motifs ----------------------------------------------------------
  edge: "rosette",
  edge-sides: ("start", "end"),
  edge-size: 0.42cm,
  edge-gap: 0.9cm,
  edge-count: auto,
  edge-shift: 0cm,
  edge-mask: auto,
  edge-band: none,
  edge-band-fill: auto,
  edge-band-stroke: none,
  edge-alternate: false,    // true mirrors every second motif; a motif replaces it
  edge-pack: false,         // butt the motifs together
  edge-fit: false,          // resize so a whole number closes the run
  edge-clear: auto,         // auto = corner-size + 0.15cm
  edge-turn: true,          // rotate motifs on the top / bottom edges
  // --- corners --------------------------------------------------------------
  corner: "wedge",
  corner-size: 0.7cm,
  corner-shift: (0cm, 0cm),
  // --- centre pieces --------------------------------------------------------
  centre: (bottom: "rosette"),
  centre-size: auto,        // auto = edge-size
  centre-mask: auto,
  // --- title band -----------------------------------------------------------
  title-style: "sash",
  title-colour: auto,       // auto = a light gold
  title-size: 1.1em,
  title-weight: "bold",
  title-align: auto,        // auto = start for sash, center for tiles
  title-inset: (x: 0.45cm, y: 0.16cm),
  title-gap: 0.28cm,        // between the band and the body
  title-rule: auto,         // a hairline under the band; auto = on for sash
  sash-fill: auto,          // auto = ink
  sash-stroke: none,
  sash-line: none,          // a gold hairline inside the band, from its foot
  sash-gap: 0.14cm,
  sash-inset: (0.55cm, 0.9cm),
  caps: ("ogee", "ogee"),   // the default sash ends: an ogee S-curve
  cap-len: auto,
  tile: "tile",             // the motif of a "tiles" band
  pennant-caps: ("point", "point"),
  pennant-width: auto,      // auto = the words + insets + caps
  pennant-stroke: auto,
  // --- decorations on the band ----------------------------------------------
  badge: none,
  badge-label: none,
  badge-size: auto,         // auto = 1.55 × band height
  badge-star: true,
  badge-shift: auto,        // (fx, fy) in fractions of the badge size
  end-motif: none,
  end-motif-size: auto,     // auto = 1.15 × band height
  flank: none,
  flank-size: auto,         // auto = 0.9 × band height
  // --- geometry -------------------------------------------------------------
  inset: (x: 0.55cm, y: 0.42cm),
  width: 100%,
  height: auto,             // a minimum height (page frames)
  shadow: false,
  watermark: none,
  watermark-colour: auto,
  watermark-angle: -18deg,
  watermark-size: 2.1em,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let pal = make-palette(ink: colour, gold: gold, paper: paper, ..palette)
  let fill = if fill == auto { pal.paper } else { fill }

  // --- rules ----------------------------------------------------------------
  let rule-list = rules.map(r => {
    if type(r) == array { (thickness: r.at(0), paint: _paint(r.at(1), pal)) }
    else if type(r) == length { (thickness: r, paint: pal.ink) }
    else if type(r) == stroke { (thickness: r.thickness, paint: r.paint) }
    else { panic("a rule is (thickness, paint)") }
  })
  let band-t = (
    rule-list.map(r => r.thickness).sum(default: 0pt)
    + rule-gap * calc.max(0, rule-list.len() - 1)
  )
  let o = _cm(outset)
  let band-mid = o + band-t / 2          // the motif line

  // --- motifs ---------------------------------------------------------------
  let edge-m = resolve-motif(edge)
  let sides = _sides(edge-sides, rtl)
  let corners = _corners(corner, rtl)
  let centres = _per-side(centre, rtl)
  let flank-m = resolve-motif(flank)
  let end-m = resolve-motif(end-motif)
  let cs = _cm(corner-size)
  let es = _cm(edge-size)
  let csz = if centre-size == auto { es } else { _cm(centre-size) }
  let (c-dx, c-dy) = (_cm(corner-shift.at(0)), _cm(corner-shift.at(1)))
  let has-corner = corners.values().any(v => v != none)
  let clear = if edge-clear == auto { (if has-corner { cs } else { 0.2cm }) + 0.15cm } else { _cm(edge-clear) }
  let shift = _cm(edge-shift)
  let alt-m = if edge-alternate != none and type(edge-alternate) != bool and edge-alternate != false {
    resolve-motif(edge-alternate)
  } else { none }
  let flip-alt = edge-alternate == true

  let m-dims(m, s) = (w: s * m.aspect.at(0), h: s * m.aspect.at(1))

  // how far the frame furniture reaches inward on each side
  let reach(side) = {
    let r = o + band-t
    if edge-m != none and side in sides {
      let d = m-dims(edge-m, es)
      let across = if side in ("left", "right") { d.w } else { if edge-turn { d.w } else { d.h } }
      r = calc.max(r, band-mid + shift + across / 2)
      if edge-band != none { r = calc.max(r, band-mid + _cm(edge-band) / 2) }
    }
    if side in centres and centres.at(side) != none {
      let d = m-dims(centres.at(side), csz)
      let across = if side in ("left", "right") { d.w } else { d.h }
      r = calc.max(r, band-mid + across / 2)
    }
    r
  }
  let ins = if type(inset) == dictionary {
    (x: _cm(inset.at("x", default: 0.5cm)), y: _cm(inset.at("y", default: 0.4cm)))
  } else { (x: _cm(inset), y: _cm(inset)) }
  let pad-l = reach("left") + ins.x
  let pad-r = reach("right") + ins.x
  let pad-t = reach("top") + ins.y
  let pad-b = reach("bottom") + ins.y

  // --- title ----------------------------------------------------------------
  let t-ins = if type(title-inset) == dictionary {
    (x: _cm(title-inset.at("x", default: 0.4cm)), y: _cm(title-inset.at("y", default: 0.15cm)))
  } else { (x: _cm(title-inset), y: _cm(title-inset)) }
  let t-colour = if title-colour == auto { pal.gold.lighten(28%) } else { _paint(title-colour, pal) }
  let title-body = if title == none { none } else {
    text(fill: t-colour, weight: title-weight, size: title-size, dir: body-dir, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) } else { measure(title-body) }
  let has-band = title != none and title-style != none
  let th = if has-band { tm.height + 2 * t-ins.y } else { 0pt }
  let t-align = if title-align == auto {
    if title-style == "tiles" { center } else { start }
  } else { title-align }
  let cl = if cap-len == auto { th * 0.55 } else { _cm(cap-len) }
  let (cap-l, cap-r) = _lr(caps, rtl)
  let (sin-l, sin-r) = _lr(sash-inset, rtl).map(_cm)
  let sgap = _cm(sash-gap)
  let bsz = if badge-size == auto { th * 1.55 } else { _cm(badge-size) }
  let esz = if end-motif-size == auto { th * 1.15 } else { _cm(end-motif-size) }
  let fsz = if flank-size == auto { th * 0.9 } else { _cm(flank-size) }
  let t-rule = if title-rule == auto { title-style == "sash" } else { title-rule }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { _cm(width) }

    // band geometry (y relative to the frame's top edge)
    let band-y0 = if title-style == "tiles" { o } else { o + band-t + sgap }
    let band-y1 = band-y0 + th
    let band-x0 = if title-style == "tiles" { o } else { o + band-t + sin-l }
    let band-x1 = if title-style == "tiles" { W - o } else { W - o - band-t - sin-r }
    let band-cy = (band-y0 + band-y1) / 2
    // where the badge rides: astride the band's leading end, or shifted
    let badge-c = if badge != none and has-band {
      let cx = if badge-shift == auto {
        if rtl { band-x1 - bsz / 2 + 0.02cm } else { band-x0 + bsz / 2 - 0.02cm }
      } else {
        (if rtl { band-x1 } else { band-x0 }) + (if rtl { -1 } else { 1 }) * badge-shift.at(0) * bsz
      }
      let cy = band-cy + (if badge-shift == auto { 0pt } else { badge-shift.at(1) * bsz })
      (cx, cy)
    } else { (0pt, band-cy) }
    // the badge may stick out above the frame
    let hang-t = if badge != none and has-band { calc.max(0pt, bsz / 2 - badge-c.at(1) + 0.04cm) } else { 0pt }
    let hang-b = if shadow { 0.18cm } else { 0pt }

    let body-y0 = if has-band { band-y1 + _cm(title-gap) } else { pad-t }
    let main = block(width: W - pad-l - pad-r, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let bh = measure(main).height
    let H0 = body-y0 + bh + pad-b
    let H = if height != auto { calc.max(H0, _cm(height)) } else { H0 }

    // --- one rule rectangle -----------------------------------------------
    let rule-rect(inset, r) = {
      let t = r.thickness
      place(top + left, dx: inset + t / 2, dy: inset + t / 2,
        rect(width: W - 2 * inset - t, height: H - 2 * inset - t,
          stroke: (paint: r.paint, thickness: t, join: "miter"),
          radius: calc.max(0pt, _cm(radius) - (inset - o))))
    }

    // --- one motif, centred at (cx, cy), optionally rotated ----------------
    let put(m, s, cx, cy, angle: 0deg, mirror-x: false, mirror-y: false) = {
      let d = m-dims(m, s)
      let it = (m.draw)(s, pal)
      if mirror-x or mirror-y {
        it = scale(x: if mirror-x { -100% } else { 100% }, y: if mirror-y { -100% } else { 100% }, it)
      }
      if angle != 0deg { it = rotate(angle, it) }
      place(top + left, dx: cx - d.w / 2, dy: cy - d.h / 2, it)
    }
    let mask(cx, cy, w, h) = place(top + left, dx: cx - w / 2, dy: cy - h / 2,
      rect(width: w, height: h, fill: fill, radius: 0.04cm))

    // --- the run of motifs along one side ----------------------------------
    let run(side) = {
      if edge-m == none or side not in sides { return }
      let vertical = side in ("left", "right")
      let d = m-dims(edge-m, es)
      let turned = (not vertical) and edge-turn
      let along0 = if vertical or turned { d.h } else { d.w }
      let angle = if not turned { 0deg } else if side == "top" { -90deg } else { 90deg }
      // the free run, between the corner clearances
      let top-clear = if has-band and vertical { band-y1 + 0.25cm } else { clear }
      let (a, b) = if vertical { (top-clear, H - clear) } else { (clear, W - clear) }
      // a centre piece on this side takes the middle of the run
      let centre-here = side in centres and centres.at(side) != none
      let L = b - a
      let packed = edge-pack or edge-fit
      let gap = if packed { 0pt } else { _cm(edge-gap) }
      let n0 = if edge-count != auto { edge-count } else {
        calc.max(0, calc.floor((L + gap + 0.001pt) / (along0 + gap)))
      }
      let n = if centre-here and calc.odd(n0) { n0 - 1 } else { n0 }
      if n <= 0 { return }
      // edge-fit resizes the motifs so a whole number closes the run
      let k = if edge-fit and along0 > 0pt { L / (n * along0) } else { 1 }
      let es-run = es * k
      let along = along0 * k
      let lead-in = if packed { (L - n * along) / 2 } else { 0pt }
      let step = if packed { along } else { if n > 1 { (L - along) / (n - 1) } else { 0pt } }
      let line-pos = band-mid + shift
      let strip-fill = _paint(edge-band-fill, pal)
      if edge-band != none {
        let bw = _cm(edge-band)
        if vertical {
          let x = if side == "left" { line-pos } else { W - line-pos }
          place(top + left, dx: x - bw / 2, dy: a - along / 2,
            rect(width: bw, height: L + along, fill: strip-fill, stroke: edge-band-stroke))
        } else {
          let y = if side == "top" { line-pos } else { H - line-pos }
          place(top + left, dx: a - along / 2, dy: y - bw / 2,
            rect(width: L + along, height: bw, fill: strip-fill, stroke: edge-band-stroke))
        }
      }
      for i in range(n) {
        let t = if n == 1 and not packed { (a + b) / 2 } else { a + lead-in + along / 2 + i * step }
        let (cx, cy) = if side == "left" { (line-pos, t) }
          else if side == "right" { (W - line-pos, t) }
          else if side == "top" { (t, line-pos) }
          else { (t, H - line-pos) }
        let m-i = if alt-m != none and calc.odd(i) { alt-m } else { edge-m }
        let d-i = m-dims(m-i, es-run)
        let along-i = if vertical or turned { d-i.h } else { d-i.w }
        let across-i = if vertical or turned { d-i.w } else { d-i.h }
        let do-mask = if edge-mask == auto { m-i.at("mask", default: true) and edge-band == none } else { edge-mask }
        if do-mask {
          if vertical { mask(cx, cy, across-i + 0.08cm, along-i + 0.12cm) }
          else { mask(cx, cy, along-i + 0.12cm, across-i + 0.08cm) }
        }
        put(m-i, es-run, cx, cy, angle: angle,
          mirror-x: (side == "right") != (flip-alt and calc.odd(i)),
          mirror-y: side == "bottom")
      }
    }

    // --- centre pieces ------------------------------------------------------
    let centre-piece(side) = {
      if side not in centres or centres.at(side) == none { return }
      let m = centres.at(side)
      let d = m-dims(m, csz)
      let (cx, cy) = if side == "top" { (W / 2, band-mid) }
        else if side == "bottom" { (W / 2, H - band-mid) }
        else if side == "left" { (band-mid, (body-y0 + H) / 2) }
        else { (W - band-mid, (body-y0 + H) / 2) }
      let do-mask = if centre-mask == auto { m.at("mask", default: true) } else { centre-mask }
      if do-mask { mask(cx, cy, d.w + 0.14cm, d.h + 0.10cm) }
      put(m, csz, cx, cy, mirror-y: side == "bottom" and m.at("flip-bottom", default: false))
    }

    // --- corners ------------------------------------------------------------
    let corner-piece(key) = {
      let m = corners.at(key)
      if m == none { return }
      let drawn-right = m.at("native-tr", default: false)
      let d = m-dims(m, cs)
      let x = if key in ("tl", "bl") { o + c-dx + d.w / 2 } else { W - o - c-dx - d.w / 2 }
      let y = if key in ("tl", "tr") { o + c-dy + d.h / 2 } else { H - o - c-dy - d.h / 2 }
      put(m, cs, x, y, mirror-x: (key in ("tr", "br")) != drawn-right, mirror-y: key in ("bl", "br"))
    }

    block(width: W, height: H + hang-t + hang-b, {
      // shadow
      if shadow {
        for k in range(6) {
          let t = (k + 1) / 6
          place(top + left, dx: 0.05cm * t, dy: hang-t + 0.09cm * t,
            rect(width: W - 2 * o, height: H - 2 * o,
              fill: luma(60).transparentize(100% - 8% * (1 - t)),
              radius: _cm(radius) + 0.05cm))
        }
      }

      place(top + left, dy: hang-t, block(width: W, height: H, {
        // 1. paper
        place(top + left, dx: o, dy: o,
          rect(width: W - 2 * o, height: H - 2 * o, fill: fill, radius: _cm(radius)))

        // 2. rules
        let inset = o
        for r in rule-list {
          rule-rect(inset, r)
          inset += r.thickness + rule-gap
        }

        // 3. edge motifs, centre pieces, corners
        for s in ("left", "right", "top", "bottom") { run(s) }
        for s in ("left", "right", "top", "bottom") { centre-piece(s) }
        for k in ("bl", "br", "tl", "tr") { corner-piece(k) }

        // 4. the title band
        if has-band {
          let s-fill = _paint(sash-fill, pal)
          if title-style == "tiles" {
            let tile-m = resolve-motif(tile)
            let d = m-dims(tile-m, th)
            let n = calc.ceil((band-x1 - band-x0) / d.w) + 1
            place(top + left, dx: band-x0, dy: band-y0,
              box(width: band-x1 - band-x0, height: th, clip: true,
                stack(dir: ltr, ..range(n).map(i => (tile-m.draw)(th, pal)))))
            // the pennant
            let pw-base = tm.width + 2 * t-ins.x + 2 * cl
            let pw = if pennant-width == auto { pw-base } else {
              calc.max(pw-base, if type(pennant-width) == ratio {
                (band-x1 - band-x0) * pennant-width
              } else { _cm(pennant-width) })
            }
            let px0 = if t-align == center { (band-x0 + band-x1 - pw) / 2 }
              else if (t-align == start) != rtl { band-x0 + d.w * 1.5 }
              else { band-x1 - d.w * 1.5 - pw }
            let (pc-l, pc-r) = _lr(pennant-caps, rtl)
            let pst = if pennant-stroke == auto { 0.5pt + pal.ink } else { pennant-stroke }
            sash-shape(px0, px0 + pw, band-y0 + 0.06cm, band-y1 - 0.06cm,
              caps: (pc-l, pc-r), cap-len: (cl, cl), fill: pal.paper, stroke: pst)
            place(top + left, dx: px0 + cl, dy: band-y0,
              box(width: pw - 2 * cl, height: th, align(center + horizon, title-body)))
            // hairlines above and below the tiles
            hair((band-x0, band-y0), (band-x1, band-y0), stroke: 1pt + pal.ink)
            hair((band-x0, band-y1), (band-x1, band-y1), stroke: 1pt + pal.ink)
          } else {
            sash-shape(band-x0, band-x1, band-y0, band-y1,
              caps: (cap-l, cap-r), cap-len: (cl, cl),
              fill: s-fill, stroke: sash-stroke)
            // a gold hairline inside the band, this far from its foot
            if sash-line != none {
              let y = calc.max(band-y0 + 0.04cm, band-y1 - _cm(sash-line))
              hair((band-x0 + cl * 0.75, y), (band-x1 - cl * 0.75, y),
                stroke: 0.4pt + pal.gold.lighten(30%))
            }
            // the title, inside the flat part of the band
            let flat-x0 = band-x0 + cl
            let flat-x1 = band-x1 - cl
            let lead = if badge != none { bsz * 0.75 } else { 0pt }
            let tx0 = if rtl { flat-x0 } else { flat-x0 + lead }
            let tx1 = if rtl { flat-x1 - lead } else { flat-x1 }
            place(top + left, dx: tx0, dy: band-y0,
              box(width: tx1 - tx0, height: th, inset: (x: t-ins.x),
                align(t-align + horizon, title-body)))
          }
          if t-rule {
            let y = band-y1 + _cm(title-gap) * 0.45
            let x0 = o + band-t + 0.35cm
            let x1 = W - o - band-t - 0.35cm
            hair((x0, y), (x1, y), stroke: 0.45pt + pal.gold)
            poly(ngon-points((x0, y), 0.06cm, 4), fill: pal.gold)
            poly(ngon-points((x1, y), 0.06cm, 4), fill: pal.gold)
          }
          // end motifs at the cap tips
          if end-m != none and title-style != "tiles" {
            put(end-m, esz, band-x0, band-cy)
            put(end-m, esz, band-x1, band-cy, mirror-x: true)
          }
          // flank motifs between the caps and the rules
          if flank-m != none and title-style != "tiles" {
            let d = m-dims(flank-m, fsz)
            let room-l = band-x0 - (o + band-t)
            let room-r = (W - o - band-t) - band-x1
            if room-l > d.w * 0.6 { put(flank-m, fsz, (o + band-t + band-x0) / 2, band-cy) }
            if room-r > d.w * 0.6 { put(flank-m, fsz, (band-x1 + W - o - band-t) / 2, band-cy, mirror-x: true) }
          }
          // the badge on the leading end
          if badge != none {
            place(top + left, dx: badge-c.at(0) - bsz / 2, dy: badge-c.at(1) - bsz / 2,
              khatam-badge(badge, label: badge-label, size: bsz, ink: pal.ink,
                gold: pal.gold, paper: pal.paper, star: badge-star))
          }
        }

        // 5. watermark (behind the body, clipped to the paper)
        if watermark != none {
          let wc = resolve-wm-colour(watermark-colour, pal.ink)
          place(top + left, dx: o, dy: o,
            box(width: W - 2 * o, height: H - 2 * o, clip: true,
              paint-watermark(watermark, colour: wc.transparentize(45%),
                angle: watermark-angle, size: watermark-size)))
        }

        // 6. body
        place(top + left, dx: pad-l, dy: body-y0, main)
      }))
    })
  })
}

// ---------------------------------------------------------------------------
//  the presets — one per plate of the reference textbook
// ---------------------------------------------------------------------------

/// Navy sash, khatam badge at the leading corner, gold rosettes on a dark
/// strip down the leading edge, wedges at the foot.
#let khatambox(body, title: none, badge: none, badge-label: none,
               colour: rgb("#1F3A68"), sash-fill: rgb("#1E6B5A"), ..a) = ornatebox(
  body, title: title, badge: badge, badge-label: badge-label,
  colour: colour, sash-fill: sash-fill,
  rules: ((0.8pt, "ink"), (0.35pt, "gold")),
  edge: "rosette", edge-sides: ("start",), edge-size: 0.40cm, edge-gap: 0.75cm,
  edge-band: 0.36cm, edge-shift: 0.18cm,
  corner: (bottom: "wedge"), corner-size: 0.62cm,
  centre: (bottom: "rosette"), centre-size: 0.36cm,
  caps: ("flat", "arch"), sash-inset: (0cm, 1.1cm), sash-gap: 0.12cm,
  ..a)

/// A course of zellij tiles across the top with a paper pennant for the
/// title; knot tiles down the sides, star tiles in the corners.
#let zellijbox(body, title: none, colour: rgb("#1F3A68"), gold: rgb("#B8863B"),
               tile-colour: rgb("#1B7F8C"), ..a) = ornatebox(
  body, title: title, colour: colour, gold: gold,
  palette: (tile: tile-colour),
  rules: ((0.7pt, "tile"), (0.35pt, "gold")), rule-gap: 0.08cm,
  edge: "knot", edge-sides: ("start", "end"), edge-size: 0.34cm, edge-gap: 0.7cm,
  corner: (bottom: "tile"), corner-size: 0.5cm, corner-shift: (-0.08cm, -0.08cm),
  centre: (bottom: "tile"), centre-size: 0.42cm,
  title-style: "tiles", title-colour: "ink", title-inset: (x: 0.6cm, y: 0.22cm),
  title-gap: 0.32cm,
  ..a)

/// A rounded frame, a navy banner with ogee ends flanked by finials,
/// palmettes down the sides and arabesque scrolls at the foot.
#let arabesquebox(body, title: none, colour: rgb("#1F3A68"), gold: rgb("#C9A24E"), ..a) = ornatebox(
  body, title: title, colour: colour, gold: gold,
  rules: ((0.7pt, "ink"), (0.3pt, "gold")), rule-gap: 0.07cm, radius: 0.32cm,
  edge: "palmette", edge-size: 0.36cm, edge-gap: 0.55cm, edge-shift: 0.28cm,
  edge-mask: false,
  corner: (bottom: "scroll"), corner-size: 0.85cm, corner-shift: (-0.12cm, -0.12cm),
  centre: (bottom: "flourish"), centre-size: 0.32cm,
  caps: ("ogee", "ogee"), cap-len: 0.9cm, sash-inset: (1.25cm, 1.25cm), sash-gap: 0cm,
  flank: "finial", flank-size: 0.34cm,
  title-align: center, title-gap: 0.3cm,
  ..a)

/// Emerald sash ending in pointed arches with a medallion at each tip,
/// rosettes down both sides, notched corners at the head and wedges at
/// the foot.
#let mihrabbox(body, title: none, colour: rgb("#1E5C4A"), gold: rgb("#C9A24E"), ..a) = ornatebox(
  body, title: title, colour: colour, gold: gold,
  rules: ((0.8pt, "ink"), (0.35pt, "gold")), rule-gap: 0.08cm,
  edge: "rosette-ink", edge-size: 0.40cm, edge-gap: 0.7cm,
  corner: (top: "notch", bottom: "wedge"), corner-size: 0.55cm,
  centre: (bottom: "rosette"), centre-size: 0.36cm,
  caps: ("arch", "arch"), cap-len: 0.55cm, sash-inset: (0.75cm, 0.75cm), sash-gap: 0.16cm,
  end-motif: "medallion",
  ..a)

/// A continuous course of zellij tiles on the four sides, alternating star
/// tiles in the corners — the chapter plate. `edge-fit` closes each run
/// exactly, so the tessellation reads as one band.
#let mosaicbox(body, title: none, colour: rgb("#1F3A68"), gold: rgb("#B8863B"),
               tile-colour: rgb("#1B7F8C"), ..a) = ornatebox(
  body, title: title, colour: colour, gold: gold,
  palette: (tile: tile-colour),
  rules: ((0.7pt, "tile"), (0.35pt, "gold")), rule-gap: 0.08cm,
  edge: "tile", edge-sides: "all", edge-size: 0.40cm,
  edge-pack: true, edge-fit: true, edge-mask: false, edge-clear: 0.46cm,
  corner: "tile-alt", corner-size: 0.44cm, corner-shift: (-0.06cm, -0.06cm),
  centre: none,
  caps: ("flat", "flat"), sash-inset: (0.8cm, 0.8cm),
  inset: (x: 0.75cm, y: 0.6cm),
  ..a)

/// Fleurons from an ornament font: a warm sepia frame with ❦ down the
/// sides and ✤ in the corners — for front matter. Any glyph, any face.
#let fleuronbox(body, title: none, colour: rgb("#5C4326"), gold: rgb("#A87F3C"),
                edge-glyph: "❦", corner-glyph: "✤", glyph-font: auto, ..a) = ornatebox(
  body, title: title, colour: colour, gold: gold,
  rules: ((0.7pt, "ink"), (0.3pt, "gold")), rule-gap: 0.08cm, radius: 0.18cm,
  edge: glyph-motif(edge-glyph, font: glyph-font), edge-sides: "all",
  edge-size: 0.34cm, edge-gap: 0.5cm, edge-turn: false,
  corner: glyph-motif(corner-glyph, font: glyph-font, fill: p => p.gold),
  corner-size: 0.55cm, corner-shift: (-0.04cm, -0.04cm),
  centre: none,
  caps: ("ogee", "ogee"), cap-len: 0.5cm, sash-inset: (0.9cm, 0.9cm),
  title-align: center, title-gap: 0.3cm,
  ..a)

// ---------------------------------------------------------------------------
//  page frames
// ---------------------------------------------------------------------------

/// Draw a frame on every page's background and keep the text inside it.
///
///   #show: ornate-pages.with(preset: arabesquebox, margin: 1cm)
///
/// `preset` is any of the box functions (or `ornatebox` itself) — extra
/// arguments go straight to it. `margin` is the distance from the paper
/// edge to the outer rule; `inner` the paper left between the frame and
/// the text (auto = 0.85cm). The page margins are set to `margin + inner`.
#let ornate-pages(doc, preset: ornatebox, margin: 1.2cm, inner: auto, ..args) = {
  let m = _cm(margin)
  let gap = if inner == auto { 0.85cm } else { _cm(inner) }
  set page(
    margin: m + gap,
    background: context {
      let fw = page.width - 2 * m
      let fh = page.height - 2 * m
      place(top + left, dx: m, dy: m,
        preset([], width: fw, height: fh, ..args.named()))
    },
  )
  doc
}
