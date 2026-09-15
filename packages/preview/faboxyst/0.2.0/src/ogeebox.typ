// ===========================================================================
//  faboxyst/ogeebox.typ — the teal-and-gold banner family, after the
//  "28 lettres" plates: an ogee-pointed plaque with a double gold rule,
//  star rosettes and a numbered badge; a full-width frieze band with
//  girih line-work at both ends; and a scalloped letter medallion.
//
//    #ogeebox[LES 28 LETTRES AVEC LA KASRAH]
//    #ogeebox(light: true, badge: 1)[#medallion[ث] #medallion[ت]]
//    #frisebox[Observe • Prononce • Répète]
// ===========================================================================

#import "engine.typ": polygon-pts, star-pts

/// The plates' palette.
#let ogee-colours = (
  teal:  rgb("#0F6B5B"),   // deep banner green
  mint:  rgb("#DCE9DC"),   // the light banner ground
  gold:  rgb("#C9A227"),   // double rules, rosettes, girih
  badge: rgb("#8A5A2B"),   // the numbered octagon
  cream: rgb("#F7F3E8"),   // paper behind the bands
  ink:   rgb("#0F6B5B"),   // lettering on light grounds
)

// The pointed plaque silhouette: a rectangle whose ends gather into an
// ogee point at mid-height.
#let _ogee(W, H, m) = (
  (m, 0pt), (W - m, 0pt),
  (W - m, H * 0.12), (W - m * 0.35, H * 0.30), (W, H * 0.5),
  (W - m * 0.35, H * 0.70), (W - m, H * 0.88),
  (W - m, H), (m, H),
  (m, H * 0.88), (m * 0.35, H * 0.70), (0pt, H * 0.5),
  (m * 0.35, H * 0.30), (m, H * 0.12),
)

// An eight-point star rosette: star outline, tilted octagon, core dot.
#let rosette(
  size: 0.85cm,
  line: ogee-colours.gold,
  weight: 0.8pt,
) = block(width: size, height: size, {
  let r = size / 2
  let c = (r, r)
  place(top + left, polygon(stroke: weight + line,
    ..star-pts(c, r, r * 0.55, n: 8, start: 90)))
  place(top + left, polygon(stroke: (weight * 0.8) + line,
    ..polygon-pts(c, r * 0.62, n: 8, start: 112)))
  place(top + left, dx: r * 0.82, dy: r * 0.82,
    circle(radius: r * 0.18, fill: line))
})

// Girih line-work: nested diamonds and squares, clipped by the band.
#let girih(
  size: 3cm,
  line: ogee-colours.gold,
  weight: 0.55pt,
) = block(width: size, height: size, {
  let r = size / 2
  let c = (r, r)
  for k in (1.0, 0.78, 0.56, 0.34) {
    place(top + left, polygon(stroke: weight + line,
      ..polygon-pts(c, r * k, n: 4, start: 0)))
    place(top + left, polygon(stroke: weight + line,
      ..polygon-pts(c, r * k, n: 4, start: 45)))
  }
})

// A scalloped white medallion for a letter or a digit.
#let medallion(
  body,
  size: 1.7cm,
  fill: white,
  line: ogee-colours.gold,
  text-fill: ogee-colours.ink,
  text-size: 1.2em,
) = box(width: size, height: size, {
  let r = size / 2
  place(top + left, circle(radius: r, fill: fill, stroke: 1pt + line))
  for i in range(12) {
    let a = (30 * i) * 1deg
    place(top + left,
      dx: r + r * 0.92 * calc.cos(a) - r * 0.14,
      dy: r + r * 0.92 * calc.sin(a) - r * 0.14,
      circle(radius: r * 0.14, stroke: 0.7pt + line))
  }
  place(top + left,
    block(width: size, height: size,
      align(center + horizon,
        text(fill: text-fill, weight: "bold", size: text-size, body))))
})

