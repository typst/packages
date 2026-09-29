///! Binned y-summary statistic.
///!
///! Bins x with the same uniform-width rule as `src/stat/bin.typ`, then for
///! each bin reduces the y values inside to a `(y, ymin, ymax)` summary
///! using one of the helpers in `src/utils/summaries.typ`.

#import "../utils/summaries.typ": summarise
#import "../utils/bin.typ": bin-1d-cells, bin-midpoint, panel-bin-grid
#import "../utils/aes-resolve.typ": stat-output-mapping

/// Summary statistic over uniform x bins.
///
/// Partitions x into uniform-width bins (same rule as `stat-bin`), then for every bin reduces the y values inside to a `(x, y, ymin, ymax)` row where `x` is the bin midpoint. The reduction is chosen by `fun`; supported names are `"mean-se"`, `"mean-cl-normal"`, `"mean-sd"`, and `"median-hilow"`.
///
/// Either `bins` or `binwidth` fixes the partition; if both are supplied, `binwidth` wins.
///
/// - fun: Name of the summary helper to apply to each bin's y values.
/// - bins: Target number of bins when `binwidth` is `none`.
/// - binwidth: Fixed bin width. Overrides `bins` when set.
/// - fun-args: Keyword arguments forwarded to the helper.
///
/// Returns: Statistic object with `name: "summary-bin"`, consumed by geom layers.
///
/// See also: `stat-summary`, `stat-bin`.
///
/// Mean and standard-error bands per bin, drawn as a polyline.
///
/// ```typst
/// #let d = range(0, 80).map(i => (x: i / 10, y: calc.sin(i / 10) + i / 80))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-line(stat: stat-summary-bin(fun: "mean-se", bins: 8)),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// `stat: "summary-bin"` is equivalent to `stat: stat-summary-bin()` with defaults (`fun: "mean-se"`, `bins: 30`). Use the constructor to customise the reduction or partition.
///
/// ```typst
/// #let d = range(0, 80).map(i => (x: i / 10, y: calc.sin(i / 10) + i / 80))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-pointrange(
///       size: 3pt,
///       stat: stat-summary-bin(fun: "median-hilow", bins: 8),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-summary-bin(
  fun: "mean-se",
  bins: 30,
  binwidth: none,
  fun-args: (:),
) = (
  kind: "stat",
  name: "summary-bin",
  params: (
    fun: fun,
    bins: bins,
    binwidth: binwidth,
    "fun-args": fun-args,
  ),
)

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "x", y: "y", ymin: "ymin", ymax: "ymax"),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: (), mapping: new-mapping)
  }

  let weight-col = mapping.at("weight", default: none)
  let cells = bin-1d-cells(data, x-col, weight-col, params, y-col: y-col)
  if cells == none { return (data: (), mapping: new-mapping) }

  let fun = params.at("fun", default: "mean-se")
  let fun-args = params.at("fun-args", default: (:))

  let out = ()
  for i in range(cells.grid.n-bins) {
    let bucket = cells.buckets.at(i)
    if bucket.ys.len() == 0 { continue }
    let weights = if weight-col == none { none } else { bucket.ws }
    let summary = summarise(
      fun,
      bucket.ys,
      fun-args: fun-args,
      weights: weights,
    )
    if summary.y == none { continue }
    out.push((
      x: bin-midpoint(cells.grid.lo, cells.grid.width, i),
      y: summary.y,
      ymin: summary.ymin,
      ymax: summary.ymax,
    ))
  }

  (data: out, mapping: new-mapping)
}
