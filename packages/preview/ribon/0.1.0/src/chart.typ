/// Shared chart geometry for quantitative Ribon figures.
///
/// Data coordinates, axes, plot-area layout, and legend placement are separate
/// values. RNA-specific plot functions consume these values without owning
/// their typography or page composition.

#let plot-theme(
  text-size: 6.5pt,
  label-size: 7pt,
  text-fill: luma(32%),
  label-fill: luma(18%),
  grid-stroke: (paint: luma(90%), thickness: 0.35pt),
  minor-grid-stroke: (paint: luma(94%), thickness: 0.25pt),
  frame-stroke: (paint: luma(35%), thickness: 0.55pt),
  tick-stroke: (paint: luma(35%), thickness: 0.55pt),
  minor-tick-stroke: (paint: luma(50%), thickness: 0.4pt),
  background: none,
  legend-fill: white,
  legend-stroke: (paint: luma(82%), thickness: 0.35pt),
  legend-radius: 2pt,
) = (
  text-size: text-size,
  label-size: label-size,
  text-fill: text-fill,
  label-fill: label-fill,
  grid-stroke: grid-stroke,
  minor-grid-stroke: minor-grid-stroke,
  frame-stroke: frame-stroke,
  tick-stroke: tick-stroke,
  minor-tick-stroke: minor-tick-stroke,
  background: background,
  tick-length: 3pt,
  minor-tick-length: 1.8pt,
  tick-label-gap: 2.5pt,
  axis-label-gap: 6pt,
  legend-fill: legend-fill,
  legend-stroke: legend-stroke,
  legend-radius: legend-radius,
  legend-inset: (x: 5pt, y: 3.5pt),
  legend-item-gap: 9pt,
  legend-swatch-gap: 3.5pt,
  legend-swatch-width: 14pt,
)

/// Configure one axis independently from its plot.
///
/// `domain` is `auto` or `(minimum, maximum)`. A descending domain reverses
/// the axis. `ticks` accepts `auto`, `none`, values, or `(value, label)` tuples.
#let axis-style(
  domain: auto,
  ticks: auto,
  tick-step: auto,
  minor-ticks: none,
  minor-tick-step: none,
  tick-count: 5,
  format: auto,
  label: auto,
  mode: "linear",
  base: 10,
  grid: "major",
  show-line: true,
  show-ticks: true,
  show-labels: true,
) = {
  if domain != auto {
    if type(domain) != array or domain.len() != 2 or domain.at(0) == domain.at(1) {
      panic("axis domain must contain two distinct values")
    }
  }
  if mode not in ("linear", "log") { panic("axis mode must be \"linear\" or \"log\"") }
  if mode == "log" and base <= 1 { panic("logarithmic axis base must exceed one") }
  if mode == "log" and domain != auto and (domain.at(0) <= 0 or domain.at(1) <= 0) {
    panic("logarithmic axis domains must be positive")
  }
  if grid not in (none, false, true, "major", "minor", "both") {
    panic("axis grid must be none, major, minor, or both")
  }
  (
    domain: domain,
    ticks: ticks,
    tick-step: tick-step,
    minor-ticks: minor-ticks,
    minor-tick-step: minor-tick-step,
    tick-count: calc.max(2, tick-count),
    format: format,
    label: label,
    mode: mode,
    base: base,
    grid: grid,
    show-line: show-line,
    show-ticks: show-ticks,
    show-labels: show-labels,
  )
}

/// Configure plot-area dimensions and padding.
#let plot-layout(
  padding: auto,
  aspect: auto,
  frame: true,
  clip: true,
) = {
  if aspect != auto and aspect <= 0 { panic("plot aspect must be positive") }
  if padding != auto and type(padding) not in (length, dictionary) {
    panic("plot padding must be auto, a length, or a dictionary")
  }
  (padding: padding, aspect: aspect, frame: frame, clip: clip)
}

