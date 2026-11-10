#import "./layout_math.typ": _clamp-centered-label-left, _resolve-length

/// Default gap between a coordinate-axis tick and its label
#let _default-axis-label-gap = 2.5pt

/// Default gap between a scale bar and its label
#let _default-scale-label-gap = 1.5pt

/// Minimum horizontal gap required between two adjacent tick labels before the
/// axis starts dropping ticks. Unrelated to `_default-axis-label-gap`, which is
/// vertical.
#let _default-tick-label-min-gap = 2pt

/// Returns whether a numeric value is effectively an integer.
///
/// - value (int, float): Value to check.
/// -> bool
#let _value-is-integer(value) = {
  let nearest-int = calc.round(value)
  calc.abs(value - nearest-int) < 1e-6
}

/// Formats a scale label with optional unit.
///
/// - value (int, float): Scale value.
/// - unit (str, none): Optional unit suffix.
/// -> str
#let _format-scale-label(value, unit) = {
  let rounded = calc.round(value, digits: 2)
  let display-value = if _value-is-integer(rounded) {
    int(calc.round(rounded))
  } else {
    rounded
  }

  if unit == none { str(display-value) } else {
    str(display-value) + " " + unit
  }
}

/// Builds label content for axis and scale annotations.
///
/// - label (str, content): Label content.
/// - size (length): Label font size.
/// -> content
#let _make-axis-scale-label(label, size) = text(
  size: size,
  bottom-edge: "descender",
)[#label]

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
#let _tick-labels-fit(entries, gap) = range(1, entries.len()).all(index => (
  entries.at(index).label-left >= entries.at(index - 1).label-right + gap
))

/// Snaps a scale length up or down to a 1/2.5/5/7.5 x 10^n step.
///
/// - target (float): Target scale length.
/// - ceil (bool): Round the mantissa up to the next step when `true`, down when
///   `false`.
/// -> float
#let _snap-scale(target, ceil) = {
  let exponent = calc.floor(calc.log(target))
  let base = calc.pow(10, exponent)
  let scaled = target / base
  let steps = (1, 2.5, 5, 7.5, 10)
  // `scaled` normally lands in [1, 10), but floating-point error in the
  // mantissa split can push it outside; fall back to the nearest end step.
  let step = if ceil {
    steps.find(candidate => scaled <= candidate)
  } else {
    steps.rev().find(candidate => scaled >= candidate)
  }
  if step == none { step = if ceil { 10 } else { 1 } }
  step * base
}

/// Rounds a scale length to 1/2.5/5/7.5 x 10^n.
///
/// - target (float): Target scale length.
/// -> float
#let _round-scale(target) = {
  if target <= 0 { return 1 }
  _snap-scale(target, true)
}

/// Floors a scale length to 1/2.5/5/7.5 x 10^n.
///
/// - target (float): Maximum allowed scale length.
/// -> float
#let _floor-scale(target) = {
  if target <= 0 { return 0 }
  _snap-scale(target, false)
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
/// -> array: Dictionaries with `x` (length), `label-text` (content),
///   `label-left` (length), and `label-right` (length).
#let _resolve-coordinate-axis-tick-layout(
  region-start,
  region-end,
  region-length,
  track-width,
  axis-left,
  label-size,
  unit,
) = {
  let label-gap = _default-tick-label-min-gap
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
    let label-text = _make-axis-scale-label(label, label-size)
    let label-width = measure(label-text).width
    let label-left = _clamp-centered-label-left(
      x,
      label-width,
      axis-left,
      track-width,
    )

    entries.push((
      x: x,
      label-text: label-text,
      label-left: label-left,
      label-right: label-left + label-width,
    ))
  }

  if entries.len() <= 1 { return entries }

  let stride = 1

  while stride <= entries.len() {
    let offset = 0

    while offset < stride {
      let sampled = range(offset, entries.len(), step: stride).map(index => (
        entries.at(index)
      ))

      if _tick-labels-fit(sampled, label-gap) { return sampled }

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

/// Places a line, skipping it when the stroke is `none`.
///
/// Unlike `curve`, `polygon`, `rect`, and `grid.cell`, Typst's `line` rejects
/// `stroke: none`, so every line drawn from a user-supplied stroke goes through
/// this helper.
///
/// - start (array): Line start as `(x, y)` lengths.
/// - end (array): Line end as `(x, y)` lengths.
/// - line-stroke (stroke, none): Line stroke styling. `none` draws nothing.
/// -> content, none
#let _draw-line(start, end, line-stroke) = {
  if line-stroke != none {
    place(top + left, line(start: start, end: end, stroke: line-stroke))
  }
}

/// Draws a horizontal line segment.
///
/// - x (length): Starting x-position.
/// - y (length): Starting y-position.
/// - length (length): Segment length.
/// - line-stroke (stroke, none): Line stroke styling. `none` draws nothing.
/// Non-positive lengths draw nothing and return `none`.
/// -> content, none
#let _draw-horizontal-segment(x, y, length, line-stroke) = {
  if length > 0pt {
    _draw-line((x, y), (x + length, y), line-stroke)
  }
}

