///! Step function between consecutive observations.
///!
///! Like \@geom-line but each segment between two points is drawn as a
///! stair-step: a horizontal then vertical move (`direction: "hv"`,
///! default) or vertical then horizontal (`direction: "vh"`).

#import "../layer.typ": make-layer
#import "../utils/errors.typ": fail-enum
#import "grouped-path.typ": draw-grouped-paths, rows-to-points, sort-rows-by-x

/// Step layer connecting observations as a stair-step path, one per group.
///
/// `direction` chooses between `"hv"` (horizontal first, then vertical) and `"vh"` (vertical first, then horizontal).
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - direction: Step direction: `"hv"` (default) or `"vh"`.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` resolves via the colour scale or a neutral default.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword (e.g., `"solid"`, `"dashed"`). `auto` honours the linetype scale.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-line`, `geom-path`.
///
/// Default `"hv"` step path moving right then up between points.
///
/// ```typst
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
/// `"vh"` direction reverses the corner placement, useful when the change is best read as happening at the previous timestamp.
///
/// ```typst
/// #let d = range(0, 7).map(i => (x: i, y: calc.rem(i * 3, 5)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-step(direction: "vh", stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
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
    fail-enum("geom-step", "direction", direction, ("hv", "vh"))
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
