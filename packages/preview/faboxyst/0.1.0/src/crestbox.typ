// ===========================================================================
//  faboxyst/crestbox.typ — octagonal plate scanned from the source.
//
//  Layers, back to front:
//    1. a hard drop-shadow (offset black octagon)
//    2. the black outer octagon + L-brackets at the four cuts
//    3. the beige fill
//    4. TWO clearly separated thin inner strokes (the green pair)
//    5. the crest sitting on the top rule
// ===========================================================================

#import "fabox.typ": is-rtl

#let _st(paint, w) = (paint: paint, thickness: w, cap: "square", join: "miter")

#let _octagon(w, h, cut) = {
  let c = calc.min(cut, w / 2 - 0.02cm, h / 2 - 0.02cm)
  (
    (c, 0pt),
    (w - c, 0pt),
    (w, c),
    (w, h - c),
    (w - c, h),
    (c, h),
    (0pt, h - c),
    (0pt, c),
  )
}

#let _curl(w, h, paint, flip: false) = {
  let body = box(width: w, height: h, {
    place(curve(
      stroke: (paint: paint, thickness: 0.95pt, cap: "round"),
      curve.move((0.04 * w, 0.62 * h)),
      curve.cubic((0.18 * w, 0.02 * h), (0.48 * w, 0.08 * h), (0.58 * w, 0.48 * h)),
      curve.cubic((0.68 * w, 0.88 * h), (0.88 * w, 0.58 * h), (0.98 * w, 0.32 * h)),
    ))
    place(curve(
      stroke: (paint: paint, thickness: 0.75pt, cap: "round"),
      curve.move((0.10 * w, 0.55 * h)),
      curve.cubic((0.22 * w, 0.22 * h), (0.38 * w, 0.28 * h), (0.42 * w, 0.50 * h)),
    ))
    place(dx: 0.06 * w, dy: 0.18 * h,
      circle(radius: 0.055 * h, fill: paint))
    place(dx: 0.78 * w, dy: 0.22 * h,
      circle(radius: 0.04 * h, fill: paint))
  })
  if flip { scale(x: -100%, reflow: true, body) } else { body }
}

/// An octagon (or just its stroke) placed at `(dx, dy)`.
#let _put-oct(dx, dy, w, h, cut, fill: none, stroke: none) = {
  place(top + left, dx: dx, dy: dy,
    polygon(fill: fill, stroke: stroke, .._octagon(w, h, cut)))
}

#let crestbox(
  body,
  title: none,
  colour: rgb("#1E5C4A"),
  outer: rgb("#141414"),
  fill: rgb("#D4B896"),
  title-colour: rgb("#1B3A8C"),
  cut: 0.30cm,
  weight: 0.95pt,
  outer-weight: 1.65pt,
  gap: 0.11cm,
  pair: 0.13cm,
  ear: 0.18cm,
  shadow: true,
  shadow-offset: (0.00cm, 0.11cm),
  flourish: true,
  inset: 0.40cm,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }

  let title-body = if title == none { none } else {
    text(fill: title-colour, weight: "bold", size: 0.95em, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let crest-h = if title == none { 0pt } else { calc.max(0.42cm, tm.height) + 0.10cm }

  let pad-l = 0.08cm
  let pad-r = 0.08cm
  let pad-t = (if title == none { 0.08cm } else { crest-h * 0.55 }) + 0.06cm
  let pad-b = 0.10cm

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let m = gap + 0.08cm
    let inner-w = W - 2 * m
    let main = block(width: inner-w - 2 * inset, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let bh = measure(main).height
    let H = bh + 2 * inset + 2 * m

    let iw = W - 2 * m
    let ih = H - 2 * m
    let ow = iw + 2 * gap
    let oh = ih + 2 * gap
    let ox = pad-l + m - gap
    let oy = pad-t + m - gap
    let ix = pad-l + m
    let iy = pad-t + m

    block(width: W + pad-l + pad-r, height: H + pad-t + pad-b, {
      // 1. single black outer octagon
      _put-oct(ox, oy, ow, oh, cut + gap,
        stroke: _st(outer, outer-weight))

      // 2. beige fill
      _put-oct(ix, iy, iw, ih, cut, fill: fill)

      // 3. two green hairlines with a WHITE gutter between them
      _put-oct(ix, iy, iw, ih, cut, stroke: _st(colour, weight))
      let woff = pair / 2 + weight / 2
      _put-oct(ix + woff, iy + woff, iw - 2 * woff, ih - 2 * woff,
        cut - woff, stroke: _st(white, pair))
      let ioff = pair + weight
      _put-oct(ix + ioff, iy + ioff, iw - 2 * ioff, ih - 2 * ioff,
        cut - ioff, stroke: _st(colour, weight))

      // 5. body
      place(top + left, dx: ix + inset, dy: iy + inset, main)

      // 6. crest
      if title != none {
        let fw = 1.15cm
        let fh = crest-h
        let crest = {
          set text(dir: ltr)
          if flourish {
            box(baseline: 40%, _curl(fw, fh, title-colour))
            h(0.18cm)
          }
          title-body
          if flourish {
            h(0.18cm)
            box(baseline: 40%, _curl(fw, fh, title-colour, flip: true))
          }
        }
        place(top + center, dy: iy - gap - tm.height * 0.55, {
          box(fill: fill, inset: (x: 0.14cm, y: 0.02cm), crest)
        })
      }
    })
  })
}

#let plate(body, title: [Example], ..a) = crestbox(body, title: title, ..a)