/// The ogee-pointed banner: deep teal (or mint with `light: true`),
/// double gold rule, a star rosette at each side of the content and an
/// optional numbered octagon badge over the leading point.
#let ogeebox(
  body,
  fill: auto,
  line: auto,
  light: false,
  medallions: auto,    // auto = rosettes flanking the content
  badge: none,         // a number (or content) on the leading octagon
  text-fill: auto,
  inset: (x: 0.6cm, y: 0.42cm),
  width: 100%,
) = context {
  let oc = ogee-colours
  let bk = if fill == auto { if light { oc.mint } else { oc.teal } } else { fill }
  let ln = if line == auto { oc.gold } else { line }
  let tc = if text-fill == auto { if light { oc.ink } else { white } } else { text-fill }
  let ix = inset.at("x", default: 0.6cm)
  let iy = inset.at("y", default: 0.42cm)
  let content = text(fill: tc, weight: "bold", body)
  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let cm = measure(content)
    let H = calc.max(cm.height + 2 * iy, 1.5cm)
    let m = 0.5cm
    block(width: W, height: H, {
      // the plaque, double-ruled
      place(top + left, polygon(fill: bk, stroke: 1.3pt + ln,
        .._ogee(W, H, m)))
      let i = 0.09cm
      place(top + left, dx: i, dy: i,
        polygon(stroke: 0.7pt + ln, .._ogee(W - 2 * i, H - 2 * i, m - i)))
      // rosettes flanking the text
      if medallions != none and medallions != false {
        let rs = calc.min(0.9cm, H * 0.62)
        if badge == none {
          place(top + left, dx: m + 0.45cm, dy: (H - rs) / 2,
            rosette(size: rs, line: ln))
        }
        place(top + left, dx: W - m - 0.45cm - rs, dy: (H - rs) / 2,
          rosette(size: rs, line: ln))
      }
      // the numbered octagon on the leading point
      if badge != none {
        let bs = 1.05cm
        place(top + left, dx: 0.05cm, dy: (H - bs) / 2, {
          place(top + left, polygon(fill: oc.badge, stroke: 1pt + ln,
            ..polygon-pts((bs / 2, bs / 2), bs / 2, n: 8, start: 22)))
          place(top + left,
            block(width: bs, height: bs, align(center + horizon,
              text(fill: white, weight: "bold", size: 0.9em,
                str(badge)))))
        })
      }
      // centred content, clear of rosettes and points
      let side = m + (if medallions != none and medallions != false { 1.5cm } else { 0.3cm })
      place(top + left, dx: side, dy: iy,
        block(width: W - 2 * side, height: H - 2 * iy,
          align(center + horizon, content)))
    })
  })
}

/// French alias.
#let banniere(..a) = ogeebox(..a)

/// The full-width frieze band: teal ground, a gold rule along the top
/// and girih star-work climbing in from both ends.
#let frisebox(
  body,
  fill: auto,
  line: auto,
  text-fill: auto,
  inset: (x: 2.2cm, y: 0.4cm),
  width: 100%,
) = context {
  let oc = ogee-colours
  let bk = if fill == auto { oc.teal } else { fill }
  let ln = if line == auto { oc.gold } else { line }
  let tc = if text-fill == auto { white } else { text-fill }
  let ix = inset.at("x", default: 2.2cm)
  let iy = inset.at("y", default: 0.4cm)
  let content = text(fill: tc, weight: "bold", body)
  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let cm = measure(content)
    let H = calc.max(cm.height + 2 * iy, 1.3cm)
    block(width: W, height: H, clip: true, {
      place(top + left, rect(width: W, height: H, fill: bk))
      place(top + left, rect(width: W, height: 1pt, fill: ln))
      let gs = H * 1.9
      place(top + left, dx: -gs * 0.18, dy: (H - gs) / 2,
        girih(size: gs, line: ln))
      place(top + left, dx: W - gs * 0.82, dy: (H - gs) / 2,
        girih(size: gs, line: ln))
      place(top + left, dx: ix, dy: iy,
        block(width: W - 2 * ix, height: H - 2 * iy,
          align(center + horizon, content)))
    })
  })
}

/// French alias.
#let frise(..a) = frisebox(..a)
