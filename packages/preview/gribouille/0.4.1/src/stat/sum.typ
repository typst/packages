///! Count observations per unique `(x, y)` pair.
///!
///! Backing statistic for \@geom-count. Groups rows by the `(x, y)` key from
///! the layer mapping and emits one row per unique pair carrying the count
///! and proportion as new aesthetics.

#import "../utils/summaries.typ": read-weight
#import "../utils/aes-resolve.typ": stat-output-mapping

/// Sum statistic: one output row per unique `(x, y)` pair with `_n` and `_prop`.
///
/// Output rows preserve first-seen pair order. The stat re-maps `size` to the `"_n"` column so geoms picking up the aesthetic see counts directly.
///
/// Returns: Statistic object with `name: "sum"`, consumed by geom layers.
///
/// See also: `geom-count`, `stat-count`, `stat-unique`.
///
/// Marker size grows with the count of duplicate `(x, y)` rows.
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
///   layers: (geom-count(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Constructor form: `stat: stat-sum()` is equivalent to `stat: "sum"` with defaults.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1), (x: 1, y: 1), (x: 1, y: 1),
///   (x: 2, y: 2),
///   (x: 3, y: 3), (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(stat: stat-sum(), size: 3pt),),
///   scales: (scale-size-area(range: (2pt, 14pt)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-sum() = (kind: "stat", name: "sum", params: (:))

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "x", y: "y", size: "_n"),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: (), mapping: new-mapping)
  }

  let weight-col = mapping.at("weight", default: none)
  let counts = (:)
  let order = ()
  let proto = (:)
  let total = 0
  for row in data {
    let xv = row.at(x-col, default: none)
    let yv = row.at(y-col, default: none)
    if xv == none or yv == none { continue }
    let key = str(xv) + "\u{1}" + str(yv)
    if not order.contains(key) {
      order.push(key)
      proto.insert(key, (x: xv, y: yv))
    }
    let w = read-weight(row, weight-col)
    counts.insert(key, counts.at(key, default: 0) + w)
    total += w
  }

  let rows = ()
  for key in order {
    let p = proto.at(key)
    let n = counts.at(key)
    let prop = if total == 0 { 0.0 } else { n / total }
    rows.push((x: p.x, y: p.y, _n: n, _prop: prop))
  }

  (data: rows, mapping: new-mapping)
}
