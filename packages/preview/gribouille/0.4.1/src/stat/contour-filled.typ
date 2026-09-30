///! Filled iso-band statistic. Backing stat for \@geom-contour-filled.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/contour-grid.typ": grid-from-rows, resolve-levels
#import "../utils/isobands.typ": isobands

/// Filled iso-band statistic. Partitions the `(x, y, z)` field into bands defined by successive levels and emits one closed polygon per cell that touches each band. Pair with `geom-polygon` or `geom-contour-filled`.
///
/// `bins`, `binwidth`, and `breaks` follow `stat-contour` precedence, but with one extra level so neighbouring lines bound `n + 1` bands (i.e., `bins: 10` produces ~11 levels and 10 bands).
///
/// - bins: Target band count when `breaks` and `binwidth` are unset.
/// - binwidth: Fixed step between successive levels. Overrides `bins`.
/// - breaks: Explicit array of level boundaries. Overrides the rest.
///
/// Returns: Statistic object with `name: "contour-filled"`.
///
/// See also: `geom-contour-filled`, `stat-contour`.
///
/// Drive `geom-polygon` with the constructor form to fill eight iso-bands of `sin(x) * cos(y)` and paint them via the viridis palette.
///
/// ```typst
/// #let n = 30
/// #let d = ()
/// #for i in range(n) { for j in range(n) {
///   let x = -3 + 6 * i / (n - 1)
///   let y = -3 + 6 * j / (n - 1)
///   d.push((x: x, y: y, z: calc.sin(x) * calc.cos(y)))
/// } }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", z: "z"),
///   layers: (geom-polygon(stat: stat-contour-filled(bins: 8)),),
///   scales: (scale-fill-viridis-c(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-contour-filled(bins: 10, binwidth: none, breaks: auto) = (
  kind: "stat",
  name: "contour-filled",
  params: (bins: bins, binwidth: binwidth, breaks: breaks),
)

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "x", y: "y", group: "group", fill: "_level"),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let z-col = mapping.at("z", default: none)
  if x-col == none or y-col == none or z-col == none {
    return (data: (), mapping: new-mapping)
  }
  let grid = grid-from-rows(data, x-col, y-col, z-col)
  if grid.z.len() == 0 or grid.at("z-lo", default: none) == none {
    return (data: (), mapping: new-mapping)
  }
  // Pad the level set with the data extents so the lowest and highest bands
  // reach the boundary instead of being clipped away by `resolve-levels`.
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