/// Configure legend placement and flow.
///
/// Positions include the four outer sides, nine `inner-*` anchors, `none`, and
/// an explicit `(x-ratio, y-ratio)` position inside the plot.
#let legend-style(
  position: "bottom",
  anchor: auto,
  offset: (0pt, 0pt),
  direction: "row",
  columns: auto,
  max-columns: auto,
  gutter: 6pt,
  item-gap: auto,
  row-gap: 3pt,
  width: auto,
  inset: auto,
  fill: auto,
  stroke: auto,
  radius: auto,
) = {
  let valid = (
    "top", "bottom", "left", "right",
    "inner-north-west", "inner-north", "inner-north-east",
    "inner-west", "inner-center", "inner-east",
    "inner-south-west", "inner-south", "inner-south-east",
  )
  if position != none and type(position) != array and position not in valid {
    panic("unsupported legend position: " + repr(position))
  }
  if type(position) == array and position.len() != 2 {
    panic("explicit legend position must be a two-value ratio tuple")
  }
  if type(offset) != array or offset.len() != 2 {
    panic("legend offset must contain two lengths")
  }
  if direction not in ("row", "column") {
    panic("legend direction must be \"row\" or \"column\"")
  }
  if columns != auto and columns < 1 { panic("legend columns must be positive") }
  if max-columns != auto and max-columns < 1 { panic("legend max-columns must be positive") }
  (
    position: position,
    anchor: anchor,
    offset: offset,
    direction: direction,
    columns: columns,
    max-columns: max-columns,
    gutter: gutter,
    item-gap: item-gap,
    row-gap: row-gap,
    width: width,
    inset: inset,
    fill: fill,
    stroke: stroke,
    radius: radius,
  )
}

#let centered-at(point, body) = place(
  top + left,
  dx: point.at(0),
  dy: point.at(1),
  box(width: 0pt, height: 0pt, place(center + horizon, body)),
)

#let _format-number(value) = str(calc.round(value * 1000) / 1000)

#let _superscript-integer(value) = {
  let digits = (
    "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
    "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
  )
  let result = if value < 0 { "⁻" } else { "" }
  for digit in str(calc.abs(value)).clusters() { result += digits.at(digit) }
  result
}

#let _format-value(axis, value) = {
  if type(axis.format) == function { return axis.format(value) }
  if axis.format == none { return none }
  if axis.format == "scientific" {
    if value == 0 { return [0] }
    let exponent = calc.floor(calc.log(calc.abs(value), base: 10))
    let coefficient = calc.round(value / calc.pow(10, exponent) * 100) / 100
    return str(coefficient) + "×10" + _superscript-integer(exponent)
  }
  _format-number(value)
}

/// Return a stable, human-readable positive axis step and upper bound.
#let nice-axis(maximum, count: 5) = {
  let maximum = calc.max(0.0, maximum)
  if maximum == 0 { return (step: 1.0, maximum: 1.0, ticks: (0.0, 1.0)) }
  let raw = maximum / calc.max(1, count - 1)
  let decade = 1.0
  while raw / decade >= 10 { decade *= 10 }
  while raw / decade < 1 { decade /= 10 }
  let normalized = raw / decade
  let factor = if normalized <= 1 { 1.0 }
  else if normalized <= 2 { 2.0 }
  else if normalized <= 2.5 { 2.5 }
  else if normalized <= 5 { 5.0 }
  else { 10.0 }
  let step = factor * decade
  let upper = calc.ceil(maximum / step) * step
  let intervals = int(calc.round(upper / step))
  (step: step, maximum: upper, ticks: range(0, intervals + 1).map(index => index * step))
}

#let _positive-mod(value, modulus) = calc.rem(calc.rem(value, modulus) + modulus, modulus)

#let _linear-ticks(minimum, maximum, step) = {
  let low = calc.min(minimum, maximum)
  let high = calc.max(minimum, maximum)
  if step <= 0 { panic("axis tick step must be positive") }
  let first = calc.ceil(low / step) * step
  let values = ()
  let value = first
  let guard = 0
  while value <= high + step * 1e-9 and guard < 1000 {
    values.push(value)
    value += step
    guard += 1
  }
  if guard >= 1000 { panic("axis generated too many ticks") }
  values
}

#let _auto-step(minimum, maximum, count) = {
  let span = calc.abs(maximum - minimum)
  nice-axis(span, count: count).step
}

