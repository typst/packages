///! Nanoplot renderers drawn with native Typst primitives.
///!
///! A nanoplot is a shape, not a chart: no axes, no labels, no legend. Native
///! `curve`, `rect`, and `circle` inside a `box` draw one in a few lines, so the
///! package needs no plotting dependency and no third-party canvas.
///!
///! Every coordinate is computed as a fraction of the box and multiplied by the
///! width or height only when it is drawn, so the caller's units are whatever
///! they gave: an `em` size tracks `set text(size: ..)`, needs no absolute
///! resolution, and never has to be compared against a length in other units.
///! That is what lets a sparkline sit at 0.8em, the height Tufte's guidance and
///! Typst's em semantics both point at.
///!
///! A renderer is a dictionary `(kind: "nanoplot-renderer", draw, readings,
///! axis)`. `format-nanoplot` accepts any dictionary of this shape, so a
///! renderer written in a document works exactly as well as these four.

#import "../utils/errors.typ": check, fail-type
#import "nanoplot.typ": values-of

// The ink follows the surrounding text unless a colour is given, so a plot in a
// styled cell is drawn in that cell's colour rather than in a fixed black.
#let _ink(given) = if given == auto { text.fill } else { given }

// Falls back to the series' own range, so a renderer called by hand outside
// `format-nanoplot` still draws. Inside it, the domain always spans the column.
#let _range(numbers, domain) = {
  if domain != none { return (float(domain.first()), float(domain.last())) }
  (calc.min(..numbers), calc.max(..numbers))
}

// Fractions of the box: index across it, value up it. A domain of zero span
// would divide by nothing, so a flat series draws along the middle rather than
// at an edge, and a single reading sits in the centre rather than at the left.
#let _fractions(numbers, low, high) = {
  let span = high - low
  let last = numbers.len() - 1
  numbers
    .enumerate()
    .map(((index, value)) => (
      if last == 0 { 0.5 } else { index / last },
      if span == 0 { 0.5 } else { 1 - (value - low) / span },
    ))
}

#let _dot(fraction, width, height, radius, paint) = {
  let (fx, fy) = fraction
  place(top + left, dx: width * fx - radius, dy: height * fy - radius, circle(radius: radius, fill: paint))
}

// The frame every renderer draws in: the numbers, the empty-series answer, the
// domain, and the box the contents are clipped to. `draw(values, low, high)`
// supplies the contents, and runs inside the context this opens, so `_ink`
// resolves `text.fill` there as it would written out here.
#let _canvas(numbers, domain, width, height, draw) = {
  if numbers.len() == 0 { return box(width: width, height: height) }
  context {
    let (low, high) = _range(numbers, domain)
    box(
      width: width,
      height: height,
      // A value outside the domain would otherwise be drawn outside the cell,
      // across whatever sits beside it. An explicit domain is a choice to look
      // at one window of the data, so what falls outside it is not drawn.
      clip: true,
      draw(numbers, low, high),
    )
  }
}

// A sparkline: the shape of a series, without axes or labels.
#let _line(numbers, domain: none, width: 4em, height: 0.8em, stroke: auto, thickness: 0.6pt) = {
  _canvas(numbers, domain, width, height, (values, low, high) => {
    let fractions = _fractions(values, low, high)
    let paint = _ink(stroke)
    // A single reading has no line to draw, so it draws as the point it is.
    if fractions.len() == 1 {
      _dot(fractions.first(), width, height, thickness, paint)
    } else {
      curve(
        stroke: thickness + paint,
        ..fractions
          .enumerate()
          .map(((index, fraction)) => {
            let point = (width * fraction.first(), height * fraction.last())
            if index == 0 { curve.move(point) } else { curve.line(point) }
          }),
      )
    }
  })
}

// A trend with its readings marked, for series short enough to show both.
#let _points(
  numbers,
  domain: none,
  width: 4em,
  height: 0.8em,
  stroke: auto,
  thickness: 0.6pt,
  radius: 1pt,
) = {
  _canvas(numbers, domain, width, height, (values, low, high) => {
    let paint = _ink(stroke)
    // The line is drawn by the renderer above, in a box of the same size, so
    // the marks laid over it land on the same coordinates.
    place(top + left, _line(
      values,
      domain: (low, high),
      width: width,
      height: height,
      stroke: paint,
      thickness: thickness,
    ))
    _fractions(values, low, high).map(fraction => _dot(fraction, width, height, radius, paint)).join()
  })
}

