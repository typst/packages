// ===========================================================================
//  faboxyst/plankbox.typ — a rustic wooden sign, after the hand-drawn
//  "Ma lettre de fin d'année" pancarte.
//
//    #plankbox(title: [Ma lettre])[de fin d'année]
//
//  A small horizontal sign of light golden-beige wood, seen from the
//  front: an elongated, slightly irregular plank (about 2.4 times as wide
//  as high when the text is short) with cut/torn ends — deep irregular
//  slits, about as long as the box inset, with uneven thickness — and
//  wavy top and bottom edges; darker shading on the rim, grain streaks,
//  cracks, scratches and discreet brown spots, a matte worn surface and
//  a faint light-grey shadow under the lower edge. With a title the sign
//  is two leaning planks (title on top, body below); without, a single
//  plank.
// ===========================================================================

#import "fabox.typ": is-rtl
#import "engine.typ": randoms

/// The reference artwork's wood palette.
#let plank-colours = (
  wood:   rgb("#E8C078"),   // golden-beige plank wood
  rim:    rgb("#C08A4E"),   // darker shading on the edges
  edge:   rgb("#4A2F15"),   // bark outline
  streak: rgb("#A97134"),   // grain, cracks and knot
  spot:   rgb("#8A5A2B"),   // discreet brown spots
  shadow: luma(226),        // faint light-grey relief shadow
  ink:    rgb("#221407"),   // handwritten lettering
)

// Slit specs for the two cut/torn ends: irregular positions, lengths
// around `base` (the box inset) and uneven thicknesses. Each entry is
// (y, length, opening thickness, tip drift, silhouette step).
#let _slit-specs(H, seed, base) = {
  let r = randoms(seed + 977, 20)
  let a(i) = calc.abs(r.at(i))
  let len(i) = calc.min(base * (0.85 + 0.55 * a(i)), H * 0.46)
  let th(i) = 1.2pt + 1.8pt * a(i + 6)
  let dy(i) = (r.at(i + 12) * 1.3pt)
  let st(i) = 1.4pt + 1.4pt * a(i + 3)
  (
    right: (
      (H * (0.28 + 0.08 * r.at(0)), len(0), th(0), dy(0), st(0)),
      (H * (0.61 + 0.08 * r.at(1)), len(1), th(1), dy(1), st(1)),
    ),
    left: (
      (H * (0.21 + 0.06 * r.at(2)), len(2), th(2), dy(2), st(2)),
      (H * (0.48 + 0.06 * r.at(3)), len(3), th(3), dy(3), st(3)),
      (H * (0.76 + 0.05 * r.at(4)), len(4), th(4), dy(4), st(4)),
    ),
  )
}

