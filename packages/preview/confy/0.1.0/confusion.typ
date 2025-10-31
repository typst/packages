#import "@preview/cetz:0.4.2": canvas, draw
#let Gradient = gradient

// Confusion matrix rendering as a reusable Typst function.
// Usage:
//   #import "confusion.typ": confy
//   #confy(labels, M, ...options)
//
// Params:
// - labels: tuple/list of n labels
// - M: n×n matrix (tuple of tuples) of non-negative values
// - title-row: column axis title
// - title-col: row axis title
// - cmap: a palette, e.g., color.map.viridis | magma | inferno | plasma | cividis
// - gradient: a gradient value, e.g., gradient.linear(red, blue)
// - cell-size: cell size in canvas units
// - show-colorbar: display colorbar on the right
// - colorbar-ticks: 5
// - label-rotate: rotation for column labels
// - value-font-size: value text size inside cells
// - tick-scale: tick length factor relative to cell size
#let confy(
  labels,
  M,
  title-row: "Predicted",
  title-col: "Ground Truth",
  cmap: color.map.viridis,
  gradient: none,
  cell-size: 1.3,
  show-colorbar: true,
  colorbar-ticks: 7,
  label-rotate: -35deg,
  value-font-size: 9pt,
  tick-scale: 0.07,
) = {
  canvas({
    import draw: content, line, rect

    // Basic geometry
    let n = labels.len()
    let cell = cell-size
    let left = 0
    let top = 0
    let tick = tick-scale * cell

    // Find max value
    let maxv = 0
    for row in M {
      for v in row {
        if v > maxv { maxv = v }
      }
    }

    let colormap = if gradient != none { gradient } else {
      Gradient.linear(..cmap, angle: 270deg, relative: "self")
    }
    let sample_map(v, max) = {
      if max == 0 { colormap.sample(0%) } else { colormap.sample((v / max) * 100%) }
    }

    // Contrast-aware text color
    let text_on(bg) = {
      let L = color.oklab(bg).components().at(0)
      if L > 65% { black } else { white }
    }

    // Cells + values
    for (i, row) in M.enumerate() {
      for (j, v) in row.enumerate() {
        let x1 = left + (j) * cell
        let y1 = top - (i) * cell
        let x2 = left + (j + 1) * cell
        let y2 = top - (i + 1) * cell

        let bg = sample_map(v, maxv)
        rect((x1, y1), (x2, y2), fill: bg, stroke: none)

        let cx = (x1 + x2) / 2
        let cy = (y1 + y2) / 2
        content((cx, cy), text(size: value-font-size, weight: "bold", fill: text_on(bg))[#v], anchor: "center")
      }
    }

    // Outer border
    let x0 = left
    let y0 = top
    let xN = left + (n) * cell
    let yN = top - (n) * cell
    rect(
      (x0, yN),
      (xN, y0),
      fill: none,
      stroke: (thickness: .7pt, cap: "square", join: "miter"),
    )

    // Tick marks
    for i in range(0, n) {
      let y = top - (i + .5) * cell
      line((x0 - tick, y), (x0, y), stroke: (thickness: 0.6pt, cap: "square"))
    }
    for j in range(0, n) {
      let x = left + (j + .5) * cell
      line((x, yN), (x, yN - tick), stroke: (thickness: 0.6pt, cap: "square"))
    }

    // Column labels
    for (j, lab) in labels.enumerate() {
      let x = left + j * cell
      let y = yN - 0.6 * cell - tick
      content(
        (x, y),
        rotate(label-rotate)[#text(size: 8pt, weight: "bold")[#lab]],
        anchor: "center",
      )
    }

    // Row labels
    for (i, lab) in labels.enumerate() {
      let x = left - tick - 0.06 * cell
      let y = top - (i + .5) * cell
      content(
        (x, y),
        text(size: 8pt, weight: "bold")[#lab],
        anchor: "east",
      )
    }

    // Headers
    let header_margin = 0.30 * cell
    content(
      (left + (n / 2) * cell, y0 + header_margin),
      smallcaps[#title-row],
      anchor: "center",
    )
    let max_label_size = 2.2
    let x = x0 - tick - header_margin - max_label_size
    let y = (y0 + yN) / 2
    content(
      (x, y),
      rotate(-90deg)[#smallcaps[#title-col]],
      anchor: "center",
    )

    // Colorbar
    if show-colorbar {
      let lg_w = 0.35
      let lg_h = y0 - yN
      let lg_x0 = xN + 0.4 * cell
      let lg_y0 = yN

      rect(
        (lg_x0, lg_y0),
        (lg_x0 + lg_w, lg_y0 + lg_h),
        fill: colormap,
        stroke: (thickness: .5pt, cap: "square", join: "miter"),
      )

      let tlen = 0.15
      let tx = lg_x0 + lg_w
      if maxv > 0 {
        let n_ticks = colorbar-ticks
        for k in range(0, n_ticks) {
          let t = k / (calc.clamp(n_ticks, 1, n_ticks) - 1)
          let y = lg_y0 + t * lg_h
          let s = calc.round(t * maxv)
          line((tx, y), (tx + tlen, y), stroke: (thickness: 0.4pt, cap: "square"))
          content((tx + tlen + 0.1, y), text(size: 7pt)[#s], anchor: "west")
        }
      }
    }
  })
}
