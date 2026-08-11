/// Visualize the conceptual frame around an example text.
///
/// https://typst.app/docs/reference/text/text/#parameters-top-edge
/// https://typst.app/docs/reference/text/text/#parameters-bottom-edge
/// https://forum.typst.app/t/a-snippet-to-debug-font-by-visualize-baseline-cap-height-etc/4597/
#let debug-font(
  models: (
    (top-edge: "bounds"),
    (top-edge: "ascender"),
    (top-edge: "cap-height"),
    (top-edge: "x-height"),
    // Usually, top and bottom baselines are identical
    // However, it's not true for most math equations.
    // You can specify both of them, and they will collapse into one or display separately, depending whether they are identical.
    (top-edge: "baseline"),
    (bottom-edge: "baseline"),
    (bottom-edge: "descender"),
    (bottom-edge: "bounds"),
  ),
  palette: (aqua, fuchsia, green, yellow, fuchsia, aqua, yellow),
  example-body,
) = context {
  // Measure the distance between top and bottom baselines
  // Usually, the two baselines are identical, and `d == 0`.
  // However, it's not true for most math equations.
  let d = measure(text(
    top-edge: "baseline",
    bottom-edge: "baseline",
    example-body,
  )).height

  // Measure heights and sort increasingly
  // A list of (edge name, signed height relative to the bottom baseline)
  let edge-heights = models
    .map(raw-m => {
      // Fill with defaults
      let m = (top-edge: "baseline", bottom-edge: "baseline", ..raw-m)

      // Measure the height of the example
      let h = measure(text(..m, example-body)).height

      // Calculate the sign of the height
      if m.top-edge != "baseline" and m.bottom-edge == "baseline" {
        (m.top-edge, h)
      } else if m.top-edge == "baseline" and m.bottom-edge != "baseline" {
        (m.bottom-edge, d - h)
      } else {
        assert(m.top-edge == m.bottom-edge and m.bottom-edge == "baseline")
        assert.eq(
          h,
          d,
          message: "Measuring the distance between top and bottom baselines twice gives inconsistent results. How did you achieve that?",
        )
        if d == 0pt {
          ("baseline", h)
        } else {
          let key = raw-m.keys().first()
          (
            "baseline (" + key + ")",
            if key == "top-edge" { h } else { h - d },
          )
        }
      }
    })
    .sorted(key: ((e, h)) => h)
    .dedup() // Collapse two baselines into one, if they are identical


  // Check there are enough colors
  assert(
    edge-heights.len() - 1 <= palette.len(),
    message: "There are too few colors in `palette` to fill between all edge lines in `models`. Please set more colors.",
  )

  // Make sure `place(bottom, dy: …)` is relative to the baseline
  set text(bottom-edge: "baseline")

  box({
    // Draw stripes
    let heights = edge-heights.map(((e, h)) => h)
    for (h-low, h-high, fill) in heights
      .slice(0, -1)
      .zip(heights.slice(1), palette) {
      place(bottom, dy: -h-low, box(
        height: h-high - h-low,
        fill: fill,
        hide(example-body),
      ))
    }

    // Write the example
    example-body
  })

  // Write annotations
  box({
    let last-h = none
    let long-arrow = false
    for (edge, h) in edge-heights {
      // if too narrow, change the arrow size
      if last-h != none and calc.abs(h - last-h) < 0.2em.to-absolute() {
        long-arrow = not long-arrow
      } else {
        long-arrow = false
      }
      let arrow-size = if long-arrow { 6em } else { 1em }

      place(
        bottom,
        dy: -h + 0.3em / 2,
        text(
          0.3em,
          bottom-edge: "descender",
          text(
            black.transparentize(50%),
            $stretch(arrow.l, size: #arrow-size)$,
          )
            + edge,
        ),
      )

      last-h = h
    }
  })
}
