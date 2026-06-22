///! Q-Q plot points against a reference distribution.
///!
///! Thin wrapper around \@geom-point that computes its data via \@stat-qq.

#import "../layer.typ": make-layer

/// Q-Q point layer: sorted sample versus theoretical quantile.
///
/// The `sample` aesthetic selects the column to compare against the chosen
/// reference distribution.
/// When `sample` is absent the layer falls back to `y` so simple
/// `aes(y: ...)` plots also work.
/// Colour, fill, shape, and alpha can be set or mapped through \@aes.
///
/// \@category Geoms
/// \@subcategory Distributions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Falls back to the plot mapping when `none`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param size Marker size (a Typst length).
///
/// \@param stroke Marker outline thickness (a Typst length) or stroke dictionary; `none` disables the outline and the `colour` aesthetic.
///
/// \@param fill Marker fill colour. `auto` resolves via the colour scale or a neutral default.
///
/// \@param colour Fixed marker outline colour. `auto` resolves via the colour scale, falling back to the theme `ink`. Only takes effect when `stroke` is non-zero.
///
/// \@param alpha Marker opacity in `[0, 1]`.
///
/// \@param shape Marker shape keyword. `auto` honours the shape scale.
///
/// \@param distribution Reference distribution name; one of `"normal"` (default), `"uniform"`, `"exponential"`.
///
/// \@param position Position adjustment name. Usually `"identity"`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Simple Q-Q against a normal reference, mapping `y` only.
/// ```
/// //| alt: "Q-Q plot of five values v showing sample quantiles on y against theoretical normal quantiles on x as points."
/// #let d = (1, 2, 3, 4, 5).map(v => (v: v))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (geom-qq(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Switch `distribution` to `"uniform"` to compare against a
/// different reference.
/// ```
/// //| alt: "Q-Q plot of 20 integer values v against theoretical uniform quantiles showing a near-straight diagonal of points."
/// #let d = range(1, 21).map(i => (v: i))
/// #plot(
///   data: d,
///   mapping: aes(y: "v"),
///   layers: (geom-qq(distribution: "uniform"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-qq-line, \@stat-qq, \@geom-point
#let geom-qq(
  mapping: none,
  data: none,
  size: auto,
  stroke: auto,
  fill: auto,
  colour: auto,
  alpha: auto,
  shape: auto,
  distribution: "normal",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "point",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    stroke: stroke,
    fill: fill,
    colour: colour,
    alpha: alpha,
    shape: shape,
    distribution: distribution,
  ),
  stat: "qq",
  position: position,
  inherit-aes: inherit-aes,
)
