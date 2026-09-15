// ===========================================================================
//  faboxyst/programme.typ — the "annual programme" plate family, after the
//  secondary-school physics programme sheet (السنة الأولى — البرنامج السنوي):
//
//    * `leconbox` / `lecon`      — the numbered lesson bar: grey gradient tag
//                                  with a pointed tail, a coloured chevron +
//                                  underline and a comma-badge number;
//    * `pinbox` / `epingle`      — the map-pin badge (thin ring, thick teal
//                                  crescent, pointed tail, white disc);
//    * `brushbox` / `pinceau`    — the watercolour brush-stroke banner;
//    * `matierebox` / `cartouche`— the subject-and-year ribbon (teal pill +
//                                  halftone end panel).
//
//    #show: faboxyst.with(theme: (lang: "ar", dir: rtl))
//    #leconbox(num: 1)[بنية وهندسة أفراد بعض الأنواع الكيميائية]
//    #pinbox[السنة الأولى][1 ج م ع ت]
//    #brushbox[البرنامج السنوي لمادة العلوم الفيزيائية]
//    #matierebox(subject: [Physique], year: [2026/2027])
// ===========================================================================

#import "fabox.typ": is-rtl
#import "fills.typ": halftone

// ---------------------------------------------------------------------------
//  small geometry helpers (local, placed coordinates; y grows downwards)
// ---------------------------------------------------------------------------

// Sampled circular arc: angles in degrees, screen convention (0 = right,
// 90 = down, 270 = up).
#let arc-pts(cx, cy, r, a0, a1, n: 40) = {
  range(n + 1).map(i => {
    let a = (a0 + (a1 - a0) * i / n) * 1deg
    (cx + r * calc.cos(a), cy + r * calc.sin(a))
  })
}

// An open polyline as a placed curve (round caps and joins).
#let poly-pts(pts, paint, w, closed: false, dx: 0pt, dy: 0pt) = {
  if pts.len() < 2 { return }
  let segs = (curve.move(pts.first()),) + pts.slice(1).map(p => curve.line(p))
  let segs = if closed { segs + (curve.close(mode: "straight"),) } else { segs }
  place(top + left, dx: dx, dy: dy, curve(
    stroke: (paint: paint, thickness: w, join: "round", cap: "round"),
    ..segs,
  ))
}

// A filled polygon with softly rounded corners: the outline is stroked with
// its own paint, so the join rounding eats `w / 2` — coordinates are meant
// to be given already inset by that amount.
#let round-poly(pts, paint, w: 1.6pt, dx: 0pt, dy: 0pt, stroke-paint: none) = {
  place(top + left, dx: dx, dy: dy, curve(
    fill: paint,
    stroke: (
      paint: if stroke-paint == none { paint } else { stroke-paint },
      thickness: w, join: "round", cap: "round",
    ),
    curve.move(pts.first()),
    ..pts.slice(1).map(p => curve.line(p)),
    curve.close(mode: "straight"),
  ))
}

// Deterministic pseudo-random in [0, 1) from an integer seed.
#let _rand(i) = {
  let x = calc.rem(i * 127 + 31, 97)
  calc.rem(x * x + 13, 89) / 89.0
}

// ---------------------------------------------------------------------------
//  palette — the accent / badge pairs of the reference sheet
// ---------------------------------------------------------------------------

/// The (underline+chevron, badge) colour pairs of the reference plate, in
/// order; `leconbox` cycles through them when `accent`/`badge` are `auto`.
#let prog-colours = (
  (accent: rgb("#CE8147"), badge: rgb("#17708C")),
  (accent: rgb("#439184"), badge: rgb("#C42A70")),
  (accent: rgb("#8E1F56"), badge: rgb("#E3B02A")),
  (accent: rgb("#7A6BC4"), badge: rgb("#2AA7A2")),
  (accent: rgb("#E07B39"), badge: rgb("#D97A2E")),
  (accent: rgb("#3FA98F"), badge: rgb("#1B89A0")),
  (accent: rgb("#B6405E"), badge: rgb("#8E2DA2")),
  (accent: rgb("#35A7B5"), badge: rgb("#C2205E")),
  (accent: rgb("#E0BE2E"), badge: rgb("#2AA7C6")),
  (accent: rgb("#C86BC8"), badge: rgb("#C42A90")),
  (accent: rgb("#A8285E"), badge: rgb("#7BB33A")),
  (accent: rgb("#2AA7A2"), badge: rgb("#17708C")),
)

