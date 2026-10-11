// ===========================================================================
//  stubbox — ticket with a coloured stub and a perforated tear line.
//
//    #stubbox(stub: [N° 12])[…]
//    #stubbox(stub: [رقم 12], stub-width: 1.6cm, dots: 7, dot: 1.6pt)[…]
// ===========================================================================

#import "fabox.typ": is-rtl
#import "engine.typ": rounded-rect-pts
#import "antique.typ": vintage-pts

#import "theme.typ": theme-state

#let stubbox(
  body,
  stub: none,
  colour: rgb("#1A4FA0"),
  stub-colour: white,
  fill: white,
  radius: 0.10cm,
  stub-width: 1.35cm,
  dots: 11,
  dot: 1.1pt,
  frame-weight: 0.9pt,
  shadow: true,
  inset: 0.34cm,
  width: 100%,
  direction: auto,
  vintage: false,      // main frame engraved with an elliptical nib
  vintage-pen: none,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let colour = if print-mode { black } else { colour }
  let stub-colour = if print-mode { black } else { stub-colour }
  let fill = if print-mode { white } else { fill }
  if print-mode { set text(fill: black) }

  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let sw = stub-width
  let hang-b = if shadow { 0.16cm } else { 0.04cm }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let main = block(width: W - sw - 2 * inset, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let mh = measure(main).height
    let H = calc.max(mh + 2 * inset, 1.6cm)

    block(width: W, height: H + hang-b, {
      set text(dir: ltr)
      if shadow {
        for k in range(5) {
          let t = (k + 1) / 5
          place(top + left, dx: 0.05cm * t, dy: 0.05cm * t,
            box(width: W, height: H,
              fill: luma(90).transparentize(100% - 6% * (1 - t)),
              radius: radius))
        }
      }
      place(top + left,
        box(width: W, height: H, fill: fill, radius: radius,
          stroke: if vintage { none } else { frame-weight + colour.darken(10%) }))
      if vintage {
        place(top + left,
          vintage-pts(rounded-rect-pts((0pt, 0pt), (W, H), radius: radius, n: 10),
            colour.darken(10%), frame-weight, vintage-pen: vintage-pen))
      }

      let sx = if rtl { W - sw } else { 0pt }
      place(top + left, dx: sx,
        box(width: sw, height: H,
          fill: if print-mode { luma(224) } else { colour },
          stroke: if print-mode { (paint: black, thickness: frame-weight) } else { none },
          radius: if rtl { (top-right: radius, bottom-right: radius, rest: 0pt) }
                  else { (top-left: radius, bottom-left: radius, rest: 0pt) }))

      if stub != none {
        // Always LTR + Western digits (lang: en). Rotate in place without
        // reflow — reflow + RTL was collapsing Arabic / Indic numerals.
        let label = text(
          fill: stub-colour,
          weight: "bold",
          size: 0.88em,
          dir: ltr,
          lang: "en",
          stub,
        )
        place(top + left, dx: sx,
          box(width: sw, height: H, clip: true,
            place(center + horizon,
              rotate(90deg, reflow: false, label))))
      }

      let perf-x = if rtl { W - sw } else { sw }
      let n = calc.max(0, dots)
      let gap = H / (n + 1)
      let dr = dot
      for i in range(1, n + 1) {
        place(top + left, dx: perf-x - dr, dy: gap * i - dr,
          circle(radius: dr, fill: luma(230),
            stroke: 0.5pt + colour.darken(5%)))
      }

      let bx = if rtl { inset } else { sw + inset }
      place(top + left, dx: bx, dy: inset, main)
    })
  })
}
