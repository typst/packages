///! Uniform-width histogram binning.
///!
///! Backing statistic for \@geom-histogram. Emits one row per bin with the
///! bin midpoint as x, the count as y, and the bin `width` for reference.

#import "../utils/bin.typ": bin-1d-cells, bin-midpoint, panel-bin-grid
#import "../utils/aes-resolve.typ": stat-output-mapping

/// Bin statistic: partition x into uniform-width bins, count rows per bin.
///
/// Either `bins` or `binwidth` fixes the partition; if both are supplied, `binwidth` wins.
///
/// - bins: Target number of bins when `binwidth` is `none`.
/// - binwidth: Fixed bin width. Overrides `bins` when set.
///
/// Returns: Statistic object with `name: "bin"`, consumed by geom layers.
///
/// See also: `geom-histogram`, `stat-count`.
///
/// Histogram driven by an eight-bin partition.
///
/// ```typst
/// #let d = range(0, 40).map(i => (x: i * 0.25))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-histogram(bins: 8),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Constructor form: `stat: stat-bin()` is equivalent to `stat: "bin"` with defaults (`bins: 30`). Use the constructor to customise the partition on any geom, not just `geom-histogram`.
///
/// ```typst
/// #let d = range(0, 40).map(i => (x: i * 0.25))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-col(stat: stat-bin(bins: 8)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-bin(bins: 30, binwidth: none) = (
  kind: "stat",
  name: "bin",
  params: (bins: bins, binwidth: binwidth),
)

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  let new-mapping = stat-output-mapping(mapping, (x: "x", y: "y"))
  if x-col == none { return (data: data, mapping: mapping) }
  let cells = bin-1d-cells(
    data,
    x-col,
    mapping.at("weight", default: none),
    params,
  )
  if cells == none { return (data: (), mapping: new-mapping) }
  let denom = if cells.total == 0 { 1 } else { cells.total * cells.grid.width }
  let rows = range(cells.grid.n-bins).map(i => {
    let c = cells.counts.at(i)
    (
      x: bin-midpoint(cells.grid.lo, cells.grid.width, i),
      y: c,
      width: cells.grid.width,
      _count: c,
      _density: c / denom,
    )
  })
  (data: rows, mapping: new-mapping)
}