// A plank outline, sampled densely: wavy top and bottom edges, barely
// rounded corners, and jagged ends where the silhouette steps in at each
// slit (the deep cut itself is drawn on top by `_slits`).
#let _outline(W, H, seed, jit, specs) = {
  let r = randoms(seed, 14)
  let m = 1.2pt                          // keeps the wobble inside the block
  let ph1 = r.at(4) * 3.1416
  let ph2 = r.at(5) * 3.1416
  let wob(t) = jit * (0.6 * calc.sin(10.7 * t + ph1) + 0.4 * calc.sin(19.5 * t + ph2))
  let cr = calc.min(2.6pt, H * 0.12)     // barely rounded corners
  let pts = ()
  let n = 14
  // top edge, left to right (wavy)
  for i in range(n + 1) {
    let x = cr + (W - 2 * cr) * i / n
    pts.push((x, m + wob(x / W)))
  }
  // top-right corner
  pts.push((W - m - cr * 0.3, m + cr * 0.4))
  pts.push((W - m, m + cr))
  // right end, top to bottom, jags at the slits
  let R = specs.at("right")
  let ycur = m + cr
  for (y, ln, th, dyv, st) in R {
    for i in range(1, 5) {
      let yy = ycur + (y - ycur) * i / 4
      pts.push((W - m + wob(yy / H) * 0.5, yy))
    }
    pts.push((W - m - st, y + 0.6pt))
    pts.push((W - m, y + 2.0pt))
    ycur = y + 2.0pt
  }
  for i in range(1, 4) {
    let yy = ycur + (H - m - cr - ycur) * i / 4
    pts.push((W - m + wob(yy / H + 0.2) * 0.5, yy))
  }
  // bottom-right corner
  pts.push((W - m, H - m - cr))
  pts.push((W - m - cr * 0.3, H - m - cr * 0.4))
  // bottom edge, right to left (wavy)
  for i in range(1, n + 1) {
    let x = (W - cr) - (W - 2 * cr) * i / n
    pts.push((x, H - m + wob(x / W + 0.37)))
  }
  // bottom-left corner
  pts.push((m + cr * 0.3, H - m - cr * 0.4))
  pts.push((m, H - m - cr))
  // left end, bottom to top, jags at the slits
  let L = specs.at("left")
  let ycur2 = H - m - cr
  for (y, ln, th, dyv, st) in L.rev() {
    for i in range(1, 5) {
      let yy = ycur2 + (y + 2.0pt - ycur2) * i / 4
      pts.push((m + wob(yy / H + 0.5) * 0.5, yy))
    }
    pts.push((m + st, y + 0.6pt))
    pts.push((m, y - 1.4pt))
    ycur2 = y - 1.4pt
  }
  for i in range(1, 4) {
    let yy = ycur2 + (cr - ycur2) * i / 4
    pts.push((m + wob(yy / H + 0.1) * 0.5, calc.max(yy, cr)))
  }
  // top-left corner
  pts.push((m, m + cr))
  pts.push((m + cr * 0.3, m + cr * 0.4))
  pts
}

// The deep cut/torn slits: tapered wedges from the end into the wood,
// each with its own length and thickness, slightly drifting at the tip.
#let _slits(W, H, specs, paint) = {
  for (y, ln, th, dyv, st) in specs.at("right") {
    let y0 = y - th * 0.55
    place(top + left, dx: W - 0.5pt - ln, dy: y0, polygon(fill: paint,
      (ln, 0pt),
      (0pt, y + dyv - y0),
      (ln, th * 1.35)))
  }
  for (y, ln, th, dyv, st) in specs.at("left") {
    let y0 = y - th * 0.55
    place(top + left, dx: 0.5pt, dy: y0, polygon(fill: paint,
      (0pt, 0pt),
      (ln, y + dyv - y0),
      (0pt, th * 1.35)))
  }
}

