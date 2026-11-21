///! Discretisation helpers.
///!
///! Each helper takes an array of numbers and returns an array of bin labels
///! of the same length. Right-open intervals `(lo, hi]` are used, except the
///! last bin is closed on both sides. Non-numeric or `none` inputs map to
///! `none` in the output so callers can detect missing entries.

#import "types.typ": parse-number
#import "errors.typ": fail, fail-type
#import "format.typ": format-break
#import "summaries.typ": quantile-type-7

// Keeps `none` entries (unlike `types.to-numeric`) so bin labels stay
// positionally aligned with the input rows.
#let _parse-numbers(values) = {
  values.map(v => parse-number(v))
}

#let _filter-numeric(values) = {
  values.filter(v => v != none)
}

#let _default-label(lo, hi) = {
  "(" + format-break(lo) + "," + format-break(hi) + "]"
}

#let _check-labels-type(scope, labels) = {
  if labels != auto and type(labels) != array {
    fail-type(scope, "labels", labels, "`auto` or an array")
  }
}

#let _check-count(scope, n) = {
  if type(n) != int { fail-type(scope, "n", n, "a positive integer") }
  if n < 1 { fail(scope, "n must be >= 1; got " + repr(n)) }
}

// Labels for the single bin that a constant vector falls in.
#let _single-label(scope, lo, hi, labels, reason) = {
  let single = if labels == auto { (_default-label(lo, hi),) } else { labels }
  if single.len() != 1 {
    fail(
      scope,
      "labels must be a single-element array when "
        + reason
        + "; got "
        + repr(labels),
    )
  }
  single.at(0)
}

#let _resolve-labels(scope, breaks, labels) = {
  let n = breaks.len() - 1
  if labels == auto {
    let out = ()
    let i = 0
    while i < n {
      out.push(_default-label(breaks.at(i), breaks.at(i + 1)))
      i = i + 1
    }
    return out
  }
  if labels.len() != n {
    fail(
      scope,
      "labels length "
        + str(labels.len())
        + " does not match number of bins "
        + str(n),
    )
  }
  labels
}

#let _assign-bin(value, breaks, labels) = {
  if value == none { return none }
  let n-bins = labels.len()
  let lo = breaks.at(0)
  let hi = breaks.at(n-bins)
  if value < lo or value > hi { return none }
  let i = 0
  while i < n-bins {
    let upper = breaks.at(i + 1)
    if value <= upper {
      if i == 0 and value == lo { return labels.at(0) }
      if value > breaks.at(i) or i == n-bins - 1 { return labels.at(i) }
    }
    i = i + 1
  }
  labels.at(n-bins - 1)
}

/// Cut a numeric vector into `n` equal-width bins.
///
/// Splits the closed range `[min, max]` of `values` into `n` bins of equal width. Bins are right-open (`(lo, hi]`), except the leftmost bin is closed on the left so the minimum value is captured. The default labels are `"(lo,hi]"` strings using the bin boundaries.
///
/// - values: Array of numbers; non-numeric or `none` entries map to `none`.
/// - n: Number of equal-width bins. Must be positive.
/// - labels: Either `auto` for default boundary labels, or an array of length `n` providing explicit labels.
///
/// Returns: Array of bin labels with the same length as `values`.
///
/// Default labels show the boundary intervals.
///
/// ```typst
/// #let bins = cut-interval((1, 2, 3, 4, 5, 6, 7, 8), n: 4)
/// // ("(1,2.75]", "(1,2.75]", "(2.75,4.5]", "(2.75,4.5]", ...)
/// ```
///
/// Provide explicit labels per bin for tidier display.
///
/// ```typst
/// #let bins = cut-interval(
///   (1, 2, 3, 4, 5, 6, 7, 8),
///   n: 4,
///   labels: ("low", "mid-low", "mid-high", "high"),
/// )
/// ```
#let cut-interval(values, n: 4, labels: auto) = {
  _check-count("cut-interval", n)
  _check-labels-type("cut-interval", labels)
  let parsed = _parse-numbers(values)
  let numeric = _filter-numeric(parsed)
  if numeric.len() == 0 {
    return parsed.map(_ => none)
  }
  let lo = calc.min(..numeric)
  let hi = calc.max(..numeric)
  if lo == hi {
    let single = _single-label("cut-interval", lo, hi, labels, "min == max")
    return parsed.map(v => if v == none { none } else { single })
  }
  let step = (hi - lo) / n
  let breaks = range(0, n + 1).map(i => lo + i * step)
  let label-arr = _resolve-labels("cut-interval", breaks, labels)
  parsed.map(v => _assign-bin(v, breaks, label-arr))
}

