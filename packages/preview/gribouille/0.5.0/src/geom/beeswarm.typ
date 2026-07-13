#import "point.typ": geom-point

///! Point wrapper that defaults `position` to `"beeswarm"`.
///!
///! Sugar for a scatter of per-group observations arranged into a
///! deterministic density-shaped swarm; equivalent to
///! `geom-point(position: position-beeswarm())`.

/// Beeswarm layer: points offset sideways into a density-shaped swarm.
///
/// Mapping must provide `x` and `y`. A discrete (categorical) x is swarmed directly, like `geom-violin`; `as-factor` is only needed to force a numeric column onto a discrete axis. Customise `width` or `adjust` by passing `position: position-beeswarm(...)`.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x` and `y`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - size: Marker size (a Typst length). `auto` resolves via the size scale.
/// - colour: Fixed marker colour. `auto` resolves via the colour scale.
/// - fill: Fixed marker fill for fillable shapes. `auto` resolves via the fill scale.
/// - stroke: Marker outline thickness. `auto` honours the stroke aesthetic.
/// - alpha: Marker opacity in `[0, 1]`.
/// - shape: Marker shape keyword or literal glyph. `auto` honours the shape scale.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment. Defaults to `"beeswarm"`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `position-beeswarm`, `geom-jitter`, `geom-violin`.
///
/// Swarms of two shifted samples over a discrete axis.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 50) {
///     d.push((grp: grp, y: calc.sin(i * 0.7) + calc.sin(i * 1.9) + (if grp == "b" { 4 } else { 0 })))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: as-factor("grp"), y: "y"),
///   layers: (geom-beeswarm(size: 2pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Colour the swarm by the same discrete column driving the x slots; each group keeps its scale colour under the offsets.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for i in range(0, 40) {
///     d.push((grp: grp, y: calc.sin(i * 0.7) + calc.sin(i * 1.9) + (if grp == "b" { 3 } else if grp == "c" { 6 } else { 0 })))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: as-factor("grp"), y: "y", colour: "grp"),
///   layers: (geom-beeswarm(size: 2pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-beeswarm(
  mapping: none,
  data: none,
  size: auto,
  colour: auto,
  fill: auto,
  stroke: auto,
  alpha: auto,
  shape: auto,
  stat: "identity",
  position: "beeswarm",
  key: auto,
  inherit-aes: true,
  ..args,
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
  key: key,
  inherit-aes: inherit-aes,
  ..args,
)