// The same series as bars, for counts rather than a trend.
//
// Bars are measured from zero, not from the domain's low: a bar drawn from 5 to
// 10 makes a small difference look like the whole quantity, which is the lie the
// shared domain exists to prevent. The line renderers scale to the domain
// instead, because a trend is about shape rather than magnitude.
#let _bar(numbers, domain: none, width: 4em, height: 0.8em, fill: auto, gap: 30%) = {
  _canvas(numbers, domain, width, height, (values, low, high) => {
    let base = calc.min(0.0, low)
    let peak = calc.max(0.0, high)
    let span = peak - base
    let pitch = 1 / values.len()
    let thick = pitch * (1 - gap / 100%)
    let paint = _ink(fill)
    // Every reading is zero, so every bar is, and there is no span to measure
    // against either.
    if span == 0 { [] } else {
      let zero = 1 - (0 - base) / span
      values
        .enumerate()
        .map(((index, value)) => {
          let level = 1 - (value - base) / span
          place(
            top + left,
            dx: width * (pitch * index + (pitch - thick) / 2),
            dy: height * calc.min(level, zero),
            rect(
              width: width * thick,
              height: height * calc.abs(level - zero),
              fill: paint,
              stroke: none,
            ),
          )
        })
        .join()
    }
  })
}

// Read when the renderer is built, and whether or not there is anything to
// draw: whether a gap leaves the bars some width does not depend on the data.
#let _check-gap(gap) = {
  // The type is tested first, because the range test compares against a
  // percentage and anything else fails that comparison rather than this check.
  if type(gap) != ratio {
    fail-type(
      "nanoplot-bar",
      "gap",
      gap,
      "a percentage of the bar pitch",
      hint: "Give a percentage of the bar pitch below 100%.",
    )
  }
  // Two ends of one range, said apart: a gap at or above the pitch leaves no bar
  // to draw, and a gap below zero would draw each bar over its neighbours. One
  // message covering both described neither.
  check(
    gap >= 0%,
    "nanoplot-bar",
    "gap cannot be negative",
    value: gap,
    hint: "A gap is the share of the bar pitch left empty between the bars.",
  )
  check(
    gap < 100%,
    "nanoplot-bar",
    "gap must leave the bars some width",
    value: gap,
    hint: "Give a percentage of the bar pitch below 100%.",
  )
}

// The three draw a series of numbers, so each reads the cell value with the
// same function it gives as its readings.
#let _renderer(plot) = (
  kind: "nanoplot-renderer",
  draw: (value, domain: none, width: 4em, height: 0.8em) => plot(
    values-of(value),
    domain: domain,
    width: width,
    height: height,
  ),
  readings: values-of,
  axis: none,
)

#let nanoplot-line(stroke: auto, thickness: 0.6pt) = _renderer(_line.with(stroke: stroke, thickness: thickness))

#let nanoplot-points(stroke: auto, thickness: 0.6pt, radius: 1pt) = _renderer(
  _points.with(stroke: stroke, thickness: thickness, radius: radius),
)

#let nanoplot-bar(fill: auto, gap: 30%) = {
  _check-gap(gap)
  _renderer(_bar.with(fill: fill, gap: gap))
}

// The bar track is measured from zero, like the bar renderer's bars, so a value
// and its colour read against one range: the colour of a bar and its length
// never disagree about how large the value is.
#let _value-bar-range(domain) = {
  let (low, high) = (float(domain.first()), float(domain.last()))
  (calc.min(0.0, low), calc.max(0.0, high))
}

// The position of a value in the zero-based range, which is where a gradient is
// sampled.
#let _value-bar-fraction(value, domain) = {
  let (base, peak) = _value-bar-range(domain)
  let span = peak - base
  if span == 0 { 0 } else { calc.clamp((value - base) / span, 0, 1) }
}

// Where the bar starts and ends along the track, as fractions of it. A bar runs
// from zero to the value, so a negative one runs from its value up to zero.
#let _value-bar-geometry(value, domain) = {
  let (at-value, at-zero) = (_value-bar-fraction(value, domain), _value-bar-fraction(0.0, domain))
  (start: calc.min(at-value, at-zero), end: calc.max(at-value, at-zero))
}

// The space between the end of the track and a label.
#let _VALUE-BAR-GAP = 0.3em

// The number a cell holds, or none for a value that is not one.
#let _value-bar-number(value) = if type(value) in (int, float, decimal) { float(value) } else { none }

// A label function may return a number or a string, so its result is written
// as content.
#let _value-bar-label(label, value) = if label == auto { str(calc.round(value)) } else { [#label(value)] }

// The room reserved to the right of the track for the label of whichever end of
// the domain is larger, so no label is wider than the room it is given. The
// peak label is measured as well, since the axis writes it in this room even
// when a custom label makes it the wider of the two.
#let _value-bar-room(label, domain) = {
  if label == none { return 0pt }
  let (base, peak) = _value-bar-range(domain)
  let widest = if calc.abs(base) > calc.abs(peak) { base } else { peak }
  let room = calc.max(measure(_value-bar-label(label, widest)).width, measure(_value-bar-label(label, peak)).width)
  room + _VALUE-BAR-GAP.to-absolute()
}

