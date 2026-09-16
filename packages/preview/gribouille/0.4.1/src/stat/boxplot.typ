///! Five-number summary backing \@geom-boxplot.
///!
///! For every distinct x level in the input data, reduces the rows to a
///! single summary row carrying `lower` (Q1), `middle` (median),
///! `upper` (Q3), `ymin`, `ymax`, and `outliers`. Quantiles use the
///! type-7 / numpy default linear interpolation rule.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": quantile-type-7

/// Boxplot statistic: per-x five-number summary with outlier list.
///
/// One output row per distinct x value with keys `(x, lower, middle, upper, ymin, ymax, outliers)`. `lower`, `middle`, and `upper` are the quartiles of the input y values; `ymin` and `ymax` are the smallest and largest y still inside the 1.5 × IQR fence; values outside the fence land in `outliers`.
///
/// - coefficient: Whisker length as a multiple of the inter-quartile range.
///
/// Returns: Statistic object with `name: "boxplot"`, consumed by geom layers.
///
/// See also: `geom-boxplot`, `stat-identity`.
///
/// Default 1.5 × IQR whisker rule on grouped raw observations.
///
/// ```typst
/// #let ys = (1, 2, 3, 4, 5, 6, 7, 8, 9, 13)
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for y in ys {
///     d.push((grp: grp, y: y))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (geom-boxplot(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// `stat: "boxplot"` is equivalent to `stat: stat-boxplot()` with the default `coefficient: 1.5`. Use the constructor to customise the whisker length, e.g., `stat: stat-boxplot(coefficient: 1.0)` tightens the fence so more values surface as outliers.
///
/// ```typst
/// #let ys = (1, 2, 3, 4, 5, 6, 7, 8, 9, 13)
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for y in ys {
///     d.push((grp: grp, y: y))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (geom-boxplot(stat: stat-boxplot(coefficient: 1.0)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-boxplot(coefficient: 1.5) = (
  kind: "stat",
  name: "boxplot",
  params: (coefficient: coefficient),
)

#let _summarise(rows, x-col, y-col, coefficient) = {
  let ys = rows
    .map(r => parse-number(r.at(y-col, default: none)))
    .filter(v => v != none)
  if ys.len() == 0 { return none }
  let sorted = ys.sorted()
  let lower = quantile-type-7(sorted, 0.25)
  let middle = quantile-type-7(sorted, 0.5)
  let upper = quantile-type-7(sorted, 0.75)
  let iqr = upper - lower
  let fence-lo = lower - coefficient * iqr
  let fence-hi = upper + coefficient * iqr
  let inside = sorted.filter(v => v >= fence-lo and v <= fence-hi)
  let whisker-lo = if inside.len() == 0 { lower } else { inside.first() }
  let whisker-hi = if inside.len() == 0 { upper } else { inside.last() }
  let outliers = sorted.filter(v => v < whisker-lo or v > whisker-hi)

  // ymin/ymax span the absolute extremes (whiskers and outliers) so the
  // y-axis training picks up outlier-driven range expansion. The geom uses
  // the explicit `whisker-lo`/`whisker-hi` fields to draw the actual whisker
  // endpoints.
  let ymin = calc.min(whisker-lo, sorted.first())
  let ymax = calc.max(whisker-hi, sorted.last())

  let raw-x = rows.first().at(x-col, default: none)
  let parsed-x = parse-number(raw-x)
  let x-value = if parsed-x != none { parsed-x } else { raw-x }

  // Keep the x value under its original column name (like stat-count) so a
  // grouping aesthetic mapped to the same column (e.g. fill == x) still finds
  // its value after the stat runs.
  let summary = (
    lower: lower,
    middle: middle,
    upper: upper,
    ymin: ymin,
    ymax: ymax,
    "whisker-lo": whisker-lo,
    "whisker-hi": whisker-hi,
    outliers: outliers,
  )
  summary.insert(x-col, x-value)
  summary
}

#let apply(data, mapping, params: (:)) = {
  let base-mapping = (
    x: "x",
    lower: "lower",
    middle: "middle",
    upper: "upper",
    ymin: "ymin",
    ymax: "ymax",
  )
  if mapping == none { return (data: (), mapping: base-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: (), mapping: base-mapping)
  }
  if data.len() == 0 { return (data: (), mapping: base-mapping) }

  let coefficient = params.at("coefficient", default: 1.5)

  // Bucket rows by their raw x value; emit one summary row per bucket in
  // first-appearance order so the downstream discrete x scale keeps the
  // same level ordering as the input.
  let buckets = (:)
  let order = ()
  for row in data {
    let key = str(row.at(x-col, default: ""))
    if key == "" { continue }
    let bucket = buckets.at(key, default: ())
    bucket.push(row)
    buckets.insert(key, bucket)
    if not order.contains(key) { order.push(key) }
  }

  let out = ()
  for key in order {
    let summary = _summarise(buckets.at(key), x-col, y-col, coefficient)
    if summary == none { continue }
    out.push(summary)
  }

  // Report x under its source column name so the summary rows and mapping
  // agree (matching `_summarise` above and `stat-count`'s convention).
  let out-mapping = base-mapping
  out-mapping.insert("x", x-col)
  (data: out, mapping: out-mapping)
}