#let _log-major-ticks(minimum, maximum, base) = {
  if minimum <= 0 or maximum <= 0 { panic("logarithmic axis domains must be positive") }
  let low = calc.min(minimum, maximum)
  let high = calc.max(minimum, maximum)
  let first = calc.ceil(calc.log(low, base: base))
  let last = calc.floor(calc.log(high, base: base))
  if last < first { return (low, high) }
  range(first, last + 1).map(exponent => calc.pow(base, exponent))
}

#let _tick-value(entry) = if type(entry) == array { entry.at(0) } else { entry }

#let _tick-label(axis, entry) = {
  if type(entry) == array and entry.len() >= 2 { entry.at(1) }
  else { _format-value(axis, _tick-value(entry)) }
}

#let resolve-axis(axis, fallback-domain, fallback-ticks: auto, fallback-label: none) = {
  let domain = if axis.domain == auto { fallback-domain } else { axis.domain }
  if axis.mode == "log" and (domain.at(0) <= 0 or domain.at(1) <= 0) {
    panic("logarithmic axis domains must be positive")
  }
  let ticks = if axis.ticks == none { () }
  else if axis.ticks != auto { axis.ticks }
  else if axis.tick-step != auto { _linear-ticks(domain.at(0), domain.at(1), axis.tick-step) }
  else if axis.mode == "log" { _log-major-ticks(domain.at(0), domain.at(1), axis.base) }
  else if fallback-ticks != auto and axis.domain == auto { fallback-ticks }
  else { _linear-ticks(domain.at(0), domain.at(1), _auto-step(domain.at(0), domain.at(1), axis.tick-count)) }
  let minor = if axis.minor-ticks == none and axis.minor-tick-step == none { () }
  else if axis.minor-ticks not in (none, auto) { axis.minor-ticks }
  else if axis.minor-tick-step != none { _linear-ticks(domain.at(0), domain.at(1), axis.minor-tick-step) }
  else { () }
  axis + (
    domain: domain,
    ticks: ticks,
    minor-ticks: minor,
    label: if axis.label == auto { fallback-label } else { axis.label },
  )
}

#let _axis-transform(axis, value) = if axis.mode == "log" {
  calc.log(calc.max(value, 1e-12), base: axis.base)
} else { value }

#let _axis-map(axis, value, low, high) = {
  let minimum = _axis-transform(axis, axis.domain.at(0))
  let maximum = _axis-transform(axis, axis.domain.at(1))
  let transformed = _axis-transform(axis, value)
  low + (transformed - minimum) / (maximum - minimum) * (high - low)
}

#let _padding-dictionary(value, defaults) = {
  if value == auto { return defaults }
  if type(value) == length { return (left: value, right: value, top: value, bottom: value) }
  defaults + value
}

#let _grid-major(axis) = axis.grid in (true, "major", "both")
#let _grid-minor(axis) = axis.grid in ("minor", "both")

#let _frame-geometry(width, height, x-axis, y-axis, x2-axis, y2-axis, layout, square: false) = {
  let defaults = (
    left: if y-axis.label == none { 28pt } else { 36pt },
    right: if y2-axis == none { 8pt } else if y2-axis.label == none { 28pt } else { 36pt },
    top: if x2-axis == none { 7pt } else if x2-axis.label == none { 20pt } else { 29pt },
    bottom: if x-axis.label == none { 20pt } else { 29pt },
  )
  let padding = _padding-dictionary(layout.padding, defaults)
  let available-width = width - padding.left - padding.right
  let available-height = height - padding.top - padding.bottom
  let plot-width = available-width
  let plot-height = available-height
  if square {
    let side = calc.min(available-width, available-height)
    plot-width = side
    plot-height = side
  } else if layout.aspect != auto {
    let desired = layout.aspect
    if available-width / available-height > desired { plot-width = available-height * desired }
    else { plot-height = available-width / desired }
  }
  if plot-width <= 0pt or plot-height <= 0pt { panic("plot dimensions are too small for axes") }
  let left = padding.left + (available-width - plot-width) / 2
  let top = padding.top + (available-height - plot-height) / 2
  (
    left: left,
    top: top,
    width: plot-width,
    height: plot-height,
    x: value => _axis-map(x-axis, value, left, left + plot-width),
    y: value => _axis-map(y-axis, value, top + plot-height, top),
    x2: if x2-axis == none { none } else { value => _axis-map(x2-axis, value, left, left + plot-width) },
    y2: if y2-axis == none { none } else { value => _axis-map(y2-axis, value, top + plot-height, top) },
  )
}

