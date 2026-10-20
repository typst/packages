///! Empirical cumulative distribution function statistic.
///!
///! Backing statistic for ECDF curves. Emits one row per unique x value with
///! the cumulative fraction reaching that value as y.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": read-weight
#import "../utils/aes-resolve.typ": stat-output-mapping

/// ECDF statistic: one row per unique x value with the cumulative fraction.
///
/// Numeric x values are parsed via `parse-number`; `none` and unparseable inputs are dropped. For each unique value `v` in the sorted sample, y is the cumulative weighted count of observations less than or equal to `v` divided by the total weight, matching `R`'s `ecdf(x)(v)`. Output rows are sorted by x ascending.
///
/// Returns: Statistic object with `name: "ecdf"`, consumed by geom layers.
///
/// See also: `stat-bin`, `stat-count`.
///
/// ECDF curve over a tiny sample, drawn as a polyline.
///
/// ```typst
/// #let d = (3, 1, 2, 1).map(v => (x: v))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-line(stat: "ecdf"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Constructor form: `stat: stat-ecdf()` is equivalent to `stat: "ecdf"` with defaults. Mapping `colour` to a group column produces one ECDF per group; both syntax forms honour aesthetic grouping identically.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 15) {
///     d.push((x: i + (if grp == "b" { 3 } else { 0 }), grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", colour: "grp"),
///   layers: (geom-line(stat: stat-ecdf(), stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-ecdf() = (kind: "stat", name: "ecdf", params: (:))

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  let new-mapping = stat-output-mapping(mapping, (x: "x", y: "y"))
  if x-col == none { return (data: (), mapping: new-mapping) }
  let weight-col = mapping.at("weight", default: none)
  let pairs = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      if xv == none { return none }
      (x: xv, w: read-weight(r, weight-col))
    })
    .filter(p => p != none)
  if pairs.len() == 0 { return (data: (), mapping: new-mapping) }
  let total = pairs.fold(0, (acc, p) => acc + p.w)
  if total == 0 { return (data: (), mapping: new-mapping) }
  let sorted = pairs.sorted(key: p => p.x)
  let rows = ()
  let cum = 0
  let i = 0
  let n = sorted.len()
  while i < n {
    let v = sorted.at(i).x
    cum += sorted.at(i).w
    let j = i + 1
    while j < n and sorted.at(j).x == v {
      cum += sorted.at(j).w
      j = j + 1
    }
    rows.push((x: v, y: cum / total))
    i = j
  }
  (data: rows, mapping: new-mapping)
}
