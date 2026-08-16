///! Polyline preserving row order.
///!
///! Identical to \@geom-line except rows are joined in their input order
///! rather than sorted by x. Useful for trajectories, time-series with
///! out-of-order timestamps, and any path where order is meaningful.

#import "../layer.typ": make-layer
#import "grouped-path.typ": draw-grouped-paths, rows-to-points

/// Path layer connecting observations in row order, one path per group.
///
/// Grouping is implicit on discrete aesthetics (colour, fill, linetype) or the explicit `group` mapping, just like `geom-line`.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` resolves via the colour scale or a neutral default.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword (e.g., `"solid"`, `"dashed"`). `auto` honours the linetype scale.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-line`, `geom-step`, `geom-segment`.
///
/// Connect rows in input order (deliberately not sorted by x).
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1), (x: 3, y: 4), (x: 2, y: 2), (x: 4, y: 5),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-path(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Trajectory of a moving point parameterised by `t`, drawn in time order with a coloured fade.
///
/// ```typst
/// #let d = range(0, 24).map(t => (
///   x: calc.cos(t * 0.4), y: calc.sin(t * 0.4) * (t / 24 + 0.5), t: t,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "t"),
///   layers: (geom-path(stroke: 1.2pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-path(
  mapping: none,
  data: none,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  key: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "path",
  mapping: mapping,
  data: data,
  params: (stroke: stroke, colour: colour, alpha: alpha, linetype: linetype),
  key: key,
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let _build-pts(rows, layer, mapping, x-trained, ctx) = (
  rows-to-points(rows, mapping, ctx)
)

#let draw(layer, ctx) = draw-grouped-paths(layer, ctx, _build-pts)