#let _draw-frame(width, height, x-axis, y-axis, body, layout, theme, x2-axis: none, y2-axis: none, square: false) = {
  let geometry = _frame-geometry(width, height, x-axis, y-axis, x2-axis, y2-axis, layout, square: square)
  block(width: width, height: height, {
    if theme.background != none {
      place(top + left, rect(width: geometry.width, height: geometry.height, fill: theme.background, stroke: none), dx: geometry.left, dy: geometry.top)
    }
    for entry in x-axis.minor-ticks {
      let value = _tick-value(entry)
      let x = (geometry.x)(value)
      if _grid-minor(x-axis) {
        place(top + left, line(start: (x, geometry.top), end: (x, geometry.top + geometry.height), stroke: theme.minor-grid-stroke))
      }
      if x-axis.show-ticks {
        place(top + left, line(start: (x, geometry.top + geometry.height), end: (x, geometry.top + geometry.height + theme.minor-tick-length), stroke: theme.minor-tick-stroke))
      }
    }
    for entry in y-axis.minor-ticks {
      let value = _tick-value(entry)
      let y = (geometry.y)(value)
      if _grid-minor(y-axis) {
        place(top + left, line(start: (geometry.left, y), end: (geometry.left + geometry.width, y), stroke: theme.minor-grid-stroke))
      }
      if y-axis.show-ticks {
        place(top + left, line(start: (geometry.left - theme.minor-tick-length, y), end: (geometry.left, y), stroke: theme.minor-tick-stroke))
      }
    }
    for entry in x-axis.ticks {
      let value = _tick-value(entry)
      let x = (geometry.x)(value)
      if _grid-major(x-axis) {
        place(top + left, line(start: (x, geometry.top), end: (x, geometry.top + geometry.height), stroke: theme.grid-stroke))
      }
      if x-axis.show-ticks {
        place(top + left, line(start: (x, geometry.top + geometry.height), end: (x, geometry.top + geometry.height + theme.tick-length), stroke: theme.tick-stroke))
      }
      let label = _tick-label(x-axis, entry)
      if x-axis.show-labels and label != none {
        centered-at((x, geometry.top + geometry.height + theme.tick-length + theme.tick-label-gap + theme.text-size / 2), box(text(size: theme.text-size, fill: theme.text-fill, label)))
      }
    }
    for entry in y-axis.ticks {
      let value = _tick-value(entry)
      let y = (geometry.y)(value)
      if _grid-major(y-axis) {
        place(top + left, line(start: (geometry.left, y), end: (geometry.left + geometry.width, y), stroke: theme.grid-stroke))
      }
      if y-axis.show-ticks {
        place(top + left, line(start: (geometry.left - theme.tick-length, y), end: (geometry.left, y), stroke: theme.tick-stroke))
      }
      let label = _tick-label(y-axis, entry)
      if y-axis.show-labels and label != none {
        place(top + left, dx: geometry.left - theme.tick-length - theme.tick-label-gap, dy: y,
          box(width: 0pt, height: 0pt, place(right + horizon, box(text(size: theme.text-size, fill: theme.text-fill, label)))),
        )
      }
    }
    if x2-axis != none {
      for entry in x2-axis.minor-ticks {
        let value = _tick-value(entry)
        let x = (geometry.x2)(value)
        if _grid-minor(x2-axis) {
          place(top + left, line(start: (x, geometry.top), end: (x, geometry.top + geometry.height), stroke: theme.minor-grid-stroke))
        }
        if x2-axis.show-ticks {
          place(top + left, line(start: (x, geometry.top - theme.minor-tick-length), end: (x, geometry.top), stroke: theme.minor-tick-stroke))
        }
      }
      for entry in x2-axis.ticks {
        let value = _tick-value(entry)
        let x = (geometry.x2)(value)
        if _grid-major(x2-axis) {
          place(top + left, line(start: (x, geometry.top), end: (x, geometry.top + geometry.height), stroke: theme.grid-stroke))
        }
        if x2-axis.show-ticks {
          place(top + left, line(start: (x, geometry.top - theme.tick-length), end: (x, geometry.top), stroke: theme.tick-stroke))
        }
        let label = _tick-label(x2-axis, entry)
        if x2-axis.show-labels and label != none {
          centered-at((x, geometry.top - theme.tick-length - theme.tick-label-gap - theme.text-size / 2), box(text(size: theme.text-size, fill: theme.text-fill, label)))
        }
      }
    }
    if y2-axis != none {
      for entry in y2-axis.minor-ticks {
        let value = _tick-value(entry)
        let y = (geometry.y2)(value)
        if _grid-minor(y2-axis) {
          place(top + left, line(start: (geometry.left, y), end: (geometry.left + geometry.width, y), stroke: theme.minor-grid-stroke))
        }
        if y2-axis.show-ticks {
          place(top + left, line(start: (geometry.left + geometry.width, y), end: (geometry.left + geometry.width + theme.minor-tick-length, y), stroke: theme.minor-tick-stroke))
        }
      }
      for entry in y2-axis.ticks {
        let value = _tick-value(entry)
        let y = (geometry.y2)(value)
        if _grid-major(y2-axis) {
          place(top + left, line(start: (geometry.left, y), end: (geometry.left + geometry.width, y), stroke: theme.grid-stroke))
        }
        if y2-axis.show-ticks {
          place(top + left, line(start: (geometry.left + geometry.width, y), end: (geometry.left + geometry.width + theme.tick-length, y), stroke: theme.tick-stroke))
        }
        let label = _tick-label(y2-axis, entry)
        if y2-axis.show-labels and label != none {
          place(top + left, dx: geometry.left + geometry.width + theme.tick-length + theme.tick-label-gap, dy: y,
            box(width: 0pt, height: 0pt, place(left + horizon, box(text(size: theme.text-size, fill: theme.text-fill, label)))),
          )
        }
      }
    }
    place(top + left, dx: geometry.left, dy: geometry.top,
      block(width: geometry.width, height: geometry.height, clip: layout.clip,
        move(dx: -geometry.left, dy: -geometry.top, body(geometry)),
      ),
    )
    if layout.frame {
      place(top + left, rect(width: geometry.width, height: geometry.height, stroke: theme.frame-stroke, fill: none), dx: geometry.left, dy: geometry.top)
    } else {
      if x-axis.show-line { place(top + left, line(start: (geometry.left, geometry.top + geometry.height), end: (geometry.left + geometry.width, geometry.top + geometry.height), stroke: theme.frame-stroke)) }
      if y-axis.show-line { place(top + left, line(start: (geometry.left, geometry.top), end: (geometry.left, geometry.top + geometry.height), stroke: theme.frame-stroke)) }
      if x2-axis != none and x2-axis.show-line { place(top + left, line(start: (geometry.left, geometry.top), end: (geometry.left + geometry.width, geometry.top), stroke: theme.frame-stroke)) }
      if y2-axis != none and y2-axis.show-line { place(top + left, line(start: (geometry.left + geometry.width, geometry.top), end: (geometry.left + geometry.width, geometry.top + geometry.height), stroke: theme.frame-stroke)) }
    }
    if x-axis.label != none {
      centered-at((geometry.left + geometry.width / 2, height - theme.label-size / 2),
        box(width: geometry.width, align(center, text(size: theme.label-size, fill: theme.label-fill, x-axis.label))),
      )
    }
    if y-axis.label != none {
      centered-at((theme.label-size / 2, geometry.top + geometry.height / 2),
        rotate(-90deg, box(width: geometry.height, align(center, text(size: theme.label-size, fill: theme.label-fill, y-axis.label)))),
      )
    }
    if x2-axis != none and x2-axis.label != none {
      centered-at((geometry.left + geometry.width / 2, theme.label-size / 2),
        box(width: geometry.width, align(center, text(size: theme.label-size, fill: theme.label-fill, x2-axis.label))),
      )
    }
    if y2-axis != none and y2-axis.label != none {
      centered-at((width - theme.label-size / 2, geometry.top + geometry.height / 2),
        rotate(90deg, box(width: geometry.height, align(center, text(size: theme.label-size, fill: theme.label-fill, y2-axis.label)))),
      )
    }
  })
}