// Natural details: grain veins, a crack with a fork, light scratches,
// discreet brown spots and a knot. All seeded, all inside the plank.
#let _grain(W, H, pc, knot: none, seed: 7) = {
  let r = randoms(seed + 501, 10)
  let yj(i, y) = y + r.at(i) * H * 0.04
  // two long wavy veins running with the grain
  place(top + left, curve(stroke: 0.7pt + pc.streak.transparentize(45%),
    curve.move((W * 0.08, yj(0, H * 0.28))),
    curve.cubic((W * 0.30, yj(1, H * 0.24)), (W * 0.52, yj(2, H * 0.33)), (W * 0.74, yj(3, H * 0.27))),
    curve.cubic((W * 0.84, yj(4, H * 0.24)), (W * 0.90, yj(5, H * 0.29)), (W * 0.94, yj(6, H * 0.26))),
  ))
  place(top + left, curve(stroke: 0.7pt + pc.streak.transparentize(55%),
    curve.move((W * 0.06, yj(7, H * 0.78))),
    curve.cubic((W * 0.28, yj(8, H * 0.82)), (W * 0.55, yj(9, H * 0.74)), (W * 0.80, yj(0, H * 0.80))),
    curve.cubic((W * 0.87, yj(1, H * 0.82)), (W * 0.92, yj(2, H * 0.78)), (W * 0.95, yj(3, H * 0.80))),
  ))
  // a short crack with a fork, near the trailing end
  let cx = W * 0.885
  place(top + left, curve(stroke: 0.6pt + pc.edge.transparentize(40%),
    curve.move((cx, yj(4, H * 0.50))),
    curve.cubic((cx + W * 0.02, yj(5, H * 0.47)), (cx + W * 0.04, yj(6, H * 0.52)), (cx + W * 0.065, yj(7, H * 0.49))),
  ))
  place(top + left,
    line(start: (cx + W * 0.028, yj(8, H * 0.49)), end: (cx + W * 0.036, yj(9, H * 0.535)),
      stroke: (paint: pc.edge.transparentize(55%), thickness: 0.45pt, cap: "round")))
  // two light scratches
  place(top + left,
    line(start: (W * 0.16, yj(0, H * 0.55)), end: (W * 0.30, yj(1, H * 0.53)),
      stroke: (paint: pc.wood.lighten(28%), thickness: 0.5pt, cap: "round")))
  place(top + left,
    line(start: (W * 0.58, yj(2, H * 0.44)), end: (W * 0.66, yj(3, H * 0.46)),
      stroke: (paint: pc.wood.lighten(28%), thickness: 0.5pt, cap: "round")))
  // discreet brown spots
  for (i, (sx, sy, sw)) in ((0.22, 0.62, 3.4pt), (0.47, 0.36, 2.6pt), (0.71, 0.66, 3.0pt)).enumerate() {
    place(top + left, dx: W * sx + r.at(i) * 4pt, dy: H * sy + r.at(i + 3) * 3pt,
      ellipse(width: sw, height: sw * 0.62, fill: pc.spot.transparentize(68%)))
  }
  // a knot: two rings and a core
  if knot != none {
    let kx = W * knot
    let ky = H * 0.47
    place(top + left, dx: kx - 2.6pt, dy: ky - 3.4pt,
      ellipse(width: 5.2pt, height: 6.8pt, stroke: 0.8pt + pc.streak.transparentize(25%)))
    place(top + left, dx: kx - 1.5pt, dy: ky - 2.0pt,
      ellipse(width: 3.0pt, height: 4.0pt, stroke: 0.6pt + pc.streak.transparentize(45%)))
    place(top + left, dx: kx - 0.7pt, dy: ky - 1.0pt,
      ellipse(width: 1.4pt, height: 2.0pt, fill: pc.streak))
  }
}

// Aged papyrus-like noise, after the pgfplots `surf {rand}` shaded with a
// narrow colormap: many soft seeded blotches whose intensity interpolates
// at random between the plain tint and the tint darkened by `max` (like
// the reference's cmyk black going 0 -> 5%). Large overlapping ellipses,
// not a grid, so the surface mottles instead of checkerboarding.
#let _mottle(W, H, seed, max) = {
  if max <= 0% { return }
  let n = calc.min(110, calc.max(18, int(int(W / 14pt) * int(H / 14pt) / 3)))
  let r = randoms(seed + 2000, 5 * n)
  for i in range(n) {
    let t = (r.at(5 * i) + 1) / 2
    let alpha = t * max * 0.45
    if alpha > 0.35% {
      let rx = 8pt + calc.abs(r.at(5 * i + 1)) * 22pt
      let ry = rx * (0.45 + 0.4 * calc.abs(r.at(5 * i + 2)))
      let cx = rx + 2pt + calc.abs(r.at(5 * i + 3)) * calc.max(W - 2 * rx - 4pt, 1pt)
      let cy = ry + 2pt + calc.abs(r.at(5 * i + 4)) * calc.max(H - 2 * ry - 4pt, 1pt)
      let paint = if calc.even(i) { black } else { white }
      place(top + left, dx: cx - rx, dy: cy - ry,
        ellipse(width: 2 * rx, height: 2 * ry,
          fill: paint.transparentize(100% - alpha)))
    }
  }
}

// ===========================================================================
//  Sketchy-pencil styles, after the matchstick-puzzle artwork: two
//  hand-drawn banner looks on off-white paper. "sketch" draws a wavy
//  double graphite outline with sparse pencil ticks radiating outside;
//  "hatch" surrounds a rough rectangle with a dense band of scribbled
//  diagonal strokes, like a shaded halo.
// ===========================================================================

#let pencil-colours = (
  paper: rgb("#FBF9F4"),   // off-white paper
  line:  rgb("#3E3A36"),   // graphite outline
  hatch: rgb("#6B6560"),   // pencil hatch strokes
  ink:   rgb("#26221E"),   // hand-lettered ink
)

