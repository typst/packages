///! Colour helpers for data-driven fills.

// Position of `value` between `lo` and `hi`, clamped, with a degenerate domain
// reading as the middle rather than dividing by zero.
#let fraction-of(value, lo, hi) = {
  if hi == lo { return 0.5 }
  calc.max(0.0, calc.min(1.0, (value - lo) / (hi - lo)))
}

// Piecewise mix across a palette of two or more colours.
#let sample-palette(palette, fraction) = {
  if palette.len() == 1 { return palette.first() }
  let steps = palette.len() - 1
  let scaled = fraction * steps
  let lower = calc.min(steps - 1, int(calc.floor(scaled)))
  let within = scaled - lower
  gradient.linear(palette.at(lower), palette.at(lower + 1)).sample(within * 100%)
}

// Black or white, whichever the eye reads more easily on `background`, using
// the relative luminance the WCAG contrast ratio is built on.
#let readable-on(background) = {
  let channel(text) = {
    let value = int(text, base: 16) / 255
    if value <= 0.03928 { value / 12.92 } else { calc.pow((value + 0.055) / 1.055, 2.4) }
  }
  let hex = background.to-hex().trim("#")
  let luminance = (
    0.2126 * channel(hex.slice(0, 2)) + 0.7152 * channel(hex.slice(2, 4)) + 0.0722 * channel(hex.slice(4, 6))
  )
  if luminance > 0.179 { black } else { white }
}
