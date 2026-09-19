// =============================================================================
//  scrapbook.typ — the six paper objects of a French "rituel" poster
//
//  Measured off uploads/FB_IMG_1785849173985.jpg (1407 x 1876), a
//  scrapbook-style classroom poster. Six DIFFERENT paper stocks, each with
//  its own edge treatment and its own fastening:
//
//    19  torn-note     hand-torn kraft, washi tape           (the title)
//    20  ruled-sheet   filler paper, punched, tape + clip    (the rubric)
//    21  stamp-card    scalloped sage mat + tilted card + pin
//    22  grid-note     graph paper, polka washi + paperclip
//    23  index-card    ruled card, double rule, tinted footer
//    24  deckle-tag    small deckle-edged tag, gingham tape
//
//  Everything is drawn: no images, no external assets.
// =============================================================================

#import "engine.typ": (randoms, circle-pts, arc-pts, rect-pts, smooth-pts,
  densify)
#import "mapdraw.typ": (polylines as md-polylines, region as md-region,
  rough-outline as md-rough-outline, sketched as md-sketched,
  rough-points as md-rough-points)

// -----------------------------------------------------------------------------
//  the poster's own palette, sampled from the source
// -----------------------------------------------------------------------------

#let sb-colours = (
  page:      rgb("#EEE6DB"),   // the board behind everything
  kraft:     rgb("#E8D2C4"),   // the torn title paper
  paper:     rgb("#F0E6DA"),   // filler paper
  card:      rgb("#F2EAE0"),   // the index card
  sage:      rgb("#CBC8B9"),   // the scalloped mat
  grid:      rgb("#EEDED1"),   // graph paper
  tag:       rgb("#DFD9C9"),   // the small tag
  blush:     rgb("#E7CDC0"),   // the tinted footer
  ink:       rgb("#2E2A26"),
  rose:      rgb("#B4776C"),   // the rules and the hearts
  olive:     rgb("#6E7358"),   // the green rule
  shadow:    rgb("#00000018"),
)

// -----------------------------------------------------------------------------
//  shared machinery
// -----------------------------------------------------------------------------

// A torn paper edge. Real tearing leaves TWO frequencies: a slow wander of
// a few millimetres and a fast fibre-level jitter on top. One frequency
// alone reads as a wave (too regular) or as noise (too spiky), which is why
// the first attempt with a single `randoms` call looked like a saw blade.
#let _torn-edge(p0, p1, amp: 0.10, n: 34, seed: 1, out: 1.0) = {
  let (x0, y0) = p0
  let (x1, y1) = p1
  let dx = x1 - x0
  let dy = y1 - y0
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return (p0, p1) }
  let ux = dx / len
  let uy = dy / len
  let nx = -uy * out
  let ny = ux * out
  // Few control points, then SMOOTHED. A displacement per sample point is
  // what makes a saw blade: real torn paper wanders slowly and the fibres
  // only roughen that wander. So the wander is sampled coarsely (every
  // ~8 mm), splined, and a much finer jitter is added on top.
  let k = calc.max(3, int(len / 0.85))
  let slow = randoms(seed, k + 1)
  let ctrl = range(k + 1).map(i => {
    let t = i / k
    let taper = calc.min(1.0, calc.sin(calc.pi * t) * 1.7)
    let d = (slow.at(i) - 0.5) * 2 * amp * taper
    (x0 + ux * len * t + nx * d, y0 + uy * len * t + ny * d)
  })
  let sm = smooth-pts(ctrl, samples: 7)
  let fast = randoms(seed + 977, sm.len())
  range(sm.len()).map(i => {
    let t = i / calc.max(1, sm.len() - 1)
    let taper = calc.min(1.0, calc.sin(calc.pi * t) * 1.7)
    let d = (fast.at(i) - 0.5) * 2 * amp * 0.13 * taper
    (sm.at(i).at(0) + nx * d, sm.at(i).at(1) + ny * d)
  })
}

// A closed torn contour, corner to corner.
#let _torn-rect(w, h, amp: 0.10, seed: 1, sides: (1, 1, 1, 1)) = {
  let a(i) = if sides.at(i) == 0 { 0.012 } else { amp }
  let e1 = _torn-edge((0.0, 0.0), (w, 0.0), amp: a(0), seed: seed, out: -1.0)
  let e2 = _torn-edge((w, 0.0), (w, h), amp: a(1), seed: seed + 31)
  let e3 = _torn-edge((w, h), (0.0, h), amp: a(2), seed: seed + 67)
  let e4 = _torn-edge((0.0, h), (0.0, 0.0), amp: a(3), seed: seed + 103,
    out: -1.0)
  e1 + e2.slice(1) + e3.slice(1) + e4.slice(1)
}

// Paper grain: short pale and dark strokes, so a flat fill stops looking
// like a swatch of colour and starts looking like stock.
#let _grain(w, h, seed: 5, n: 150, ink: black, strength: 4%) = {
  let r = randoms(seed, n * 4)
  let out = ()
  for i in range(n) {
    let x = r.at(i * 4) * w
    let y = r.at(i * 4 + 1) * h
    let l = 0.06 + r.at(i * 4 + 2) * 0.20
    let up = r.at(i * 4 + 3) > 0.5
    out.push((((x, y), (x + l, y + (r.at(i * 4 + 2) - 0.5) * 0.05)),
      if up { white } else { ink }))
  }
  out
}

#let _heart-pts(c, s, n: 40) = range(n + 1).map(i => {
  let t = 2 * calc.pi * i / n
  let x = 16 * calc.pow(calc.sin(t * 1rad), 3)
  let y = 13 * calc.cos(t * 1rad) - 5 * calc.cos(2 * t * 1rad) - 2 * calc.cos(3 * t * 1rad) - calc.cos(4 * t * 1rad)
  (c.at(0) + x * s / 32, c.at(1) + y * s / 32)
})

/// A little rose heart, the poster's recurring ornament.
#let sb-heart(size: 0.32, colour: auto) = {
  let col = if colour != auto { colour } else { sb-colours.rose }
  let s = size
  box(width: s * 1cm, height: s * 1cm, {
    place(top + left, md-polylines((_heart-pts((s / 2, s / 2), s * 0.92),),
      flip: s * 1cm, closed: true,
      stroke: (paint: col, thickness: 0.9pt, join: "round")))
  })
}


// -----------------------------------------------------------------------------
//  the rough-drawing knob, shared by all six
// -----------------------------------------------------------------------------

// Resample a contour so the wobble has points to act on. A rough stroke can
// only deviate where there IS a vertex, so a four-point rectangle comes out
// straight however high `roughness` is set.
#let _sb-resample(pts, step: 0.42, closed: true) = {
  let ring = if closed { pts + (pts.first(),) } else { pts }
  let out = (ring.first(),)
  for i in range(1, ring.len()) {
    let a = ring.at(i - 1)
    let b = ring.at(i)
    let d = calc.sqrt(calc.pow(b.at(0) - a.at(0), 2)
      + calc.pow(b.at(1) - a.at(1), 2))
    let n = calc.max(1, calc.min(40, int(d / step)))
    for j in range(1, n + 1) {
      out.push((a.at(0) + (b.at(0) - a.at(0)) * j / n,
                a.at(1) + (b.at(1) - a.at(1)) * j / n))
    }
  }
  out
}

/// Fill a contour and/or stroke it, honouring the hand-drawn settings.
///
/// `md-region` always fills a CLEAN outline — there is no rough fill — so a
/// rough shape is a clean fill with a rough border of its own colour drawn
/// over the top. That trick is the same one `speed-bar` needed.
///
///   hand   `none` (clean), "roughjs", or "sketch"
#let _sb-draw(
  pts, flip,
  fill: none, paint: none, w: 0.5pt, closed: true,
  hand: none, seed: 1, roughness: 1.0, bowing: 0.6, amplitude: 0.4,
) = {
  let out = ()
  if fill != none {
    out.push(md-region((pts,), flip: flip, fill: fill))
    // a rough edge on the fill itself, or the shape keeps a crisp outline
    // inside a hand-drawn drawing
    if hand != none and hand != "none" {
      out.push(md-rough-outline((_sb-resample(pts),), flip: flip, seed: seed,
        roughness: roughness * 0.7, bowing: bowing,
        stroke: (paint: fill, thickness: 1.1pt, join: "round")))
    }
  }
  if paint != none {
    let st = (paint: paint, thickness: w, join: "round", cap: "round")
    // A HAIRLINE MUST WOBBLE LESS THAN AN EDGE. rough.js displaces by a
    // fixed distance, so the same `roughness` that gives a torn edge its
    // character smears a 0.4 pt ruling into a scribble — the deviation is
    // several times the line's own width. Fine strokes are therefore scaled
    // down: full strength at 1.6 pt and above, a third of it at 0.4 pt.
    let fine = calc.min(1.0, 0.28 + 0.45 * (w / 1pt))
    if hand == "roughjs" {
      // rough.js draws every stroke TWICE — that double pass is what gives
      // a pencil edge its weight, but on a 0.4 pt ruling it just doubles
      // the ink and the line reads as bold. Fine strokes keep one pass.
      let passes = rough-points(_sb-resample(pts, closed: closed),
        closed: closed, roughness: roughness * fine, bowing: bowing,
        seed: seed)
      let keep = if w < 0.9pt { passes.slice(0, 1) } else { passes }
      out.push(md-polylines(keep, flip: flip, fill: none, stroke: st))
    } else if hand == "sketch" {
      let ring = if closed { pts + (pts.first(),) } else { pts }
      out.push(md-sketched((_sb-resample(ring, closed: false),), flip: flip,
        seed: seed, amplitude: amplitude * fine, stroke: st))
    } else {
      out.push(md-polylines(((if closed { pts + (pts.first(),) } else { pts }),),
        flip: flip, stroke: st))
    }
  }
  out.map(e => place(top + left, e)).join()
}

