///! Count observations per level of x.
///!
///! Backing statistic for \@geom-bar. Groups rows by the x column and returns
///! one row per level with the count as y.

#import "../utils/summaries.typ": read-weight

/// Count statistic: one output row per distinct x level with `y = count`.
///
/// Empty strings and `none` x values are dropped. Output rows preserve the first-seen order of x levels.
///
/// Returns: Statistic object with `name: "count"`, consumed by geom layers.
///
/// See also: `geom-bar`, `stat-bin`, `stat-identity`.
///
/// Count rows per category, drawn as bars via `geom-bar`.
///
/// ```typst
/// #let d = (
///   (grp: "a"),
///   (grp: "b"),
///   (grp: "a"),
///   (grp: "c"),
///   (grp: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp"),
///   layers: (geom-bar(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Constructor form: `stat: stat-count()` is equivalent to `stat: "count"` with defaults. Both forms honour `fill` grouping identically.
///
/// ```typst
/// #let d = (
///   (grp: "a", k: "x"),
///   (grp: "b", k: "x"),
///   (grp: "a", k: "y"),
///   (grp: "c", k: "x"),
///   (grp: "a", k: "y"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", fill: "k"),
///   layers: (geom-col(stat: stat-count()),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-count() = (kind: "stat", name: "count", params: (:))

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  if x-col == none { return (data: data, mapping: mapping) }
  let weight-col = if mapping != none {
    mapping.at("weight", default: none)
  } else { none }
  let counts = (:)
  let order = ()
  for row in data {
    let raw = row.at(x-col, default: none)
    if raw == none { continue }
    let key = str(raw)
    if key == "" { continue }
    if not order.contains(key) { order.push(key) }
    counts.insert(
      key,
      counts.at(key, default: 0) + read-weight(row, weight-col),
    )
  }
  // Use the original x column name so the per-group framework can re-inject
  // group column values without column-name mismatches. y maps to "_count"
  // rather than clobbering any existing y column.
  let rows = order.map(k => {
    let r = (:)
    r.insert(x-col, k)
    r.insert("_count", counts.at(k))
    r
  })
  let new-mapping = mapping
  new-mapping.insert("y", "_count")
  (data: rows, mapping: new-mapping)
}