#let lecon-counter = counter("faboxyst-lecon")

/// Reset the `leconbox` numbering.
#let lecon-reset() = lecon-counter.update(0)

// ---------------------------------------------------------------------------
//  leconbox — the numbered lesson bar
// ---------------------------------------------------------------------------

/// The numbered lesson bar of the annual-programme plate: a grey gradient
/// tag with a pointed tail, an open coloured chevron that continues into an
/// underline along the bottom edge, and a comma-shaped number badge.
///
/// ```typ
/// #leconbox(num: 1)[بنية وهندسة أفراد بعض الأنواع الكيميائية]
/// #lecon(accent: rgb("#B6405E"), badge: rgb("#8E2DA2"))[التماسك في الفضاء]
/// ```
#let leconbox(
  body,
  num: auto,            // auto = next counter value; int/content also ok
  accent: auto,         // chevron + underline colour
  badge: auto,          // number-badge ring colour
  width: 100%,
  min-height: 2.3em,
  inset: (x: 1.1em, y: 0.5em),
  fill: auto,           // auto = the grey gradient of the plate
  text-fill: rgb("#1C1C1C"),
  text-size: 1em,
  num-fill: rgb("#2E2E2E"),
  shadow: true,
) = context {
  let rtl = is-rtl()
  let n = if num == auto {
    lecon-counter.step()
    lecon-counter.get().first()
  } else { num }
  let pair = prog-colours.at(calc.rem(
    if type(n) == int { calc.max(n - 1, 0) } else { 0 }, prog-colours.len()))
  let acc = if accent == auto { pair.accent } else { accent }
  let bcl = if badge == auto { pair.badge } else { badge }
  let label = block(inset: (x: 0pt, y: 0pt), {
    set text(fill: text-fill, size: text-size)
    if rtl { set par(justify: false) }
    body
  })
  let nn = if type(n) == int {
    let s = str(calc.rem(n, 100))
    if s.len() == 1 { "0" + s } else { s }
  } else { n }
  let numlabel = text(
    fill: num-fill, size: text-size * 1.02,
    font: ("DejaVu Sans",),
    weight: "regular",
    nn,
  )
  layout(avail => {
    let W = if type(width) == ratio { avail.width * width }
            else if width == auto { avail.width } else { width }
    let lm = measure(label)
    let ix = measure(box(width: inset.at("x", default: 1.1em), height: 0pt)).width
    let iy = measure(box(height: inset.at("y", default: 0.5em), width: 0pt)).height
    let mh = measure(box(height: min-height, width: 0pt)).height
    let H = calc.max(lm.height + 2 * iy, mh)
    // bar body height (grey tag) and the underline band below it
    let Hb = H                       // grey tag spans 0 .. Hb
    let U = 0.11 * Hb                // underline stroke thickness
    let Ht = Hb + U * 1.25           // total height incl. underline
    // horizontal metrics, all in function of Hb
    let capd = 0.40 * Hb             // depth of the pointed caps
    let gap = 0.16 * Hb              // white gap tag → chevron
    let xc = W - 0.36 * Hb           // chevron bottom / top corner
    let xa = W - 0.04 * Hb           // chevron apex
    let vr = W - 0.72 * Hb           // grey tag right vertex
    let Ro = 0.46 * Hb               // badge outer radius
    let Ri = 0.335 * Hb              // badge inner radius
    let bcy = 0.44 * Hb
    let mx = x => if rtl { x } else { W - x }
    let bcx = mx(W - 1.05 * Hb)      // badge centre, on the chevron side
    let sx = if rtl { 1 } else { -1 }   // mirror the comma tail with the box
    block(width: W, height: Ht, {
      // -- soft drop shadow under the tag -------------------------------
      if shadow {
        round-poly((
          (mx(0.05 * Hb), 0.50 * Hb + 0.10 * Hb),
          (mx(0.40 * Hb), 0.05 * Hb + 0.10 * Hb),
          (mx(vr - capd), 0.05 * Hb + 0.10 * Hb),
          (mx(vr), 0.50 * Hb + 0.10 * Hb),
          (mx(vr - capd), Hb - 0.05 * Hb + 0.10 * Hb),
          (mx(0.40 * Hb), Hb - 0.05 * Hb + 0.10 * Hb),
        ), black.transparentize(88%), w: 0.12 * Hb)
      }
      // -- the grey tag --------------------------------------------------
      let gfill = if fill == auto {
        gradient.linear(
          (rgb("#D9D9D9"), 0%), (rgb("#EDEDED"), 45%),
          (rgb("#FBFBFB"), 78%), (white, 100%),
          angle: if rtl { 0deg } else { 180deg },
        )
      } else { fill }
      round-poly((
        (mx(0.05 * Hb), 0.50 * Hb),
        (mx(0.40 * Hb), 0.05 * Hb),
        (mx(vr - capd), 0.05 * Hb),
        (mx(vr), 0.50 * Hb),
        (mx(vr - capd), Hb - 0.05 * Hb),
        (mx(0.40 * Hb), Hb - 0.05 * Hb),
      ), gfill, w: 0.10 * Hb)
      // -- underline + chevron, one open coloured stroke -----------------
      poly-pts((
        (mx(0.34 * Hb), Hb + U * 0.62),
        (mx(xc), Hb + U * 0.62),
        (mx(xa), 0.50 * Hb),
        (mx(xc), 0.10 * Hb),
      ), acc, U)
      // -- the comma badge -----------------------------------------------
      let bx = bcx
      // ring
      place(top + left, dx: bx - (Ro + Ri) / 2, dy: bcy - (Ro + Ri) / 2,
        circle(radius: (Ro + Ri) / 2, stroke: (Ro - Ri) + bcl))
      // comma tail: sampled outer arc, sweep down to the tip, back up
      // along a concave edge to the sampled inner arc
      let mir = p => (bx + sx * (p.at(0) - bx), p.at(1))
      let outer = arc-pts(bx, bcy, Ro, 152, 96, n: 10).map(mir)
      let inner = arc-pts(bx, bcy, Ri, 80, 152, n: 10).map(mir)
      let tip = (bx + sx * 0.10 * Ro, bcy + 1.38 * Ro)
      place(top + left, curve(
        fill: bcl,
        curve.move(outer.first()),
        ..outer.slice(1).map(p => curve.line(p)),
        curve.cubic((bx + sx * 0.10 * Ro, bcy + 1.12 * Ro),
          (bx + sx * 0.13 * Ro, bcy + 1.24 * Ro), tip),
        curve.cubic((bx + sx * 0.02 * Ro, bcy + 1.12 * Ro),
          (bx + sx * 0.06 * Ro, bcy + 0.92 * Ro), inner.first()),
        ..inner.slice(1).map(p => curve.line(p)),
        curve.close(mode: "straight"),
      ))
      // inner disc + number
      place(top + left, dx: bx - Ri, dy: bcy - Ri,
        circle(radius: Ri, fill: gradient.linear(
          (rgb("#E4E4E4"), 0%), (rgb("#F4F4F4"), 55%), (white, 100%),
          angle: 90deg)))
      place(top + left, dx: bx - Ri, dy: bcy - Ri,
        block(width: 2 * Ri, height: 2 * Ri,
          align(center + horizon, numlabel)))
      // -- the lesson title ------------------------------------------------
      let pad-r = if rtl { W - bx + Ro + 0.35 * Hb } else { 0.45 * Hb + capd }
      let pad-l = if rtl { 0.45 * Hb + capd } else { bx + Ro + 0.35 * Hb }
      place(top + left, dx: pad-l, dy: 0pt,
        block(width: W - pad-l - pad-r, height: Hb,
          align(if rtl { right } else { left } + horizon, label)))
    })
  })
}