/// Turn the user's `rough:` / `roughness:` into the settings the drawing
/// helpers take. `rough: true` means "the package's usual hand".
#let _sb-hand(rough, hand, roughness) = {
  let on = rough == true or (rough == auto and hand != none)
  if not on { return (hand: none, roughness: 0.0) }
  (hand: if hand != none { hand } else { "roughjs" },
   roughness: roughness)
}

// -----------------------------------------------------------------------------
//  19. torn-note — hand-torn kraft paper held by a strip of washi tape
// -----------------------------------------------------------------------------

/// A strip of washi tape.
///
/// Tape is TRANSLUCENT: the source shows the paper darkening where the strip
/// crosses it, and the strip's own ends are cut square while its long edges
/// are slightly ragged. Drawing it opaque was the giveaway in the first
/// attempt — it read as a sticker, not as tape.
///
///   kind   "plain" | "dots" | "gingham" | "stripe"
#let sb-tape(
  w: 2.6, h: 0.78, angle: -8deg, kind: "dots",
  colour: auto, ink: auto, seed: 3,
) = {
  let base = if colour != auto { colour } else { rgb("#B9C3B0") }
  let dotc = if ink != auto { ink } else { white }
  let flip = h * 1cm
  // long edges wander a little; the ends are scissor-cut
  // NOT `top`/`bot`: `top` is the ALIGNMENT, and shadowing it makes every
  // `place(top + left, ..)` below read as "array + alignment".
  let e-top = _torn-edge((0.0, 0.0), (w, 0.0), amp: 0.022, n: 22, seed: seed,
    out: -1.0)
  let e-bot = _torn-edge((w, h), (0.0, h), amp: 0.022, n: 22, seed: seed + 44)
  let body = e-top + e-bot
  rotate(angle, reflow: false, box(width: w * 1cm, height: h * 1cm, {
    place(top + left, md-region((body,), flip: flip,
      fill: base.transparentize(22%)))
    if kind == "dots" {
      let r = randoms(seed + 7, 200)
      let cols = int(w / 0.30)
      let rows = int(h / 0.26)
      for i in range(cols) {
        for j in range(rows) {
          let x = 0.16 + i * 0.30 + (if calc.rem(j, 2) == 0 { 0.0 } else { 0.15 })
          let y = 0.16 + j * 0.26
          if x < w - 0.06 and y < h - 0.06 {
            place(top + left, md-region((circle-pts((x, y), 0.052, n: 14),),
              flip: flip, fill: dotc.transparentize(14%)))
          }
        }
      }
    } else if kind == "gingham" {
      // Gingham is not a grid of squares: it is two translucent stripe sets
      // crossing, so the overlaps come out DOUBLE strength. Painting equal
      // squares is what made the first try look like a chessboard.
      let step = 0.30
      let i = 0
      while i * step < w {
        place(top + left, md-region((rect-pts((i * step, 0.0),
          (calc.min(w, i * step + step * 0.62), h)),), flip: flip,
          fill: base.darken(16%).transparentize(52%)))
        i = i + 2
      }
      let j = 0
      while j * step < h {
        place(top + left, md-region((rect-pts((0.0, j * step),
          (w, calc.min(h, j * step + step * 0.62))),), flip: flip,
          fill: base.darken(16%).transparentize(52%)))
        j = j + 2
      }
    } else if kind == "stripe" {
      let i = 0
      while i * 0.26 < w {
        place(top + left, md-region((rect-pts((i * 0.26, 0.0),
          (calc.min(w, i * 0.26 + 0.13), h)),), flip: flip,
          fill: dotc.transparentize(30%)))
        i = i + 2
      }
    }
    // the sheen along the top edge
    place(top + left, md-polylines((e-top,), flip: flip,
      stroke: (paint: white.transparentize(55%), thickness: 1.1pt)))
  }))
}

/// Torn kraft paper, as the poster's title block.
///
///   tape    none, or a dictionary of `sb-tape` arguments, or an array of them
///   tilt    the whole sheet's rotation
#let torn-note(
  body,
  width: 12.0, pad: 0.85, fill: auto, tilt: 0deg,
  amp: 0.13, seed: 11, tape: auto, shadow: true, grain: true,
  rough: auto, hand: none, roughness: 1.0, bowing: 0.6,
) = {
  let bg = if fill != auto { fill } else { sb-colours.kraft }
  let H = _sb-hand(rough, hand, roughness)
  context {
    let inner = width - 2 * pad
    let m = measure(box(width: inner * 1cm, body))
    let h = m.height / 1cm + 2 * pad
    let cts = _torn-rect(width, h, amp: amp, seed: seed)
    let flip = h * 1cm
    let tapes = if tape == auto {
      ((w: 2.3, h: 0.72, angle: -14deg, kind: "dots", at: (1.1, -0.20)),)
    } else if tape == none { () }
    else if type(tape) == dictionary { (tape,) } else { tape }

    rotate(tilt, reflow: false, box(width: width * 1cm, height: h * 1cm, {
      if shadow {
        place(top + left, dx: 3pt, dy: 4pt,
          md-region((cts,), flip: flip, fill: sb-colours.shadow))
      }
      _sb-draw(cts, flip, fill: bg, seed: seed, ..H, bowing: bowing)
      // The torn edge exposes the paper's white core — a pale line just
      // inside the contour. Without it the sheet looks CUT, not torn.
      _sb-draw(cts, flip, paint: white.transparentize(35%), w: 1.6pt,
        seed: seed + 2, ..H, bowing: bowing)
      _sb-draw(cts, flip, paint: bg.darken(16%), w: 0.5pt,
        seed: seed + 3, ..H, bowing: bowing)
      if grain {
        for (seg, col) in _grain(width, h, seed: seed + 5, n: 130,
            ink: bg.darken(30%)) {
          place(top + left, md-polylines((seg,), flip: flip,
            stroke: (paint: col.transparentize(88%), thickness: 0.5pt)))
        }
      }
      place(top + left, dx: pad * 1cm, dy: pad * 1cm,
        box(width: inner * 1cm, body))
      for t in tapes {
        let at = t.at("at", default: (1.0, -0.2))
        let args = (:)
        for (k, v) in t.pairs() { if k != "at" { args.insert(k, v) } }
        place(top + left, dx: at.first() * 1cm, dy: at.last() * 1cm,
          sb-tape(..args))
      }
    }))
  }
}

// -----------------------------------------------------------------------------
//  20. ruled-sheet — filler paper: punched margin, ruled lines, torn top
// -----------------------------------------------------------------------------

