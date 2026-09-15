// ===========================================================================
//  faboxyst/punchbox.typ — punched header bar, title tab + number
//  badge, green side rules, soft bottom shadow.
//
//    #punchbox(title: [Example], number: [1])[…]
// ===========================================================================

#import "fabox.typ": is-rtl

#let punchbox(
  body,
  title: none,
  number: none,
  colour: rgb("#1A4FA0"),
  badge-fill: rgb("#E53935"),
  bar: black,
  hole: white,
  side: rgb("#7CB342"),
  fill: white,
  title-colour: white,
  bar-height: 0.54cm,
  hole-radius: 0.135cm,
  holes: auto,
  side-weight: 1.6pt,
  shadow: true,
  inset: 0.38cm,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let bh0 = bar-height

  let title-body = if title == none { none } else {
    text(fill: title-colour, weight: "bold", size: 0.82em, title)
  }
  let num-body = if number == none { none } else {
    text(fill: white, weight: "bold", size: 0.92em, dir: ltr, number)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let nm = if num-body == none { (width: 0pt, height: 0pt) }
           else { measure(num-body) }
  let tab-h = bh0
  let badge-d = bh0
  let tab-w = if title == none { 0pt } else { tm.width + 0.44cm }
  let badge-w = if number == none { 0pt } else { calc.max(badge-d, nm.width + 0.28cm) }
  let hang-b = if shadow { 0.18cm } else { 0.04cm }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let main = block(width: W - 2 * inset - 2 * side-weight, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let mh = measure(main).height
    let H = bh0 + mh + 2 * inset

    block(width: W, height: H + hang-b, {
      set text(dir: ltr)

      if shadow {
        for k in range(5) {
          let t = (k + 1) / 5
          place(top + left, dx: 0.08cm, dy: H - 0.02cm + 0.03cm * t,
            box(
              width: W - 0.16cm,
              height: 0.06cm + 0.04cm * t,
              fill: luma(80).transparentize(100% - 8% * (1 - t)),
              radius: 0.04cm,
            ))
        }
      }

      // paper
      place(top + left, box(width: W, height: H, fill: fill))

      // green side rules — from under the bar to the bottom
      place(top + left, dx: 0pt, dy: bh0,
        line(length: H - bh0, angle: 90deg,
          stroke: (paint: side, thickness: side-weight, cap: "butt")))
      place(top + left, dx: W, dy: bh0,
        line(length: H - bh0, angle: 90deg,
          stroke: (paint: side, thickness: side-weight, cap: "butt")))

      // punch bar
      place(top + left, box(width: W, height: bh0, fill: bar))

      // title tab on the OUTER end, badge on the INNER end (toward the holes).
      // The title is padded on the badge side so RTL Arabic never sits under it.
      let overlap = if number == none { 0pt } else { badge-w * 0.28 }
      let cluster-w = tab-w + badge-w - overlap
      let tab-x = if rtl { W - tab-w } else { 0pt }
      let badge-x = if rtl { tab-x - badge-w + overlap } else { tab-w - overlap }

      if title != none {
        let tab-inset = if number == none {
          (x: 0.16cm)
        } else if rtl {
          (left: overlap + 0.10cm, right: 0.16cm, y: 0pt)
        } else {
          (right: overlap + 0.10cm, left: 0.16cm, y: 0pt)
        }
        place(top + left, dx: tab-x, dy: 0pt,
          box(
            width: tab-w,
            height: tab-h,
            fill: colour,
            radius: tab-h / 2,
            inset: tab-inset,
            align(center + horizon, title-body),
          ))
      }
      if number != none {
        place(top + left, dx: badge-x, dy: 0pt,
          box(
            width: badge-w, height: badge-d,
            fill: badge-fill, radius: 50%,
            align(center + horizon, num-body),
          ))
      }

      // holes in the remaining bar
      let hole-pad = hole-radius + 0.14cm
      let used = cluster-w + 0.18cm
      let span-x0 = if rtl { hole-pad } else { used }
      let span-x1 = if rtl { W - used } else { W - hole-pad }
      let span = calc.max(0pt, span-x1 - span-x0)
      let pitch = hole-radius * 2 + 0.28cm
      let n-fit = calc.max(0, int(span / pitch))
      let n = if holes == auto { n-fit } else { calc.min(holes, n-fit) }
      if n > 0 {
        let step = span / n
        for i in range(n) {
          let hx = span-x0 + step * (i + 0.5)
          place(top + left, dx: hx - hole-radius, dy: (bh0 - 2 * hole-radius) / 2,
            circle(radius: hole-radius, fill: hole, stroke: none))
        }
      }

      place(top + left, dx: inset + side-weight, dy: bh0 + inset, main)
    })
  })
}