/// Draws a vertical line segment.
///
/// - x (length): Starting x-position.
/// - y (length): Starting y-position.
/// - length (length): Segment length.
/// - line-stroke (stroke, none): Line stroke styling. `none` draws nothing.
/// Non-positive lengths draw nothing and return `none`.
/// -> content, none
#let _draw-vertical-segment(x, y, length, line-stroke) = {
  if length > 0pt {
    _draw-line((x, y), (x, y + length), line-stroke)
  }
}

/// Returns the height a labeled tick row occupies.
///
/// Shared by the coordinate axis and the scale bar: callers that stack content
/// around either one must reserve the same vertical extent it draws into. Must
/// be called inside a `context` block.
///
/// - labels (array): Tick-label strings whose tallest measurement is used.
/// - label-size (length): Tick-label font size.
/// - tick-height (length): Tick height.
/// - label-gap (length): Gap between tick and label.
/// -> length
#let _tick-row-height(labels, label-size, tick-height, label-gap) = (
  tick-height
    + label-gap
    + labels
      .map(label => measure(_make-axis-scale-label(label, label-size)).height)
      .fold(0pt, calc.max)
)

/// Draws a scale-bar row with centered, clamped label.
///
/// - row-width (length): Width of the scale-bar row.
/// - bar-top (length): Top offset for the scale bar.
/// - bar-left (length): Left offset for the scale bar.
/// - bar-width (length): Scale bar width.
/// - tick-height (length): Tick height.
/// - label-gap (length): Gap between ticks and label.
/// - label-size (length): Label font size.
/// - label (str): Label text.
/// - bar-stroke (stroke, none): Stroke styling for bar and ticks.
/// -> content
#let _draw-scale-bar-row(
  row-width,
  bar-top,
  bar-left,
  bar-width,
  tick-height,
  label-gap,
  label-size,
  label,
  bar-stroke,
) = context {
  let row-width-abs = _resolve-length(row-width)
  let bar-left-abs = _resolve-length(bar-left)
  let bar-width-abs = _resolve-length(bar-width)
  let label-text = _make-axis-scale-label(label, label-size)
  let label-size-box = measure(label-text)
  let label-left = _clamp-centered-label-left(
    bar-left-abs + bar-width-abs / 2,
    label-size-box.width,
    0pt,
    row-width-abs,
  )

  box(
    width: row-width-abs,
    height: bar-top + tick-height + label-gap + label-size-box.height,
    {
      _draw-horizontal-segment(
        bar-left-abs,
        bar-top + tick-height / 2,
        bar-width-abs,
        bar-stroke,
      )
      _draw-vertical-segment(bar-left-abs, bar-top, tick-height, bar-stroke)
      _draw-vertical-segment(
        bar-left-abs + bar-width-abs,
        bar-top,
        tick-height,
        bar-stroke,
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
/// - region-start (int): Region start coordinate.
/// - region-end (int): Region end coordinate.
/// - region-length (int): Region length.
/// - track-width (length): Axis width.
/// - axis-top (length): Axis top offset.
/// - tick-height (length): Tick height.
/// - label-gap (length): Gap between tick and label.
/// - label-size (length): Label font size.
/// - axis-stroke (stroke, none): Stroke styling for the axis line and ticks.
/// - unit (str, none): Optional unit suffix for tick labels.
/// - axis-left (length): Left offset for axis line and ticks.
/// -> content, none
#let _draw-coordinate-axis(
  region-start,
  region-end,
  region-length,
  track-width,
  axis-top,
  tick-height,
  label-gap,
  label-size,
  axis-stroke,
  unit: none,
  axis-left: 0pt,
) = {
  _draw-horizontal-segment(axis-left, axis-top, track-width, axis-stroke)
  let tick-layout = _resolve-coordinate-axis-tick-layout(
    region-start,
    region-end,
    region-length,
    track-width,
    axis-left,
    label-size,
    unit,
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