/// A sheet torn out of a ring binder.
///
/// Three details carry it, and all three are measured off the source:
/// the punch holes sit on the LEADING edge at a constant pitch, the ruling
/// runs edge to edge *behind* the text, and the top edge is torn while the
/// other three are cut. A sheet with four torn edges reads as a scrap, not
/// as a page out of a pad.
///
///   holes    number of punches, or `auto` for one every 1.05 cm
///   rule     "lines" | "none"
///   heart    a rose divider rule with a heart, as in the source
#let ruled-sheet(
  body,
  width: 9.0, pad: 0.7, fill: auto, tilt: 0deg,
  holes: auto, hole-side: auto, rule: "lines", ruling: 0.62,
  heart: false, tape: none, clip: false, shadow: true, seed: 21,
  rough: auto, hand: none, roughness: 1.0, bowing: 0.6,
) = {
  let bg = if fill != auto { fill } else { sb-colours.paper }
  let H = _sb-hand(rough, hand, roughness)
  context {
    let r2l = text.dir == rtl
    let left-punch = if hole-side != auto { hole-side == left } else { not r2l }
    let gutter = 1.15
    let inner = width - 2 * pad - gutter
    let head = if heart { 0.95 } else { 0.0 }
    let m = measure(box(width: inner * 1cm, body))
    let h = m.height / 1cm + 2 * pad + head
    let flip = h * 1cm
    // top torn, the rest cut
    // `_torn-rect` walks y UPWARD (the `flip` convention), so its side 0 is
    // the sheet's BOTTOM on the page. The torn edge belongs at the top, so
    // it is side 2 — checked by rendering, not by reading the code.
    let cts = _torn-rect(width, h, amp: 0.11, seed: seed,
      sides: (0, 0, 1, 0))
    let n = if holes != auto { holes } else { calc.max(2, int((h - 0.7) / 1.05)) }
    let hx = if left-punch { 0.52 } else { width - 0.52 }

    rotate(tilt, reflow: false, box(width: width * 1cm, height: h * 1cm, {
      if shadow {
        place(top + left, dx: 3pt, dy: 4pt,
          md-region((cts,), flip: flip, fill: sb-colours.shadow))
      }
      _sb-draw(cts, flip, fill: bg, seed: seed, ..H, bowing: bowing)
      _sb-draw(cts, flip, paint: bg.darken(14%), w: 0.5pt,
        seed: seed + 3, ..H, bowing: bowing)
      // the ruling, kept clear of the punched gutter
      if rule == "lines" {
        let x0 = if left-punch { 1.10 } else { 0.30 }
        let x1 = if left-punch { width - 0.30 } else { width - 1.10 }
        let y = pad + head + 0.30
        while y < h - 0.25 {
          _sb-draw(((x0, y), (x1, y)), flip, closed: false,
            paint: rgb("#B9C6CE").transparentize(38%), w: 0.5pt,
            seed: seed + 40 + int(y * 7), ..H, bowing: bowing)
          y = y + ruling
        }
      }
      // the punch holes: a hole is a SHADOW plus a hole, or it reads as a dot
      for i in range(n) {
        let cy = 0.62 + i * ((h - 1.24) / calc.max(1, n - 1))
        place(top + left, md-region((circle-pts((hx, cy), 0.145, n: 26),),
          flip: flip, fill: bg.darken(20%)))
        place(top + left, md-region((circle-pts((hx, cy + 0.022), 0.128,
          n: 26),), flip: flip, fill: sb-colours.page))
      }
      if heart {
        let cy = h - pad - 0.30
        let seg = 1.5
        let cx = width / 2
        for s in (-1, 1) {
          _sb-draw(((cx + s * 0.42, cy), (cx + s * (0.42 + seg), cy)), flip,
            closed: false, paint: sb-colours.rose.transparentize(25%),
            w: 0.9pt, seed: seed + 30 + s, ..H, bowing: bowing)
        }
        // `cy` is a FLIP coordinate (y up) but `dy` is a page offset (y
        // down): the heart and its own rules were a whole sheet apart until
        // the two were converted into the same frame.
        place(top + left, dx: (cx - 0.17) * 1cm,
          dy: (h - cy - 0.17) * 1cm, sb-heart(size: 0.34))
      }
      place(top + left,
        dx: (if left-punch { gutter + pad } else { pad }) * 1cm,
        dy: (pad + head) * 1cm,
        box(width: inner * 1cm, body))
      if tape != none {
        let t = tape
        let at = t.at("at", default: (width / 2 - 1.0, -0.25))
        let args = (:)
        for (k, v) in t.pairs() { if k != "at" { args.insert(k, v) } }
        place(top + left, dx: at.first() * 1cm, dy: at.last() * 1cm,
          sb-tape(..args))
      }
    }))
  }
}

// -----------------------------------------------------------------------------
//  21. stamp-card — a scalloped mat with a tilted card pinned to it
// -----------------------------------------------------------------------------

/// The perforated edge of a postage stamp.
///
/// A stamp's edge is not a wavy line: it is a straight edge with round bites
/// taken OUT of it at a constant pitch. Drawing it as a sine wave (the first
/// attempt) gives a doily. The bites are semicircles, and the pitch has to
/// divide the side length exactly or the corners come out lopsided.
#let _scallop-side(p0, p1, r: 0.17, out: 1.0) = {
  let (x0, y0) = p0
  let (x1, y1) = p1
  let dx = x1 - x0
  let dy = y1 - y0
  let len = calc.sqrt(dx * dx + dy * dy)
  let ux = dx / len
  let uy = dy / len
  let nx = -uy * out
  let ny = ux * out
  let n = calc.max(1, int(calc.round(len / (2 * r))))
  let step = len / n
  let rr = step / 2
  let pts = ((x0, y0),)
  for i in range(n) {
    let c = (i + 0.5) * step
    // a half circle biting inward
    let m = 9
    for j in range(m + 1) {
      let a = calc.pi * j / m
      let along = c - rr * calc.cos(a * 1rad)
      let depth = rr * calc.sin(a * 1rad) * 0.86
      pts.push((x0 + ux * along - nx * depth, y0 + uy * along - ny * depth))
    }
  }
  pts.push((x1, y1))
  pts
}

#let _scallop-rect(w, h, r: 0.17) = {
  let s1 = _scallop-side((0.0, 0.0), (w, 0.0), r: r, out: -1.0)
  let s2 = _scallop-side((w, 0.0), (w, h), r: r)
  let s3 = _scallop-side((w, h), (0.0, h), r: r)
  let s4 = _scallop-side((0.0, h), (0.0, 0.0), r: r, out: -1.0)
  s1 + s2.slice(1) + s3.slice(1) + s4.slice(1)
}

/// A drawing pin, seen from above.
#let sb-pin(size: 0.42, colour: auto, seed: 4) = {
  let col = if colour != auto { colour } else { rgb("#D9A79C") }
  let s = size
  box(width: s * 1cm, height: s * 1cm, {
    let flip = s * 1cm
    place(top + left, md-region((circle-pts((s / 2, s / 2 - 0.02),
      s * 0.44, n: 30),), flip: flip, fill: rgb("#00000022")))
    place(top + left, md-region((circle-pts((s / 2, s / 2), s * 0.44, n: 30),),
      flip: flip, fill: col))
    // the highlight is what makes it a dome rather than a disc
    place(top + left, md-region((circle-pts((s * 0.38, s * 0.62), s * 0.17,
      n: 20),), flip: flip, fill: white.transparentize(35%)))
    place(top + left, md-polylines((circle-pts((s / 2, s / 2), s * 0.44,
      n: 30),), flip: flip, closed: true,
      stroke: (paint: col.darken(22%), thickness: 0.5pt)))
  })
}

/// A card pinned to a scalloped mat.
///
///   mat      the mat's colour; the card sits on it, rotated by `tilt`
///   pin      `true`, or a dictionary of `sb-pin` arguments
#let stamp-card(
  body,
  width: 8.0, pad: 0.62, margin: 0.55, tilt: -2.2deg, mat-tilt: 1.4deg,
  mat: auto, fill: auto, scallop: 0.20, holes: true, through: auto,
  pin: true, shadow: true, seed: 31,
  rough: auto, hand: none, roughness: 1.0, bowing: 0.6,
) = {
  let matc = if mat != auto { mat } else { sb-colours.sage }
  let bg = if fill != auto { fill } else { sb-colours.card }
  let through = if through != auto { through } else { sb-colours.page }
  let H = _sb-hand(rough, hand, roughness)
  context {
    let inner = width - 2 * pad - 2 * margin
    let m = measure(box(width: inner * 1cm, body))
    let ch = m.height / 1cm + 2 * pad
    let cw = width - 2 * margin
    let mh = ch + 2 * margin
    let mflip = mh * 1cm
    // MEASURED, not guessed: enlarging the source shows the mat is NOT
    // scalloped at the edge. It is a torn rectangle with a row of round
    // holes PUNCHED through it a few millimetres in — like a strip of
    // photo-album corner tape. The scalloped reading was wrong and produced
    // a doily; the holes are what give the piece its rhythm.
    let cts = _torn-rect(width, mh, amp: 0.055, seed: seed)

    // The mat and the card are tilted by DIFFERENT amounts — that mismatch
    // is the whole effect, and it means the outer box has to be big enough
    // for both. A snug box clips the mat's corners once it turns.
    let pad-box = 0.9
    box(width: (width + pad-box) * 1cm, height: (mh + pad-box) * 1cm, {
      place(top + left, dx: pad-box / 2 * 1cm, dy: pad-box / 2 * 1cm,
        rotate(mat-tilt, reflow: false,
          box(width: width * 1cm, height: mh * 1cm, {
            if shadow {
              place(top + left, dx: 3pt, dy: 4pt,
                md-region((cts,), flip: mflip, fill: sb-colours.shadow))
            }
            _sb-draw(cts, mflip, fill: matc, seed: seed, ..H, bowing: bowing)
            _sb-draw(cts, mflip, paint: matc.darken(12%), w: 0.4pt,
              seed: seed + 3, ..H, bowing: bowing)
            // the punched row: the hole shows the PAGE through the mat, so
            // it is filled with the backdrop colour, not merely darkened
            if holes {
              let r = scallop * 0.62
              let inset = margin * 0.52
              let run(x0, y0, x1, y1) = {
                let len = calc.sqrt(calc.pow(x1 - x0, 2) + calc.pow(y1 - y0, 2))
                let n = calc.max(2, int(calc.round(len / (r * 4.6))))
                for i in range(n + 1) {
                  let t = i / n
                  let cx = x0 + (x1 - x0) * t
                  let cy = y0 + (y1 - y0) * t
                  _sb-draw(circle-pts((cx, cy), r, n: 18), mflip,
                    fill: through, paint: matc.darken(14%), w: 0.35pt,
                    seed: seed + int(cx * 31 + cy * 7), ..H, bowing: bowing)
                }
              }
              run(inset, mh - inset, width - inset, mh - inset)
              run(inset, inset, width - inset, inset)
              run(inset, inset, inset, mh - inset)
              run(width - inset, inset, width - inset, mh - inset)
            }
          })))
      // the card, tilted the other way
      place(top + left, dx: (margin + pad-box / 2) * 1cm,
        dy: (margin + pad-box / 2) * 1cm,
        rotate(tilt, reflow: false, box(width: cw * 1cm, height: ch * 1cm, {
          let cflip = ch * 1cm
          let r = rect-pts((0.0, 0.0), (cw, ch))
          place(top + left, dx: 2.5pt, dy: 3pt,
            md-region((r,), flip: cflip, fill: sb-colours.shadow))
          _sb-draw(r, cflip, fill: bg, seed: seed + 11, ..H, bowing: bowing)
          _sb-draw(r, cflip, paint: bg.darken(14%), w: 0.4pt,
            seed: seed + 12, ..H, bowing: bowing)
          place(top + left, dx: pad * 1cm, dy: pad * 1cm,
            box(width: inner * 1cm, body))
        })))
      if pin != none and pin != false {
        let pa = if type(pin) == dictionary { pin } else { (:) }
        let sz = pa.at("size", default: 0.42)
        place(top + left, dx: (width / 2 - sz / 2 + pad-box / 2) * 1cm,
          dy: (pad-box / 2 - sz * 0.28) * 1cm, sb-pin(..pa))
      }
    })
  }
}

