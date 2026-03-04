// axes.typ - Axis drawing primitives

#import "../theme.typ": *
#import "../util.typ": format-number, nice-ceil, nice-floor
#import "layout.typ": density-skip

/// Computes the standard Cartesian layout dimensions from theme padding.
/// Returns a dictionary with: pad-left, pad-right, pad-top, pad-bottom,
/// chart-width, chart-height, origin-x, origin-y.
///
/// - width (length): Total available width
/// - height (length): Total available height
/// - theme (dictionary): Resolved theme
/// - extra-left (length): Additional left padding beyond theme default
/// - extra-right (length): Additional right padding beyond theme default
/// -> dictionary
#let cartesian-layout(width, height, theme, extra-left: 0pt, extra-right: 0pt) = {
  let pad-left = theme.axis-padding-left + extra-left
  let pad-right = theme.axis-padding-right + extra-right
  let pad-top = theme.axis-padding-top
  let pad-bottom = theme.axis-padding-bottom
  let chart-width = width - pad-left - pad-right
  let chart-height = height - pad-top - pad-bottom
  (
    pad-left: pad-left,
    pad-right: pad-right,
    pad-top: pad-top,
    pad-bottom: pad-bottom,
    chart-width: chart-width,
    chart-height: chart-height,
    origin-x: pad-left,
    origin-y: pad-top + chart-height,
  )
}

// Draw Y-axis (vertical) and X-axis (horizontal) lines.
#let draw-axis-lines(origin-x, origin-y, x-end, y-start, theme) = {
  // Y-axis: vertical from y-start down to origin-y at x=origin-x
  place(left + top,
    line(start: (origin-x, y-start), end: (origin-x, origin-y), stroke: theme.axis-stroke)
  )
  // X-axis: horizontal from origin-x to x-end at y=origin-y
  place(left + top,
    line(start: (origin-x, origin-y), end: (x-end, origin-y), stroke: theme.axis-stroke)
  )
}

// Draw tick labels along the Y axis.
// Labels are right-aligned into the padding area left of x-pos, vertically centered on the tick.
// Optional `color` overrides theme.text-color (useful for dual-axis charts).
// Optional `side` ("left" or "right") controls label placement; "right" places labels after x-pos.
#let draw-y-ticks(min-val, max-val, chart-height, y-offset, x-pos, theme, digits: 1, color: auto, side: "left") = {
  let tick-count = theme.tick-count
  let val-range = max-val - min-val
  let fill-color = if color != auto { color } else { theme.text-color }
  for i in array.range(tick-count) {
    let fraction = if tick-count > 1 { i / (tick-count - 1) } else { 0 }
    let value = min-val + val-range * fraction
    let y = y-offset + chart-height - fraction * chart-height
    let label = format-number(value, digits: digits, mode: theme.number-format)
    if side == "right" {
      place(left + top, dx: x-pos + 4pt, dy: y,
        move(dy: -0.5em, text(size: theme.axis-label-size, fill: fill-color)[#label]))
    } else {
      place(left + top, dx: 0pt, dy: y,
        box(width: x-pos - 2pt, height: 0pt,
          align(right, move(dy: -0.5em,
            text(size: theme.axis-label-size, fill: fill-color)[#label]))))
    }
  }
}

// Draw category labels along the X axis.
// Labels are centered under their position using the spacing width.
#let draw-x-category-labels(labels, x-start, spacing, y-pos, theme, center-offset: 0pt) = {
  let n = labels.len()
  let rotate-labels = n > 8
  let skip = density-skip(n, spacing * n)

  for i in array.range(n) {
    if calc.rem(i, skip) != 0 and i != n - 1 { continue }
    let x = x-start + i * spacing + center-offset
    if rotate-labels {
      place(left + top, dx: x + spacing / 2, dy: y-pos,
        rotate(-45deg, origin: top + right,
          text(size: theme.axis-label-size, fill: theme.text-color)[#labels.at(i)]
        )
      )
    } else {
      place(left + top, dx: x, dy: y-pos,
        box(width: spacing, height: 1.5em,
          align(center + top, text(size: theme.axis-label-size, fill: theme.text-color)[#labels.at(i)]))
      )
    }
  }
}

// Draw numeric tick labels along the X axis.
// Labels are centered on their tick position.
#let draw-x-ticks(min-val, max-val, chart-width, x-offset, y-pos, theme, digits: 1) = {
  let tick-count = theme.tick-count
  let val-range = max-val - min-val
  for i in array.range(tick-count) {
    let fraction = if tick-count > 1 { i / (tick-count - 1) } else { 0 }
    let value = min-val + val-range * fraction
    let x = x-offset + fraction * chart-width
    place(left + top, dx: x - 1.5em, dy: y-pos,
      box(width: 3em, height: 1.5em,
        align(center + top, text(size: theme.axis-label-size, fill: theme.text-color)[#format-number(value, digits: digits, mode: theme.number-format)]))
    )
  }
}

// Draw evenly-spaced x-axis labels (for line/area/bump charts where points are spread uniformly).
#let draw-x-even-labels(labels, n, origin-x, chart-width, origin-y, theme) = {
  let x-spacing = if n > 1 { chart-width / (n - 1) } else { chart-width }
  for (i, lbl) in labels.enumerate() {
    let x = if n == 1 { origin-x } else { origin-x + (i / (n - 1)) * chart-width }
    place(left + top, dx: x - x-spacing / 2, dy: origin-y + 4pt,
      box(width: x-spacing, height: 1.5em,
        align(center + top, text(size: theme.axis-label-size, fill: theme.text-color)[#lbl])))
  }
}

// Draw a single right-aligned y-axis category label in the left margin.
// Used by horizontal charts (horizontal-bar, horizontal-lollipop, dumbbell, diverging).
#let draw-y-label(label, y, margin-width, theme) = {
  place(left + top, dx: 0pt, dy: y,
    box(width: margin-width - 4pt, height: 0pt,
      align(right, move(dy: -0.5em,
        text(size: theme.axis-label-size, fill: theme.text-color)[#label]))))
}

// Draw grid lines behind chart area.
#let draw-grid(x-start, y-start, chart-width, chart-height, theme) = {
  if theme.show-grid == false { return }
  let tick-count = theme.tick-count
  // Horizontal grid lines
  for i in array.range(tick-count) {
    let fraction = if tick-count > 1 { i / (tick-count - 1) } else { 0 }
    let y = y-start + chart-height - fraction * chart-height
    place(left + top,
      line(start: (x-start, y), end: (x-start + chart-width, y), stroke: theme.grid-stroke)
    )
  }
  // Vertical grid lines
  for i in array.range(tick-count) {
    let fraction = if tick-count > 1 { i / (tick-count - 1) } else { 0 }
    let x = x-start + fraction * chart-width
    place(left + top,
      line(start: (x, y-start), end: (x, y-start + chart-height), stroke: theme.grid-stroke)
    )
  }
}

// Draw axis title labels (x below, y rotated on left).
#let draw-axis-titles(x-label, y-label, x-center, y-center, theme) = {
  if x-label != none {
    place(left + top, dx: x-center, dy: y-center + 1.5em,
      align(center, text(size: theme.axis-title-size, fill: theme.text-color)[#x-label])
    )
  }
  if y-label != none {
    place(left + top, dx: 2pt, dy: y-center,
      rotate(-90deg, text(size: theme.axis-title-size, fill: theme.text-color)[#y-label])
    )
  }
}
