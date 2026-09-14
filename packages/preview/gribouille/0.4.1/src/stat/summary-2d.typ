#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/bin2d.typ": bin-2d-cells, bin-midpoint-2d
#import "../utils/summaries.typ": reduce-scalar

/// Two-dimensional summary statistic.
///
/// Partitions (x, y) into a rectangular grid (same rule as `stat-bin-2d`), then for every non-empty cell reduces the `z` values inside to a single scalar emitted as the `_value` column.
///
/// `fun` accepts a string keyword (`"mean"`, `"median"`, `"sum"`, `"min"`, `"max"`) or a callable `values => scalar`.
///
/// - fun: Reduction. String keyword or callable.
/// - bins: Scalar or `(x, y)` pair — target bin counts.
/// - binwidth: Scalar or `(x, y)` pair — fixed bin widths.
///
/// Returns: Statistic object with `name: "summary-2d"`.
///
/// See also: `stat-bin-2d`, `stat-summary-bin`.
///
/// Reduce a `z` aesthetic over a 25-by-25 grid: each cell paints by the mean of the values that fell inside it.
///
/// ```typst
/// #let n = 600
/// #let d = range(0, n).map(i => {
///   let t = i / n
///   let theta = t * 6 * calc.pi
///   let r = 1 + t * 3
///   let x = r * calc.cos(theta) + calc.sin(t * 11.0) * 0.3
///   let y = r * calc.sin(theta) + calc.cos(t * 13.0) * 0.3
///   (x: x, y: y, z: r)
/// })
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", z: "z"),
///   layers: (geom-rect(stat: stat-summary-2d(fun: "mean", bins: 25)),),
///   scales: (scale-fill-viridis-c(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-summary-2d(fun: "mean", bins: 30, binwidth: none) = (
  kind: "stat",
  name: "summary-2d",
  params: (fun: fun, bins: bins, binwidth: binwidth),
)

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (
      x: "x",
      y: "y",
      xmin: "xmin",
      xmax: "xmax",
      ymin: "ymin",
      ymax: "ymax",
      fill: "_value",
    ),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let z-col = mapping.at("z", default: none)
  if z-col == none { return (data: (), mapping: new-mapping) }
  let cells = bin-2d-cells(
    data,
    mapping.at("x", default: none),
    mapping.at("y", default: none),
    params,
    z-col: z-col,
  )
  if cells == none { return (data: (), mapping: new-mapping) }
  let grid = cells.grid
  let ny = grid.y-n-bins
  let fun = params.at("fun", default: "mean")
  let rows = ()
  for k in range(cells.buckets.len()) {
    let bucket = cells.buckets.at(k)
    if bucket.len() == 0 { continue }
    let value = reduce-scalar(fun, bucket)
    if value == none { continue }
    let (xm, ym) = bin-midpoint-2d(grid, calc.quo(k, ny), calc.rem(k, ny))
    rows.push((
      x: xm,
      y: ym,
      xmin: xm - grid.x-width / 2,
      xmax: xm + grid.x-width / 2,
      ymin: ym - grid.y-width / 2,
      ymax: ym + grid.y-width / 2,
      _value: value,
    ))
  }
  (data: rows, mapping: new-mapping)
}