// A wavy hand-drawn rectangle as a closed point list.
#let _wavy-rect(W, H, seed, jit, m: 1.4pt) = {
  let r = randoms(seed, 8)
  let p1 = r.at(0) * 6.283
  let p2 = r.at(1) * 6.283
  let wob(t) = jit * (0.65 * calc.sin(6.7 * t + p1) + 0.35 * calc.sin(14.9 * t + p2))
  let pts = ()
  let nx = calc.max(6, int(W / 26pt))
  let ny = calc.max(4, int(H / 26pt))
  for i in range(nx + 1) { let x = W * i / nx; pts.push((x, m + wob(x / W))) }
  for i in range(1, ny + 1) {
    let y = m + (H - 2 * m) * i / ny
    pts.push((W - m + wob(y / H + 0.3), y))
  }
  for i in range(1, nx + 1) { let x = W - W * i / nx; pts.push((x, H - m + wob(x / W + 0.6))) }
  for i in range(1, ny) {
    let y = H - m - (H - 2 * m) * i / ny
    pts.push((m + wob(y / H + 0.9), y))
  }
  pts
}

// Point (x, y) and outward angle in degrees at fraction t of the
// rectangle perimeter, clockwise from the top-left corner.
#let _perim(W, H, t) = {
  let per = 2 * (W + H)
  let d = t * per
  if d < W { (x: d, y: 0pt, out: -90) }
  else if d < W + H { (x: W, y: d - W, out: 0) }
  else if d < 2 * W + H { (x: W - (d - W - H), y: H, out: 90) }
  else { (x: 0pt, y: H - (d - 2 * W - H), out: 180) }
}

// Sketchy banner: wavy double graphite outline, paper fill, sparse
// pencil ticks radiating outside the outer line.
#let _sketch-plank(W, H, content, ix, iy, seed, pc, weight) = {
  block(width: W, height: H, {
    place(top + left, polygon(fill: pc.paper, stroke: weight + pc.line,
      .._wavy-rect(W, H, seed, 2.4pt)))
    place(top + left, dx: 3.6pt, dy: 3.6pt,
      polygon(stroke: 0.8pt + pc.line.transparentize(20%),
        .._wavy-rect(W - 7.2pt, H - 7.2pt, seed + 3, 1.9pt)))
    let r = randoms(seed + 41, 80)
    let nt = calc.max(10, int(2 * (W + H) / 30pt))
    for i in range(nt) {
      let q = _perim(W, H, i / nt)
      let ln = 3pt + calc.abs(r.at(calc.rem(i, 80))) * 3.5pt
      let a = (q.out + 38 + r.at(calc.rem((i + 20), 80)) * 20) * 1deg
      place(top + left,
        line(start: (q.x, q.y),
          end: (q.x + ln * calc.cos(a), q.y + ln * calc.sin(a)),
          stroke: (paint: pc.hatch.transparentize(40%),
            thickness: 0.7pt, cap: "round")))
    }
    place(top + left, dx: ix, dy: iy,
      block(width: W - 2 * ix, height: H - 2 * iy,
        align(center + horizon, content)))
  })
}

// Hatched banner: rough graphite rectangle hugged by a dense scribbled
// band of diagonal pencil strokes.
#let _hatch-plank(W, H, content, ix, iy, seed, pc, weight) = {
  block(width: W, height: H, {
    place(top + left, polygon(fill: pc.paper,
      stroke: (weight * 0.85) + pc.line, .._wavy-rect(W, H, seed, 1.8pt)))
    let r = randoms(seed + 77, 120)
    let nb = calc.max(24, int(2 * (W + H) / 5pt))
    for i in range(nb) {
      let q = _perim(W, H, i / nb)
      let ln = 5pt + calc.abs(r.at(calc.rem(i, 120))) * 7pt
      let a = (q.out + 45 + r.at(calc.rem((i + 40), 120)) * 24) * 1deg
      let ox = calc.cos(q.out * 1deg) * 1.2pt
      let oy = calc.sin(q.out * 1deg) * 1.2pt
      place(top + left,
        line(start: (q.x + ox, q.y + oy),
          end: (q.x + ox + ln * calc.cos(a), q.y + oy + ln * calc.sin(a)),
          stroke: (paint: pc.hatch.transparentize(
              25% + calc.abs(r.at(calc.rem((i + 80), 120))) * 30%),
            thickness: 0.8pt, cap: "round")))
    }
    place(top + left, dx: ix, dy: iy,
      block(width: W - 2 * ix, height: H - 2 * iy,
        align(center + horizon, content)))
  })
}

