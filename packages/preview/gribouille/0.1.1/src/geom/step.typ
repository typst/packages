///! Step function between consecutive observations.
///!
///! Like \@geom-line but each segment between two points is drawn as a
///! stair-step: a horizontal then vertical move (`direction: "hv"`,
///! default) or vertical then horizontal (`direction: "vh"`).

#import "../layer.typ": make-layer
#import "grouped-path.typ": draw-grouped-paths, rows-to-points, sort-rows-by-x

/// Step layer connecting observations as a stair-step path, one per group.
///
/// `direction` chooses between `"hv"` (horizontal first, then vertical)
/// and `"vh"` (vertical first, then horizontal).
///
/// \@category Geoms
/// \@subcategory Lines and paths
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Falls back to the plot mapping when `none`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param direction Step direction: `"hv"` (default) or `"vh"`.
///
/// \@param stroke Line thickness (a Typst length).
///
/// \@param colour Fixed line colour. `auto` resolves via the colour scale or a neutral default.
///
/// \@param alpha Line opacity in `[0, 1]`.
///
/// \@param linetype Dash keyword (e.g., `"solid"`, `"dashed"`). `auto` honours the linetype scale.
///
/// \@param stat Statistical transform name. Usually `"identity"`.
///
/// \@param position Position adjustment name. Usually `"identity"`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Default `"hv"` step path moving right then up between points.
/// ```
/// //| alt: "Stair-step polyline of y against x = 0 to 6 moving horizontally then vertically between successive points."
/// #let d = range(0, 7).map(i => (x: i, y: calc.rem(i * 3, 5)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-step(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples `"vh"` direction reverses the corner placement, useful when
/// the change is best read as happening at the previous timestamp.
/// ```
/// //| alt: "Stair-step polyline of y against x = 0 to 6 moving vertically then horizontally between successive points."
/// #let d = range(0, 7).map(i => (x: i, y: calc.rem(i * 3, 5)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-step(direction: "vh", stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-line, \@geom-path
#let geom-step(
  mapping: none,
  data: none,
  direction: "hv",
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = {
  if direction != "hv" and direction != "vh" {
    panic("geom-step: direction must be \"hv\" or \"vh\"")
  }
  make-layer(
    "step",
    mapping: mapping,
    data: data,
    params: (
      direction: direction,
      stroke: stroke,
      colour: colour,
      alpha: alpha,
      linetype: linetype,
    ),
    stat: stat,
    position: position,
    inherit-aes: inherit-aes,
  )
}

#let _stair(pts, direction) = {
  if pts.len() < 2 { return pts }
  let out = (pts.first(),)
  for i in range(1, pts.len()) {
    let (x0, y0) = pts.at(i - 1)
    let (x1, y1) = pts.at(i)
    if direction == "hv" {
      out.push((x1, y0))
    } else {
      out.push((x0, y1))
    }
    out.push((x1, y1))
  }
  out
}

#let _build-pts(rows, layer, mapping, x-trained, ctx) = {
  let pts = rows-to-points(
    sort-rows-by-x(rows, mapping, x-trained),
    mapping,
    ctx,
  )
  _stair(pts, layer.params.direction)
}

#let draw(layer, ctx) = draw-grouped-paths(layer, ctx, _build-pts)