// -----------------------------------------------------------------------------
//  22. grid-note — graph paper, polka-dot washi, and a real paperclip
// -----------------------------------------------------------------------------

/// A paperclip, seen from the front.
///
/// The lesson of the `postit` package's clip, relearned: a clip is ONE wire
/// bent into three nested loops, and part of it passes BEHIND the paper.
/// Drawing the whole outline on top is the giveaway. So the shape is drawn
/// twice — the back pass, then the sheet, then the front pass — and the
/// caller decides where the sheet goes.
/// A paperclip, drawn in TWO passes.
///
/// The lesson of the `postit` package's clip: a clip grips the sheet, so
/// part of the wire runs BEHIND it and must be hidden. Drawing the whole
/// outline on top is the giveaway — it then reads as a sticker of a clip.
/// `sb-clip` therefore returns the two passes separately and the caller
/// sandwiches the sheet between them.
///
/// The wire is one continuous bend: down the left, a U at the bottom, up
/// the right, a tight turn at the top, and back down inside.
#let _clip-runs(w, h) = {
  // MEASURED — and the measurement only became trustworthy once the clip
  // was DESKEWED. In the photograph it lies at 10.5 degrees, so the naive
  // bounding box (54 x 127 px, ratio 2.35) was the box of a tilted object,
  // not the clip. Rotating the crop upright first gives 42 x 129, a ratio
  // of **3.07** — a much longer clip than two earlier attempts assumed.
  //
  // Rows sampled down the deskewed image, as fractions of the height:
  //
  //   0.08   [3..8]            [34..40]     outer left, outer right
  //   0.25   [0..5]  [26..31]               outer left, INNER (one strand)
  //   0.50   [1..7]  [28..33]               the two run parallel
  //   0.90   [7..9]  [33..35]               still parallel
  //   0.97   [9..11] [16..22] [28..31]      the bottom U closes
  //
  // So: the outer loop runs the full height; the top hook springs from the
  // outer LEFT upright, arcs over, and comes down INSIDE as a single long
  // strand that stops short of the bottom. The inner strand sits about
  // two thirds of the way across, and it curves LEFT under the hook — it
  // never crosses back outside the body, which was the flaw.
  let ro = w / 2                 // outer bend radius
  let hl = h - ro                // where the uprights meet the top bend
  let xi = w * 0.72              // the inner strand, measured
  // The free tip. In the photograph it reaches 0.885 of the way down, but
  // when the clip STRADDLES an edge that long strand is the part left
  // hanging inside the sheet, and it reads as a stray line. Shortened to
  // two thirds of the body — enough to show the clip is a bent wire, not
  // so long that it becomes a feature of its own.
  let yi = h * 0.30

  // OUTER — down the left, U at the bottom, up the right.
  // arc-pts runs 180 -> 360 from the LEFT of the circle through 270 (the
  // bottom), so it joins the two uprights in the direction of travel.
  // The outer loop is a CLOSED ring: bottom U, both uprights, and the top
  // bend. Leaving the top open — as an earlier attempt did once the hook
  // grew — makes the clip look snipped.
  let ub = arc-pts((ro, ro), ro, 180, 360, n: 26)
  let ut = arc-pts((ro, hl), ro, 0, 180, n: 26)
  let outer = ((0.0, hl),) + ub + ((w, hl),) + ut

  // HOOK — from the outer LEFT upright over the top and back down to the
  // inner strand. Its centre is midway between the two, so the arc lands
  // exactly on the strand below it rather than cutting across the clip.
  // The hook springs FROM the left upright: its left end has to sit ON
  // that upright (x = 0) and level with the top bend, not float inside the
  // loop. Measured on the deskewed image it spans x = 3..29 of 42 and drops
  // from t = 0.03 to t = 0.19 — half again as deep as it is wide — so it is
  // a half ELLIPSE from (0, hl) across to the inner strand.
  let hrx = xi / 2
  let hry = hrx * 1.30
  let hk = range(25).map(i => {
    let a = (180 - 180 * i / 24) * 1deg
    (hrx - hrx * calc.cos(a), hl + hry * calc.sin(a) - hry * 0.06)
  })

  // INNER — one straight strand hanging from the hook, ending free with a
  // rounded tip well above the bottom bend.
  let inner = ((xi, hl), (xi, yi))
  (outer, hk, inner)
}

#let sb-clip(w: 0.62, h: auto, angle: 0deg, colour: auto, wire: auto) = {
  let col = if colour != auto { colour } else { rgb("#B9997C") }
  // the source's proportions, so a caller only has to give a width
  let hh = if h != auto { h } else { w * 3.07 }
  let lw = if wire != auto { wire } else { w * 0.085 * 28.35 * 1pt }
  let (outer, hook, inner) = _clip-runs(w, hh)
  let flip = hh * 1cm
  // Three passes make the wire ROUND: a dark casing, the body colour, and a
  // thin highlight down the middle. A single stroke reads as a flat ribbon.
  let draw(paths) = box(width: w * 1cm, height: hh * 1cm, {
    for (mul, c) in ((1.55, col.darken(30%)), (1.0, col),
                     (0.30, white.transparentize(30%))) {
      for path in paths {
        place(top + left, md-polylines((path,), flip: flip,
          stroke: (paint: c, thickness: lw * mul, cap: "round",
            join: "round")))
      }
    }
  })
  // The clip GRIPS the sheet: the outer loop passes behind it, the hook and
  // the inner return stay in front. Returning the passes separately is what
  // lets the caller sandwich the paper — drawing the lot on top is the
  // giveaway that turns a clip into a sticker of a clip.
  // WHICH RUN GOES BEHIND THE PAPER. A clip works by springing apart and
  // taking the sheet BETWEEN its two layers: the big outer loop lies on top
  // of the sheet and the short inner strand slips underneath. Putting the
  // outer loop behind — the previous version — is backwards, and it hides
  // the very run that gives the clip its silhouette: everything below the
  // paper's edge vanished and only a small hook was left showing.
  //
  //   `whole`            the clip lying loose ON the paper
  //   `behind` + `front` the clip GRIPPING an edge, sheet drawn between:
  //                      `behind` is the inner strand, `front` the loop.
  (whole: rotate(angle, reflow: false, draw((outer, hook, inner))),
   behind: rotate(angle, reflow: false, draw((inner,))),
   front: rotate(angle, reflow: false, draw((outer, hook))),
   w: w, h: hh)
}

