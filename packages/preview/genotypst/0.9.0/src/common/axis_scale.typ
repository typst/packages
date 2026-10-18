#import "./layout_math.typ": _clamp, _resolve-length

/// Formats a scale label with optional unit.
///
/// - value (int, float): Scale value.
/// - unit (str, none): Optional unit suffix.
/// -> str
#let _format-scale-label(value, unit) = {
  let rounded = calc.round(value, digits: 2)
  let nearest-int = calc.round(rounded)
  let display-value = if calc.abs(rounded - nearest-int) < 1e-6 {
    int(nearest-int)
  } else {
    rounded
  }

  if unit == none { str(display-value) } else {
    str(display-value) + " " + unit
  }
}

/// Builds label content for axis and scale annotations.
///
/// Omits `fill` when `color` is `none` so labels inherit ambient text color.
///
/// - label (str, content): Label content.
/// - size (length): Label font size.
/// - color (color, none): Optional label color.
/// -> content
#let _make-axis-scale-label(label, size, color: none) = text(
  size: size,
  bottom-edge: "descender",
  ..if color != none { (fill: color) },
)[#label]

/// Returns whether a numeric value is effectively integral.
///
/// - value (int, float): Value to check.
/// -> bool
#let _value-is-integer(value) = {
  let nearest-int = calc.round(value)
  calc.abs(value - nearest-int) < 1e-6
}

/// Normalizes an effectively integral numeric value to an integer.
///
/// - value (int, float): Value to normalize.
/// -> int
#let _normalize-intish(value) = {
  assert(_value-is-integer(value), message: "value must be an integer.")
  int(calc.round(value))
}

/// Returns whether adjacent label boxes fit without overlap.
///
/// - entries (array): Tick-layout entries with `label-left` and `label-right`.
/// - gap (length): Minimum gap between adjacent labels.
/// -> bool
#let _tick-labels-fit(entries, gap) = {
  let index = 1
  while index < entries.len() {
    let previous = entries.at(index - 1)
    let current = entries.at(index)
    if current.label-left < previous.label-right + gap {
      return false
    }
    index += 1
  }

  true
}

/// Rounds a scale length to 1/2.5/5/7.5 x 10^n.
///
/// - target (float): Target scale length.
/// -> float
#let _round-scale(target) = {
  if target <= 0 { return 1 }

  let exponent = calc.floor(calc.log(target))
  let base = calc.pow(10, exponent)
  let scaled = target / base
  let step = if scaled <= 1 { 1 } else if scaled <= 2.5 { 2.5 } else if (
    scaled <= 5
  ) { 5 } else if scaled <= 7.5 {
    7.5
  } else { 10 }
  step * base
}

/// Floors a scale length to 1/2.5/5/7.5 x 10^n.
///
/// - target (float): Maximum allowed scale length.
/// -> float
#let _floor-scale(target) = {
  if target <= 0 { return 0 }

  let exponent = calc.floor(calc.log(target))
  let base = calc.pow(10, exponent)
  let scaled = target / base
  let step = if scaled >= 10 { 10 } else if scaled >= 7.5 { 7.5 } else if (
    scaled >= 5
  ) { 5 } else if scaled >= 2.5 {
    2.5
  } else { 1 }
  step * base
}

/// Resolves the integer tick values used by a coordinate axis.
///
/// Returns a single normalized `region-start` tick when `region-length <= 0`.
///
/// - region-start (int): Region start coordinate.
/// - region-end (int): Region end coordinate.
/// - region-length (int): Region length.
/// -> array: Integer tick values.
#let _resolve-coordinate-axis-ticks(region-start, region-end, region-length) = {
  assert(
    _value-is-integer(region-start),
    message: "region-start must be an integer.",
  )
  if region-length > 0 {
    assert(
      _value-is-integer(region-end),
      message: "region-end must be an integer.",
    )
  }

  if region-length <= 0 {
    return (_normalize-intish(region-start),)
  }

  let tick-step = int(calc.ceil(region-length / 10))
  let first-tick = calc.ceil(region-start / tick-step) * tick-step
  let tick-limit = region-end + 1e-6
  let ticks = ()
  let tick = first-tick

  while tick <= tick-limit {
    ticks.push(_normalize-intish(tick))
    tick += tick-step
  }

  ticks
}

