// ===========================================================================
//  faboxyst/swooshbox.typ — one sheared blue block + a plain white plate.
//
//  Construction (y-up):
//    TL (flush) → TR + (dx, dy) → BR + (dx, dy) → BL (flush) → TL
//    Rounded corners, fill blue. Then a white rounded rect, no offsets.
//
//    #swooshbox(title: [Example])[…]
//    #swooshbox(skew: 10pt)[…]
//    #swooshbox(tr: (5mm, 2mm), br: (-2mm, -5mm))[…]
// ===========================================================================

#import "fabox.typ": is-rtl

#let _cm(l) = if type(l) == length { l / 1cm } else { l }

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

#let _banner(w, h, fill) = {
  let n = h * 0.52
  polygon(
    fill: fill,
    (0pt, h * 0.5),
    (n, 0pt),
    (w - n, 0pt),
    (w, h * 0.5),
    (w - n, h),
    (n, h),
  )
}

/// Point sitting `r` away from `p` along `p → q`.
#let _inset(p, q, r) = {
  let dx = _cm(q.at(0) - p.at(0))
  let dy = _cm(q.at(1) - p.at(1))
  let len = calc.sqrt(dx * dx + dy * dy)
  if len < 1e-9 { p } else {
    let t = calc.min(_cm(r) / len, 0.42)
    (p.at(0) + (q.at(0) - p.at(0)) * t, p.at(1) + (q.at(1) - p.at(1)) * t)
  }
}

/// A filled quadrilateral with circular-ish rounded corners.
#let _round-quad(a, b, c, d, r, fill) = {
  let a-out = _inset(a, b, r)
  let b-in  = _inset(b, a, r)
  let b-out = _inset(b, c, r)
  let c-in  = _inset(c, b, r)
  let c-out = _inset(c, d, r)
  let d-in  = _inset(d, c, r)
  let d-out = _inset(d, a, r)
  let a-in  = _inset(a, d, r)
  curve(
    fill: fill,
    stroke: none,
    curve.move(a-out),
    curve.line(b-in),
    curve.quad(b, b-out),
    curve.line(c-in),
    curve.quad(c, c-out),
    curve.line(d-in),
    curve.quad(d, d-out),
    curve.line(a-in),
    curve.quad(a, a-out),
    curve.close(),
  )
}

/// Normalise a length or (x, y) pair. `auto` falls back to `fb`.
#let _xy(v, fb) = {
  if v == auto { fb }
  else if type(v) == array { (v.at(0), v.at(1)) }
  else { (v, v) }
}

#let swooshbox(
  body,
  title: none,
  colour: rgb("#1E54D6"),
  fill: white,
  tab-fill: none,
  title-colour: white,
  radius: 0.20cm,
  skew: 10pt,
  tr: auto,
  br: auto,
  flourish: true,
  tab-offset: 1.35cm,
  stroke: 0.65pt + rgb("#C4C8CE"),
  shadow: true,
  inset: 0.38cm,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  // Offsets are in y-up coordinates: +x right, +y up.
  //   tr: auto → (skew,  skew)   = out and up
  //   br: auto → (-skew, -skew)  = in  and down
  let sk = _xy(skew, (10pt, 10pt))
  let (trx, try) = _xy(tr, (sk.at(0), sk.at(1)))
  let (brx, bry) = _xy(br, (-sk.at(0), -sk.at(1)))
  let up = calc.max(0pt, try)
  let down = calc.max(0pt, -bry)
  let out = calc.max(0pt, trx, brx)

  let tab-paint = if tab-fill != none { tab-fill } else {
    gradient.linear(
      rgb("#0C9A8C"), rgb("#1788A6"),
      angle: if rtl { 180deg } else { 0deg },
    )
  }

  let title-body = if title == none { none } else {
    text(fill: title-colour, weight: "bold", size: 0.84em, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let curl-w = 0.52cm
  let tab-h = if title == none { 0pt } else { calc.max(0.46cm, tm.height + 0.20cm) }
  let tab-w = if title == none { 0pt } else {
    tm.width + (if flourish { 2 * curl-w + 0.22cm } else { 0.20cm }) + 0.36cm
  }
  let hang-t = calc.max(up + 0.04cm, if title == none { 0.10cm } else { tab-h * 0.58 })
  let hang-b = down + (if shadow { 0.16cm } else { 0.04cm })
  let trail = out + 0.08cm

  layout(avail => {
    let W0 = if type(width) == ratio { avail.width * width } else { width }
    let card-w = W0 - trail
    let cx = if rtl { trail } else { 0pt }
    let main = block(width: card-w - 2 * inset, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let bh = measure(main).height
    let H = bh + 2 * inset

    block(width: W0, height: H + hang-t + hang-b, {
      let y0 = hang-t

      // Corners of the WHITE plate, in the block's space.
      let tl = (cx, y0)
      let tr = (cx + card-w, y0)
      let br = (cx + card-w, y0 + H)
      let bl = (cx, y0 + H)

      // One sheared block (y-up offsets → Typst y-down):
      //   TL  flush with the white plate
      //   TR  += (trx, +try)   right and UP
      //   BR  += (brx,  bry)   usually left and DOWN
      //   BL  flush — coincides with the white BL
      let blue = if rtl {
        (
          (tl.at(0) - trx, tl.at(1) - try),
          tr,
          br,
          (bl.at(0) - brx, bl.at(1) - bry),
        )
      } else {
        (
          tl,
          (tr.at(0) + trx, tr.at(1) - try),
          (br.at(0) + brx, br.at(1) - bry),
          bl,
        )
      }

      if shadow {
        for k in range(6) {
          let t = (k + 1) / 6
          place(top + left, dx: 0.03cm * t, dy: 0.05cm * t,
            _round-quad(
              blue.at(0), blue.at(1), blue.at(2), blue.at(3),
              radius + 0.04cm,
              luma(90).transparentize(100% - 6% * (1 - t)),
            ))
        }
      }

      place(top + left,
        _round-quad(
          blue.at(0), blue.at(1), blue.at(2), blue.at(3),
          radius, colour,
        ))

      // 2. the white plate — same base size, no offsets
      place(top + left, dx: cx, dy: y0,
        box(
          width: card-w, height: H,
          fill: fill,
          radius: radius,
          stroke: stroke,
        ))

      place(top + left, dx: cx + inset, dy: y0 + inset, main)

      if title != none {
        let tab = box(width: tab-w, height: tab-h, {
          place(top + left, _banner(tab-w, tab-h, tab-paint))
          place(center + horizon, {
            set text(dir: ltr)
            if flourish {
              box(baseline: 40%, _curl(curl-w, tab-h * 0.72, title-colour))
              h(0.08cm)
            }
            title-body
            if flourish {
              h(0.08cm)
              box(baseline: 40%, _curl(curl-w, tab-h * 0.72, title-colour, flip: true))
            }
          })
        })
        let off = tab-offset
        place(
          top + (if rtl { right } else { left }),
          dx: if rtl { -(off + trail) } else { off },
          dy: y0 - tab-h * 0.52,
          tab)
      }
    })
  })
}