/// Cut a numeric vector into `n` bins of (approximately) equal count.
///
/// Bin boundaries are quantiles of `values` using the type-7 linear interpolation rule, the same convention as `src/utils/summaries.typ` and `src/stat/boxplot.typ`. Bins are right-open (`(lo, hi]`), with the leftmost bin closed on the left.
///
/// - values: Array of numbers; non-numeric or `none` entries map to `none`.
/// - n: Number of bins. Must be positive.
/// - labels: Either `auto` for default boundary labels, or an array of length `n` providing explicit labels.
///
/// Returns: Array of bin labels with the same length as `values`.
///
/// Quartile bins so each bin holds roughly the same number of observations.
///
/// ```typst
/// #let bins = cut-number((1, 2, 3, 4, 5, 6, 7, 8), n: 4)
/// ```
///
/// Tertile bins with custom labels.
///
/// ```typst
/// #let bins = cut-number(
///   (1, 2, 3, 4, 5, 6, 7, 8, 9),
///   n: 3,
///   labels: ("low", "mid", "high"),
/// )
/// ```
#let cut-number(values, n: 4, labels: auto) = {
  _check-count("cut-number", n)
  _check-labels-type("cut-number", labels)
  let parsed = _parse-numbers(values)
  let numeric = _filter-numeric(parsed)
  if numeric.len() == 0 {
    return parsed.map(_ => none)
  }
  let sorted = numeric.sorted()
  let breaks = range(0, n + 1).map(i => quantile-type-7(sorted, i / n))
  let lo = breaks.at(0)
  let hi = breaks.at(n)
  if lo == hi {
    let single = _single-label(
      "cut-number",
      lo,
      hi,
      labels,
      "all values are equal",
    )
    return parsed.map(v => if v == none { none } else { single })
  }
  let tied = range(0, n).any(i => breaks.at(i) == breaks.at(i + 1))
  if tied {
    fail(
      "cut-number",
      "quantile breaks are not distinct, so some bins have zero width; got n: "
        + repr(n),
      hint: "Use fewer bins, or cut-interval for equal-width bins.",
    )
  }
  let label-arr = _resolve-labels("cut-number", breaks, labels)
  parsed.map(v => _assign-bin(v, breaks, label-arr))
}

/// Cut a numeric vector into bins of fixed `width`.
///
/// Bins span `width` units; when `center` is provided, bin boundaries are shifted so that `center` lies at a bin centre. Otherwise boundaries align to multiples of `width` covering `[min, max]`. Bins are right-open (`(lo, hi]`), except the leftmost bin is closed on the left.
///
/// - values: Array of numbers; non-numeric or `none` entries map to `none`.
/// - width: Positive bin width.
/// - center: Optional number forcing a bin to be centred at this value.
/// - labels: Either `auto` for default boundary labels, or an array of length matching the number of bins.
///
/// Returns: Array of bin labels with the same length as `values`.
///
/// Bin widths of 2 align to multiples of two.
///
/// ```typst
/// #let bins = cut-width((1, 2, 3, 4, 5, 6, 7, 8), width: 2)
/// ```
///
/// Force a bin to be centred at zero by passing `center`.
///
/// ```typst
/// #let bins = cut-width((-3, -1, 0, 1, 2, 4), width: 2, center: 0)
/// ```
#let cut-width(values, width: 1, center: none, labels: auto) = {
  if type(width) != int and type(width) != float {
    fail-type("cut-width", "width", width, "a positive number")
  }
  if width <= 0 {
    fail("cut-width", "width must be positive; got " + repr(width))
  }
  _check-labels-type("cut-width", labels)
  let parsed = _parse-numbers(values)
  let numeric = _filter-numeric(parsed)
  if numeric.len() == 0 {
    return parsed.map(_ => none)
  }
  let lo-val = calc.min(..numeric)
  let hi-val = calc.max(..numeric)
  let anchor = if center == none { 0.0 } else { center - width / 2 }
  let start = anchor + calc.floor((lo-val - anchor) / width) * width
  let n-bins = int(calc.ceil((hi-val - start) / width))
  if n-bins < 1 { n-bins = 1 }
  if start + n-bins * width <= hi-val { n-bins = n-bins + 1 }
  let breaks = range(0, n-bins + 1).map(i => start + i * width)
  let label-arr = _resolve-labels("cut-width", breaks, labels)
  parsed.map(v => _assign-bin(v, breaks, label-arr))
}