/// Resolves coordinate-axis tick layout while skipping overlapping labels.
///
/// Returns only the visible non-overlapping tick labels after any needed
/// subsampling.
///
/// - region-start (int): Region start coordinate.
/// - region-end (int): Region end coordinate.
/// - region-length (int): Region length.
/// - track-width (length): Axis width.
/// - axis-left (length): Axis left offset.
/// - label-size (length): Tick-label size.
/// - unit (str, none): Optional unit suffix.
/// - axis-color (color, none): Optional label color.
/// -> array: Dictionaries with `x` (length), `label-text` (content), and
///   `label-left` (length).
#let _resolve-coordinate-axis-tick-layout(
  region-start,
  region-end,
  region-length,
  track-width,
  axis-left,
  label-size,
  unit,
  axis-color,
) = {
  let label-gap = 2pt
  let ticks = _resolve-coordinate-axis-ticks(
    region-start,
    region-end,
    region-length,
  )
  let entries = ()

  for tick in ticks {
    let x = if region-length <= 0 { axis-left + track-width / 2 } else {
      axis-left + track-width * ((tick - region-start) / region-length)
    }
    let label = _format-scale-label(tick, unit)
    let label-text = _make-axis-scale-label(
      label,
      label-size,
      color: axis-color,
    )
    let label-width = measure(label-text).width
    let label-max-left = calc.max(
      axis-left,
      axis-left + track-width - label-width,
    )
    let label-left = _clamp(
      x - label-width / 2,
      axis-left,
      label-max-left,
    )

    entries.push((
      x: x,
      label-text: label-text,
      label-left: label-left,
      label-right: label-left + label-width,
    ))
  }

  if entries.len() <= 1 {
    return entries.map(entry => (
      x: entry.x,
      label-text: entry.label-text,
      label-left: entry.label-left,
    ))
  }

  let stride = 1

  while stride <= entries.len() {
    let offset = 0

    while offset < stride {
      let sampled = ()
      let index = offset

      while index < entries.len() {
        sampled.push(entries.at(index))
        index += stride
      }

      if _tick-labels-fit(sampled, label-gap) {
        return sampled.map(entry => (
          x: entry.x,
          label-text: entry.label-text,
          label-left: entry.label-left,
        ))
      }

      offset += 1
    }

    stride += 1
  }
}

/// Resolves the effective scale-bar length and width.
///
/// When `scale-length` is `auto`, targets the larger of `region-length / 10`
/// and the length needed to reach `min-auto-bar-width`.
/// Prefers a rounded value when it fits, otherwise falls back to the exact
/// target or the largest fitting rounded value.
///
/// - scale-length (auto, int, float): Requested scale length. Positive when not auto.
/// - region-length (float): Underlying coordinate span in scale units.
/// - x-scale (length): Length per coordinate unit.
/// - max-bar-width (length): Maximum drawable bar width.
/// - min-auto-bar-width (length): Minimum rendered width used only in auto mode.
/// - zero-length-message (str): Error message used when region-length <= 0.
/// -> dictionary
#let _resolve-scale-bar-length(
  scale-length,
  region-length,
  x-scale,
  max-bar-width,
  min-auto-bar-width: 0pt,
  zero-length-message: "Cannot render scale bar for zero-length region.",
) = {
  assert(
    scale-length == auto
      or type(scale-length) == int
      or type(scale-length) == float,
    message: "scale-length must be auto, an integer, or a float.",
  )
  if scale-length != auto {
    assert(scale-length > 0, message: "scale-length must be positive.")
  }
  assert(region-length > 0, message: zero-length-message)

  let max-bar-width-abs = _resolve-length(max-bar-width)
  let x-scale-abs = _resolve-length(x-scale)
  assert(
    max-bar-width-abs > 0pt,
    message: "Cannot render scale bar: available width is too small.",
  )
  assert(
    x-scale-abs > 0pt,
    message: "Cannot render scale bar: scale conversion is zero.",
  )
  let min-auto-bar-width-abs = _resolve-length(min-auto-bar-width)
  assert(
    min-auto-bar-width-abs >= 0pt,
    message: "min-auto-bar-width must be non-negative.",
  )

  let max-fit-length = max-bar-width-abs / x-scale-abs

  let resolved-length = if scale-length == auto {
    let auto-target = calc.max(
      region-length / 10,
      min-auto-bar-width-abs / x-scale-abs,
    )
    let candidate = _round-scale(auto-target)
    if candidate <= max-fit-length {
      candidate
    } else if auto-target <= max-fit-length {
      auto-target
    } else {
      _floor-scale(max-fit-length)
    }
  } else {
    scale-length
  }

  let resolved-width = resolved-length * x-scale-abs
  let fit-tolerance = 0.01pt
  assert(
    resolved-width <= max-bar-width-abs + fit-tolerance,
    message: (
      "scale-length "
        + (if scale-length == auto { "auto" } else { str(scale-length) })
        + " does not fit the available width for the current dimensions."
    ),
  )

  (length: resolved-length, width: resolved-width)
}

