///! Vertical line from `ymin` to `ymax` with horizontal caps at each `x`.

#import "../position/apply.typ": assert-position
#import "../utils/errors.typ": assert-alpha, assert-linetype
#import "../layer.typ": make-layer, split-aes-params
#import "errorbar-draw.typ": _draw-errorbar-axis

#let spec = (
  reads: ("x", "ymin", "ymax", "colour", "alpha", "linewidth", "linetype"),
  extents: none,
)

/// Errorbar layer: vertical range with a horizontal cap at each end.
///
/// Mapping must provide `x`, `ymin`, `ymax`. The `width` parameter sets the cap span in x data units for continuous x, and as a fraction of the per-category slot width for discrete x.
///
/// Under `coord-radial` a bar that sweeps theta follows the polar grid as an arc, with each cap pointing at the centre. A bar that runs along the radius has caps that are arcs. A number for `width` sets the cap span as on a Cartesian panel. A length sets a straight cap of that span.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `ymin`, `ymax`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - width: Cap span. A Typst length sets the cap span directly in panel units; a number is interpreted as x data units for continuous x and a fraction of the slot width for discrete x.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` resolves via the colour scale.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword (e.g., `"solid"`, `"dashed"`). `auto` honours the linetype scale.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Defaults to `"identity"`; use `"dodge"` to offset groups within each x slot (no-op when `width` is a Typst length).
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
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
  linetype: auto,
  stat: "identity",
  position: "identity",
  key: auto,
  inherit-aes: true,
  ..args,
) = {
  assert-position("geom-errorbar", position)
  assert-alpha("geom-errorbar", alpha)
  assert-linetype("geom-errorbar", linetype)
  make-layer(
    "errorbar",
    mapping: mapping,
    data: data,
    params: (
      width: width,
      stroke: stroke,
      colour: colour,
      alpha: alpha,
      linetype: linetype,
    )
      + split-aes-params("geom-errorbar", args, spec.reads),
    stat: stat,
    position: position,
    key: key,
    inherit-aes: inherit-aes,
  )
}

#let draw(layer, ctx) = {
  _draw-errorbar-axis(layer, ctx, "y", layer.params.width)
}
