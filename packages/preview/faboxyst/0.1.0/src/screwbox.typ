// ===========================================================================
//  faboxyst/screwbox.typ — a plate held by corner screws.
//
//    #screwbox(angle: 35deg)[all four, same tilt]
//    #screwbox(tl: 20deg, br: -40deg, tr: false, bl: false)[…]
// ===========================================================================

#import "fabox.typ": is-rtl

#let _screw(d, metal, slot, angle) = {
  let r = d / 2
  box(width: d, height: d, {
    place(center + horizon,
      circle(radius: r, fill: metal.darken(22%),
        stroke: 0.5pt + metal.darken(40%)))
    place(center + horizon,
      circle(radius: r * 0.78, fill: metal,
        stroke: 0.45pt + metal.darken(18%)))
    place(center + horizon, dy: -r * 0.18,
      circle(radius: r * 0.28, fill: metal.lighten(35%).transparentize(45%)))
    place(center + horizon,
      rotate(angle, reflow: false,
        box(width: d * 0.62, height: calc.max(0.7pt, d * 0.12),
          fill: slot, radius: 0.3pt)))
  })
}

#let _screw-on(v) = v != false
#let _screw-ang(v, fallback) = if type(v) == angle { v } else { fallback }

#let screwbox(
  body,
  tl: true,
  tr: true,
  bl: true,
  br: true,
  colour: rgb("#5C6670"),
  fill: rgb("#F4F6F8"),
  screw: rgb("#C5CCD3"),
  slot: rgb("#3A4046"),
  screw-size: 0.34cm,
  angle: 0deg,
  weight: 1.35pt,
  radius: 0.10cm,
  inset: 0.42cm,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let sd = screw-size
  let pad = calc.max(inset, sd + 0.16cm)

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let main = block(width: W - 2 * pad, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let mh = measure(main).height
    let H = mh + 2 * pad

    block(width: W, height: H, {
      set text(dir: ltr)
      // plate
      place(top + left,
        box(width: W, height: H, fill: fill, radius: radius,
          stroke: weight + colour))
      // inner hairline, like a bevel
      place(top + left, dx: 1.6pt, dy: 1.6pt,
        box(width: W - 3.2pt, height: H - 3.2pt, radius: calc.max(0pt, radius - 1pt),
          stroke: 0.5pt + colour.lighten(35%)))

      let m = 0.10cm
      if _screw-on(tl) {
        place(top + left, dx: m, dy: m,
          _screw(sd, screw, slot, _screw-ang(tl, angle)))
      }
      if _screw-on(tr) {
        place(top + left, dx: W - m - sd, dy: m,
          _screw(sd, screw, slot, _screw-ang(tr, angle)))
      }
      if _screw-on(bl) {
        place(top + left, dx: m, dy: H - m - sd,
          _screw(sd, screw, slot, _screw-ang(bl, angle)))
      }
      if _screw-on(br) {
        place(top + left, dx: W - m - sd, dy: H - m - sd,
          _screw(sd, screw, slot, _screw-ang(br, angle)))
      }

      place(top + left, dx: pad, dy: pad, main)
    })
  })
}
