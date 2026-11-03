///! Quantile-quantile statistic against a reference distribution.
///!
///! Backing statistic for \@geom-qq.
///! Sorts numeric values from the `sample` aesthetic and pairs them with
///! theoretical quantiles of the chosen reference distribution at the
///! plotting positions `(i + 0.5) / n`.

#import "../utils/types.typ": parse-number
#import "../utils/normal.typ": theoretical-quantile
#import "../utils/aes-resolve.typ": stat-output-mapping

/// Q-Q statistic: theoretical-vs-sample pairs against a reference distribution.
///
/// Reads the `sample` aesthetic from the mapping; if `sample` is absent the statistic falls back to `y`. Non-numeric and `none` values are dropped. Output rows are sorted by `sample` ascending, with `theoretical` taken from `theoretical-quantile((i + 0.5) / n, distribution)` for `i` in `0..n`. Supported reference distributions are `"normal"` (default), `"uniform"`, and `"exponential"`.
///
/// Returns: Statistic object with `name: "qq"`, consumed by geom layers.
///
/// See also: `geom-qq`, `stat-qq-line`.
///
/// Q-Q points against a normal reference, mapping `y` only.
///
/// ```typst
/// #let d = (1, 2, 3, 4, 5).map(v => (v: v))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (geom-qq(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Constructor form: `stat: stat-qq()` is equivalent to `stat: "qq"` with defaults.
///
/// ```typst
/// #let d = range(1, 21).map(i => (v: i + calc.sin(i)))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (geom-point(stat: stat-qq(), size: 2pt), geom-qq-line(stroke: 1pt)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-qq() = (kind: "stat", name: "qq", params: (:))

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
  if n == 0 { return (data: (), mapping: new-mapping) }
  let sorted = xs.sorted()
  let rows = ()
  let i = 0
  while i < n {
    let p = (i + 0.5) / n
    rows.push((
      theoretical: theoretical-quantile(p, distribution),
      sample: sorted.at(i),
    ))
    i = i + 1
  }
  (data: rows, mapping: new-mapping)
}