/// Draws a horizontal line segment.
///
/// - x (length): Starting x-position.
/// - y (length): Starting y-position.
/// - length (length): Segment length.
/// - stroke (stroke): Line stroke styling.
/// Non-positive lengths draw nothing and return `none`.
/// -> content, none
#let _draw-horizontal-segment(x, y, length, stroke) = {
  if length > 0pt {
    place(top + left, dx: x, dy: y, line(
      start: (0pt, 0pt),
      end: (length, 0pt),
      stroke: stroke,
    ))
  }
}

/// Draws a vertical line segment.
///
/// - x (length): Starting x-position.
/// - y (length): Starting y-position.
/// - length (length): Segment length.
/// - stroke (stroke): Line stroke styling.
/// Non-positive lengths draw nothing and return `none`.
/// -> content, none
#let _draw-vertical-segment(x, y, length, stroke) = {
  if length > 0pt {
    place(top + left, dx: x, dy: y, line(
      start: (0pt, 0pt),
      end: (0pt, length),
      stroke: stroke,
    ))
  }
}

/// Draws a scale-bar row with centered, clamped label.
///
/// - row-width (length): Width of the scale-bar row.
/// - bar-top (length): Top offset for the scale bar.
/// - bar-left (length): Left offset for the scale bar.
/// - bar-width (length): Scale bar width.
/// - tick-height (length): Tick height.
/// - label-gap (length): Gap between ticks and label.
/// - label-size (length): Label font size.
/// - label-color (color, none): Label color.
/// - label (str): Label text.
/// - stroke-color (color): Stroke color for bar and ticks.
/// - stroke-width (length): Stroke thickness for bar and ticks.
/// -> content
#let _draw-scale-bar-row(
  row-width,
  bar-top,
  bar-left,
  bar-width,
  tick-height,
  label-gap,
  label-size,
  label-color,
  label,
  stroke-color,
  stroke-width,
) = context {
  let row-width-abs = _resolve-length(row-width)
  let bar-left-abs = _resolve-length(bar-left)
  let bar-width-abs = _resolve-length(bar-width)
  let stroke = (paint: stroke-color, thickness: stroke-width, cap: "round")
  let label-text = _make-axis-scale-label(
    label,
    label-size,
    color: label-color,
  )
  let label-size-box = measure(label-text)
  let label-width-abs = _resolve-length(label-size-box.width)
  let label-left = _clamp(
    bar-left-abs + bar-width-abs / 2 - label-width-abs / 2,
    0pt,
    calc.max(0pt, row-width-abs - label-width-abs),
  )

  box(
    width: row-width-abs,
    height: bar-top + tick-height + label-gap + label-size-box.height,
    {
      _draw-horizontal-segment(
        bar-left-abs,
        bar-top + tick-height / 2,
        bar-width-abs,
        stroke,
      )
      _draw-vertical-segment(bar-left-abs, bar-top, tick-height, stroke)
      _draw-vertical-segment(
        bar-left-abs + bar-width-abs,
        bar-top,
        tick-height,
        stroke,
      )
      place(
        top + left,
        dx: label-left,
        dy: bar-top + tick-height + label-gap,
        label-text,
      )
    },
  )
}

/// Draws a coordinate axis with ticks and labels.
///
/// Returns `none` when `coordinate-axis` is false.
///
/// - coordinate-axis (bool): Whether to draw the axis.
/// - region-start (int): Region start coordinate.
/// - region-end (int): Region end coordinate.
/// - region-length (int): Region length.
/// - track-width (length): Axis width.
/// - axis-top (length): Axis top offset.
/// - tick-height (length): Tick height.
/// - label-gap (length): Gap between tick and label.
/// - label-size (length): Label font size.
/// - unit (str, none): Unit suffix.
/// - axis-color (color, none): Axis label color.
/// - axis-stroke (stroke): Stroke styling.
/// - axis-left (length): Left offset for axis line and ticks (default: 0pt).
/// -> content, none
#let _draw-coordinate-axis(
  coordinate-axis,
  region-start,
  region-end,
  region-length,
  track-width,
  axis-top,
  tick-height,
  label-gap,
  label-size,
  unit,
  axis-color,
  axis-stroke,
  axis-left: 0pt,
) = {
  if coordinate-axis {
    _draw-horizontal-segment(axis-left, axis-top, track-width, axis-stroke)
    let tick-layout = _resolve-coordinate-axis-tick-layout(
      region-start,
      region-end,
      region-length,
      track-width,
      axis-left,
      label-size,
      unit,
      axis-color,
    )

    for entry in tick-layout {
      _draw-vertical-segment(entry.x, axis-top, tick-height, axis-stroke)
      place(
        top + left,
        dx: entry.label-left,
        dy: axis-top + tick-height + label-gap,
        entry.label-text,
      )
    }
  }
}