/// Graph paper.
///
///   grid      the ruling pitch in cm, or `none`
///   clip      `true` puts a paperclip over the top edge
#let grid-note(
  body,
  width: 8.4, pad: 0.72, fill: auto, tilt: 0deg, grid: 0.42,
  grid-ink: auto, tape: none, clip: false, clip-at: 0.80,
  shadow: true, seed: 41,
  rough: auto, hand: none, roughness: 1.0, bowing: 0.6,
) = {
  let bg = if fill != auto { fill } else { sb-colours.grid }
  let gi = if grid-ink != auto { grid-ink } else { bg.darken(11%) }
  let H = _sb-hand(rough, hand, roughness)
  context {
    let inner = width - 2 * pad
    let m = measure(box(width: inner * 1cm, body))
    let h = m.height / 1cm + 2 * pad
    let flip = h * 1cm
    let cts = _torn-rect(width, h, amp: 0.05, seed: seed)
    // The clip STRADDLES the top edge: `grip` of its length lies on the
    // paper, the rest stands proud above it. That overhang is the reserve
    // the outer box needs, so the two are one number.
    let cl = sb-clip(w: 0.45, angle: 7deg)
    // `grip` is the fraction of the clip lying ON the paper, so the part
    // standing proud above the edge is 1 - grip. 0.70 leaves 30% showing.
    //
    // Only the RELATIVE offset matters. An earlier "drop it 2 mm" added
    // 0.2 cm to both the clip's `dy` and the sheet's, which moved the pair
    // down together and changed nothing on the page — it only padded the
    // top of the box. The clip sits at dy = 0 and the sheet at `over`.
    let grip = 0.70
    let over = cl.h * (1 - grip)

    box(width: width * 1cm, height: (h + over) * 1cm, {
      // the outer loop goes BEHIND the sheet — that is what makes it grip

      place(top + left, dy: over * 1cm, rotate(tilt, reflow: false,
        box(width: width * 1cm, height: h * 1cm, {
          if shadow {
            place(top + left, dx: 3pt, dy: 4pt,
              md-region((cts,), flip: flip, fill: sb-colours.shadow))
          }
          _sb-draw(cts, flip, fill: bg, seed: seed, ..H, bowing: bowing)
          // the squares, clipped to the sheet by drawing them first and
          // covering the overshoot with the sheet's own outline
          if grid != none {
            let x = grid
            while x < width {
              _sb-draw(((x, 0.06), (x, h - 0.06)), flip, closed: false,
                paint: gi, w: 0.35pt, seed: seed + int(x * 13), ..H,
                bowing: bowing)
              x = x + grid
            }
            let y = grid
            while y < h {
              _sb-draw(((0.06, y), (width - 0.06, y)), flip, closed: false,
                paint: gi, w: 0.35pt, seed: seed + 90 + int(y * 13), ..H,
                bowing: bowing)
              y = y + grid
            }
          }
          _sb-draw(cts, flip, paint: bg.darken(20%), w: 0.5pt,
            seed: seed + 3, ..H, bowing: bowing)
          place(top + left, dx: pad * 1cm, dy: pad * 1cm,
            box(width: inner * 1cm, body))
        })))
      if tape != none {
        let t = tape
        let at = t.at("at", default: (width * 0.28, 0.0))
        let args = (:)
        for (k, v) in t.pairs() { if k != "at" { args.insert(k, v) } }
        place(top + left, dx: at.first() * 1cm, dy: at.last() * 1cm,
          sb-tape(..args))
      }
      if clip {
        // The WHOLE clip shows: it lies on top of the sheet and simply
        // overhangs the edge. Sending either run behind the paper hides a
        // third of the wire — the outer loop's lower bend if it is the
        // outer one, the inner strand if it is that. The clip still reads
        // as gripping because it straddles the edge, which is what the eye
        // actually uses.
        place(top + left, dx: clip-at * width * 1cm, dy: 0cm, cl.whole)
      }
    })
  }
}

// -----------------------------------------------------------------------------
//  23. index-card — a ruled card: heading, double rule, tinted footer
// -----------------------------------------------------------------------------

/// The poster's worked example: a ruled card whose heading sits above a
/// rose rule, whose example line sits above a green one, and whose closing
/// caution is set on a tinted panel let into the foot of the card.
///
/// The footer is INSIDE the card, not a second box below it: it shares the
/// card's left and right edges and only its own top edge is drawn. Making
/// it a separate block was the first attempt and it always left a seam.
///
///   heading   the title line, with its heart
///   note      the tinted footer, or `none`
///   rules     the pale horizontal ruling behind the text
#let index-card(
  body,
  heading: none, note: none, mark: sym.ast.op,
  width: 9.4, pad: 0.75, fill: auto, tilt: 0deg, rules: true, ruling: 0.60,
  note-fill: auto, clip: false, clip-at: 0.80, shadow: true, seed: 51,
  rough: auto, hand: none, roughness: 1.0, bowing: 0.6,
) = {
  let bg = if fill != auto { fill } else { sb-colours.card }
  let nf = if note-fill != auto { note-fill } else { sb-colours.blush }
  let H = _sb-hand(rough, hand, roughness)
  context {
    let inner = width - 2 * pad
    let head-h = if heading != none {
      measure(box(width: inner * 1cm, heading)).height / 1cm + 0.50
    } else { 0.0 }
    let note-h = if note != none {
      measure(box(width: (inner - 0.5) * 1cm, note)).height / 1cm + 0.70
    } else { 0.0 }
    let m = measure(box(width: inner * 1cm, body))
    let h = m.height / 1cm + 2 * pad + head-h + note-h
    let flip = h * 1cm
    let cts = _torn-rect(width, h, amp: 0.045, seed: seed)
    let cl = sb-clip(w: 0.435, angle: -6deg)
    let grip = 0.70
    let over2 = cl.h * (1 - grip)

    box(width: width * 1cm, height: (h + over2) * 1cm, {

      place(top + left, dy: over2 * 1cm, rotate(tilt, reflow: false,
        box(width: width * 1cm, height: h * 1cm, {
          if shadow {
            place(top + left, dx: 3pt, dy: 4pt,
              md-region((cts,), flip: flip, fill: sb-colours.shadow))
          }
          _sb-draw(cts, flip, fill: bg, seed: seed, ..H, bowing: bowing)
          if rules {
            let y = 0.35
            while y < h - 0.2 {
              _sb-draw(((0.25, y), (width - 0.25, y)), flip, closed: false,
                paint: rgb("#C3B7A6").transparentize(55%), w: 0.4pt,
                seed: seed + 60 + int(y * 7), ..H, bowing: bowing)
              y = y + ruling
            }
          }
          // the tinted footer, let into the foot of the card
          if note != none {
            let ny = note-h + 0.10
            // rounded corners: the source's panel is a soft-cornered tint,
            // and square corners made it read as a separate strip of paper
            let rr = 0.18
            let x0 = 0.30
            let x1 = width - 0.30
            let y0 = 0.28
            let c1 = arc-pts((x1 - rr, y0 + rr), rr, 270, 360, n: 8)
            let c2 = arc-pts((x1 - rr, ny - rr), rr, 0, 90, n: 8)
            let c3 = arc-pts((x0 + rr, ny - rr), rr, 90, 180, n: 8)
            let c4 = arc-pts((x0 + rr, y0 + rr), rr, 180, 270, n: 8)
            place(top + left, md-region((c1 + c2 + c3 + c4,), flip: flip,
              fill: nf))
          }
          _sb-draw(cts, flip, paint: bg.darken(16%), w: 0.45pt,
            seed: seed + 3, ..H, bowing: bowing)
          // heading, its rule, then the body
          if heading != none {
            place(top + left, dx: pad * 1cm, dy: pad * 0.55 * 1cm,
              box(width: inner * 1cm, heading))
            let ry = h - pad * 0.55 - head-h + 0.34
            _sb-draw(((pad, ry), (width - pad, ry)), flip, closed: false,
              paint: sb-colours.rose.transparentize(20%), w: 1.0pt,
              seed: seed + 21, ..H, bowing: bowing)
          }
          place(top + left, dx: pad * 1cm,
            dy: (pad * 0.55 + head-h) * 1cm,
            box(width: inner * 1cm, body))
          if note != none {
            place(top + left, dx: (pad * 0.72) * 1cm,
              dy: (h - note-h - 0.02) * 1cm,
              box(width: (inner + 0.4) * 1cm, {
                grid(columns: (auto, 1fr), column-gutter: 0.35em,
                  text(fill: sb-colours.rose, mark), note)
              }))
          }
        })))
      if clip {
        // The WHOLE clip shows: it lies on top of the sheet and simply
        // overhangs the edge. Sending either run behind the paper hides a
        // third of the wire — the outer loop's lower bend if it is the
        // outer one, the inner strand if it is that. The clip still reads
        // as gripping because it straddles the edge, which is what the eye
        // actually uses.
        place(top + left, dx: clip-at * width * 1cm, dy: 0cm, cl.whole)
      }
    })
  }
}

// -----------------------------------------------------------------------------
//  24. deckle-tag — a small deckle-edged tag, taped at one corner
// -----------------------------------------------------------------------------

/// The sixth stock: a small pale-olive tag with a deckle (feathered) edge,
/// held by a strip of gingham washi across one corner.
///
/// A deckle edge is not a torn one. Torn paper wanders by millimetres;
/// a deckle edge — the untrimmed edge of handmade paper — is a fine, dense
/// feathering of a fraction of a millimetre, and it is UNIFORM rather than
/// tapering to the corners. Using `_torn-edge` with a small amplitude gave
/// a limp version of the wrong thing; the frequency is what distinguishes
/// them, so this has its own generator.
#let _deckle-side(p0, p1, amp: 0.020, per-cm: 26, seed: 1, out: 1.0) = {
  let (x0, y0) = p0
  let (x1, y1) = p1
  let dx = x1 - x0
  let dy = y1 - y0
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return (p0, p1) }
  let ux = dx / len
  let uy = dy / len
  let nx = -uy * out
  let ny = ux * out
  let n = calc.max(4, int(len * per-cm))
  let r = randoms(seed, n + 1)
  let r2 = randoms(seed + 313, n + 1)
  range(n + 1).map(i => {
    let t = i / n
    // no taper: a deckle edge is as feathered at the corners as in the middle
    let d = ((r.at(i) - 0.5) * 1.4 + (r2.at(i) - 0.5) * 0.6) * amp
    (x0 + ux * len * t + nx * d, y0 + uy * len * t + ny * d)
  })
}