// A single plank: shadow + rim + wood + slits + details + centred
// content, all in one block so the whole plank tilts with one rotation.
#let _plank(W, H, content, ix, iy, seed, pc, weight, jit, knot, mottle) = {
  let specs = _slit-specs(H, seed, ix)
  let outer = _outline(W, H, seed, jit, specs)
  let rim-t = 2.2pt
  let inner = _outline(W - 2 * rim-t, H - 2 * rim-t, seed + 5, jit * 0.8,
    (right: (), left: ()))
  block(width: W, height: H, {
    // faint light-grey shadow, peeking under the lower edge
    place(top + left, dx: 0.4pt, dy: 1.6pt, polygon(fill: pc.shadow, ..outer))
    // darker rim, bark outline
    place(top + left, polygon(fill: pc.rim, stroke: weight + pc.edge, ..outer))
    // golden-beige matte surface
    place(top + left, dx: rim-t, dy: rim-t, polygon(fill: pc.wood, ..inner))
    // papyrus-like intensity noise over the wood
    place(top + left, dx: rim-t, dy: rim-t, _mottle(W - 2 * rim-t, H - 2 * rim-t, seed + 13, mottle))
    // deep cut/torn slits at both ends
    _slits(W, H, specs, pc.edge)
    _grain(W, H, pc, knot: knot, seed: seed)
    place(top + left, dx: ix, dy: iy,
      block(width: W - 2 * ix, height: H - 2 * iy,
        align(center + horizon, content)))
  })
}

