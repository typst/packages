///! Hexagonal two-dimensional summary statistic. Reduces a `z` aesthetic
///! per hex cell.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/hex.typ": hex-cells
#import "../utils/summaries.typ": reduce-scalar

/// Hex-grid summary statistic.
///
/// Partitions (x, y) into a pointy-top hex grid (same rule as `stat-bin-hex`), then reduces the `z` values inside each cell to a single scalar emitted as the `_value` column.
///
/// - fun: Reduction. String keyword (`"mean"`, `"median"`, `"sum"`, `"min"`, `"max"`) or callable.
/// - bins: Scalar or `(x, y)` pair — target bin counts.
/// - binwidth: Scalar or `(x, y)` pair — fixed pitches.
///
/// Returns: Statistic object with `name: "summary-hex"`.
///
/// See also: `stat-bin-hex`, `stat-summary-2d`.
///
/// Override the default hex statistic via a dictionary-merge so each cell paints by the mean `z` over a 25-bin grid.
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
///   layers: (
///     geom-hex(bins: 25) + (stat: stat-summary-hex(fun: "mean", bins: 25)),
///   ),
///   scales: (scale-fill-viridis-c(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-summary-hex(fun: "mean", bins: 30, binwidth: none) = (
  kind: "stat",
  name: "summary-hex",
  params: (fun: fun, bins: bins, binwidth: binwidth),
)

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "x", y: "y", fill: "_value"),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let z-col = mapping.at("z", default: none)
  if z-col == none { return (data: (), mapping: new-mapping) }
  let result = hex-cells(
    data,
    mapping.at("x", default: none),
    mapping.at("y", default: none),
    params,
    z-col: z-col,
  )
  if result == none { return (data: (), mapping: new-mapping) }
  let grid = result.grid
  let fun = params.at("fun", default: "mean")
  let rows = ()
  for c in result.cells.values() {
    let value = reduce-scalar(fun, c.zs)
    if value == none { continue }
    rows.push((
      x: c.cx,
      y: c.cy,
      _value: value,
      _hex-dx: grid.dx,
      _hex-dy: grid.dy,
    ))
  }
  (data: rows, mapping: new-mapping)
}
