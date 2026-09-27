///! Scatter with per-row jitter offset.
///!
///! Thin wrapper around \@geom-point that defaults `position` to `"jitter"`.

#import "point.typ": geom-point

/// Scatter layer with \@position-jitter applied by default.
///
/// All other parameters mirror \@geom-point.
///
/// \@category Geoms
/// \@subcategory Points
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Falls back to the plot mapping when `none`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param size Marker size (a Typst length).
///
/// \@param stroke Marker outline thickness; `none` disables the outline and the `colour` aesthetic.
///
/// \@param fill Marker body fill. `auto` resolves via the fill scale or a neutral default.
///
/// \@param colour Fixed marker outline colour. `auto` resolves via the colour scale, falling back to the theme `ink`.
///
/// \@param alpha Marker opacity in `[0, 1]`.
///
/// \@param shape Marker shape keyword.
///
/// \@param stat Statistical transform name.
///
/// \@param position Position adjustment name. Defaults to `"jitter"`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Spread overlapping points with the default jitter amount.
/// ```
/// //| alt: "Scatter of overlapping (x, y = 1) rows at x = 1, 2, 3 spread out by jittered position adjustment."
/// #let d = ()
/// #for x in (1, 2, 3) {
///   for _ in range(0, 16) { d.push((x: x, y: 1)) }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-jitter(size: 2pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Map `fill` so each jittered cluster is visually distinct.
/// ```
/// //| alt: "Jittered scatter of three discrete x categories (a, b, c) at y = 1 with markers coloured by fill aesthetic."
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for _ in range(0, 16) { d.push((x: grp, y: 1, grp: grp)) }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "grp"),
///   layers: (geom-jitter(size: 2pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-point, \@position-jitter
#let geom-jitter(
  mapping: none,
  data: none,
  size: auto,
  stroke: auto,
  fill: auto,
  colour: auto,
  alpha: auto,
  shape: auto,
  stat: "identity",
  position: "jitter",
  inherit-aes: true,
) = geom-point(
  mapping: mapping,
  data: data,
  size: size,
  stroke: stroke,
  fill: fill,
  colour: colour,
  alpha: alpha,
  shape: shape,
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)
