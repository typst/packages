///! Iso-line 2D density statistic. Backing stat for \@geom-density-2d.
///!
///! Estimates a 2D Gaussian kernel density over the `(x, y)` sample
///! (\@kde-2d) and emits the marching-squares iso-line segments of the
///! estimated surface, so the layer draws density contours directly from
///! raw observations.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": read-weight
#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/contour-grid.typ": resolve-levels
#import "../utils/marching-squares.typ": isolines-multi
#import "../utils/kde.typ": kde-2d

// Parse the `(x, y, weight)` sample shared by the line and filled 2D
// density stats. Returns `none` when the mapping or sample is unusable.
#let density-2d-pairs(data, mapping) = {
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return none }
  let weight-col = mapping.at("weight", default: none)
  let pairs = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      let yv = parse-number(r.at(y-col, default: none))
      if xv == none or yv == none { return none }
      (x: xv, y: yv, w: read-weight(r, weight-col))
    })
    .filter(p => p != none and p.w > 0)
  if pairs.len() < 2 { return none }
  pairs
}

/// 2D density statistic: iso-lines of a Gaussian kernel density estimate.
///
/// Smooths the `(x, y)` sample into a density surface on an `n × n` grid, then traces the surface's contour lines. Emits the same row shape as `stat-contour` (`x`, `y`, `group`, `_level`), so it pairs with `geom-density-2d` or `geom-path`.
///
/// Either `breaks`, `binwidth`, or `bins` controls level placement; precedence runs `breaks` > `binwidth` > `bins` (default `bins: 10`).
///
/// from R's `bw.nrd / 4` (the seed MASS `kde2d` uses); pass a number for both axes or an `(x, y)` tuple.
///
/// - bw: Kernel standard deviation per axis. `auto` derives it per axis
/// - adjust: Bandwidth multiplier: `adjust: 0.5` halves the smoothing.
/// - n: Grid resolution per axis: a number or an `(x, y)` tuple.
/// - bins: Target contour-level count when `breaks` and `binwidth` are unset.
/// - binwidth: Fixed step between levels. Overrides `bins`.
/// - breaks: Explicit array of contour levels. Overrides `bins` and `binwidth`.
///
/// Returns: Statistic object with `name: "density-2d"`.
///
/// See also: `geom-density-2d`, `stat-contour`, `stat-density`.
///
/// Density contours of two point clouds via `geom-path`.
///
/// ```typst
/// #let d = range(0, 60).map(i => {
///   let lobe = calc.rem(i, 2)
///   (
///     x: 2 + lobe * 4 + calc.sin(i * 1.7) * 0.8,
///     y: 2 + lobe * 3 + calc.cos(i * 2.3) * 0.8,
///   )
/// })
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 1.5pt, alpha: 0.5),
///     geom-path(stat: stat-density-2d(bins: 8)),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-density-2d(
  bw: auto,
  adjust: 1,
  n: 25,
  bins: 10,
  binwidth: none,
  breaks: auto,
) = (
  kind: "stat",
  name: "density-2d",
  params: (
    bw: bw,
    adjust: adjust,
    n: n,
    bins: bins,
    binwidth: binwidth,
    breaks: breaks,
  ),
)

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "x", y: "y", group: "group"),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let pairs = density-2d-pairs(data, mapping)
  if pairs == none { return (data: (), mapping: new-mapping) }
  let grid = kde-2d(
    pairs,
    bw: params.at("bw", default: auto),
    adjust: params.at("adjust", default: 1),
    n: params.at("n", default: 25),
  )
  let levels = resolve-levels(
    grid.z-lo,
    grid.z-hi,
    params.at("bins", default: 10),
    params.at("binwidth", default: none),
    params.at("breaks", default: auto),
  )
  let rows = ()
  let seg-lists = isolines-multi(grid.xs, grid.ys, grid.z, levels)
  for (li, level) in levels.enumerate() {
    let segs = seg-lists.at(li)
    for (si, ((x0, y0), (x1, y1))) in segs.enumerate() {
      let group = str(li) + ":" + str(si)
      rows.push((x: x0, y: y0, _level: level, group: group))
      rows.push((x: x1, y: y1, _level: level, group: group))
    }
  }
  (data: rows, mapping: new-mapping)
}
