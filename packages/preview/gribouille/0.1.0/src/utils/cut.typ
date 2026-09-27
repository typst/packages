///! Discretisation helpers.
///!
///! Each helper takes an array of numbers and returns an array of bin labels
///! of the same length. Right-open intervals `(lo, hi]` are used, except the
///! last bin is closed on both sides. Non-numeric or `none` inputs map to
///! `none` in the output so callers can detect missing entries.

#import "types.typ": parse-number

#let _to-numeric(values) = {
  values.map(v => parse-number(v))
}

#let _filter-numeric(values) = {
  values.filter(v => v != none)
}

#let _format-number(v) = {
  if type(v) == int { return str(v) }
  let s = str(v)
  if s.ends-with(".0") { s.slice(0, s.len() - 2) } else { s }
}

#let _default-label(lo, hi) = {
  "(" + _format-number(lo) + "," + _format-number(hi) + "]"
}

// Linear-interpolation quantile (R type 7) on a sorted array. Mirrors the
// helper in `src/utils/summaries.typ` so cut-number lines up with the
// boxplot statistic.
#let _quantile(sorted, q) = {
  let n = sorted.len()
  if n == 0 { return none }
  if n == 1 { return sorted.at(0) }
  let pos = q * (n - 1)
  let lo = int(calc.floor(pos))
  let hi = int(calc.ceil(pos))
  if lo == hi { return sorted.at(lo) }
  let frac = pos - lo
  sorted.at(lo) * (1 - frac) + sorted.at(hi) * frac
}

#let _resolve-labels(breaks, labels) = {
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
  if type(labels) != array {
    panic("cut: labels must be `auto` or an array; got " + repr(labels))
  }
  if labels.len() != n {
    panic(
      "cut: labels length "
        + str(labels.len())
        + " does not match number of bins "
        + str(n)
        + ".",
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
/// Splits the closed range `[min, max]` of `values` into `n` bins of equal
/// width. Bins are right-open (`(lo, hi]`), except the leftmost bin is
/// closed on the left so the minimum value is captured. The default labels
/// are `"(lo,hi]"` strings using the bin boundaries.
///
/// \@category Helpers
/// \@subcategory Binning helpers
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric or `none` entries map to `none`.
///
/// \@param n Number of equal-width bins. Must be positive.
///
/// \@param labels Either `auto` for default boundary labels, or an array of
///   length `n` providing explicit labels.
///
/// \@returns Array of bin labels with the same length as `values`.
///
/// \@examples-static Default labels show the boundary intervals.
/// ```
/// #let bins = cut-interval((1, 2, 3, 4, 5, 6, 7, 8), n: 4)
/// // ("(1,2.75]", "(1,2.75]", "(2.75,4.5]", "(2.75,4.5]", ...)
/// ```
///
/// \@examples-static Provide explicit labels per bin for tidier display.
/// ```
/// #let bins = cut-interval(
///   (1, 2, 3, 4, 5, 6, 7, 8),
///   n: 4,
///   labels: ("low", "mid-low", "mid-high", "high"),
/// )
/// ```
#let cut-interval(values, n: 4, labels: auto) = {
  if n < 1 { panic("cut-interval: n must be >= 1; got " + repr(n)) }
  let parsed = _to-numeric(values)
  let numeric = _filter-numeric(parsed)
  if numeric.len() == 0 {
    return parsed.map(_ => none)
  }
  let lo = calc.min(..numeric)
  let hi = calc.max(..numeric)
  if lo == hi {
    let single = if labels == auto { (_default-label(lo, hi),) } else { labels }
    if type(single) != array or single.len() != 1 {
      panic(
        "cut-interval: labels must be a single-element array when min == max.",
      )
    }
    return parsed.map(v => if v == none { none } else { single.at(0) })
  }
  let step = (hi - lo) / n
  let breaks = range(0, n + 1).map(i => lo + i * step)
  let label-arr = _resolve-labels(breaks, labels)
  parsed.map(v => _assign-bin(v, breaks, label-arr))
}

/// Cut a numeric vector into `n` bins of (approximately) equal count.
///
/// Bin boundaries are quantiles of `values` using the type-7 linear
/// interpolation rule, the same convention as `src/utils/summaries.typ` and
/// `src/stat/boxplot.typ`. Bins are right-open (`(lo, hi]`), with the
/// leftmost bin closed on the left.
///
/// \@category Helpers
/// \@subcategory Binning helpers
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric or `none` entries map to `none`.
///
/// \@param n Number of bins. Must be positive.
///
/// \@param labels Either `auto` for default boundary labels, or an array of
///   length `n` providing explicit labels.
///
/// \@returns Array of bin labels with the same length as `values`.
///
/// \@examples-static Quartile bins so each bin holds roughly the same
/// number of observations.
/// ```
/// #let bins = cut-number((1, 2, 3, 4, 5, 6, 7, 8), n: 4)
/// ```
///
/// \@examples-static Tertile bins with custom labels.
/// ```
/// #let bins = cut-number(
///   (1, 2, 3, 4, 5, 6, 7, 8, 9),
///   n: 3,
///   labels: ("low", "mid", "high"),
/// )
/// ```
#let cut-number(values, n: 4, labels: auto) = {
  if n < 1 { panic("cut-number: n must be >= 1; got " + repr(n)) }
  let parsed = _to-numeric(values)
  let numeric = _filter-numeric(parsed)
  if numeric.len() == 0 {
    return parsed.map(_ => none)
  }
  let sorted = numeric.sorted()
  let breaks = range(0, n + 1).map(i => _quantile(sorted, i / n))
  let lo = breaks.at(0)
  let hi = breaks.at(n)
  if lo == hi {
    let single = if labels == auto { (_default-label(lo, hi),) } else { labels }
    if type(single) != array or single.len() != 1 {
      panic(
        "cut-number: labels must be a single-element array when all values are equal.",
      )
    }
    return parsed.map(v => if v == none { none } else { single.at(0) })
  }
  let label-arr = _resolve-labels(breaks, labels)
  parsed.map(v => _assign-bin(v, breaks, label-arr))
}

/// Cut a numeric vector into bins of fixed `width`.
///
/// Bins span `width` units; when `center` is provided, bin boundaries are
/// shifted so that `center` lies at a bin centre. Otherwise boundaries align
/// to multiples of `width` covering `[min, max]`. Bins are right-open
/// (`(lo, hi]`), except the leftmost bin is closed on the left.
///
/// \@category Helpers
/// \@subcategory Binning helpers
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of numbers; non-numeric or `none` entries map to `none`.
///
/// \@param width Positive bin width.
///
/// \@param center Optional number forcing a bin to be centred at this value.
///
/// \@param labels Either `auto` for default boundary labels, or an array of
///   length matching the number of bins.
///
/// \@returns Array of bin labels with the same length as `values`.
///
/// \@examples-static Bin widths of 2 align to multiples of two.
/// ```
/// #let bins = cut-width((1, 2, 3, 4, 5, 6, 7, 8), width: 2)
/// ```
///
/// \@examples-static Force a bin to be centred at zero by passing `center`.
/// ```
/// #let bins = cut-width((-3, -1, 0, 1, 2, 4), width: 2, center: 0)
/// ```
#let cut-width(values, width: 1, center: none, labels: auto) = {
  if width <= 0 {
    panic("cut-width: width must be positive; got " + repr(width))
  }
  let parsed = _to-numeric(values)
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
  let label-arr = _resolve-labels(breaks, labels)
  parsed.map(v => _assign-bin(v, breaks, label-arr))
}
