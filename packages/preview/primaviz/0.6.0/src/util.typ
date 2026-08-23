// util.typ - Shared utilities for primaviz

/// Returns white or black depending on the perceived luminance of a color.
/// Uses the W3C relative luminance formula for good contrast.
///
/// - c (color): Input color
/// -> color
#let contrast-text(c) = {
  let comps = rgb(c).components()
  let r = comps.at(0) / 100%
  let g = comps.at(1) / 100%
  let b = comps.at(2) / 100%
  let lum = 0.299 * r + 0.587 * g + 0.114 * b
  if lum > 0.55 { black } else { white }
}

/// Normalizes data input to a `(labels: array, values: array)` dictionary.
///
/// - data (dictionary, array): Dict with `labels`/`values` keys, or array of `(label, value)` tuples
/// -> dictionary
#let normalize-data(data) = {
  let labels = if type(data) == dictionary { data.labels } else { data.map(d => d.at(0)) }
  let values = if type(data) == dictionary { data.values } else { data.map(d => d.at(1)) }
  (labels: labels, values: values)
}

/// Linearly interpolates between two colors.
///
/// - c1 (color): Start color (at t=0)
/// - c2 (color): End color (at t=1)
/// - t (float): Interpolation factor, clamped to 0..1
/// -> color
#let lerp-color(c1, c2, t) = {
  let t-clamped = calc.max(0, calc.min(1, t))
  color.mix((c1, (1 - t-clamped) * 100%), (c2, t-clamped * 100%))
}

// Named palette definitions — arrays of color stops for N-stop interpolation.
#let _named-palettes = (
  viridis: (rgb("#440154"), rgb("#3b528b"), rgb("#21918c"), rgb("#5ec962"), rgb("#fde725")),
  heat: (rgb("#313695"), rgb("#74add1"), rgb("#a6d96a"), rgb("#fdae61"), rgb("#a50026")),
  blues: (rgb("#f7fbff"), rgb("#6baed6"), rgb("#08306b")),
  greens: (rgb("#f7fcf5"), rgb("#74c476"), rgb("#00441b")),
  reds: (rgb("#fff5f0"), rgb("#fb6a4a"), rgb("#67000d")),
  purples: (rgb("#fcfbfd"), rgb("#9e9ac8"), rgb("#3f007d")),
  inferno: (rgb("#000004"), rgb("#420a68"), rgb("#932667"), rgb("#dd513a"), rgb("#fcffa4")),
  plasma: (rgb("#0d0887"), rgb("#7e03a8"), rgb("#cc4778"), rgb("#f89540"), rgb("#f0f921")),
  coolwarm: (rgb("#3b4cc0"), rgb("#7b9ff9"), rgb("#f7f7f7"), rgb("#f4987a"), rgb("#b40426")),
  spectral: (rgb("#9e0142"), rgb("#f46d43"), rgb("#fee08b"), rgb("#abdda4"), rgb("#5e4fa2")),
)

/// Interpolates across an array of color stops for a 0..1 value.
///
/// - stops (array): Array of colors (2 or more)
/// - v (float): Normalized value 0..1
/// -> color
#let _interpolate-stops(stops, v) = {
  let n = stops.len()
  if n == 1 { return stops.at(0) }
  let scaled = v * (n - 1)
  let idx = calc.min(int(scaled), n - 2)
  let t = scaled - idx
  lerp-color(stops.at(idx), stops.at(idx + 1), t)
}

/// Maps a normalized 0..1 value to a color using a palette.
///
/// Palette can be a string name (`"viridis"`, `"heat"`, `"blues"`, `"greens"`,
/// `"reds"`, `"purples"`, `"inferno"`, `"plasma"`, `"coolwarm"`, `"spectral"`,
/// `"grayscale"`) or an array of color stops for custom palettes.
///
/// Append `"-r"` to any named palette to reverse it (e.g., `"viridis-r"`).
///
/// - val (float): Value in the range 0 to 1
/// - palette (str, array): Palette name or array of color stops
/// - reverse (bool): Reverse the palette direction
/// -> color
#let heat-color(val, palette: "viridis", reverse: false) = {
  let v = calc.max(0, calc.min(1, val))

  // Handle array palette directly
  if type(palette) == array {
    let stops = if reverse { palette.rev() } else { palette }
    return _interpolate-stops(stops, v)
  }

  // Handle grayscale specially (not stop-based)
  if palette == "grayscale" or palette == "grayscale-r" {
    let rv = if reverse or palette == "grayscale-r" { v } else { 1 - v }
    return luma(int(rv * 255))
  }

  // Check for -r suffix
  let pal-name = palette
  let rev = reverse
  if palette.ends-with("-r") {
    pal-name = palette.slice(0, palette.len() - 2)
    rev = true
  }

  // Look up named palette
  let stops = _named-palettes.at(pal-name, default: _named-palettes.at("blues"))
  if rev { stops = stops.rev() }
  _interpolate-stops(stops, v)
}