/// Draw a scientific axis frame with explicit axis and layout values.
#let scientific-frame(width, height, x-axis, y-axis, body, x2-axis: none, y2-axis: none, layout: plot-layout(), theme: plot-theme()) = {
  _draw-frame(width, height, x-axis, y-axis, body, layout, theme, x2-axis: x2-axis, y2-axis: y2-axis)
}

/// Draw an exact square matrix viewport with explicit axis and layout values.
#let matrix-frame(width, height, x-axis, y-axis, body, layout: plot-layout(), theme: plot-theme()) = {
  _draw-frame(width, height, x-axis, y-axis, body, layout, theme, square: true)
}

/// Construct an item for a categorical or shared legend.
#let legend-item(
  label,
  kind: "line",
  stroke: black + 0.8pt,
  fill: black,
  radius: 2.6pt,
  preview: none,
) = (label: label, kind: kind, stroke: stroke, fill: fill, radius: radius, preview: preview)

#let _legend-preview(item, theme) = {
  let kind = item.at("kind", default: "line")
  if kind == "line" { line(length: theme.legend-swatch-width, stroke: item.stroke) }
  else if kind == "circle" { circle(radius: item.at("radius", default: 2.6pt), fill: item.fill, stroke: item.at("stroke", default: none)) }
  else if kind == "square" { rect(width: 5pt, height: 5pt, fill: item.fill, stroke: item.at("stroke", default: none)) }
  else if kind == "content" { item.preview }
  else { panic("unsupported legend preview kind: " + kind) }
}

