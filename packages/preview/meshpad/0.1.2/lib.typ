// =============================================================================
//  meshpad · Configurable grid backgrounds for printable worksheets
//
//  `size` and `step` are independent: when the width or height is not a whole
//  multiple of `step`, the grid draws every full cell that fits and leaves the
//  remainder as a narrower strip against the frame. It never overflows.
//  E.g. size: (7, 3), step: 0.6 → 11 columns of 0.6 (= 6.6) and a 0.4 strip.
// =============================================================================

#import "@preview/cetz:0.5.2"

#let grid-paper(
  size: (10, 10),
  kind: "square",
  lines: "both",
  step: 0.5,
  major-every: none,
  background: none,
  color: gray,
  major-color: none,
  frame: true,
) = {
  assert(
    kind in ("square", "dot"),
    message: "meshpad: unknown kind \"" + kind + "\" (expected \"square\" or \"dot\")",
  )
  assert(
    lines in ("both", "horizontal", "vertical"),
    message: "meshpad: unknown lines \"" + lines + "\" (expected \"both\", \"horizontal\" or \"vertical\")",
  )

  let (w, h) = size
  // `size` and `step` take either plain numbers or Typst lengths (5cm, 5mm).
  // Integers and floats mix freely; what cannot mix is a plain number with a
  // length, which fails deep inside CeTZ with "cannot add length and float".
  let is-length(v) = type(v) == length
  assert(
    is-length(w) == is-length(step) and is-length(h) == is-length(step),
    message: "meshpad: size and step must be all plain numbers or all Typst lengths, not a mix (got size (" + repr(w) + ", " + repr(h) + ") and step " + repr(step) + ")",
  )
  // Positivity is tested against the zero of the value's own type: `5mm > 0`
  // does not compile, because a length and an integer cannot be compared.
  let positive(v) = v > v * 0
  assert(
    positive(w) and positive(h),
    message: "meshpad: size must be positive (got (" + repr(w) + ", " + repr(h) + "))",
  )
  assert(
    positive(step),
    message: "meshpad: step must be positive (got " + repr(step) + ")",
  )
  assert(
    major-every == none or (type(major-every) == int and major-every > 0),
    message: "meshpad: major-every must be a positive whole number or none (got " + repr(major-every) + ")",
  )

  let maj-color = if major-color != none { major-color } else { color.darken(35%) }

  cetz.canvas({
    import cetz.draw: *

    if background != none {
      rect((0, 0), (w, h), fill: background, stroke: none)
    }

    let is-major(i) = major-every != none and calc.rem(i, major-every) == 0

    if kind == "square" {
      let nx = if lines != "horizontal" { calc.floor(w / step + 1e-6) } else { -1 }
      let ny = if lines != "vertical" { calc.floor(h / step + 1e-6) } else { -1 }
      // Minor lines first, major lines on top: drawn in a single pass, each
      // minor line cut a notch into every major line it crossed.
      for major in (false, true) {
        let stroke = if major { 0.6pt + maj-color } else { 0.3pt + color }
        for i in range(0, nx + 1) {
          if is-major(i) == major { line((i * step, 0), (i * step, h), stroke: stroke) }
        }
        for j in range(0, ny + 1) {
          if is-major(j) == major { line((0, j * step), (w, j * step), stroke: stroke) }
        }
      }
    } else if kind == "dot" {
      // One dashed line per row, not one CeTZ circle per dot: a full page of
      // circles took over a minute to compile. A dash a thousandth of a step
      // long, with round caps, is a dot as wide as the line is thick.
      let nx = calc.floor(w / step + 1e-6)
      let ny = calc.floor(h / step + 1e-6)
      // Stroke measures must be lengths; coordinates keep the type of `step`.
      let len(v) = if is-length(step) { v } else { v * 1cm }
      let coord(v) = if is-length(step) { v } else { v / 1cm }
      let (minor, major) = (0.02cm, 0.035cm)
      let row(j, every, radius, paint) = {
        let nib = step * every * 1e-3
        let last = calc.quo(nx, every) * every * step
        line((-nib / 2, j * step), (last + nib / 2, j * step), stroke: (
          paint: paint,
          thickness: 2 * radius,
          cap: "round",
          dash: (len(nib), len(step * every - nib)),
        ))
      }
      for j in range(0, ny + 1) { row(j, 1, minor, color) }
      // Major dots go on top and cover the minor dot underneath.
      if major-every != none {
        for j in range(0, ny + 1, step: major-every) { row(j, major-every, major, maj-color) }
      }
      // CeTZ sizes the canvas from the paths and ignores how thick a stroke
      // is, so the room the outermost dots take is claimed here.
      let reach(i) = coord(if is-major(i) { major } else { minor })
      rect((-reach(0), -reach(0)), (nx * step + reach(nx), ny * step + reach(ny)), stroke: none)
    }

    if frame {
      rect((0, 0), (w, h), fill: none, stroke: 0.6pt + luma(20%))
    }
  })
}
