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
  let maj-color = if major-color != none { major-color } else { color.darken(35%) }

  cetz.canvas({
    import cetz.draw: *

    if background != none {
      rect((0, 0), (w, h), fill: background, stroke: none)
    }

    if kind == "square" {
      let draw-v = lines != "horizontal"
      let draw-h = lines != "vertical"
      let is-major(i) = major-every != none and calc.rem(i, major-every) == 0

      if draw-v {
        let n = calc.floor(w / step + 1e-6)
        for i in range(0, n + 1) {
          let x = i * step
          let stroke = if is-major(i) { 0.6pt + maj-color } else { 0.3pt + color }
          line((x, 0), (x, h), stroke: stroke)
        }
      }
      if draw-h {
        let n = calc.floor(h / step + 1e-6)
        for j in range(0, n + 1) {
          let y = j * step
          let stroke = if is-major(j) { 0.6pt + maj-color } else { 0.3pt + color }
          line((0, y), (w, y), stroke: stroke)
        }
      }
    } else if kind == "dot" {
      let nx = calc.floor(w / step + 1e-6)
      let ny = calc.floor(h / step + 1e-6)
      let is-major(i) = major-every != none and calc.rem(i, major-every) == 0
      for i in range(0, nx + 1) {
        for j in range(0, ny + 1) {
          let major = is-major(i) and is-major(j)
          circle(
            (i * step, j * step),
            radius: if major { 0.035 } else { 0.02 },
            fill: if major { maj-color } else { color },
            stroke: none,
          )
        }
      }
    }

    if frame {
      rect((0, 0), (w, h), fill: none, stroke: 0.6pt + luma(20%))
    }
  })
}
