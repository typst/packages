#let _line-sample(lines) = {
  for i in range(lines) {
    if i > 0 {
      linebreak()
    }

    [Ag]
  }
}

#let _max-lines-height(lines, factor) = {
  measure(text(size: 1em * factor)[#_line-sample(lines)]).height
}

#let _fits(size, body, factor, max-lines: none) = {
  let measured = measure(
    width: size.width,
    text(size: 1em * factor)[#body],
  )

  let fits-frame = measured.width <= size.width and measured.height <= size.height
  let fits-lines = if max-lines == none {
    true
  } else {
    measured.height <= _max-lines-height(max-lines, factor)
  }

  fits-frame and fits-lines
}

#let _is-unbounded-max(max) = max == none or max == -1

#let _validate-args(min, max, steps, max-lines, only-if-overflow) = {
  if type(min) != ratio {
    panic("framefit: `min` must be a percentage.")
  }

  if not _is-unbounded-max(max) and type(max) != ratio {
    panic("framefit: `max` must be a percentage, `none`, or `-1`.")
  }

  if not _is-unbounded-max(max) and min > max {
    panic("framefit: `min` must be less than or equal to `max`.")
  }

  if steps < 1 {
    panic("framefit: `steps` must be at least 1.")
  }

  if max-lines != none and type(max-lines) != int {
    panic("framefit: `max-lines` must be an integer or `none`.")
  }

  if max-lines != none and max-lines < 1 {
    panic("framefit: `max-lines` must be at least 1.")
  }

  if only-if-overflow and min > 100% {
    panic("framefit: `only-if-overflow` requires `min` to be 100% or less.")
  }
}

#let _bounded-fitting-factor(size, body, min, max, steps, max-lines) = {
  if not _fits(size, body, min, max-lines: max-lines) {
    panic(
      "framefit: content does not fit at the minimum size. " +
      "Make the frame larger, reduce the content, or lower `min`.",
    )
  }

  if _fits(size, body, max, max-lines: max-lines) {
    return max
  }

  let low = min
  let high = max

  for _ in range(steps) {
    let mid = low + (high - low) / 2

    if _fits(size, body, mid, max-lines: max-lines) {
      low = mid
    } else {
      high = mid
    }
  }

  low
}

#let _unbounded-fitting-factor(size, body, min, steps, max-lines) = {
  if not _fits(size, body, min, max-lines: max-lines) {
    panic(
      "framefit: content does not fit at the minimum size. " +
      "Make the frame larger, reduce the content, or lower `min`.",
    )
  }

  let low = min
  let high = if min < 100% { 100% } else { min * 2 }

  for _ in range(32) {
    if _fits(size, body, high, max-lines: max-lines) {
      low = high
      high = high * 2
    } else {
      return _bounded-fitting-factor(size, body, low, high, steps, max-lines)
    }
  }

  panic(
    "framefit: could not find an overflowing size for unbounded `max`. " +
    "Set a finite `max` for this content.",
  )
}

#let _largest-fitting-factor(size, body, min, max, steps, max-lines) = {
  if _is-unbounded-max(max) {
    _unbounded-fitting-factor(size, body, min, steps, max-lines)
  } else {
    _bounded-fitting-factor(size, body, min, max, steps, max-lines)
  }
}

#let fit-copy(
  min: 70%,
  max: none,
  max-lines: none,
  steps: 24,
  only-if-overflow: false,
  body,
) = {
  _validate-args(min, max, steps, max-lines, only-if-overflow)

  layout(size => {
    if only-if-overflow and _fits(size, body, 100%, max-lines: max-lines) {
      text(size: 1em)[#body]
    } else {
      let upper = if only-if-overflow {
        if _is-unbounded-max(max) or max > 100% { 100% } else { max }
      } else {
        max
      }
      let factor = _largest-fitting-factor(size, body, min, upper, steps, max-lines)
      text(size: 1em * factor)[#body]
    }
  })
}

#let framefit(
  width: auto,
  height: auto,
  min: 70%,
  max: none,
  max-lines: none,
  steps: 24,
  inset: 0pt,
  stroke: none,
  fill: none,
  radius: 0pt,
  only-if-overflow: false,
  body,
) = {
  block(
    width: width,
    height: height,
    inset: inset,
    stroke: stroke,
    fill: fill,
    radius: radius,
  )[
    #fit-copy(
      min: min,
      max: max,
      max-lines: max-lines,
      steps: steps,
      only-if-overflow: only-if-overflow,
    )[#body]
  ]
}