/// French alias for `leconbox`.
#let lecon(..a) = leconbox(..a)

// ---------------------------------------------------------------------------
//  pinbox — the map-pin badge
// ---------------------------------------------------------------------------

/// The map-pin badge of the plate header: a thin teal ring on top, a thick
/// crescent with a pointed tail below, and a raised white disc carrying two
/// lines of text.
///
/// ```typ
/// #pinbox[السنة الأولى][1 ج م ع ت]
/// ```
#let pinbox(
  ..a,
  colour: rgb("#009A96"),
  diameter: 3.1cm,
  text-fill: rgb("#141414"),
  disc: white,
  shadow: true,
  subtitle: none,
) = {
  let pos = a.pos()
  let title = pos.at(0, default: [])
  let sub = if pos.len() > 1 { pos.at(1) } else { subtitle }
  let D = diameter
  let R = D / 2
  let H = 1.52 * D
  let cx = R
  let cy = R
  block(width: D, height: H, {
    // soft shadow of the whole pin
    if shadow {
      place(top + left, dx: 0.04 * D, dy: 0.05 * D,
        curve(fill: black.transparentize(88%),
          curve.move((cx - 0.30 * R, cy + 0.80 * R)),
          curve.line((cx, cy + 1.50 * R)),
          curve.line((cx + 0.30 * R, cy + 0.80 * R)),
          curve.close(mode: "straight")))
    }
    // thin ring, upper arc (185° → 355°, through the top)
    poly-pts(arc-pts(cx, cy, R * 0.985, 187, 353, n: 56), colour, 0.045 * D)
    // raised white disc, with the inner shade the plate shows on its right
    place(top + left, dx: cx - R * 0.94, dy: cy - R * 0.94,
      circle(radius: R * 0.94, fill: disc))
    if shadow {
      poly-pts(arc-pts(cx, cy, R * 0.87, -40, 70, n: 40),
        black.transparentize(80%), 0.055 * D)
    }
    // thick crescent + tail (filled)
    let outer = arc-pts(cx, cy, R, 172, 118, n: 22)
    let outer2 = arc-pts(cx, cy, R, 62, 8, n: 22)
    let inner = arc-pts(cx, cy, R * 0.72, 8, 172, n: 44)
    let tip = (cx, cy + 1.46 * R)
    place(top + left, curve(
      fill: gradient.linear(colour.lighten(6%), colour.darken(8%), angle: 90deg),
      curve.move(outer.first()),
      ..outer.slice(1).map(p => curve.line(p)),
      curve.cubic((cx - 0.34 * R, cy + 1.02 * R), (cx - 0.16 * R, cy + 1.24 * R), tip),
      curve.cubic((cx + 0.16 * R, cy + 1.24 * R), (cx + 0.34 * R, cy + 1.02 * R), outer2.first()),
      ..outer2.slice(1).map(p => curve.line(p)),
      ..inner.map(p => curve.line(p)),
      curve.close(mode: "straight"),
    ))
    // the two lines of text
    place(top + left, dx: cx - R * 0.72, dy: cy - R * 0.62,
      block(width: R * 1.44, height: R * 1.24, {
        set align(center)
        text(fill: text-fill, size: 0.140 * D, title)
        if sub != none {
          v(0.06 * D)
          text(fill: text-fill, size: 0.158 * D, weight: "bold", sub)
        }
      }))
  })
}