/// Returns the value unchanged if non-zero, otherwise returns `fallback`.
/// Prevents division-by-zero in range calculations.
///
/// - val (int, float): Value to check
/// - fallback (int, float): Returned when `val` is zero
/// -> int, float
#let nonzero(val, fallback: 1) = if val == 0 { fallback } else { val }

/// Clamps a numeric value to the range [lo, hi].
///
/// - val (int, float): Value to clamp
/// - lo (int, float): Lower bound
/// - hi (int, float): Upper bound
/// -> int, float
#let clamp(val, lo, hi) = {
  calc.max(lo, calc.min(hi, val))
}

/// Formats a number for display using the specified mode.
///
/// - val (int, float): Number to format
/// - digits (int): Decimal places to round to
/// - mode (str): Format mode: `"auto"`, `"comma"`, `"si"`, `"plain"`, or `"percent"`
/// -> str
#let format-number(val, digits: 1, mode: "auto") = {
  let abs-val = calc.abs(val)
  let rounded = calc.round(val, digits: digits)

  if mode == "si" or (mode == "auto" and abs-val >= 10000) {
    // SI abbreviations
    if abs-val >= 1000000000 {
      str(calc.round(val / 1000000000, digits: 1)) + "B"
    } else if abs-val >= 1000000 {
      str(calc.round(val / 1000000, digits: 1)) + "M"
    } else if abs-val >= 1000 {
      str(calc.round(val / 1000, digits: 1)) + "k"
    } else {
      str(rounded)
    }
  } else if mode == "comma" {
    // Add comma separators - Typst doesn't have built-in number formatting
    // so we'll build the string manually
    let s = str(calc.round(val, digits: digits))
    let negative = s.starts-with("-")
    let abs-str = if negative { s.slice(1) } else { s }
    let parts = abs-str.split(".")
    let int-str = parts.at(0)
    let result = ""
    let count = 0
    let chars = int-str.clusters()
    let n = chars.len()
    for i in array.range(n) {
      let idx = n - 1 - i
      if count > 0 and calc.rem(count, 3) == 0 {
        result = "," + result
      }
      result = chars.at(idx) + result
      count = count + 1
    }
    if parts.len() > 1 {
      result = result + "." + parts.at(1)
    }
    if negative { "-" + result } else { result }
  } else if mode == "percent" {
    str(calc.round(val, digits: digits)) + "%"
  } else {
    // plain or auto (below threshold)
    str(rounded)
  }
}

/// Sorts a simple data dictionary by values.
///
/// - data (dictionary): Dict with `labels` and `values` arrays
/// - descending (bool): Sort in descending order
/// -> dictionary
#let sort-data(data, descending: false) = {
  let pairs = data.labels.zip(data.values)
  let sorted = pairs.sorted(key: p => p.at(1))
  if descending {
    sorted = sorted.rev()
  }
  (labels: sorted.map(p => p.at(0)), values: sorted.map(p => p.at(1)))
}

/// Returns the top N entries by value (descending) from a simple data dictionary.
///
/// - data (dictionary): Dict with `labels` and `values` arrays
/// - n (int): Number of top entries to return
/// -> dictionary
#let top-n(data, n) = {
  let sorted = sort-data(data, descending: true)
  (labels: sorted.labels.slice(0, calc.min(n, sorted.labels.len())),
   values: sorted.values.slice(0, calc.min(n, sorted.values.len())))
}

/// Aggregates multi-series data into a simple label-value dictionary.
///
/// - data (dictionary): Dict with `labels` and `series` (each with `values`)
/// - fn (str): Aggregation function: `"sum"`, `"mean"`, `"max"`, or `"min"`
/// -> dictionary
#let aggregate(data, fn: "sum") = {
  let n = data.labels.len()
  let agg-values = ()
  for i in array.range(n) {
    let vals = data.series.map(s => s.values.at(i))
    let result = if fn == "sum" { vals.sum() }
      else if fn == "mean" { vals.sum() / vals.len() }
      else if fn == "max" { calc.max(..vals) }
      else if fn == "min" { calc.min(..vals) }
      else { vals.sum() }
    agg-values.push(result)
  }
  (labels: data.labels, values: agg-values)
}

/// Rounds a value up to the next "nice" number for axis scaling.
/// Uses the standard nice-number algorithm (similar to D3/matplotlib).
///
/// - val (int, float): Value to round up
/// -> int, float
#let nice-ceil(val) = {
  if val <= 0 { return val }
  let exp = calc.floor(calc.log(val, base: 10))
  let base = calc.pow(10, exp)
  let frac = val / base
  // Pick the next nice fraction: 1, 1.5, 2, 2.5, 3, 4, 5, 7, 10
  let nice = if frac <= 1 { 1 }
    else if frac <= 1.5 { 1.5 }
    else if frac <= 2 { 2 }
    else if frac <= 2.5 { 2.5 }
    else if frac <= 3 { 3 }
    else if frac <= 4 { 4 }
    else if frac <= 5 { 5 }
    else if frac <= 7 { 7 }
    else { 10 }
  nice * base
}

