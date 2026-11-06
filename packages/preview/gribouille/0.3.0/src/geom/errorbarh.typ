///! Horizontal line from `xmin` to `xmax` with vertical caps at each `y`.

#import "../layer.typ": make-layer
#import "../utils/errorbar-draw.typ": _draw-errorbar-axis

/// Horizontal errorbar layer: range with a vertical cap at each end.
///
/// Mapping must provide `y`, `xmin`, `xmax`. The `height` parameter sets the cap span in y data units for continuous y, and as a fraction of the per-category slot height for discrete y.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `y`, `xmin`, `xmax`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - height: Cap span. A Typst length sets the cap span directly in panel units; a number is interpreted as y data units for continuous y and a fraction of the slot height for discrete y.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` resolves via the colour scale.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword. Defaults to `"solid"`.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Defaults to `"identity"`; use `"dodge"` to offset groups within each y slot (no-op when `height` is a Typst length).
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-errorbar`, `geom-linerange`, `geom-pointrange`.
///
/// Horizontal error bars across an integer y axis.
///
/// ```typst
/// #let d = range(1, 6).map(i => (
///   y: i,
///   lo: i - 0.5,
///   hi: i + 0.5,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(y: "y", xmin: "lo", xmax: "hi"),
///   layers: (geom-errorbarh(height: 0.4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Combine with `geom-point` at the central estimate to show point estimates with horizontal uncertainty.
///
/// ```typst
/// #let d = range(1, 6).map(i => (
///   x: i, y: i, lo: i - 0.5, hi: i + 0.5,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xmin: "lo", xmax: "hi"),
///   layers: (
///     geom-errorbarh(height: 0.3),
///     geom-point(size: 3pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-errorbarh(
  mapping: none,
  data: none,
  height: 0.4,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "errorbarh",
  mapping: mapping,
  data: data,
  params: (
    height: height,
    stroke: stroke,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  _draw-errorbar-axis(layer, ctx, "x", layer.params.height)
}
