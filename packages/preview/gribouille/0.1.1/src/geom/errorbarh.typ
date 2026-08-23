///! Horizontal line from `xmin` to `xmax` with vertical caps at each `y`.

#import "../layer.typ": make-layer
#import "../utils/errorbar-draw.typ": _draw-errorbar-axis

/// Horizontal errorbar layer: range with a vertical cap at each end.
///
/// Mapping must provide `y`, `xmin`, `xmax`. The `height` parameter sets the
/// cap span in y data units for continuous y, and as a fraction of the
/// per-category slot height for discrete y.
///
/// \@category Geoms
/// \@subcategory Intervals and errors
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `y`, `xmin`, `xmax`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param height Cap span. A Typst length sets the cap span directly in panel units; a number is interpreted as y data units for continuous y and a fraction of the slot height for discrete y.
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
/// \@param position Position adjustment name. Defaults to `"identity"`; use `"dodge"` to offset groups within each y slot (no-op when `height` is a Typst length).
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Horizontal error bars across an integer y axis.
/// ```
/// //| alt: "Horizontal errorbars at y = 1 to 5 spanning lo to hi on the x axis with vertical caps at each end."
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
/// \@examples Combine with \@geom-point at the central estimate to show point
/// estimates with horizontal uncertainty.
/// ```
/// //| alt: "Horizontal errorbars from lo to hi at y = 1 to 5 overlaid with point markers at the central x estimate."
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
///
/// \@see \@geom-errorbar, \@geom-linerange, \@geom-pointrange
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
