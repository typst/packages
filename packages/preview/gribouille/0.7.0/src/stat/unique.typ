///! Deduplication statistic.
///!
///! Drops repeated `(x, y)` observations within a group. The framework already
///! partitions data per group, so duplicates are detected within one call.

/// Unique statistic: keep the first row per `(x, y)` key, drop later duplicates.
///
/// The dedup key concatenates the values referenced by `mapping.x` and `mapping.y`. Mapping is returned unchanged.
///
/// Returns: Statistic object with `name: "unique"`, consumed by geom layers.
///
/// See also: `stat-identity`, `stat-sum`.
///
/// Drop the duplicate `(1, 1)` row; the rendered scatter shows each pair only once.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1),
///   (x: 1, y: 1),
///   (x: 2, y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(stat: "unique"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Constructor form: `stat: stat-unique()` is equivalent to `stat: "unique"` with defaults.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1),
///   (x: 1, y: 1),
///   (x: 2, y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(stat: stat-unique(), size: 3pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-unique() = (kind: "stat", name: "unique", params: (:))

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  let y-col = if mapping != none { mapping.at("y", default: none) } else {
    none
  }
  let seen = (:)
  let rows = ()
  for row in data {
    let xv = if x-col != none { row.at(x-col, default: none) } else { none }
    let yv = if y-col != none { row.at(y-col, default: none) } else { none }
    let key = str(xv) + "\u{1}" + str(yv)
    if seen.at(key, default: false) { continue }
    seen.insert(key, true)
    rows.push(row)
  }
  (data: rows, mapping: mapping)
}