#let _deckle-rect(w, h, amp: 0.020, seed: 1) = {
  let s1 = _deckle-side((0.0, 0.0), (w, 0.0), amp: amp, seed: seed, out: -1.0)
  let s2 = _deckle-side((w, 0.0), (w, h), amp: amp, seed: seed + 21)
  let s3 = _deckle-side((w, h), (0.0, h), amp: amp, seed: seed + 47)
  let s4 = _deckle-side((0.0, h), (0.0, 0.0), amp: amp, seed: seed + 83,
    out: -1.0)
  s1 + s2.slice(1) + s3.slice(1) + s4.slice(1)
}

#let deckle-tag(
  body,
  width: 5.6, pad: 0.62, fill: auto, tilt: 1.6deg, amp: 0.020,
  tape: auto, shadow: true, seed: 61,
  rough: auto, hand: none, roughness: 1.0, bowing: 0.6,
) = {
  let bg = if fill != auto { fill } else { sb-colours.tag }
  let H = _sb-hand(rough, hand, roughness)
  context {
    let inner = width - 2 * pad
    let m = measure(box(width: inner * 1cm, body))
    let h = m.height / 1cm + 2 * pad
    let flip = h * 1cm
    let cts = _deckle-rect(width, h, amp: amp, seed: seed)
    let tapes = if tape == auto {
      ((w: 2.1, h: 0.72, angle: -12deg, kind: "gingham",
        colour: rgb("#B9C3B0"), at: (0.55, -0.28)),)
    } else if tape == none { () }
    else if type(tape) == dictionary { (tape,) } else { tape }

    box(width: width * 1cm, height: (h + 0.5) * 1cm, {
      place(top + left, dy: 0.5 * 1cm, rotate(tilt, reflow: false,
        box(width: width * 1cm, height: h * 1cm, {
          if shadow {
            place(top + left, dx: 3pt, dy: 4pt,
              md-region((cts,), flip: flip, fill: sb-colours.shadow))
          }
          _sb-draw(cts, flip, fill: bg, seed: seed, ..H, bowing: bowing)
          // the feathered edge catches the light: a pale line just inside
          _sb-draw(cts, flip, paint: white.transparentize(52%), w: 0.9pt,
            seed: seed + 2, ..H, bowing: bowing)
          _sb-draw(cts, flip, paint: bg.darken(15%), w: 0.4pt,
            seed: seed + 3, ..H, bowing: bowing)
          place(top + left, dx: pad * 1cm, dy: pad * 1cm,
            box(width: inner * 1cm, body))
        })))
      for t in tapes {
        let at = t.at("at", default: (0.55, -0.28))
        let args = (:)
        for (k, v) in t.pairs() { if k != "at" { args.insert(k, v) } }
        place(top + left, dx: at.first() * 1cm, dy: (at.last() + 0.5) * 1cm,
          sb-tape(..args))
      }
    })
  }
}

// -----------------------------------------------------------------------------
//  25. notepad — a spiral-bound page, smooth or crumpled
// -----------------------------------------------------------------------------

/// Crumple a sheet into FACETS.
///
/// Crumpled paper is not a set of drawn lines — that reads as a cracked
/// windscreen. A creased sheet is broken into facets, each tilted a little
/// differently, so each catches a different amount of light; what the eye
/// reads is the patchwork of tones, and the fold lines themselves are barely
/// visible. Each chord shades the whole half-plane on one side of it, very
/// faintly, and the overlaps build the patchwork.
///
/// The endpoints are taken from the sheet's OWN outline, so a fold can never
/// begin outside the paper. Typst has no path clipping, so keeping each
/// crease inside the contour by construction beats trimming it afterwards.
#let _crumple(contour, w, h, n: 9, seed: 1) = {
  let r = randoms(seed, n * 6)
  let m = contour.len()
  let out = ()
  for i in range(n) {
    let ia = int(r.at(i * 6) * (m - 1))
    // the far end is at least a third of the way round, so a fold crosses
    // the sheet instead of nicking a corner
    let ib = calc.rem(ia + int(m / 3) + int(r.at(i * 6 + 1) * m / 3), m)
    let p = contour.at(ia)
    let q = contour.at(ib)
    let dx = q.at(0) - p.at(0)
    let dy = q.at(1) - p.at(1)
    let len = calc.max(0.001, calc.sqrt(dx * dx + dy * dy))
    let nx = -dy / len
    let ny = dx / len
    // Closed off JUST past the sheet, not at some huge distance: a polygon
    // 1.5 x (w + h) across, clipped, sent the rasteriser into the weeds and
    // the compile never finished.
    let far = calc.max(w, h) * 1.05
    let poly = (p, q,
      (q.at(0) + nx * far, q.at(1) + ny * far),
      (p.at(0) + nx * far, p.at(1) + ny * far))
    // Half of the facets lighten and half darken — but the darkening is
    // weighted DOWN. Overlapping half-planes accumulate, and equal weights
    // sank the whole sheet into grey: with n chords a given point is on the
    // dark side of about n/2 of them, so the tint has to be far smaller
    // than one fold's worth.
    let lit = r.at(i * 6 + 2) > 0.44
    let k = (0.28 + r.at(i * 6 + 3) * 0.72) * (if lit { 1.0 } else { 0.55 })
    out.push((poly, lit, k, p, q, r.at(i * 6 + 4)))
  }
  out
}

/// A sheet torn from a spiral pad, as a self-contained BOX.
///
/// (`spiral-binding` does the same job as a page background; this one flows
/// in the text and sizes itself to its contents.)
///
/// Measured off uploads/FB_IMG_1785752988356.jpg (1240 x 633): 18 rings down
/// the page, a pitch of 31.9 px and a ring 12 px across. The pitch is a
/// property of the COIL, not of the sheet — a real pad has the same wire
/// whatever the page — so it is a fixed 0.81 cm rather than a fraction of
/// the box; taking 5 % of a short box's height packed the rings into a
/// black stripe. The ring's 12 px on that pitch is its DIAMETER, 0.376 of
/// the pitch, so the radius is half of that.
///
/// The paper edge along the binding is TORN, not cut: the sheet has been
/// pulled off the coil.
#let notepad(
  body,
  width: 9.5, pad: 0.72, fill: auto, tilt: 0deg,
  crumpled: false, creases: 11, crease-ink: 0.055,
  rings: auto, ring: auto, ring-colour: auto, side: auto,
  shadow: true, seed: 71,
  rough: auto, hand: none, roughness: 1.0, bowing: 0.6,
) = {
  let bg = if fill != auto { fill } else { rgb("#F4EFEA") }
  let rc = if ring-colour != auto { ring-colour } else { rgb("#2B2622") }
  let H = _sb-hand(rough, hand, roughness)
  context {
    let r2l = text.dir == rtl
    let bind-left = if side != auto { side == left } else { not r2l }
    let gutter = 1.05
    let inner = width - 2 * pad - gutter
    let m = measure(box(width: inner * 1cm, body))
    let h = calc.max(2.4, m.height / 1cm + 2 * pad)
    let flip = h * 1cm
    // `rings` names the COUNT and `pitch` follows from it; left to `auto`
    // the pitch is the measured one and the count follows instead. Dividing
    // the height by the count is not enough on its own: the first turn sits
    // 0.34 below the top and the last needs the same clearance, so the span
    // the turns share is `h - 2 x 0.34` — without that, asking for 5 turns
    // drew 4 and left a gap at the foot.
    let inset = 0.34
    let span = calc.max(0.1, h - 2 * inset)
    let n = if rings != auto { calc.max(1, rings) }
            else { calc.max(2, int(span / 0.81) + 1) }
    let pitch = if n <= 1 { span } else { span / (n - 1) }
    let rr = if ring != auto { ring } else { 0.81 * 0.376 / 2 }
    let hx = if bind-left { 0.52 } else { width - 0.52 }
    let cts = _torn-rect(width, h, amp: 0.055, seed: seed,
      sides: if bind-left { (0, 0, 0, 1) } else { (0, 1, 0, 0) })

    rotate(tilt, reflow: false, box(width: width * 1cm, height: h * 1cm, {
      if shadow {
        place(top + left, dx: 3pt, dy: 4pt,
          md-region((cts,), flip: flip, fill: sb-colours.shadow))
      }
      _sb-draw(cts, flip, fill: bg, seed: seed, ..H, bowing: bowing)

      if crumpled {
        let fac = _crumple(cts, width, h, n: creases, seed: seed + 5)
        place(top + left, block(width: width * 1cm, height: h * 1cm,
          clip: true, {
            for (poly, lit, k, p, q, t) in fac {
              place(top + left, md-region((poly,), flip: flip,
                fill: (if lit { white } else { rc })
                  .transparentize(100% - crease-ink * k * 100%)))
            }
            for (poly, lit, k, p, q, t) in fac {
              place(top + left, md-polylines(((p, q),), flip: flip,
                stroke: (paint: (if lit { white } else { rc })
                  .transparentize(100% - crease-ink * 80%),
                  thickness: (0.35 + t * 0.45) * 1pt)))
            }
          }))
      }

      _sb-draw(cts, flip, paint: bg.darken(15%), w: 0.5pt,
        seed: seed + 3, ..H, bowing: bowing)

      // ---- the coil ----------------------------------------------------
      //
      // A spiral binding is ONE continuous wire, not a row of rings. Each
      // turn comes up through a punched hole, wraps round the edge of the
      // sheet and dives back behind it, so what shows on the page is:
      //
      //   * a dark oval lying ON the paper — the wire seen almost end-on
      //     where it crosses its hole. MEASURED at 14 x 10 px on a 31.9 px
      //     pitch (0.44 x 0.31 of it), centred 0.67 of a pitch in from the
      //     torn edge;
      //   * a thinner run leaving the oval and crossing the edge, hanging a
      //     little past it;
      //   * nothing where the wire passes behind the sheet.
      //
      // Drawing closed rings sitting on the paper — the first version — is
      // why it read as a row of eyelets and no spring was visible at all.
      // The oval's own size and its distance from the edge are properties
      // of the WIRE, not of the spacing: measured against the source's
      // 31.9 px pitch, they stay put whatever `rings` is asked for. Scaling
      // them with `pitch` made a five-turn coil grow comically fat.
      let unit = 0.81
      let ox = if bind-left { unit * 0.67 } else { width - unit * 0.67 }
      let sgn = if bind-left { -1.0 } else { 1.0 }
      let orx = unit * 0.40 / 2          // the oval's own half-axes
      let ory = unit * 0.27 / 2
      for i in range(n) {
        let cy = h - inset - i * pitch
        if cy < 0.10 { continue }
        // the punched hole, just visible under the wire
        place(top + left, md-region((circle-pts((ox, cy), ory * 0.85, n: 16),),
          flip: flip, fill: bg.darken(22%)))
        // the run out over the edge: it leaves the oval, crosses the torn
        // edge and stops just past it, rising as it goes — that rise is
        // what makes it a helix rather than a stack of rings
        let out-x = ox + sgn * (unit * 0.67 + rr * 1.4)
        // The wire RISES as it leaves the paper — in the photograph the
        // thin run sits above its oval, not below. `flip` coordinates have
        // y going UP, so the rise is a plus.
        let wrap = range(15).map(j => {
          let t = j / 14
          (ox + (out-x - ox) * t, cy + ory * 0.5 + unit * 0.26 * t * t)
        })
        place(top + left, md-polylines((wrap,), flip: flip,
          stroke: (paint: rc.darken(8%), thickness: 1.7pt, cap: "round")))
        place(top + left, md-polylines((wrap,), flip: flip,
          stroke: (paint: rc.lighten(40%), thickness: 0.6pt, cap: "round")))
        // the oval on the paper, leaning with the helix
        let ov = range(25).map(j => {
          let a = 360deg * j / 24
          let ex = orx * calc.cos(a)
          let ey = ory * calc.sin(a)
          (ox + ex - ey * 0.30, cy + ey + ex * 0.22)
        })
        place(top + left, md-region((ov,), flip: flip, fill: rc))
        place(top + left, md-polylines((ov,), flip: flip, closed: true,
          stroke: (paint: rc.lighten(34%), thickness: 0.45pt)))
      }

      // `align(start, ..)` explicitly: a paragraph's DEFAULT alignment does
      // not resolve against the text direction inside a `box`, so Arabic
      // came out ranged left. Same trap as the slide blocks.
      place(top + left,
        dx: (if bind-left { gutter + pad } else { pad }) * 1cm,
        dy: pad * 1cm,
        box(width: inner * 1cm, align(start, body)))
    }))
  }
}

