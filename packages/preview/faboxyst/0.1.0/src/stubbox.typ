// ===========================================================================
//  stubbox — ticket with a coloured stub and a perforated tear line.
//
//    #stubbox(stub: [N° 12])[…]
//    #stubbox(stub: [رقم 12], stub-width: 1.6cm, dots: 7, dot: 1.6pt)[…]
// ===========================================================================

#import "fabox.typ": is-rtl

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
) = context {
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
          stroke: frame-weight + colour.darken(10%)))

      let sx = if rtl { W - sw } else { 0pt }
      place(top + left, dx: sx,
        box(width: sw, height: H, fill: colour,
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
