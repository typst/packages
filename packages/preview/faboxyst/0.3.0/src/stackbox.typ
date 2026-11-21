// ===========================================================================
//  stackbox — a card sitting on 2–3 offset sheets.
//
//    #stackbox(title: [Stack], layers: 3)[…]
// ===========================================================================

#import "fabox.typ": is-rtl
#import "engine.typ": rounded-rect-pts
#import "antique.typ": vintage-pts

#import "theme.typ": theme-state

#let stackbox(
  body,
  title: none,
  colour: rgb("#1A4FA0"),
  fill: white,
  title-colour: white,
  back: (rgb("#D6DCE4"), rgb("#B8C0CC")),
  layers: 3,
  offset: 0.16cm,
  radius: 0.10cm,
  frame-weight: 0.85pt,
  inset: 0.36cm,
  width: 100%,
  direction: auto,
  vintage: false,      // main frame engraved with an elliptical nib
  vintage-pen: none,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let colour = if print-mode { black } else { colour }
  let fill = if print-mode { white } else { fill }
  let title-colour = if print-mode { black } else { title-colour }
  let back = if print-mode { (luma(224), luma(224)) } else { back }
  if print-mode { set text(fill: black) }

  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let n = calc.max(1, layers)
  let backs = if type(back) == array { back } else { (back,) }
  let title-body = if title == none { none } else {
    text(fill: title-colour, weight: "bold", size: 0.84em, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let bar-h = if title == none { 0pt } else { tm.height + 0.22cm }

  layout(avail => {
    let W0 = if type(width) == ratio { avail.width * width } else { width }
    let shift = offset * (n - 1)
    let card-w = W0 - shift
    let main = block(width: card-w - 2 * inset, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let mh = measure(main).height
    let H = bar-h + mh + 2 * inset

    block(width: W0, height: H + shift, {
      set text(dir: ltr)
      let sgn = if rtl { -1 } else { 1 }
      // back sheets, farthest first
      for k in range(n - 1).rev() {
        let i = k + 1
        let c = backs.at(calc.min(k, backs.len() - 1))
        let dx = if rtl { shift - offset * i } else { offset * i }
        place(top + left, dx: dx, dy: offset * i,
          box(width: card-w, height: H, fill: c, radius: radius,
            stroke: 0.6pt + c.darken(18%)))
      }
      let fx = if rtl { shift } else { 0pt }
      place(top + left, dx: fx,
        box(width: card-w, height: H, fill: fill, radius: radius,
          stroke: if vintage { none } else { frame-weight + colour }))
      if vintage {
        place(top + left, dx: fx,
          vintage-pts(rounded-rect-pts((0pt, 0pt), (card-w, H), radius: radius, n: 10),
            colour, frame-weight, vintage-pen: vintage-pen))
      }
      if title != none {
        place(top + left, dx: (fx) + title-offset-x, dy: title-offset-y, box(width: card-w, height: bar-h,
            fill: if print-mode { white } else { colour },
            stroke: if print-mode { (paint: black, thickness: frame-weight) } else { none },
            radius: (top: radius, bottom: 0pt),
            align(center + horizon, title-body)))
      }
      place(top + left, dx: fx + inset, dy: bar-h + inset, main)
    })
  })
}