// -----------------------------------------------------------------------------
//  26. lesson-card — a green exercise-book card with a dovetail banner
// -----------------------------------------------------------------------------

/// The title ribbon: a rectangle with a V notched INTO each end.
///
/// Measured on uploads/FB_IMG_1785663912704.jpg: 225 x 72 px, so 3.1 to 1,
/// with the notch biting 15 px in — 0.21 of the height. The card's top rule
/// crosses it at 0.97 of its height, i.e. the ribbon sits almost entirely
/// ABOVE the rule and only its bottom edge is level with it. That overlap is
/// the whole trick: the banner is pinned to the frame, not floating over it.
#let _dovetail(w, h, notch: 0.21) = {
  let d = h * notch
  (
    (0.0, 0.0), (d, h / 2), (0.0, h),           // left end, notched in
    (w, h), (w - d, h / 2), (w, 0.0),           // right end, notched in
  )
}

/// A rounded rectangle as a point list.
#let _round-rect(w, h, r: 0.3, n: 8) = {
  let c1 = arc-pts((w - r, r), r, 270, 360, n: n)
  let c2 = arc-pts((w - r, h - r), r, 0, 90, n: n)
  let c3 = arc-pts((r, h - r), r, 90, 180, n: n)
  let c4 = arc-pts((r, r), r, 180, 270, n: n)
  c1 + c2 + c3 + c4
}

/// A lined exercise-book card with a green rule and a dovetail title.
///
/// This one is Arabic by design — the source is an Arabic grammar card — so
/// `align(start, ..)` is applied throughout and the paperclip follows the
/// leading edge.
///
///   title     the ribbon's text; `none` leaves the frame plain
///   rule      the ruled paper behind the text
///   clip      a paperclip over the leading corner
#let lesson-card(
  body,
  title: none,
  width: 9.0, pad: 0.62, fill: auto, tilt: 0deg,
  ink: auto, radius: 0.34, rule: true, ruling: 0.62, rule-ink: auto,
  banner-w: auto, banner-h: 0.92, notch: 0.21,
  clip: true, clip-at: 0.10, shadow: true, seed: 81,
  rough: auto, hand: none, roughness: 1.0, bowing: 0.6,
) = {
  let bg = if fill != auto { fill } else { rgb("#FCF9F4") }
  let gi = if ink != auto { ink } else { rgb("#1D7A3D") }
  let ri = if rule-ink != auto { rule-ink } else { rgb("#BFD3E8") }
  let H = _sb-hand(rough, hand, roughness)
  context {
    let r2l = text.dir == rtl
    let inner = width - 2 * pad
    // The banner straddles the frame's top rule, so the card has to reserve
    // room ABOVE itself for the part that sticks out — measured at 0.97 of
    // the ribbon's height.
    let bh = if title != none { banner-h } else { 0.0 }
    // MEASURED: the frame's top rule crosses the ribbon at 0.97 of its
    // height, so all but the last 3 % stands ABOVE the frame. Reserving the
    // full height instead left the ribbon sitting on top of the card like a
    // separate label rather than pinned across its edge.
    let over = bh * 0.97
    let head = if title != none { 0.30 } else { 0.0 }
    let m = measure(box(width: inner * 1cm, body))
    let h = m.height / 1cm + 2 * pad + head
    let flip = h * 1cm
    let fr = _round-rect(width, h, r: radius)

    box(width: width * 1cm, height: (h + over) * 1cm, {
      place(top + left, dy: over * 1cm, rotate(tilt, reflow: false,
        box(width: width * 1cm, height: h * 1cm, {
          if shadow {
            place(top + left, dx: 3pt, dy: 4pt,
              md-region((fr,), flip: flip, fill: sb-colours.shadow))
          }
          _sb-draw(fr, flip, fill: bg, seed: seed, ..H, bowing: bowing)
          // the ruled paper, kept inside the frame
          if rule {
            let y = 0.40
            while y < h - 0.30 {
              _sb-draw(((0.30, y), (width - 0.30, y)), flip, closed: false,
                paint: ri, w: 0.4pt, seed: seed + 20 + int(y * 7), ..H,
                bowing: bowing)
              y = y + ruling
            }
          }
          // the frame itself, over the ruling
          _sb-draw(fr, flip, paint: gi, w: 1.5pt, seed: seed + 3, ..H,
            bowing: bowing)
          place(top + left, dx: pad * 1cm, dy: (pad + head) * 1cm,
            box(width: inner * 1cm, align(start, body)))
        })))

      // the banner, straddling the top rule
      if title != none {
        // 225 px of ribbon on a 289 px frame: 0.78 of the card's width. It
        // is also capped: the ribbon's notched ends must land INSIDE the
        // rounded corners, and on a narrow card 0.78 pushed them past the
        // frame so the banner hung over thin air.
        let bw = if banner-w != auto { banner-w }
                 else { calc.min(width * 0.78, width - 2 * radius - 0.5) }
        let dt = _dovetail(bw, bh, notch: notch)
        place(top + left, dx: (width - bw) / 2 * 1cm, dy: 0cm,
          box(width: bw * 1cm, height: bh * 1cm, {
            place(top + left, md-region((dt,), flip: bh * 1cm, fill: bg))
            _sb-draw(dt, bh * 1cm, paint: gi, w: 1.5pt, seed: seed + 7, ..H,
              bowing: bowing)
            place(center + horizon, text(fill: gi, weight: "bold",
              size: 1.15em, title))
          }))
      }

      if clip {
        // MEASURED on the source: the clip grips the frame's TOP-LEFT
        // corner, straddling the rule with about 40 % of itself above it,
        // and it stays clear of the ribbon. Note it is on the left in the
        // Arabic original — a clip is put where the hand reaches, not where
        // the script runs, so this one does NOT mirror with the direction.
        let cl = sb-clip(w: 0.40, angle: -8deg)
        place(top + left, dx: clip-at * width * 1cm,
          dy: (over - cl.h * 0.40) * 1cm, cl.whole)
      }
    })
  }
}

