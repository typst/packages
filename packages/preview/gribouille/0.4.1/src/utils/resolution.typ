///! Resolution helper: smallest non-zero gap between unique numeric values.
///!
///! Used by positional adjustments such as `position-dodge` to choose bar
///! widths when the `x` aesthetic is numeric.

#import "types.typ": parse-number

#let _to-numeric(values) = {
  values.map(v => parse-number(v)).filter(v => v != none)
}

/// Smallest non-zero gap between unique numeric values in `values`.
///
/// With `zero: true` (the default) the value `0` is added to `values` before the calculation, so the resolution also accounts for the distance to zero. This is the convention adopted throughout Gribouille for positional adjustments.
///
/// Returns `1` when `values` has fewer than two distinct numeric entries.
///
/// - values: Array of numbers; non-numeric and `none` entries are dropped.
/// - zero: Whether to include zero when computing the resolution.
///
/// Returns: The smallest positive difference between consecutive unique values, or `1` when no such difference exists.
///
/// Default behaviour folds in zero so the result reflects the smallest distinct increment from the origin too.
///
/// ```typst
/// #let r = resolution((1, 2, 4, 7))
/// // r == 1.0
/// ```
///
/// Pass `zero: false` when the data does not naturally include zero and you only want gaps between observed values.
///
/// ```typst
/// #let r = resolution((10, 12, 16, 22), zero: false)
/// // r == 2.0
/// ```
#let resolution(values, zero: true) = {
  let xs = _to-numeric(values)
  if zero { xs.push(0.0) }
  let unique = ()
  for v in xs {
    if not unique.contains(v) { unique.push(v) }
  }
  if unique.len() < 2 { return 1 }
  let sorted = unique.sorted()
  let best = none
  let i = 1
  while i < sorted.len() {
    let d = sorted.at(i) - sorted.at(i - 1)
    if d > 0 and (best == none or d < best) { best = d }
    i = i + 1
  }
  if best == none { 1 } else { best }
}
