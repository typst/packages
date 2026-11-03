// ===========================================================================
//  faboxyst/ribbonbox.typ — yellow plate, thick blue band, white
//  gutter, thin inner blue, corner chevrons, pink title tab, soft shadow.
//
//    #ribbonbox(title: [Example])[…]
// ===========================================================================

#import "fabox.typ": is-rtl
#import "engine.typ": rounded-rect-pts
#import "antique.typ": vintage-pts

#import "theme.typ": theme-state

#let _curl(w, h, paint, flip: false) = {
  let body = box(width: w, height: h, {
    place(curve(
      stroke: (paint: paint, thickness: 0.85pt, cap: "round"),
      curve.move((0.04 * w, 0.62 * h)),
      curve.cubic((0.18 * w, 0.02 * h), (0.48 * w, 0.08 * h), (0.58 * w, 0.48 * h)),
      curve.cubic((0.68 * w, 0.88 * h), (0.88 * w, 0.58 * h), (0.98 * w, 0.32 * h)),
    ))
    place(dx: 0.08 * w, dy: 0.20 * h,
      circle(radius: 0.05 * h, fill: paint))
  })
  if flip { scale(x: -100%, reflow: true, body) } else { body }
}

/// An L drawn with physical start/end points. `hx`/`vy` are +1 or −1
/// (right/down vs left/up). Never uses `line(length:, angle:)` — those
/// follow `text.dir` and flip in RTL.
#let _corner-ell(size, stroke, hx, vy, vintage: false, vintage-pen: none) = {
  if vintage {
    place(top + left, vintage-pts(((0pt, 0pt), (hx * size, 0pt)),
      stroke.paint, stroke.thickness, closed: false, vintage-pen: vintage-pen))
    place(top + left, vintage-pts(((0pt, 0pt), (0pt, vy * size)),
      stroke.paint, stroke.thickness, closed: false, vintage-pen: vintage-pen))
  } else {
    place(top + left, line(start: (0pt, 0pt), end: (hx * size, 0pt), stroke: stroke))
    place(top + left, line(start: (0pt, 0pt), end: (0pt, vy * size), stroke: stroke))
  }
}

#let ribbonbox(
  body,
  title: none,
  colour: rgb("#1A3580"),
  fill: rgb("#F6D56A"),
  tab-fill: rgb("#F3C2D4"),
  title-colour: rgb("#5A2A6A"),
  radius: 0.10cm,
  band: 0.20cm,
  weight: 1.05pt,
  pair: 0.07cm,
  chevron: true,
  chevron-colour: rgb("#F4F0E4"),
  chevron-size: 0.22cm,
  shadow: true,
  flourish: true,
  tab-offset: 0.85cm,
  inset: 0.38cm,
  width: 100%,
  direction: auto,
  vintage: false,      // the inner rule and chevrons engraved with a nib
  vintage-pen: none,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let colour = if print-mode { white } else { colour }
  let fill = if print-mode { white } else { fill }
  let tab-fill = if print-mode { white } else { tab-fill }
  let title-colour = if print-mode { black } else { title-colour }
  let chevron-colour = if print-mode { black } else { chevron-colour }
  if print-mode { set text(fill: black) }

  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }

  let title-body = if title == none { none } else {
    text(fill: title-colour, weight: "bold", size: 0.88em, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let tab-h = if title == none { 0pt } else { tm.height + 0.22cm }
  let hang-t = if title == none { 0.08cm } else { tab-h * 0.55 }
  let hang-b = if shadow { 0.22cm } else { 0.06cm }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let frame = band + pair + weight
    let inner-w = W - 2 * frame
    let main = block(width: inner-w - 2 * inset, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let bh = measure(main).height
    let H = bh + 2 * inset + 2 * frame

    block(width: W, height: H + hang-t + hang-b, {
      let y0 = hang-t

      // --- soft drop shadow ----------------------------------------------
      if shadow {
        for k in range(6) {
          let t = (k + 1) / 6
          place(top + left, dx: 0.04cm * t, dy: y0 + 0.07cm * t,
            box(
              width: W, height: H,
              fill: luma(80).transparentize(100% - 7% * (1 - t)),
              radius: radius + 0.04cm,
            ))
        }
      }

      // --- blue band (outermost fill) ------------------------------------
      place(top + left, dy: y0,
        box(width: W, height: H, fill: colour, radius: radius,
          stroke: if print-mode { 0.9pt + black } else { none }))

      // --- white gutter --------------------------------------------------
      place(top + left, dx: band, dy: y0 + band,
        box(
          width: W - 2 * band, height: H - 2 * band,
          fill: white,
          radius: calc.max(0pt, radius - band * 0.4),
        ))

      // --- yellow plate + thin inner blue --------------------------------
      let inn = band + pair
      let inn-rad = calc.max(0pt, radius - inn * 0.4)
      place(top + left, dx: inn, dy: y0 + inn,
        box(
          width: W - 2 * inn, height: H - 2 * inn,
          fill: fill,
          radius: inn-rad,
          stroke: if vintage { none } else {
            weight + (if print-mode { black } else { colour })
          },
        ))
      if vintage {
        place(top + left, dx: inn, dy: y0 + inn,
          vintage-pts(rounded-rect-pts((0pt, 0pt), (W - 2 * inn, H - 2 * inn),
            radius: inn-rad, n: 8),
            if print-mode { black } else { colour }, weight,
            vintage-pen: vintage-pen))
      }

      // --- corner chevrons: physical start/end, forced LTR ---------------
      // `line(length:, angle:)` mirrors with text.dir — left Ls flip
      // outward in RTL. start/end + place(top + left) stay physical.
      if chevron {
        set text(dir: ltr)
        let cs = chevron-size
        let st = (paint: chevron-colour, thickness: 1.35pt, cap: "square", join: "miter")
        let inset-c = band * 0.28
        // Each L opens toward the INTERIOR of the card.
        place(top + left, dx: inset-c, dy: y0 + inset-c,
          _corner-ell(cs, st, 1, 1, vintage: vintage, vintage-pen: vintage-pen))
        place(top + left, dx: W - inset-c, dy: y0 + inset-c,
          _corner-ell(cs, st, -1, 1, vintage: vintage, vintage-pen: vintage-pen))
        place(top + left, dx: inset-c, dy: y0 + H - inset-c,
          _corner-ell(cs, st, 1, -1, vintage: vintage, vintage-pen: vintage-pen))
        place(top + left, dx: W - inset-c, dy: y0 + H - inset-c,
          _corner-ell(cs, st, -1, -1, vintage: vintage, vintage-pen: vintage-pen))
      }

      // --- body ----------------------------------------------------------
      place(top + left, dx: frame + inset, dy: y0 + frame + inset, main)

      // --- pink title tab, astride the top band --------------------------
      if title != none {
        let fw = 0.95cm
        let fh = tab-h
        let tab = box(
          fill: tab-fill,
          // same rounding as the card itself, so the tab reads as part of it
          radius: calc.min(radius, tab-h * 0.45),
          stroke: weight + (if print-mode { black } else { colour }),
          inset: (x: 0.26cm, y: 0.08cm),
          {
            set text(dir: ltr)
            if flourish {
              box(baseline: 40%, _curl(fw, fh, title-colour))
              h(0.12cm)
            }
            title-body
            if flourish {
              h(0.12cm)
              box(baseline: 40%, _curl(fw, fh, title-colour, flip: true))
            }
          })
        let off = tab-offset
        place(
          top + (if rtl { right } else { left }),
          dx: if rtl { -off } else { off },
          dy: y0 - tab-h * 0.48,
          tab)
      }
    })
  })
}
