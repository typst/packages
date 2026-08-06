///! Reference line for a Q-Q plot.
///!
///! Backing statistic for \@geom-qq-line.
///! Computes the slope and intercept that pass through the 25th and 75th
///! sample quantiles versus the corresponding theoretical quantiles of the
///! chosen reference distribution, then emits the two endpoints of that
///! line across the theoretical range used by \@stat-qq.

#import "../utils/types.typ": parse-number
#import "../utils/normal.typ": theoretical-quantile
#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/summaries.typ": quantile-type-7

/// Q-Q reference-line statistic: two endpoints of the IQR-fitted line.
///
/// Slope is `(q3 - q1) / (t3 - t1)` from the sample's 25th and 75th type-7 quantiles divided by the corresponding theoretical quantiles of the reference distribution, and intercept is `q1 - slope * t1`. Endpoints span the theoretical range that `stat-qq` would emit for the same `n` and reference distribution. Supported reference distributions are `"normal"` (default), `"uniform"`, and `"exponential"`.
///
/// Returns: Statistic object with `name: "qq-line"`, consumed by geom layers.
///
/// See also: `geom-qq-line`, `stat-qq`.
///
/// Reference line under `geom-qq` for a normal Q-Q plot.
///
/// ```typst
/// #let d = (1, 2, 3, 4, 5).map(v => (v: v))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (geom-qq(), geom-qq-line()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Constructor form: `stat: stat-qq-line()` is equivalent to `stat: "qq-line"` with defaults.
///
/// ```typst
/// #let d = range(1, 21).map(i => (v: i + calc.sin(i)))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (
///     geom-qq(size: 2pt),
///     geom-line(stat: stat-qq-line(), stroke: 1pt, colour: rgb("#cc0000")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-qq-line() = (kind: "stat", name: "qq-line", params: (:))

#let apply(data, mapping, params: (:)) = {
  // The input `sample` aesthetic referenced a user column; that column has
  // been consumed into the synthesised `sample` data column, so the input key
  // is dropped to avoid pointing at a stale column name.
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "theoretical", y: "sample"),
  )
  if "sample" in new-mapping { let _ = new-mapping.remove("sample") }
  let sample-col = if mapping != none {
    let s = mapping.at("sample", default: none)
    if s != none { s } else { mapping.at("y", default: none) }
  } else { none }
  if sample-col == none { return (data: (), mapping: new-mapping) }
  let distribution = params.at("distribution", default: "normal")
  let xs = data
    .map(r => parse-number(r.at(sample-col, default: none)))
    .filter(v => v != none)
  let n = xs.len()
  if n < 2 { return (data: (), mapping: new-mapping) }
  let sorted = xs.sorted()
  let q1 = quantile-type-7(sorted, 0.25)
  let q3 = quantile-type-7(sorted, 0.75)
  let z1 = theoretical-quantile(0.25, distribution)
  let z3 = theoretical-quantile(0.75, distribution)
  let slope = (q3 - q1) / (z3 - z1)
  let intercept = q1 - slope * z1
  let t-lo = theoretical-quantile(0.5 / n, distribution)
  let t-hi = theoretical-quantile((n - 0.5) / n, distribution)
  let rows = (
    (theoretical: t-lo, sample: intercept + slope * t-lo),
    (theoretical: t-hi, sample: intercept + slope * t-hi),
  )
  (data: rows, mapping: new-mapping)
}