// Where the axis writes the two ends of the track. The base label starts at the
// track start, and the peak label starts at the track end, in the room kept for
// it, as a cell label does. A base label wider than the track would run into
// the peak label, so it is refused.
#let _value-bar-axis-labels(label, domain, width) = {
  let format = if label == none { auto } else { label }
  let track = width.to-absolute() - _value-bar-room(format, domain)
  let (base, peak) = _value-bar-range(domain)
  let (first, last) = (_value-bar-label(format, base), _value-bar-label(format, peak))
  let first-width = measure(first).width
  check(
    first-width <= track,
    "nanoplot-value-bar",
    "the axis label of the track's low is wider than the track",
    value: base,
    hint: "Widen the plot with width, or shorten the label.",
  )
  (
    base: (x: 0pt, width: first-width, content: first),
    peak: (x: track + _VALUE-BAR-GAP.to-absolute(), width: measure(last).width, content: last),
  )
}

// Where the label starts: right of the end of the bar, and for a negative value
// right of zero, since the end of the bar is the larger of the value and zero.
#let _value-bar-label-x(value, domain, track) = {
  track * _value-bar-geometry(value, domain).end + _VALUE-BAR-GAP.to-absolute()
}

#let _value-bar-paint(fill, value, domain) = {
  if fill == auto { return _ink(auto) }
  if type(fill) == function {
    let paint = fill(value)
    check(
      type(paint) in (color, gradient),
      "nanoplot-value-bar",
      "fill must return a colour or a gradient",
      value: paint,
      hint: "Give a function that returns a colour such as rgb(\"#c33\") or a gradient.",
    )
    return paint
  }
  if type(fill) == gradient { return fill.sample(_value-bar-fraction(value, domain) * 100%) }
  fill
}

#let _check-value-bar(fill, label, axis) = {
  if fill != auto and type(fill) not in (color, gradient, function) {
    fail-type(
      "nanoplot-value-bar",
      "fill",
      fill,
      "a colour, a gradient, or a function",
      hint: "Give a colour such as rgb(\"#c33\"), a gradient, or value => colour.",
    )
  }
  if type(axis) != bool {
    fail-type("nanoplot-value-bar", "axis", axis, "a boolean", hint: "Give true to draw the axis rows, or false.")
  }
  if label != auto and label != none and type(label) != function {
    fail-type(
      "nanoplot-value-bar",
      "label",
      label,
      "auto, none, or a function",
      hint: "Give auto, none, or value => content.",
    )
  }
}

#let nanoplot-value-bar(fill: auto, label: auto, axis: false) = {
  _check-value-bar(fill, label, axis)
  // The axis writes its ends even with no cell label, so the track keeps room
  // for them and the bars line up under the axis.
  let room-label = if label == none and axis { auto } else { label }
  let draw(value, domain: none, width: 4em, height: 0.8em) = {
    let number = _value-bar-number(value)
    if domain == none or number == none { return box(width: width, height: height) }
    context {
      let track = width.to-absolute() - _value-bar-room(room-label, domain)
      check(
        track > 0pt,
        "nanoplot-value-bar",
        "the label room leaves no track for the bars",
        value: width,
        hint: "Widen the plot with width, or shorten the label.",
      )
      let (start, end) = _value-bar-geometry(number, domain)
      box(width: width, height: height, {
        // Only the bar is clipped: a label may be taller than the cell, and its
        // descenders must not be cut.
        place(top + left, box(width: width, height: height, clip: true, place(top + left, dx: track * start, rect(
          width: track * (end - start),
          height: height,
          fill: _value-bar-paint(fill, number, domain),
          stroke: none,
        ))))
        if label != none {
          let (base, peak) = _value-bar-range(domain)
          check(
            base <= number and number <= peak,
            "nanoplot-value-bar",
            "the value is outside the domain, so its label has no room",
            value: number,
            hint: "Give a domain that holds every value, or label: none to draw the bars alone.",
          )
          let content = _value-bar-label(label, number)
          let x = _value-bar-label-x(number, domain, track)
          // The room is sized from the labels of the ends of the domain, so a
          // custom label wider for another value can still run past the cell.
          check(
            x + measure(content).width <= width.to-absolute() + 0.01pt,
            "nanoplot-value-bar",
            "the label runs past the cell",
            value: number,
            hint: "Widen the plot with width, or shorten the label.",
          )
          place(left + horizon, dx: x, content)
        }
      })
    }
  }
  let draw-axis(domain: none, width: 4em, side: "bottom") = {
    if domain == none { return none }
    context {
      let (base, peak) = _value-bar-axis-labels(label, domain, width)
      box(width: width, height: calc.max(measure(base.content).height, measure(peak.content).height), {
        place(top + left, dx: base.x, base.content)
        place(top + left, dx: peak.x, peak.content)
      })
    }
  }
  (
    kind: "nanoplot-renderer",
    draw: draw,
    readings: value => {
      let number = _value-bar-number(value)
      if number == none { () } else { (number,) }
    },
    axis: if axis { draw-axis } else { none },
  )
}
