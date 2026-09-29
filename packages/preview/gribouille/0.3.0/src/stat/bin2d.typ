///! Rectangular two-dimensional binning. Backing statistic for \@geom-bin-2d.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/bin2d.typ": bin-2d-cells, bin-midpoint-2d, panel-bin-grid-2d

/// Two-dimensional bin statistic: partition (x, y) into a rectangular grid and count rows per cell.
///
/// `bins` and `binwidth` accept either a scalar (applied to both axes) or an `(x, y)` pair. `binwidth` wins on each axis where both are set.
///
/// - bins: Scalar or `(x, y)` pair — target bin counts when binwidth is `none`.
/// - binwidth: Scalar or `(x, y)` pair — fixed bin widths. Overrides `bins` per axis.
///
/// Returns: Statistic object with `name: "bin-2d"`.
///
/// See also: `geom-bin-2d`, `stat-bin`.
///
/// Drive `geom-rect` with the constructor form to bin a noisy scatter into a 20-by-20 grid coloured by count.
///
/// ```typst
/// #let d = range(0, 400).map(i => (
///   x: calc.sin(i * 0.13) * 4,
///   y: calc.cos(i * 0.21) * 4,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-rect(stat: stat-bin-2d(bins: 20)),),
///   scales: (scale-fill-viridis-c(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-bin-2d(bins: 30, binwidth: none) = (
  kind: "stat",
  name: "bin-2d",
  params: (bins: bins, binwidth: binwidth),
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
      fill: "_count",
    ),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let cells = bin-2d-cells(
    data,
    mapping.at("x", default: none),
    mapping.at("y", default: none),
    params,
    weight-col: mapping.at("weight", default: none),
  )
  if cells == none { return (data: (), mapping: new-mapping) }
  let grid = cells.grid
  let ny = grid.y-n-bins
  // `_density` is the cell's fraction of the total count, `count / sum(count)`
  // (the ggplot2 convention). Only non-empty cells emit rows, so the total is
  // never zero where it is used as a denominator.
  let total = cells.total
  let rows = ()
  for k in range(cells.counts.len()) {
    let n = cells.counts.at(k)
    if n == 0 { continue }
    let (xm, ym) = bin-midpoint-2d(grid, calc.quo(k, ny), calc.rem(k, ny))
    rows.push((
      x: xm,
      y: ym,
      xmin: xm - grid.x-width / 2,
      xmax: xm + grid.x-width / 2,
      ymin: ym - grid.y-width / 2,
      ymax: ym + grid.y-width / 2,
      _count: n,
      _density: n / total,
    ))
  }
  (data: rows, mapping: new-mapping)
}
