// util.typ - Shared utilities for primaviz

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

/// Maps a normalized 0..1 value to a color using a named palette.
///
/// - val (float): Value in the range 0 to 1
/// - palette (str): Palette name (`"viridis"`, `"heat"`, `"grayscale"`, or default blue gradient)
/// -> color
#let heat-color(val, palette: "viridis") = {
  let v = calc.max(0, calc.min(1, val))

  if palette == "viridis" {
    if v < 0.25 {
      lerp-color(rgb("#440154"), rgb("#3b528b"), v * 4)
    } else if v < 0.5 {
      lerp-color(rgb("#3b528b"), rgb("#21918c"), (v - 0.25) * 4)
    } else if v < 0.75 {
      lerp-color(rgb("#21918c"), rgb("#5ec962"), (v - 0.5) * 4)
    } else {
      lerp-color(rgb("#5ec962"), rgb("#fde725"), (v - 0.75) * 4)
    }
  } else if palette == "heat" {
    if v < 0.25 {
      lerp-color(rgb("#313695"), rgb("#74add1"), v * 4)
    } else if v < 0.5 {
      lerp-color(rgb("#74add1"), rgb("#a6d96a"), (v - 0.25) * 4)
    } else if v < 0.75 {
      lerp-color(rgb("#a6d96a"), rgb("#fdae61"), (v - 0.5) * 4)
    } else {
      lerp-color(rgb("#fdae61"), rgb("#a50026"), (v - 0.75) * 4)
    }
  } else if palette == "grayscale" {
    luma(int((1 - v) * 255))
  } else {
    lerp-color(rgb("#f7fbff"), rgb("#08306b"), v)
  }
}

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

/// Converts values to percentages of total, returning a new data dictionary.
///
/// - data (dictionary): Dict with `labels` and `values` arrays
/// -> dictionary
#let percent-of-total(data) = {
  let total = data.values.sum()
  if total == 0 { return data }
  (labels: data.labels, values: data.values.map(v => calc.round(v / total * 100, digits: 1)))
}