/// A rustic wooden sign: light golden-beige planks with cut/torn ends —
/// deep irregular slits with uneven thickness — wavy edges, grain,
/// cracks, scratches, spots, a faint shadow and a very slight lean (top
/// edge rising to the right). `style: "sketch"` or `style: "hatch"`
/// switch to the sketchy-pencil banner looks (wavy double graphite
/// outline, or a dense hatched halo) on off-white paper. The title rides the upper plank and the
/// body the lower one; without a title the body sits alone on a single
/// plank about 2.4 times as wide as high.
///
/// ```typ
/// #plankbox(title: [Ma lettre])[de fin d'année]
/// #pancarte[Une petite pancarte rustique]   // French alias, one plank
/// ```
#let plankbox(
  body,
  title: none,
  wood: auto,
  edge: auto,
  streak: auto,
  text-fill: auto,
  title-size: 1.1em,
  tilt: 2deg,          // very slight lean; the lower plank leans less
  gap: 0.06cm,         // daylight between the two planks
  style: "wood",       // "wood" | "sketch" | "hatch" (sketchy pencil)
  weight: 1.6pt,       // bark outline
  jitter: 0.8pt,       // waviness of the hand-sawn edges
  mottle: 6%,          // papyrus-like intensity noise on the wood
  inset: (x: 0.55cm, y: 0.30cm),
  width: 96%,
  height: auto,        // force the sign's height (page frames)
  seed: auto,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let pc = plank-colours
  let pencil = style != "wood"
  let pc2 = (
    wood:   if wood == auto { pc.wood } else { wood },
    rim:    if wood == auto { pc.rim } else { wood.darken(18%) },
    edge:   if edge == auto { pc.edge } else { edge },
    streak: if streak == auto { pc.streak } else { streak },
    spot:   if streak == auto { pc.spot } else { streak.darken(12%) },
    shadow: pc.shadow,
    ink:    if text-fill != auto { text-fill }
            else if pencil { pencil-colours.ink } else { pc.ink },
  )
  let pc3 = (
    paper: pencil-colours.paper,
    line:  if edge == auto { pencil-colours.line } else { edge },
    hatch: pencil-colours.hatch,
  )
  let sd = if seed == auto { 11 } else { seed }
  let ix = inset.at("x", default: 0.55cm)
  let iy = inset.at("y", default: 0.30cm)

  let title-body = if title == none { none } else {
    text(fill: pc2.ink, weight: "bold", size: title-size, title)
  }
  let body-body = text(fill: pc2.ink, weight: "bold", body)

  layout(avail => {
    let Wfull = avail.width
    let W = if type(width) == ratio { Wfull * width } else { width }
    let cx = (Wfull - W) / 2             // the sign sits centred
    let sgn = if rtl { -1 } else { 1 }

    // lean angles (positive `tilt` raises the leading edge, as in the art)
    let a-top = -tilt * sgn
    let a-bot = -tilt * 0.7 * sgn

    // headroom each rotated plank needs above its anchor
    let deg-top = calc.abs(tilt / 1deg)
    let deg-bot = deg-top * 0.7
    let lift-top = W * deg-top / 57.3
    let lift-bot = W * deg-bot / 57.3

    let two = title != none
    let tm = if two { measure(title-body) } else { (width: 0pt, height: 0pt) }
    let top-h = if two { calc.max(tm.height + 2 * iy, 1.05cm) } else { 0pt }
    let bm = measure(body-body)
    let min-h = if two { 1.05cm } else { W / 2.4 }   // the 2.4 proportion
    let bot-h = calc.max(bm.height + 2 * iy, min-h)

    let y-top = lift-top
    let y-bot = y-top + top-h + (if two { gap } else { 0pt })
    let sink = if rtl { lift-top + lift-bot } else { 0pt }
    if height != auto {
      let Ht = if type(height) == ratio { avail.height * height } else { height }
      let cur = (if two { y-bot + bot-h } else { y-top + bot-h }) + sink + 4pt
      let extra = Ht - cur
      if extra > 0pt { bot-h = bot-h + extra }
    }
    let H = (if two { y-bot + bot-h } else { y-top + bot-h }) + sink + 4pt

    block(width: Wfull, height: H, {
      set text(dir: body-dir)
      set align(start)

      if two {
        let top-w = W * 0.97
        let tx = cx + (W - top-w) / 2
        let art = if style == "sketch" {
          _sketch-plank(top-w, top-h, title-body, ix, iy, sd, pc3, weight)
        } else if style == "hatch" {
          _hatch-plank(top-w, top-h, title-body, ix, iy, sd, pc3, weight)
        } else {
          _plank(top-w, top-h, title-body, ix, iy, sd, pc2, weight,
            jitter, if rtl { 88% } else { 12% }, mottle)
        }
        place(top + left, dx: tx, dy: y-top,
          rotate(a-top, origin: top + left, reflow: false, art))
      }

      let bot-w = W * 0.99
      let bx = cx + (W - bot-w) / 2
      let by = if two { y-bot } else { y-top }
      let art2 = if style == "sketch" {
        _sketch-plank(bot-w, bot-h, body-body, ix, iy, sd + 77, pc3, weight)
      } else if style == "hatch" {
        _hatch-plank(bot-w, bot-h, body-body, ix, iy, sd + 77, pc3, weight)
      } else {
        _plank(bot-w, bot-h, body-body, ix, iy, sd + 77, pc2, weight,
          jitter, if rtl { 14% } else { 86% }, mottle)
      }
      place(top + left, dx: bx, dy: by,
        rotate(a-bot, origin: top + left, reflow: false, art2))
    })
  })
}

/// French alias, after the pancarte the box imitates.
#let pancarte(..a) = plankbox(..a)

/// Draw the wooden sign as a full-page frame on every page, after
/// `ornate-pages`: the sign seats in the page background at `margin`
/// while the text flows `gap` inside it. Use `#show: plank-pages` to frame a whole document, or call the rule
/// directly on a section (`#plank-pages[...]`) to chain several different
/// frames in one document.
#let plank-pages(doc, margin: 0.7cm, gap: 1.1cm, ..args) = {
  set page(
    margin: margin + gap,
    background: context {
      let fw = page.width - 2 * margin
      let fh = page.height - 2 * margin
      place(top + left, dy: margin,
        plankbox([], width: fw, height: fh, tilt: 0deg, ..args.named()))
    },
  )
  doc
}