/// Draw one measured legend panel around arbitrary content.
#let legend-panel(body, style: legend-style(), theme: plot-theme()) = {
  let inset = if style.inset == auto { theme.legend-inset } else { style.inset }
  let fill = if style.fill == auto { theme.legend-fill } else { style.fill }
  let stroke = if style.stroke == auto { theme.legend-stroke } else { style.stroke }
  let radius = if style.radius == auto { theme.legend-radius } else { style.radius }
  box(width: style.width, inset: inset, fill: fill, stroke: stroke, radius: radius, body)
}

/// Draw categorical legend items with explicit flow and wrapping.
#let categorical-legend(items, style: legend-style(), theme: plot-theme()) = {
  let columns = if style.columns != auto { calc.max(1, style.columns) }
  else if style.direction == "column" { 1 }
  else if style.max-columns != auto { calc.min(items.len(), calc.max(1, style.max-columns)) }
  else { calc.max(1, items.len()) }
  let item-gap = if style.item-gap == auto { theme.legend-item-gap } else { style.item-gap }
  let cells = items.map(item => grid(
    columns: (theme.legend-swatch-width, auto),
    column-gutter: theme.legend-swatch-gap,
    align(horizon, _legend-preview(item, theme)),
    text(size: theme.text-size, fill: theme.label-fill, item.label),
  ))
  legend-panel(
    grid(columns: (auto,) * columns, column-gutter: item-gap, row-gutter: style.row-gap, ..cells),
    style: style,
    theme: theme,
  )
}

/// Draw a standalone categorical legend, suitable for sharing across plots.
#let plot-legend(items, style: legend-style(), theme: plot-theme()) = {
  categorical-legend(items, style: style, theme: theme)
}

#let _default-anchor(position) = (
  top: bottom,
  bottom: top,
  left: right,
  right: left,
  inner-north-west: top + left,
  inner-north: top,
  inner-north-east: top + right,
  inner-west: left + horizon,
  inner-center: center + horizon,
  inner-east: right + horizon,
  inner-south-west: bottom + left,
  inner-south: bottom,
  inner-south-east: bottom + right,
).at(position, default: center + horizon)

