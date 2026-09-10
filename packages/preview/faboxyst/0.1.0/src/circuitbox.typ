// ===========================================================================
//  faboxyst/circuitbox.typ — double-line rounded frame whose top
//  breaks into two circuit-like stepped rails, title sitting in the gap.
//
//    #circuitbox(title: [Example])[…]
//    #circuitbox(gap: 3pt)[…]
// ===========================================================================

#import "fabox.typ": is-rtl

#let _curl(w, h, paint, flip: false) = {
  let body = box(width: w, height: h, {
    place(curve(
      stroke: (paint: paint, thickness: 0.75pt, cap: "round"),
      curve.move((0.06 * w, 0.68 * h)),
      curve.cubic((0.22 * w, 0.04 * h), (0.50 * w, 0.10 * h), (0.62 * w, 0.50 * h)),
      curve.cubic((0.74 * w, 0.88 * h), (0.88 * w, 0.52 * h), (0.98 * w, 0.28 * h)),
    ))
    place(dx: 0.10 * w, dy: 0.22 * h,
      circle(radius: 0.055 * h, fill: paint))
  })
  if flip { scale(x: -100%, reflow: true, body) } else { body }
}

/// Open path: left rail-cap → around the box → right rail-cap.
/// Origin is the top-left of the white plate; rails sit at y = -step.
#let _trace(W, H, r, s, sr, xs-l, xs-r, g0, g1) = {
  (
    curve.move((g0, -s)),
    curve.line((xs-l + sr, -s)),
    curve.cubic((xs-l + sr * 0.15, -s), (xs-l - sr * 0.15, 0pt), (xs-l - sr, 0pt)),
    curve.line((r, 0pt)),
    curve.quad((0pt, 0pt), (0pt, r)),
    curve.line((0pt, H - r)),
    curve.quad((0pt, H), (r, H)),
    curve.line((W - r, H)),
    curve.quad((W, H), (W, H - r)),
    curve.line((W, r)),
    curve.quad((W, 0pt), (W - r, 0pt)),
    curve.line((xs-r + sr, 0pt)),
    curve.cubic((xs-r + sr * 0.15, 0pt), (xs-r - sr * 0.15, -s), (xs-r - sr, -s)),
    curve.line((g1, -s)),
  )
}

#let _stroke-trace(parts, paint, w) = curve(
  stroke: (paint: paint, thickness: w, cap: "round", join: "round"),
  ..parts,
)

#let _fill-trace(parts, paint) = curve(
  fill: paint,
  stroke: none,
  ..parts,
)

#let circuitbox(
  body,
  title: none,
  colour: rgb("#1B4F9C"),
  fill: white,
  title-colour: auto,
  radius: 0.28cm,
  step: 0.26cm,
  rail: 1.35cm,
  weight: 1.05pt,
  pair: 1.55pt,
  gap: auto,
  flourish: true,
  inset: 0.38cm,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let tc = if title-colour == auto { colour } else { title-colour }

  let title-body = if title == none { none } else {
    text(fill: tc, weight: "bold", size: 0.86em, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let curl-w = 0.50cm
  let title-w = if title == none { 0pt } else {
    tm.width + (if flourish { 2 * curl-w + 0.18cm } else { 0pt }) + 0.16cm
  }
  let gap-w = if title == none { 0pt } else { title-w + 0.28cm }
  let gutter = if gap == auto { pair } else { gap }
  let frame-w = 2 * weight + gutter
  let hang-t = if title == none { frame-w / 2 + 0.04cm }
               else { step + frame-w / 2 + 0.06cm }
  let hang-b = frame-w / 2 + 0.04cm
  let hang-x = frame-w / 2 + 0.04cm

  layout(avail => {
    let W0 = if type(width) == ratio { avail.width * width } else { width }
    let card-w = W0 - 2 * hang-x
    let main = block(width: card-w - 2 * inset, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let bh = measure(main).height
    let H = bh + 2 * inset
    let r = calc.min(radius, H / 2, card-w / 2)
    let s = step
    let sr = calc.min(s * 1.15, 0.22cm)

    let g0 = (card-w - gap-w) / 2
    let g1 = (card-w + gap-w) / 2
    let room-l = g0 - r - 2 * sr
    let room-r = card-w - r - 2 * sr - g1
    let rail-l = calc.min(rail, calc.max(0.28cm, room-l))
    let rail-r = calc.min(rail, calc.max(0.28cm, room-r))
    let xs-l = g0 - rail-l - sr
    let xs-r = g1 + rail-r + sr

    let open-parts = if title == none {
      (
        curve.move((r, 0pt)),
        curve.line((card-w - r, 0pt)),
        curve.quad((card-w, 0pt), (card-w, r)),
        curve.line((card-w, H - r)),
        curve.quad((card-w, H), (card-w - r, H)),
        curve.line((r, H)),
        curve.quad((0pt, H), (0pt, H - r)),
        curve.line((0pt, r)),
        curve.quad((0pt, 0pt), (r, 0pt)),
        curve.close(),
      )
    } else {
      _trace(card-w, H, r, s, sr, xs-l, xs-r, g0, g1)
    }
    // Close across the title gap so the fill follows the rails up.
    let fill-parts = if title == none { open-parts } else {
      open-parts + (curve.line((g0, -s)), curve.close())
    }

    block(width: W0, height: H + hang-t + hang-b, {
      let y0 = hang-t
      let x0 = hang-x

      // fill follows the rails, not just the rectangle
      place(top + left, dx: x0, dy: y0,
        _fill-trace(fill-parts, fill))

      // double stroke: fat colour, then a thin fill-coloured core
      place(top + left, dx: x0, dy: y0,
        _stroke-trace(open-parts, colour, frame-w))
      place(top + left, dx: x0, dy: y0,
        _stroke-trace(open-parts, fill, gutter))

      place(top + left, dx: x0 + inset, dy: y0 + inset, main)

      if title != none {
        let tab = {
          set text(dir: ltr)
          if flourish {
            box(baseline: 40%, _curl(curl-w, step + 0.12cm, tc))
            h(0.08cm)
          }
          title-body
          if flourish {
            h(0.08cm)
            box(baseline: 40%, _curl(curl-w, step + 0.12cm, tc, flip: true))
          }
        }
        place(
          top + center,
          dy: y0 - s - tm.height / 2 + 0.02cm,
          tab)
      }
    })
  })
}