/// French alias for `pinbox`.
#let epingle(..a) = pinbox(..a)

// ---------------------------------------------------------------------------
//  brushbox — the watercolour brush-stroke banner
// ---------------------------------------------------------------------------

/// A title laid over a dry watercolour brush stroke: one soft blob with
//  ragged, streaky ends, after the pink banner of the plate header.
///
/// ```typ
/// #brushbox[البرنامج السنوي لمادة العلوم الفيزيائية]
/// ```
#let brushbox(
  body,
  colour: rgb("#F0DCE8"),
  width: 100%,
  inset: (x: 2em, y: 0.62em),
  text-fill: rgb("#15343A"),
  text-size: 1.05em,
  streaks: 9,
) = context {
  let label = block(inset: (x: 0pt, y: 0pt), {
    set text(fill: text-fill, size: text-size, weight: "bold")
    body
  })
  layout(avail => {
    let W = if type(width) == ratio { avail.width * width }
            else if width == auto { avail.width } else { width }
    let lm = measure(label)
    let ix = measure(box(width: inset.at("x", default: 2em), height: 0pt)).width
    let iy = measure(box(height: inset.at("y", default: 0.62em), width: 0pt)).height
    let H = lm.height + 2 * iy
    let blob = color2 => curve(
      fill: color2,
      curve.move((0.055 * W, 0.30 * H)),
      curve.cubic((0.16 * W, 0.10 * H), (0.34 * W, 0.16 * H), (0.52 * W, 0.13 * H)),
      curve.cubic((0.70 * W, 0.10 * H), (0.86 * W, 0.16 * H), (0.945 * W, 0.28 * H)),
      curve.cubic((0.985 * W, 0.42 * H), (0.975 * W, 0.62 * H), (0.93 * W, 0.76 * H)),
      curve.cubic((0.82 * W, 0.90 * H), (0.62 * W, 0.84 * H), (0.44 * W, 0.88 * H)),
      curve.cubic((0.28 * W, 0.92 * H), (0.12 * W, 0.86 * H), (0.065 * W, 0.70 * H)),
      curve.cubic((0.03 * W, 0.56 * H), (0.035 * W, 0.42 * H), (0.055 * W, 0.30 * H)),
      curve.close(mode: "straight"),
    )
    block(width: W, height: H, {
      // pale halo pass, slightly offset: the watercolour bleed
      place(top + left, dx: -0.008 * W, dy: 0.03 * H, blob(colour.transparentize(55%)))
      place(top + left, blob(colour))
      // dry-brush streaks: thin slivers flying off both ends and the edges
      let sl = (
        ((0.000, 0.30, 0.115, 0.22, 0.015, 0.46), 1.0),
        ((0.010, 0.60, 0.140, 0.68, 0.020, 0.80), 0.9),
        ((0.870, 0.16, 0.995, 0.10, 0.955, 0.30), 1.0),
        ((0.890, 0.64, 1.000, 0.56, 0.965, 0.78), 0.9),
        ((0.280, 0.045, 0.470, 0.005, 0.450, 0.115), 0.8),
        ((0.540, 0.955, 0.710, 0.995, 0.690, 0.905), 0.8),
        ((0.140, 0.085, 0.270, 0.045, 0.250, 0.155), 0.7),
        ((0.740, 0.085, 0.885, 0.045, 0.865, 0.155), 0.7),
        ((0.080, 0.880, 0.230, 0.960, 0.210, 0.830), 0.7),
      )
      for i in range(calc.min(streaks, sl.len())) {
        let (pts, op) = sl.at(i)
        place(top + left, curve(
          fill: colour.transparentize((1 - op) * 100%),
          curve.move((pts.at(0) * W, pts.at(1) * H)),
          curve.line((pts.at(2) * W, pts.at(3) * H)),
          curve.line((pts.at(4) * W, pts.at(5) * H)),
          curve.close(mode: "straight"),
        ))
      }
      place(top + left, block(width: W, height: H,
        align(center + horizon, label)))
    })
  })
}

