///! Scatter with per-row jitter offset.
///!
///! Thin wrapper around \@geom-point that defaults `position` to `"jitter"`.

#import "point.typ": geom-point

/// Scatter layer with `position-jitter` applied by default.
///
/// All other parameters mirror `geom-point`.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - size: Marker size (a Typst length).
/// - stroke: Marker outline thickness; `none` disables the outline and the `colour` aesthetic.
/// - fill: Marker body fill. `auto` resolves via the fill scale or a neutral default.
/// - colour: Fixed marker outline colour. `auto` resolves via the colour scale, falling back to the theme `ink`.
/// - alpha: Marker opacity in `[0, 1]`.
/// - shape: Marker shape keyword.
/// - stat: Statistical transform name.
/// - position: Position adjustment name. Defaults to `"jitter"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-point`, `position-jitter`.
///
/// Spread overlapping points with the default jitter amount.
///
/// ```typst
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
/// Map `fill` so each jittered cluster is visually distinct.
///
/// ```typst
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
