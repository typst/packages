///! Vertical line from `ymin` to `ymax` with horizontal caps at each `x`.

#import "../layer.typ": make-layer
#import "../utils/errorbar-draw.typ": _draw-errorbar-axis

/// Errorbar layer: vertical range with a horizontal cap at each end.
///
/// Mapping must provide `x`, `ymin`, `ymax`. The `width` parameter sets the cap span in x data units for continuous x, and as a fraction of the per-category slot width for discrete x.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `ymin`, `ymax`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - width: Cap span. A Typst length sets the cap span directly in panel units; a number is interpreted as x data units for continuous x and a fraction of the slot width for discrete x.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` resolves via the colour scale.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword. Defaults to `"solid"`.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Defaults to `"identity"`; use `"dodge"` to offset groups within each x slot (no-op when `width` is a Typst length).
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-linerange`, `geom-pointrange`, `geom-crossbar`.
///
/// Vertical error bars with default cap span.
///
/// ```typst
/// #let d = range(1, 6).map(i => (
///   x: i,
///   lo: i - 0.5,
///   hi: i + 0.5,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", ymin: "lo", ymax: "hi"),
///   layers: (geom-errorbar(width: 0.4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Combine with `geom-point` at the central estimate to convey the uncertainty around it.
///
/// ```typst
/// #let d = range(1, 6).map(i => (
///   x: i, y: i, lo: i - 0.5, hi: i + 0.5,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi"),
///   layers: (
///     geom-errorbar(width: 0.3),
///     geom-point(size: 3pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-errorbar(
  mapping: none,
  data: none,
  width: 0.4,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "errorbar",
  mapping: mapping,
  data: data,
  params: (
    width: width,
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
  _draw-errorbar-axis(layer, ctx, "y", layer.params.width)
}