/// French alias for `brushbox`.
#let pinceau(..a) = brushbox(..a)

// ---------------------------------------------------------------------------
//  matierebox — the subject-and-year ribbon
// ---------------------------------------------------------------------------

/// The ribbon of the plate header: a white rounded banner with a teal
/// gradient pill carrying the subject on the left, and a halftone teal end
/// panel with a slanted edge carrying the year on the right.
///
/// ```typ
/// #matierebox(subject: [Physique], year: [2026/2027])
/// ```
#let matierebox(
  subject: none,
  year: none,
  body: none,
  base: rgb("#45B3BE"),
  width: 100%,
  height: 1.5cm,
  dots: true,
  shadow: true,
  text-fill: rgb("#0E5F6E"),
  year-fill: rgb("#141414"),
  text-size: 0.95em,
) = context {
  layout(avail => {
    let W = if type(width) == ratio { avail.width * width }
            else if width == auto { avail.width } else { width }
    let H = height
    let rad = 0.16 * H
    block(width: W, height: H, {
      // drop shadow
      if shadow {
        place(top + left, dx: 0.010 * H, dy: 0.10 * H,
          rect(width: W, height: H * 0.94, radius: rad,
            fill: black.transparentize(80%)))
        place(top + left, dx: 0.005 * H, dy: 0.05 * H,
          rect(width: W, height: H * 0.97, radius: rad,
            fill: black.transparentize(86%)))
      }
      // white banner body, clipping the end panel
      block(width: W, height: H, radius: rad, clip: true, {
        place(top + left, rect(width: W, height: H,
          fill: gradient.linear((white, 0%), (rgb("#F6F6F6"), 70%),
            (rgb("#ECECEC"), 100%), angle: 90deg)))
        // halftone end panel with a slanted left edge
        let px = 0.865 * W
        place(top + left, curve(
          fill: gradient.linear((base.lighten(14%), 0%), (base, 55%),
            (base.darken(12%), 100%), angle: 105deg),
          curve.move((px, 0pt)),
          curve.line((W, 0pt)),
          curve.line((W, H)),
          curve.line((px - 0.075 * W, H)),
          curve.close(mode: "straight"),
        ))
        if dots {
          place(top + left, curve(
            fill: halftone(base, dot: base.darken(22%).transparentize(30%),
              spacing: 0.115 * H, radius: 19%),
            curve.move((px, 0pt)),
            curve.line((W, 0pt)),
            curve.line((W, H)),
            curve.line((px - 0.075 * W, H)),
            curve.close(mode: "straight"),
          ))
        }
        // the subject pill on the left
        let tw = 0.44 * W
        let th = 0.66 * H
        let ty = 0.10 * H
        place(top + left, dx: 0.015 * W, dy: ty,
          rect(width: tw, height: th, radius: (left: 0.10 * H, right: th / 2),
            fill: gradient.linear((base.lighten(10%), 0%), (base, 60%),
              (base.darken(6%), 100%), angle: 90deg)))
        // dark fold at the very left of the pill
        place(top + left, dx: 0.015 * W, dy: ty,
          block(width: 0.045 * W, height: th, clip: true,
            rect(width: 0.045 * W, height: th,
              radius: (left: 0.10 * H, right: 0pt),
              fill: gradient.linear(base.darken(28%), base.darken(14%),
                angle: 0deg))))
        // gloss along the top of the pill
        place(top + left, dx: 0.02 * W, dy: ty + 0.06 * th,
          rect(width: tw * 0.96, height: th * 0.30,
            radius: (left: 0.08 * H, right: th * 0.15),
            fill: white.transparentize(72%)))
        // lettering
        if subject != none {
          place(top + left, dx: 0.015 * W, dy: ty,
            block(width: tw, height: th, align(center + horizon,
              text(fill: text-fill, size: text-size, weight: "bold",
                font: ("DejaVu Serif",),
                subject))))
        }
        if year != none {
          place(top + left, dx: tw + 0.06 * W, dy: 0pt,
            block(width: px - tw - 0.14 * W, height: H, align(center + horizon,
              text(fill: year-fill, size: text-size, weight: "bold",
                font: ("DejaVu Serif",),
                year))))
        }
        if body != none {
          place(top + left, dx: tw + 0.06 * W, dy: 0pt,
            block(width: px - tw - 0.14 * W, height: H, align(center + horizon,
              text(fill: year-fill, size: text-size, body))))
        }
      })
    })
  })
}

/// French alias for `matierebox`.
#let cartouche(..a) = matierebox(..a)
