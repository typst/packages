///! Vertical line from `ymin` to `ymax` with horizontal caps at each `x`.

#import "../layer.typ": make-layer
#import "../utils/errorbar-draw.typ": _draw-errorbar-axis

/// Errorbar layer: vertical range with a horizontal cap at each end.
///
/// Mapping must provide `x`, `ymin`, `ymax`. The `width` parameter sets the
/// cap span in x data units for continuous x, and as a fraction of the
/// per-category slot width for discrete x.
///
/// \@category Geoms
/// \@subcategory Intervals and errors
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `ymin`, `ymax`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param width Cap span. A Typst length sets the cap span directly in panel units; a number is interpreted as x data units for continuous x and a fraction of the slot width for discrete x.
///
/// \@param stroke Line thickness (a Typst length).
///
/// \@param colour Fixed line colour. `auto` resolves via the colour scale.
///
/// \@param alpha Line opacity in `[0, 1]`.
///
/// \@param linetype Dash keyword. Defaults to `"solid"`.
///
/// \@param stat Statistical transform name. Usually `"identity"`.
///
/// \@param position Position adjustment name. Defaults to `"identity"`; use `"dodge"` to offset groups within each x slot (no-op when `width` is a Typst length).
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Vertical error bars with default cap span.
/// ```
/// //| alt: "Vertical errorbars at x = 1 to 5 spanning lo to hi with horizontal caps at each end indicating uncertainty."
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
/// \@examples Combine with \@geom-point at the central estimate to convey the
/// uncertainty around it.
/// ```
/// //| alt: "Vertical errorbars at x = 1 to 5 from lo to hi overlaid with circular markers at the central y estimate."
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
///
/// \@see \@geom-linerange, \@geom-pointrange, \@geom-crossbar
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
