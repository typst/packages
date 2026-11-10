// axes.typ - Axis drawing primitives

#import "../theme.typ": *
#import "../util.typ": format-number

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
#let draw-y-ticks(min-val, max-val, chart-height, y-offset, x-pos, theme, digits: 1) = {
  let tick-count = theme.tick-count
  let val-range = max-val - min-val
  for i in array.range(tick-count) {
    let fraction = if tick-count > 1 { i / (tick-count - 1) } else { 0 }
    let value = min-val + val-range * fraction
    let y = y-offset + chart-height - fraction * chart-height
    place(left + top, dx: x-pos, dy: y - 5pt,
      text(size: theme.axis-label-size, fill: theme.text-color)[#format-number(value, digits: digits, mode: theme.number-format)]
    )
  }
}

// Draw category labels along the X axis.
#let draw-x-category-labels(labels, x-start, spacing, y-pos, theme, center-offset: 0pt) = {
  let n = labels.len()
  let rotate-labels = n > 8
  let skip = if n > 15 { calc.ceil(n / 10) } else { 1 }

  for i in array.range(n) {
    if calc.rem(i, skip) != 0 and i != n - 1 { continue }
    let x = x-start + i * spacing + center-offset
    if rotate-labels {
      place(left + top, dx: x - 5pt, dy: y-pos,
        rotate(-45deg, origin: top + right,
          text(size: theme.axis-label-size, fill: theme.text-color)[#labels.at(i)]
        )
      )
    } else {
      place(left + top, dx: x - 15pt, dy: y-pos,
        text(size: theme.axis-label-size, fill: theme.text-color)[#labels.at(i)]
      )
    }
  }
}

// Draw numeric tick labels along the X axis.
#let draw-x-ticks(min-val, max-val, chart-width, x-offset, y-pos, theme, digits: 1) = {
  let tick-count = theme.tick-count
  let val-range = max-val - min-val
  for i in array.range(tick-count) {
    let fraction = if tick-count > 1 { i / (tick-count - 1) } else { 0 }
    let value = min-val + val-range * fraction
    let x = x-offset + fraction * chart-width
    place(left + top, dx: x - 12pt, dy: y-pos,
      text(size: theme.axis-label-size, fill: theme.text-color)[#format-number(value, digits: digits, mode: theme.number-format)]
    )
  }
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
    place(left + top, dx: x-center, dy: y-center + 18pt,
      align(center, text(size: theme.axis-title-size, fill: theme.text-color)[#x-label])
    )
  }
  if y-label != none {
    place(left + top, dx: 2pt, dy: y-center,
      rotate(-90deg, text(size: theme.axis-title-size, fill: theme.text-color)[#y-label])
    )
  }
}
