// ===========================================================================
//  faboxyst/keybox.typ — picture-frame box: an inset colour band,
//  Greek-key corners, and connecting rules. Ported from a page background.
//
//    #keybox[…]
//    #keybox(sz: 14pt, colour: rgb("#1A237E"))[…]
// ===========================================================================

#import "fabox.typ": is-rtl

/// One Greek-key corner. `angle` turns it onto TL / TR / BR / BL.
#let _key-corner(angle, sz, paint, weight) = {
  let o = sz + 3pt
  let ps = ((sz, o), (sz, 0pt), (0pt, 0pt), (0pt, sz), (o, sz), (o, 0pt))
  rotate(angle, reflow: true, curve(
    stroke: (paint: paint, thickness: weight, cap: "square", join: "miter"),
    curve.move((0pt, o)),
    ..ps.map(p => curve.line(p)),
  ))
}

#let _hrule(paint, weight) = layout(size => {
  line(
    length: size.width,
    angle: 0deg,
    stroke: (paint: paint, thickness: weight, cap: "square"),
  )
})

#let _vrule(paint, weight) = layout(size => {
  line(
    length: size.height,
    angle: 90deg,
    stroke: (paint: paint, thickness: weight, cap: "square"),
  )
})

#let keybox(
  body,
  colour: rgb(0, 0, 128),
  frame: black,
  fill: white,
  sz: 10pt,
  band: auto,
  band-inset: 5pt,
  weight: 1pt,
  inset: auto,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let band-w = if band == auto { calc.max(1pt, sz - 5pt) } else { band }
  let pad = if inset == auto { sz + 8pt } else { inset }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let main = block(width: W - 2 * pad, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let bh = measure(main).height
    let H = bh + 2 * pad

    block(width: W, height: H, {
      set text(dir: ltr)

      if fill != none {
        place(top + left, box(width: W, height: H, fill: fill))
      }

      // inset colour band
      place(top + left, dx: band-inset, dy: band-inset,
        box(
          width: W - 2 * band-inset,
          height: H - 2 * band-inset,
          stroke: band-w + colour,
        ))

      // corners + connecting rules
      place(top + left, box(width: W, height: H,
        grid(
          columns: (auto, 1fr, auto),
          rows: (auto, 1fr, auto),
          _key-corner(0deg, sz, frame, weight),
          align(top, _hrule(frame, weight)),
          _key-corner(90deg, sz, frame, weight),
          _vrule(frame, weight),
          [],
          align(right, _vrule(frame, weight)),
          _key-corner(270deg, sz, frame, weight),
          align(bottom, _hrule(frame, weight)),
          _key-corner(180deg, sz, frame, weight),
        )))

      place(top + left, dx: pad, dy: pad, main)
    })
  })
}
