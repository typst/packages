///! Iso-line contour statistic. Backing stat for \@geom-contour.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/contour-grid.typ": grid-from-rows, resolve-levels
#import "../utils/marching-squares.typ": isolines

/// Marching-squares contour statistic.
///
/// Treats input rows as samples of a scalar field `z` over a regular `(x, y)` grid (one row per Cartesian product cell) and emits the iso-line segments at each level. Pair with `geom-path` or `geom-contour` to draw.
///
/// Either `breaks`, `binwidth`, or `bins` controls level placement; precedence runs `breaks` > `binwidth` > `bins` (default `bins: 10`).
///
/// - bins: Target contour-level count when `breaks` and `binwidth` are unset.
/// - binwidth: Fixed step between levels. Overrides `bins`.
/// - breaks: Explicit array of contour levels. Overrides `bins` and `binwidth`.
///
/// Returns: Statistic object with `name: "contour"`.
///
/// See also: `geom-contour`, `stat-bin-2d`.
///
/// Drive `geom-path` with the constructor form over a `sin(x) * cos(y)` grid to trace eight iso-lines.
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
///   layers: (geom-path(stat: stat-contour(bins: 8)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-contour(bins: 10, binwidth: none, breaks: auto) = (
  kind: "stat",
  name: "contour",
  params: (bins: bins, binwidth: binwidth, breaks: breaks),
)

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "x", y: "y", group: "group"),
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
  let levels = resolve-levels(
    grid.z-lo,
    grid.z-hi,
    params.at("bins", default: 10),
    params.at("binwidth", default: none),
    params.at("breaks", default: auto),
  )
  let rows = ()
  for (li, level) in levels.enumerate() {
    let segs = isolines(grid.xs, grid.ys, grid.z, level)
    for (si, ((x0, y0), (x1, y1))) in segs.enumerate() {
      let group = str(li) + ":" + str(si)
      rows.push((x: x0, y: y0, _level: level, group: group))
      rows.push((x: x1, y: y1, _level: level, group: group))
    }
  }
  (data: rows, mapping: new-mapping)
}
