// ===========================================================================
//  calloutbox — a speech / thought bubble with a movable tail.
//
//    #calloutbox(title: [Tip], tail: "sw")[…]
//    tail: "sw" | "se" | "nw" | "ne" | "start" | "end"
// ===========================================================================

#import "fabox.typ": is-rtl

#let _tail-tri(side, W, H, s, t) = {
  // (A on edge, tip, B on edge). The tip sits PAST A or B so the
  // triangle leans, like a speech-bubble pointer.
  let x = W * t
  if side == "sw" {
    ((x, H), (x - s * 0.22, H + s), (x + s * 0.88, H))
  } else if side == "se" {
    ((x - s * 0.88, H), (x + s * 0.22, H + s), (x, H))
  } else if side == "nw" {
    ((x, 0pt), (x - s * 0.22, -s), (x + s * 0.88, 0pt))
  } else {
    ((x - s * 0.88, 0pt), (x + s * 0.22, -s), (x, 0pt))
  }
}

#let calloutbox(
  body,
  title: none,
  colour: rgb("#1A4FA0"),
  fill: rgb("#F4F8FF"),
  title-colour: white,
  tail: "sw",
  tail-size: 0.42cm,
  tail-at: 0.18,
  radius: 0.18cm,
  weight: 1.35pt,
  inset: 0.34cm,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let side = if tail == "start" { if rtl { "se" } else { "sw" } }
             else if tail == "end" { if rtl { "sw" } else { "se" } }
             else { tail }
  let title-body = if title == none { none } else {
    text(fill: title-colour, weight: "bold", size: 0.84em, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let bar-h = if title == none { 0pt } else { tm.height + 0.20cm }
  let up = if side == "nw" or side == "ne" { tail-size } else { 0pt }
  let down = if side == "sw" or side == "se" { tail-size } else { 0pt }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let main = block(width: W - 2 * inset, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let mh = measure(main).height
    let H = bar-h + mh + 2 * inset

    block(width: W, height: H + up + down, {
      set text(dir: ltr)
      let y0 = up
      place(top + left, dy: y0,
        box(width: W, height: H, fill: fill, radius: radius,
          stroke: weight + colour))
      if title != none {
        place(top + left, dy: y0,
          box(width: W, height: bar-h, fill: colour,
            radius: (top: radius, bottom: 0pt),
            align(center + horizon, title-body)))
      }
      let t = if rtl { 1 - tail-at } else { tail-at }
      let (a, tip, b) = _tail-tri(side, W, H, tail-size, t)
      let sh(p) = (p.at(0), p.at(1) + y0)
      let A = sh(a)
      let Tip = sh(tip)
      let B = sh(b)

      // 1. fill the leaning triangle
      place(top + left, polygon(fill: fill, stroke: none, A, Tip, B))
      // 2. cover the bubble stroke on the chord — thick enough, exactly
      //    between the two attachment points (not the tip).
      let x0 = calc.min(A.at(0), B.at(0))
      let x1 = calc.max(A.at(0), B.at(0))
      let cover = weight + 1.2pt
      place(top + left, dx: x0, dy: A.at(1) - cover / 2,
        box(width: x1 - x0, height: cover, fill: fill))
      // 3. the two sides, on top
      let st = (paint: colour, thickness: weight, cap: "round", join: "round")
      place(top + left, line(start: A, end: Tip, stroke: st))
      place(top + left, line(start: B, end: Tip, stroke: st))

      place(top + left, dx: inset, dy: y0 + bar-h + inset, main)
    })
  })
}