#let _inner-alignment(position) = (
  inner-north-west: top + left,
  inner-north: top,
  inner-north-east: top + right,
  inner-west: left + horizon,
  inner-center: center + horizon,
  inner-east: right + horizon,
  inner-south-west: bottom + left,
  inner-south: bottom,
  inner-south-east: bottom + right,
).at(position, default: center + horizon)

#let is-inner-legend(position) = type(position) == array or (type(position) == str and position.starts-with("inner-"))

#let _anchor-factors(anchor) = {
  let x = if anchor in (left, top + left, bottom + left, left + horizon) { 0.0 }
  else if anchor in (right, top + right, bottom + right, right + horizon) { 1.0 }
  else { 0.5 }
  let y = if anchor in (top, top + left, top + right) { 0.0 }
  else if anchor in (bottom, bottom + left, bottom + right) { 1.0 }
  else { 0.5 }
  (x, y)
}

#let _place-at-point(x, y, body, anchor) = context {
  let size = measure(body)
  let (fx, fy) = _anchor-factors(anchor)
  place(top + left, dx: x - fx * size.width, dy: y - fy * size.height, body)
}

/// Place a legend against the exact data viewport of a rendered frame.
#let place-inner-legend(geometry, legend, style: legend-style()) = {
  if not is-inner-legend(style.position) { panic("place-inner-legend requires an inner position") }
  let position = style.position
  let x = if type(position) == array {
    geometry.left + position.at(0) * geometry.width
  } else if position.ends-with("west") or position == "inner-west" {
    geometry.left + style.gutter
  } else if position.ends-with("east") or position == "inner-east" {
    geometry.left + geometry.width - style.gutter
  } else { geometry.left + geometry.width / 2 }
  let y = if type(position) == array {
    geometry.top + position.at(1) * geometry.height
  } else if position.contains("north") {
    geometry.top + style.gutter
  } else if position.contains("south") {
    geometry.top + geometry.height - style.gutter
  } else { geometry.top + geometry.height / 2 }
  let anchor = if style.anchor != auto { style.anchor }
  else if type(position) == array { center + horizon }
  else { _inner-alignment(position) }
  _place-at-point(
    x + style.offset.at(0),
    y + style.offset.at(1),
    legend,
    anchor,
  )
}

/// Compose a plot and legend at an outer side or inside the plot viewport.
#let compose-legend(body, legend, style: legend-style()) = {
  if style.position == none { return body }
  let shifted = move(dx: style.offset.at(0), dy: style.offset.at(1), legend)
  if style.position == "bottom" {
    block(breakable: false, grid(columns: (auto,), row-gutter: style.gutter, body, align(if style.anchor == auto { top } else { style.anchor }, shifted)))
  } else if style.position == "top" {
    block(breakable: false, grid(columns: (auto,), row-gutter: style.gutter, align(if style.anchor == auto { bottom } else { style.anchor }, shifted), body))
  } else if style.position == "right" {
    block(breakable: false, grid(columns: (auto, auto), column-gutter: style.gutter, body, align(if style.anchor == auto { left + horizon } else { style.anchor }, shifted)))
  } else if style.position == "left" {
    block(breakable: false, grid(columns: (auto, auto), column-gutter: style.gutter, align(if style.anchor == auto { right + horizon } else { style.anchor }, shifted), body))
  } else {
    let alignment = if type(style.position) == array { top + left } else { _inner-alignment(style.position) }
    let overlay = if type(style.position) == array {
      let x = if type(style.position.at(0)) == ratio { style.position.at(0) } else { style.position.at(0) * 100% }
      let y = if type(style.position.at(1)) == ratio { style.position.at(1) } else { style.position.at(1) * 100% }
      _place-at-point(x, y, shifted, if style.anchor == auto { center + horizon } else { style.anchor })
    } else if style.anchor == auto { place(alignment, shifted) }
    else { place(alignment, box(width: 0pt, height: 0pt, place(style.anchor, shifted))) }
    block(breakable: false, { body; overlay })
  }
}

/// Place a standalone legend around or inside arbitrary content.
#let place-legend(body, legend, style: legend-style()) = {
  compose-legend(body, legend, style: style)
}
