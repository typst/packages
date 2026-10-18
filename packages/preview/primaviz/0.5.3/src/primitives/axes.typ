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
// When show-ticks is true, draws small tick marks at each grid position on both axes.
#let draw-axis-lines(origin-x, origin-y, x-end, y-start, theme, show-ticks: false) = {
  let chart-width = x-end - origin-x
  let chart-height = origin-y - y-start
  // Y-axis: vertical from y-start down to origin-y at x=origin-x
  place(left + top,
    line(start: (origin-x, y-start), end: (origin-x, origin-y), stroke: theme.axis-stroke)
  )
  // X-axis: horizontal from origin-x to x-end at y=origin-y
  place(left + top,
    line(start: (origin-x, origin-y), end: (x-end, origin-y), stroke: theme.axis-stroke)
  )
  // Tick marks
  if show-ticks {
    let tick-count = theme.tick-count
    let tick-len = theme.at("tick-length", default: 4pt)
    for i in array.range(tick-count) {
      let fraction = if tick-count > 1 { i / (tick-count - 1) } else { 0 }
      // Y-axis ticks (left side)
      let y = y-start + chart-height - fraction * chart-height
      place(left + top,
        line(start: (origin-x - tick-len, y), end: (origin-x, y), stroke: theme.axis-stroke))
      // X-axis ticks (bottom)
      let x = origin-x + fraction * chart-width
      place(left + top,
        line(start: (x, origin-y), end: (x, origin-y + tick-len), stroke: theme.axis-stroke))
    }
  }
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
    let gap = theme.axis-label-gap
    if side == "right" {
      place(left + top, dx: x-pos + gap, dy: y,
        move(dy: -0.5em, text(size: theme.axis-label-size, fill: fill-color)[#label]))
    } else {
      place(left + top, dx: 0pt, dy: y,
        box(width: x-pos - gap / 2, height: 0pt,
          align(right, move(dy: -0.5em,
            text(size: theme.axis-label-size, fill: fill-color)[#label]))))
    }
  }
}

// Draw category labels along the X axis.
// Labels are centered under their position using the spacing width.
#let draw-x-category-labels(labels, x-start, spacing, y-pos, theme, center-offset: 0pt) = {
  let n = labels.len()
  // Rotate labels if too many OR if the widest label exceeds the slot width
  let max-label-w = labels.map(l => measure(text(size: theme.axis-label-size)[#l]).width).fold(0pt, (a, b) => calc.max(a, b))
  let rotate-labels = n > 8 or max-label-w > spacing * 0.95
  // When rotated, labels don't compete for horizontal space — show all
  let skip = if rotate-labels { 1 } else { density-skip(n, spacing * n) }

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
        box(width: spacing, height: theme.axis-label-size * 2,
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
    let label-w = theme.axis-label-size * 4
    place(left + top, dx: x - label-w / 2, dy: y-pos,
      box(width: label-w, height: theme.axis-label-size * 2,
        align(center + top, text(size: theme.axis-label-size, fill: theme.text-color)[#format-number(value, digits: digits, mode: theme.number-format)]))
    )
  }
}

// Draw evenly-spaced x-axis labels (for line/area/bump charts where points are spread uniformly).
#let draw-x-even-labels(labels, n, origin-x, chart-width, origin-y, theme) = {
  let x-spacing = if n > 1 { chart-width / (n - 1) } else { chart-width }
  for (i, lbl) in labels.enumerate() {
    let x = if n == 1 { origin-x } else { origin-x + (i / (n - 1)) * chart-width }
    place(left + top, dx: x - x-spacing / 2, dy: origin-y + theme.axis-label-gap,
      box(width: x-spacing, height: theme.axis-label-size * 2,
        align(center + top, text(size: theme.axis-label-size, fill: theme.text-color)[#lbl])))
  }
}

// Draw a single right-aligned y-axis category label in the left margin.
// Used by horizontal charts (horizontal-bar, horizontal-lollipop, dumbbell, diverging).
#let draw-y-label(label, y, margin-width, theme) = {
  place(left + top, dx: 0pt, dy: y,
    box(width: margin-width - theme.axis-label-gap, height: 0pt,
      align(right, move(dy: -0.5em,
        text(size: theme.axis-label-size, fill: theme.text-color)[#label]))))
}

// Draw grid lines behind chart area.
// When show-minor-grid is true, draws lighter lines between major grid lines.
#let draw-grid(x-start, y-start, chart-width, chart-height, theme, show-minor-grid: false, minor-count: 4) = {
  if theme.show-grid == false { return }
  let tick-count = theme.tick-count

  // Minor grid lines (drawn first, behind major)
  if show-minor-grid and tick-count > 1 {
    let minor-stroke = theme.at("minor-grid-stroke", default: 0.25pt + theme.text-color-light.transparentize(60%))
    for i in array.range(tick-count - 1) {
      for j in array.range(1, minor-count) {
        let fraction = (i + j / minor-count) / (tick-count - 1)
        // Horizontal minor
        let y = y-start + chart-height - fraction * chart-height
        place(left + top,
          line(start: (x-start, y), end: (x-start + chart-width, y), stroke: minor-stroke))
        // Vertical minor
        let x = x-start + fraction * chart-width
        place(left + top,
          line(start: (x, y-start), end: (x, y-start + chart-height), stroke: minor-stroke))
      }
    }
  }

  // Major grid lines
  for i in array.range(tick-count) {
    let fraction = if tick-count > 1 { i / (tick-count - 1) } else { 0 }
    let y = y-start + chart-height - fraction * chart-height
    place(left + top,
      line(start: (x-start, y), end: (x-start + chart-width, y), stroke: theme.grid-stroke)
    )
  }
  for i in array.range(tick-count) {
    let fraction = if tick-count > 1 { i / (tick-count - 1) } else { 0 }
    let x = x-start + fraction * chart-width
    place(left + top,
      line(start: (x, y-start), end: (x, y-start + chart-height), stroke: theme.grid-stroke)
    )
  }
}

/// Measures the width of the widest y-axis tick label for layout calculations.
///
/// - min-val (number): Minimum axis value
/// - max-val (number): Maximum axis value
/// - theme (dictionary): Resolved theme
/// - digits (int): Decimal places for formatting
/// -> length
#let measure-y-tick-width(min-val, max-val, theme, digits: 1) = {
  let tick-count = theme.tick-count
  let val-range = max-val - min-val
  let max-w = 0pt
  for i in array.range(tick-count) {
    let fraction = if tick-count > 1 { i / (tick-count - 1) } else { 0 }
    let value = min-val + val-range * fraction
    let label = format-number(value, digits: digits, mode: theme.number-format)
    let w = measure(text(size: theme.axis-label-size)[#label]).width
    if w > max-w { max-w = w }
  }
  max-w
}

// Draw axis title labels (x below axis, y rotated on left).
//
// Layout is measurement-based:
// - x-title: positioned below measured tick label height + gap
// - y-title: positioned to the left of measured tick labels, with fitment check
//
// y-tick-width: measured width of the widest y-tick label (from measure-y-tick-width)
// x-tick-height: measured height of x-tick labels (defaults to axis-label-size * 2)
#let draw-axis-titles(x-label, y-label, x-center, y-center, theme,
  origin-x: none, origin-y: none, y-tick-width: 0pt, x-tick-height: none) = {
  let ax-origin-y = if origin-y != none { origin-y } else { y-center * 2 }
  let ax-origin-x = if origin-x != none { origin-x } else { theme.axis-padding-left }
  let gap = theme.axis-label-gap

  if x-label != none {
    let lbl-content = text(size: theme.axis-title-size, fill: theme.text-color)[#x-label]
    let lbl-size = measure(lbl-content)
    // Position below x-tick labels: measure actual tick label height + small gap
    let tick-h = if x-tick-height != none { x-tick-height } else {
      measure(text(size: theme.axis-label-size)[0]).height * 1.4
    }
    let x-title-dy = ax-origin-y + gap * 0.75 + tick-h
    place(left + top, dx: x-center - lbl-size.width / 2, dy: x-title-dy,
      lbl-content
    )
  }
  if y-label != none {
    let lbl-content = text(size: theme.axis-title-size, fill: theme.text-color)[#y-label]
    let rotated = rotate(-90deg, lbl-content)
    let rot-size = measure(rotated)
    // Align with tick label layout: ticks right-edge is at origin-x - gap/2
    let y-title-dx = ax-origin-x - gap / 4 - y-tick-width - rot-size.width

    place(left + top, dx: y-title-dx, dy: y-center - rot-size.height / 2,
      rotated
    )
  }
}
