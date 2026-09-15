// ===========================================================================
//  plannerbox — punch-hole header + binder rings on the leading edge.
//
//    #plannerbox(title: [Week], number: [3])[…]
// ===========================================================================

#import "fabox.typ": is-rtl

#let _ring(width, radius, thickness, paint, rtl) = {
  let body = {
    line(length: width, angle: 0deg,
      stroke: (paint: paint, thickness: thickness, cap: "round"))
    place(top + left, dx: width - radius, dy: -radius,
      circle(radius: radius, stroke: none, fill: paint))
  }
  if rtl { scale(x: -100%, reflow: true, body) } else { body }
}

#let plannerbox(
  body,
  title: none,
  number: none,
  colour: rgb("#1A4FA0"),
  badge-fill: rgb("#E53935"),
  bar: black,
  hole: white,
  ring-colour: black,
  fill: white,
  title-colour: white,
  bar-height: 0.50cm,
  hole-radius: 0.12cm,
  holes: auto,
  rings: auto,
  ring-width: 0.55cm,
  ring-radius: 2.6pt,
  ring-thickness: 2.6pt,
  frame: true,
  frame-weight: 0.7pt,
  shadow: true,
  inset: 0.34cm,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let bh0 = bar-height
  let rw = ring-width
  let hang = rw / 2
  let spine = hang + ring-radius + 3pt

  let title-body = if title == none { none } else {
    text(fill: title-colour, weight: "bold", size: 0.80em, title)
  }
  let num-body = if number == none { none } else {
    text(fill: white, weight: "bold", size: 0.88em, dir: ltr, number)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let nm = if num-body == none { (width: 0pt, height: 0pt) }
           else { measure(num-body) }
  let tab-w = if title == none { 0pt } else { tm.width + 0.40cm }
  let badge-w = if number == none { 0pt } else { calc.max(bh0, nm.width + 0.24cm) }
  let hang-b = if shadow { 0.16cm } else { 0.04cm }

  layout(avail => {
    let W0 = if type(width) == ratio { avail.width * width } else { width }
    let paper-w = W0 - hang
    let main = block(width: paper-w - spine - inset, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let mh = measure(main).height
    let H = bh0 + mh + 2 * inset

    let overlap = if number == none { 0pt } else { badge-w * 0.28 }
    let cluster-w = tab-w + badge-w - overlap
    let tab-x-local = if rtl { paper-w - tab-w } else { 0pt }
    let badge-x-local = if rtl { tab-x-local - badge-w + overlap } else { tab-w - overlap }

    let inner-h = calc.max(0pt, H - bh0 - 6pt)
    let pitch = calc.max(2 * ring-radius, ring-thickness) + 3pt
    let n-fit = calc.max(1, int(inner-h / pitch))
    let n-r = if rings == auto { n-fit } else { calc.max(1, rings) }
    let row-h = inner-h / n-r
    let one = _ring(rw, ring-radius, ring-thickness, ring-colour, rtl)

    block(width: W0, height: H + hang-b, {
      set text(dir: ltr)
      let px = if rtl { 0pt } else { hang }

      if shadow {
        for k in range(5) {
          let t = (k + 1) / 5
          place(top + left, dx: px + 0.08cm, dy: H - 0.02cm + 0.03cm * t,
            box(width: paper-w - 0.16cm, height: 0.05cm + 0.03cm * t,
              fill: luma(80).transparentize(100% - 7% * (1 - t)), radius: 0.04cm))
        }
      }

      place(top + left, dx: px,
        box(width: paper-w, height: H, fill: fill,
          stroke: if frame { frame-weight + luma(180) } else { none }))

      place(top + left, dx: px, box(width: paper-w, height: bh0, fill: bar))

      if title != none {
        let tab-inset = if number == none { (x: 0.14cm) }
          else if rtl { (left: overlap + 0.08cm, right: 0.14cm, y: 0pt) }
          else { (right: overlap + 0.08cm, left: 0.14cm, y: 0pt) }
        place(top + left, dx: px + tab-x-local,
          box(width: tab-w, height: bh0, fill: colour, radius: bh0 / 2,
            inset: tab-inset, align(center + horizon, title-body)))
      }
      if number != none {
        place(top + left, dx: px + badge-x-local,
          box(width: badge-w, height: bh0, fill: badge-fill, radius: 50%,
            align(center + horizon, num-body)))
      }

      let hole-pad = hole-radius + 0.12cm
      let used = cluster-w + 0.16cm
      let span-x0 = if rtl { hole-pad } else { used }
      let span-x1 = if rtl { paper-w - used } else { paper-w - hole-pad }
      let span = calc.max(0pt, span-x1 - span-x0)
      let h-pitch = hole-radius * 2 + 0.26cm
      let n-h = if holes == auto { calc.max(0, int(span / h-pitch)) }
                else { calc.min(holes, calc.max(0, int(span / h-pitch))) }
      if n-h > 0 {
        let step = span / n-h
        for i in range(n-h) {
          let hx = px + span-x0 + step * (i + 0.5)
          place(top + left, dx: hx - hole-radius, dy: (bh0 - 2 * hole-radius) / 2,
            circle(radius: hole-radius, fill: hole, stroke: none))
        }
      }

      let rx = if rtl { paper-w - hang } else { 0pt }
      for i in range(n-r) {
        let y = bh0 + 4pt + row-h * (i + 0.5)
        place(top + left, dx: rx, dy: y, one)
      }

      let bx = if rtl { inset } else { hang + spine }
      place(top + left, dx: bx, dy: bh0 + inset, main)
    })
  })
}
