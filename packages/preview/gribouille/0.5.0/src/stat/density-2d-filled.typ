///! Filled iso-band 2D density statistic. Backing stat for
///! \@geom-density-2d-filled.
///!
///! Estimates a 2D Gaussian kernel density over the `(x, y)` sample
///! (\@kde-2d) and emits one closed polygon per grid cell per density band,
///! so the layer shades the estimated surface directly from raw
///! observations.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/contour-grid.typ": resolve-levels
#import "../utils/isobands.typ": isobands
#import "../utils/kde.typ": kde-2d
#import "density-2d.typ": density-2d-pairs

/// Filled 2D density statistic: iso-bands of a Gaussian kernel density estimate.
///
/// Smooths the `(x, y)` sample into a density surface on an `n × n` grid, then cuts the surface into level bands. Emits the same row shape as `stat-contour-filled` (closed polygons with `fill` bound to `_level`), so it pairs with `geom-density-2d-filled` or `geom-polygon`.
///
/// Either `breaks`, `binwidth`, or `bins` controls band placement; precedence runs `breaks` > `binwidth` > `bins` (default `bins: 10`).
///
/// from R's `bw.nrd / 4` (the seed MASS `kde2d` uses); pass a number for both axes or an `(x, y)` tuple.
///
/// - bw: Kernel standard deviation per axis. `auto` derives it per axis
/// - adjust: Bandwidth multiplier: `adjust: 0.5` halves the smoothing.
/// - n: Grid resolution per axis: a number or an `(x, y)` tuple.
/// - bins: Target band count when `breaks` and `binwidth` are unset.
/// - binwidth: Fixed step between band edges. Overrides `bins`.
/// - breaks: Explicit array of band edges. Overrides `bins` and `binwidth`.
///
/// Returns: Statistic object with `name: "density-2d-filled"`.
///
/// See also: `geom-density-2d-filled`, `stat-contour-filled`, `stat-density-2d`.
///
/// Shaded density bands of two point clouds.
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
///   layers: (geom-density-2d-filled(bins: 8),),
///   scales: scales(
///     x: scale-continuous(expand: (0, 0)),
///     y: scale-continuous(expand: (0, 0)),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-density-2d-filled(
  bw: auto,
  adjust: 1,
  n: 25,
  bins: 10,
  binwidth: none,
  breaks: auto,
) = (
  kind: "stat",
  name: "density-2d-filled",
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
    (x: "x", y: "y", group: "group", fill: "_level"),
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
  // Pad the level set with the surface extents so the lowest and highest
  // bands reach the boundary instead of being clipped by `resolve-levels`.
  let inner = resolve-levels(
    grid.z-lo,
    grid.z-hi,
    params.at("bins", default: 10),
    params.at("binwidth", default: none),
    params.at("breaks", default: auto),
  )
  let edges = (grid.z-lo,) + inner + (grid.z-hi,)
  let rows = ()
  for bi in range(edges.len() - 1) {
    let lo = edges.at(bi)
    let hi = edges.at(bi + 1)
    if hi <= lo { continue }
    let polys = isobands(grid.xs, grid.ys, grid.z, lo, hi)
    for (ci, poly) in polys.enumerate() {
      let group = str(bi) + ":" + str(ci)
      for v in poly {
        rows.push((x: v.x, y: v.y, _level: lo, group: group))
      }
    }
  }
  (data: rows, mapping: new-mapping)
}
