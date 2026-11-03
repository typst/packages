// ===========================================================================
//  faboxyst/ringbox.typ — a pad with binder rings on the leading edge.
//  Ported from a compact "line + bead" notebook.
//
//    #ringbox[…]
//    #ringbox(frame: true)[…]
//    #ringbox(rings: 6, colour: rgb("#1565C0"))[…]
// ===========================================================================

#import "fabox.typ": is-rtl

#let _ring(width, radius, thickness, paint, rtl) = {
  let body = {
    line(
      length: width,
      angle: 0deg,
      stroke: (paint: paint, thickness: thickness, cap: "round"),
    )
    place(
      top + left,
      dx: width - radius, dy: -radius,
      circle(radius: radius, stroke: none, fill: paint),
    )
  }
  if rtl { scale(x: -100%, reflow: true, body) } else { body }
}

#let ringbox(
  body,
  colour: black,
  fill: luma(252),
  rings: auto,
  ring-width: 0.8em,
  ring-radius: 3pt,
  ring-thickness: 3pt,
  ring-spacing: 3pt,
  radius: 2pt,
  frame: false,
  frame-colour: auto,
  frame-weight: 0.85pt,
  inset: 1em,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let rw = ring-width
  let rr = ring-radius
  let rt = ring-thickness
  let rs = ring-spacing
  let hang = rw / 2
  let spine = hang + rr + 3pt
  let fc = if frame-colour == auto { colour } else { frame-colour }
  let paper-stroke = if frame == false { none }
                    else if frame == true { frame-weight + fc }
                    else { frame }

  layout(avail => {
    let W0 = if type(width) == ratio { avail.width * width } else { width }
    let paper-w = W0 - hang
    let body-w = paper-w - spine - (if type(inset) == dictionary {
      inset.at("rest", default: 1em)
    } else { inset })
    let pads = if type(inset) == dictionary { inset } else {
      if rtl { (right: spine, rest: inset) } else { (left: spine, rest: inset) }
    }
    let main = block(width: paper-w, {
      set text(dir: body-dir)
      set align(start)
      pad(..pads, body)
    })
    let bh = measure(main).height
    let H = bh

    let inner-h = calc.max(0pt, H - rs * 2)
    let pitch = calc.max(2 * rr, rt) + rs
    let n-fit = calc.max(1, int(inner-h / pitch))
    let n = if rings == auto { n-fit } else { calc.max(1, rings) }
    let row-h = inner-h / n
    let one = _ring(rw, rr, rt, colour, rtl)

    block(width: W0, height: H, {
      set text(dir: ltr)
      let px = if rtl { 0pt } else { hang }
      place(top + left, dx: px,
        box(width: paper-w, height: H, fill: fill, radius: radius,
          stroke: paper-stroke, main))
      let rx = if rtl { paper-w - hang } else { 0pt }
      for i in range(n) {
        let y = rs + row-h * (i + 0.5)
        place(top + left, dx: rx, dy: y, one)
      }
    })
  })
}
