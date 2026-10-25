// Shared watermark painter. Used inside boxes (behind the body) and as
// `#with-watermark` around any content.
//
//   watermark          content (or none)
//   watermark-angle    rotation; default −18deg
//   watermark-colour   auto = a pale wash of `fallback`
//   watermark-size     type size of the mark

#let paint-watermark(
  mark,
  colour: luma(70%),
  angle: -18deg,
  size: 2.1em,
  width: auto,
  height: auto,
) = {
  if mark == none { none } else {
    let it = rotate(angle, origin: center + horizon, reflow: false,
      text(size: size, weight: "bold", fill: colour, mark))
    if width == auto {
      place(center + horizon, it)
    } else {
      place(center + horizon,
        box(width: width, height: height, clip: true,
          align(center + horizon, it)))
    }
  }
}

#let resolve-wm-colour(colour, fallback) = {
  if colour == auto {
    if type(fallback) == color { fallback.lighten(62%) }
    else { luma(80) }
  } else { colour }
}

/// Overlay a watermark on any box or block.
/// The mark sits on top, clipped, translucent by default.
#let with-watermark(
  body,
  watermark,
  watermark-angle: -18deg,
  watermark-colour: auto,
  watermark-size: 2.1em,
) = context {
  let col = resolve-wm-colour(watermark-colour, luma(80))
  let col = if watermark-colour == auto { col.transparentize(55%) } else { col }
  layout(avail => {
    let b = block(width: avail.width, body)
    let m = measure(b)
    box(width: m.width, height: m.height, {
      b
      paint-watermark(watermark, colour: col, angle: watermark-angle,
        size: watermark-size, width: m.width, height: m.height)
    })
  })
}