// -----------------------------------------------------------------------------
//  27. highlight — a felt-tip marker stroke behind text
// -----------------------------------------------------------------------------

/// Text struck through with a highlighter.
///
/// Measured on uploads/FB_IMG_1785752988356.jpg: the green band is 145 x 27
/// px behind a line of ~19 px type, so it stands about 1.4 times the
/// x-height and is TRANSLUCENT — the ruled line of the paper shows straight
/// through it. Sampled `#D1E2B6` over `#EFEBE8` paper, which is the ink at
/// roughly 45 % opacity, not a pale green fill.
///
/// A marker is not a rectangle. Three things give it away, all visible in
/// the source at 3x:
///
///   * the ends are ROUNDED, because the nib is;
///   * the long edges wander by a fraction of a millimetre;
///   * where the stroke overlaps itself the ink is DARKER — most obviously
///     at the two ends, where the nib pauses.
///
/// A flat rectangle of pale colour reads as a table cell, which is exactly
/// what the first attempt looked like.
#let sb-inks = (
  green:  rgb("#8CC63F"),
  yellow: rgb("#FFD24A"),
  pink:   rgb("#F58BB0"),
  blue:   rgb("#7FB2E5"),
  orange: rgb("#F5A25D"),
  violet: rgb("#B99BD6"),
)

#let highlight(
  body,
  colour: auto, ink: "yellow", alpha: 45%,
  height: 1.42, rise: 0.0, pad: 0.10,
  cap: 0.55, wobble: 0.020, seed: 91, rough: false,
) = context {
  let col = if colour != auto { colour }
            else { sb-inks.at(ink, default: sb-inks.yellow) }
  let m = measure(body)
  let w = m.width / 1cm + 2 * pad
  // `measure` stops at the BASELINE, so `LEARN` and `Ppyjgq` both report
  // the same height and neither includes the descender. The band is
  // therefore sized off the FONT — a lower-case x measured in the current
  // style — rather than off the text it is covering, so a highlight over
  // `voyage` is the same height as one over `LEARN`.
  let ex = measure("x").height / 1cm
  let hh = height * calc.max(0.22, ex)
  let r = calc.min(cap * hh, w / 2)
  let flip = hh * 1cm
  let jig = randoms(seed, 40)
  // the outline: two wandering long edges closed by round caps
  let n = calc.max(6, int(w / 0.22))
  let topline = range(n + 1).map(i => {
    let t = i / n
    (r + (w - 2 * r) * t, hh - jig.at(calc.rem(i, 40)) * wobble)
  })
  let botline = range(n + 1).map(i => {
    let t = 1 - i / n
    (r + (w - 2 * r) * t, jig.at(calc.rem(i + 17, 40)) * wobble)
  })
  let capR = arc-pts((w - r, hh / 2), r, 90, -90, n: 12)
    .map(p => (p.at(0), (p.at(1) - hh / 2) * (hh / (2 * r)) + hh / 2))
  let capL = arc-pts((r, hh / 2), r, 270, 90, n: 12)
    .map(p => (p.at(0), (p.at(1) - hh / 2) * (hh / (2 * r)) + hh / 2))
  let band = topline + capR + botline + capL

  // Where the band sits vertically. The box's own top is at the line's
  // ASCENT, and the ink has to straddle the x-height: its centre belongs at
  // (ascent - ex/2) below that top. Placing it at dy = 0 — the first try —
  // hung the stroke above the words instead of through them.
  let asc = m.height / 1cm
  let dy0 = asc - ex / 2 - hh / 2 + rise * ex
  box(baseline: 0pt, {
    place(top + left, dy: dy0 * 1cm,
      box(width: w * 1cm, height: hh * 1cm, {
        place(top + left, md-region((band,), flip: flip,
          fill: col.transparentize(100% - alpha)))
        // the nib pauses at each end, so the ink doubles there
        for cx in (r * 0.75, w - r * 0.75) {
          place(top + left, md-region((circle-pts((cx, hh / 2), r * 0.72,
            n: 18),), flip: flip,
            fill: col.transparentize(100% - alpha * 0.55)))
        }
      }))
    box(inset: (x: pad * 1cm), body)
  })
}

// -----------------------------------------------------------------------------
//  28. lesson-table — the lavender-headed grammar table
// -----------------------------------------------------------------------------

/// The table of `MODAL VERBS`: a thin grey grid, a lavender header row, and
/// columns that keep their proportions.
///
/// Measured on the same page: rules at x = 663 / 780 / 965 / 1202, so the
/// three columns are 117 / 185 / 237 px — 0.22 / 0.34 / 0.44 of the width.
/// The header is `#DEDBE4` on a `#F5F1EE` body, and every rule is the same
/// hairline: no heavy outer border, which is what keeps it looking drawn in
/// a notebook rather than generated.
#let lesson-table(
  ..cells,
  columns: auto, header: true,
  fill: auto, head-fill: auto, ink: auto,
  pad: 0.30, width: 100%, align-cells: auto, ltr-cols: (),
  seed: 95, rough: auto, hand: none, roughness: 1.0, bowing: 0.6,
) = context {
  let bg = if fill != auto { fill } else { rgb("#F7F4F0") }
  let hf = if head-fill != auto { head-fill } else { rgb("#DEDBE4") }
  let gi = if ink != auto { ink } else { rgb("#8A8894") }
  let items = cells.pos()
  let cols = if columns != auto { columns } else { (0.22fr, 0.34fr, 0.44fr) }
  let ncol = cols.len()
  let al = if align-cells != auto { align-cells } else { center + horizon }
  // A Latin sentence inside an RTL paragraph is a BiDi problem, not a
  // styling one: `I can swim.` ends with a NEUTRAL character, so the
  // full stop takes the paragraph's direction and jumps to the left —
  // `.I can swim`. Wrapping such a cell in `text(dir: ltr)` fixes the
  // sentence's own base direction. The table cannot guess which cells are
  // Latin, so `ltr-cells` marks them by column index.

  table(
    columns: cols,
    stroke: 0.5pt + gi,
    inset: pad * 1cm,
    align: al,
    fill: (x, y) => if header and y == 0 { hf } else { bg },
    ..items.enumerate().map(p => {
      let (i, c) = p
      let col = calc.rem(i, ncol)
      let cc = if ltr-cols.contains(col) and not (header and i < ncol) {
        text(dir: ltr, c)
      } else { c }
      if header and i < ncol { strong(cc) } else { cc }
    }),
  )
}

// -----------------------------------------------------------------------------
//  29. sb-underline / sb-divider — the two pen marks of the grammar card
// -----------------------------------------------------------------------------

/// A hand-drawn underline, as the source rules its red sub-headings.
///
/// MEASURED on uploads/FB_IMG_1785663912704.jpg: the rule under `تعريفه` is
/// 44 px long beneath a 78 px word — **0.56 of it** — and it is not centred:
/// a pen stroke starts where the hand lands, not where the word begins. It
/// also wobbles, and it sits about half an x-height below the baseline.
///
/// A `line(length: 100%)` under the word is the giveaway: dead straight,
/// full width, perfectly centred. All three are wrong.
#let sb-underline(
  body,
  colour: auto, span: 0.56, shift: 0.06, drop: 0.42,
  weight: 1.5pt, wobble: 0.020, seed: 97,
) = context {
  let col = if colour != auto { colour } else { rgb("#B5423F") }
  let m = measure(body)
  let w = m.width / 1cm
  let ex = measure("x").height / 1cm
  let len = w * span
  let x0 = w * (1 - span) / 2 + w * shift
  let jig = randoms(seed, 24)
  let n = calc.max(4, int(len / 0.12))
  let pts = range(n + 1).map(i => {
    let t = i / n
    // the stroke lifts a little at each end, as a pen does
    let taper = calc.min(1.0, calc.sin(calc.pi * t) * 2.4)
    (x0 + len * t, (jig.at(calc.rem(i, 24)) - 0.5) * wobble * taper)
  })
  box({
    body
    place(top + left, dy: (m.height / 1cm + drop * ex) * 1cm,
      md-polylines((pts,), flip: 0cm,
        stroke: (paint: col, thickness: weight, cap: "round")))
  })
}

/// The dotted rule between sections.
///
/// MEASURED: 2 px dashes with 2 px gaps — a fine, even dotted line, not the
/// long dashes a default `dash: "dashed"` gives. It runs the full width of
/// the card's text column.
#let sb-divider(
  colour: auto, dash: 0.055, gap: 0.055, weight: 0.9pt, above: 0.5em,
  below: 0.5em,
) = context {
  let col = if colour != auto { colour } else { rgb("#1D7A3D") }
  block(width: 100%, above: above, below: below,
    line(length: 100%, stroke: (paint: col, thickness: weight,
      dash: (array: (dash * 1cm, gap * 1cm), phase: 0pt))))
}