/// Rounds a value down to the previous "nice" number for axis scaling.
///
/// - val (int, float): Value to round down
/// -> int, float
#let nice-floor(val) = {
  if val == 0 { return 0 }
  if val < 0 { return -nice-ceil(calc.abs(val)) }
  let exp = calc.floor(calc.log(val, base: 10))
  let base = calc.pow(10, exp)
  let frac = val / base
  let nice = if frac >= 10 { 10 }
    else if frac >= 7 { 7 }
    else if frac >= 5 { 5 }
    else if frac >= 4 { 4 }
    else if frac >= 3 { 3 }
    else if frac >= 2.5 { 2.5 }
    else if frac >= 2 { 2 }
    else if frac >= 1.5 { 1.5 }
    else { 1 }
  nice * base
}

/// Normalizes an `errors` parameter for bar/line/scatter charts into a uniform
/// list of `(low, high)` dicts. Accepts either symmetric (single number per
/// point) or asymmetric (two-tuple per point) specifications.
///
/// - errors (none, array): Symmetric `(e1, e2, ...)` or asymmetric `((lo1, hi1), ...)`
/// - n (int): Expected number of entries
/// -> none, array
#let normalize-errors(errors, n) = {
  if errors == none { return none }
  assert(errors.len() == n,
    message: "errors length (" + str(errors.len()) + ") must match data length (" + str(n) + ")")
  let result = ()
  for e in errors {
    if type(e) == array {
      result.push((low: e.at(0), high: e.at(1)))
    } else {
      result.push((low: e, high: e))
    }
  }
  result
}

/// Computes nice step-aligned tick values for an axis using D3-style step selection.
/// Steps are restricted to 1, 2, 5, or 10 × 10^n for clean tick labels.
/// Returns a dictionary with `min`, `max`, `step`, `ticks` (array of values),
/// and `digits` (auto-detected decimal places for formatting).
///
/// - data-min (number): Minimum data value
/// - data-max (number): Maximum data value
/// - count (int): Target number of ticks (actual count may vary slightly)
/// -> dictionary
#let nice-ticks(data-min, data-max, count: 5) = {
  let raw-range = nonzero(data-max - data-min, fallback: 1.0)
  // Target intervals = count - 1
  let raw-step = raw-range / calc.max(1, count - 1)

  // Round step to a nice number: 1, 2, 5, or 10 × 10^n (D3 algorithm)
  let exp = calc.floor(calc.log(raw-step, base: 10))
  let base = calc.pow(10, exp)
  let error = raw-step / base
  // D3 thresholds: sqrt(50), sqrt(10), sqrt(2) partition [1, 10) into step tiers
  let step = if error >= calc.sqrt(50) { base * 10 }
    else if error >= calc.sqrt(10) { base * 5 }
    else if error >= calc.sqrt(2) { base * 2 }
    else { base }

  // Snap min/max to step boundaries
  let tick-min = calc.floor(data-min / step) * step
  let tick-max = calc.ceil(data-max / step) * step

  // Generate ticks
  let ticks = ()
  let v = tick-min
  while v <= tick-max + step * 0.001 {
    let rv = calc.round(v, digits: 10)
    ticks.push(if rv == calc.floor(rv) { int(rv) } else { rv })
    v += step
  }

  // Auto-detect digits from step size (Heckbert's TickmarkPrecision formula)
  let digits = int(calc.max(-calc.floor(calc.log(step, base: 10)), 0))

  (min: tick-min, max: tick-max, step: step, ticks: ticks, digits: digits)
}

/// Computes nice-rounded (min, max, range) for a numeric array.
/// Returns a dictionary with `min`, `max`, and `range` (nonzero-guarded) keys.
///
/// - vals (array): Array of numbers
/// -> dictionary
#let numeric-range(vals) = {
  let lo = nice-floor(calc.min(..vals))
  let hi = nice-ceil(calc.max(..vals))
  (min: lo, max: hi, range: nonzero(hi - lo))
}

/// Returns day-of-week for a "YYYY-MM-DD" string (0=Mon … 6=Sun).
///
/// Uses Tomohiko Sakamoto's algorithm.
///
/// - date-str (str): Date in "YYYY-MM-DD" format
/// -> int
#let day-of-week(date-str) = {
  let parts = date-str.split("-")
  let y = int(parts.at(0))
  let m = int(parts.at(1))
  let d = int(parts.at(2))
  let offsets = (0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4)
  let yy = if m < 3 { y - 1 } else { y }
  let dow = calc.rem(yy + calc.div-euclid(yy, 4) - calc.div-euclid(yy, 100) + calc.div-euclid(yy, 400) + offsets.at(m - 1) + d, 7)
  // Convert from 0=Sun to 0=Mon: Sun(0)→6, Mon(1)→0, …, Sat(6)→5
  calc.rem(dow + 6, 7)
}

/// Converts values to percentages of total, returning a new data dictionary.
///
/// - data (dictionary): Dict with `labels` and `values` arrays
/// -> dictionary
#let percent-of-total(data) = {
  let total = data.values.sum()
  if total == 0 { return data }
  (labels: data.labels, values: data.values.map(v => calc.round(v / total * 100, digits: 1)))
}
