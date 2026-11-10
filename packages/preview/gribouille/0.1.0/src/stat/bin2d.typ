///! Rectangular two-dimensional binning. Backing statistic for \@geom-bin-2d.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/bin2d.typ": bin-2d-cells, bin-midpoint-2d, panel-bin-grid-2d

/// Two-dimensional bin statistic: partition (x, y) into a rectangular grid
/// and count rows per cell.
///
/// `bins` and `binwidth` accept either a scalar (applied to both axes) or
/// an `(x, y)` pair. `binwidth` wins on each axis where both are set.
///
/// \@category Stats
/// \@subcategory Binning
/// \@stability stable
/// \@since 0.4.0
///
/// \@param bins Scalar or `(x, y)` pair — target bin counts when binwidth is `none`.
///
/// \@param binwidth Scalar or `(x, y)` pair — fixed bin widths. Overrides `bins` per axis.
///
/// \@returns Statistic object with `name: "bin-2d"`.
///
/// \@examples Drive `geom-rect` with the constructor form to bin a noisy
/// scatter into a 20-by-20 grid coloured by count.
/// ```
/// //| alt: "Two-dimensional bin grid of sine/cosine samples with 20-by-20 rectangular cells shaded by count via stat-bin-2d and the viridis fill palette."
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
///
/// \@see \@geom-bin-2d, \@stat-bin
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
  let cell-area = grid.x-width * grid.y-width
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
      _density: n / cell-area,
    ))
  }
  (data: rows, mapping: new-mapping)
}
