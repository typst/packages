// ===========================================================================
//  tapebox — a card sealed at the top with a strip of washi tape.
//
//    #tapebox(title: [Note])[…]
//    #tapebox(pattern: "gingham")[…]
// ===========================================================================

#import "fabox.typ": is-rtl
#import "engine.typ": rounded-rect-pts
#import "antique.typ": vintage-pts

#import "theme.typ": theme-state

#let _gingham(w, h, a, b) = {
  let step = 0.16cm
  let cols = calc.max(2, int(w / step))
  let rows = calc.max(2, int(h / step))
  let cw = w / cols
  let rh = h / rows
  for i in range(cols) {
    for j in range(rows) {
      let even = calc.rem(i + j, 2) == 0
      place(top + left, dx: i * cw, dy: j * rh,
        box(width: cw + 0.01cm, height: rh + 0.01cm,
          fill: if even { a } else { b }))
    }
  }
}

#let tapebox(
  body,
  title: none,
  colour: rgb("#E07A5F"),
  tape-b: rgb("#F2CC8F"),
  fill: rgb("#FFFEF8"),
  title-colour: rgb("#4A2C1A"),
  pattern: "solid",
  tape-height: 0.46cm,
  tape-overhang: 0.18cm,
  tilt: -1.2deg,
  radius: 0.08cm,
  frame-weight: 0.7pt,
  inset: 0.36cm,
  top-inset: auto,     // clear space between the card top and the text (auto: below the tilted tape)
  width: 100%,
  direction: auto,
  vintage: false,      // main frame engraved with an elliptical nib
  vintage-pen: none,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let colour = if print-mode { white } else { colour }
  let tape-b = if print-mode { luma(224) } else { tape-b }
  let fill = if print-mode { white } else { fill }
  let title-colour = if print-mode { black } else { title-colour }
  if print-mode { set text(fill: black) }

  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let title-body = if title == none { none } else {
    text(fill: title-colour, weight: "bold", size: 0.82em, title)
  }
  let th = tape-height
  let over = tape-overhang

  layout(avail => {
    // a relative width is the width of the whole piece, tape ends included
    let W = if type(width) == ratio { avail.width * width - 2 * (over + 0.14cm) } else { width }
    // the tape hangs th*0.55 into the card; its tilt lowers one end by
    // half the tape width times sin(tilt). The text must start below that.
    let tape-low = th * 0.55 + (W + 2 * over) / 2 * calc.sin(calc.abs(tilt)) + 0.20cm
    let pad-top = if top-inset == auto { calc.max(inset, tape-low) } else { top-inset }
    let main = block(width: W - 2 * inset, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let mh = measure(main).height
    let H = mh + inset + pad-top
    let hang-t = th * 0.72 + 0.16cm
    let hang-x = over + 0.14cm

    block(width: W + 2 * hang-x, height: H + hang-t + 0.10cm, {
      set text(dir: ltr)
      let x0 = hang-x
      let y0 = hang-t
      place(top + left, dx: x0, dy: y0,
        box(width: W, height: H, fill: fill, radius: radius,
          stroke: if vintage { none } else {
            frame-weight + (if print-mode { black } else { luma(175) })
          }))
      if vintage {
        place(top + left, dx: x0, dy: y0,
          vintage-pts(rounded-rect-pts((0pt, 0pt), (W, H), radius: radius, n: 10),
            if print-mode { black } else { luma(175) }, frame-weight,
            vintage-pen: vintage-pen))
      }
      place(top + left, dx: x0 + inset, dy: y0 + pad-top, main)

      let tape-w = W + 2 * over
      let tape = box(width: tape-w, height: th, clip: true, {
        if pattern == "gingham" {
          _gingham(tape-w, th, colour, tape-b)
        } else {
          box(width: tape-w, height: th, fill: colour)
        }
        if title != none {
          place(center + horizon, dx: title-offset-x, dy: title-offset-y, title-body)
        }
      })
      let ang = if rtl { -tilt } else { tilt }
      place(top + left, dx: x0 - over, dy: y0 - th * 0.45,
        rotate(ang, origin: center + horizon, reflow: false, tape))
    })
  })
}
