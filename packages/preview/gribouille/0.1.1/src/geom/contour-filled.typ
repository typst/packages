///! Filled-contour geom. Wraps \@stat-contour-filled over polygon fills.

#import "../layer.typ": make-layer
#import "../stat/contour-filled.typ": stat-contour-filled

/// Filled iso-band layer: marching-squares cell clipping over a regular
/// `(x, y, z)` grid. Pair with a continuous fill scale on `_level` to shade
/// each band by its lower bound.
///
/// Default `stroke: none` so adjacent cell polygons tile seamlessly. Set
/// `stroke` explicitly to outline every cell, which is rarely useful unless
/// you want to inspect the partition.
///
/// \@category Geoms
/// \@subcategory Contours
/// \@stability stable
/// \@since 0.4.0
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `y`, and `z`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param bins Target band count.
///
/// \@param binwidth Fixed step between successive levels. Overrides `bins`.
///
/// \@param breaks Explicit array of level boundaries. Overrides the rest.
///
/// \@param colour Cell outline colour. Honoured only when `stroke` is set.
///
/// \@param fill Cell fill colour. `auto` lets the fill scale paint by `_level`.
///
/// \@param stroke Outline thickness or stroke dictionary. Defaults to `none`.
///
/// \@param alpha Cell opacity in `[0, 1]`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Ten bands on a radial-wave field, shaded by level.
/// ```
/// //| alt: "Filled contour bands over x and y from -3 to 3 of a sin(x) * cos(y) field shaded by level via viridis fill."
/// #let n = 50
/// #let d = ()
/// #for i in range(n) { for j in range(n) {
///   let x = -3 + 6 * i / (n - 1)
///   let y = -3 + 6 * j / (n - 1)
///   d.push((x: x, y: y, z: calc.sin(x) * calc.cos(y)))
/// } }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", z: "z"),
///   layers: (geom-contour-filled(bins: 10),),
///   scales: (scale-fill-viridis-c(),),
///   width: 11cm,
///   height: 7cm,
/// )
/// ```
///
/// \@see \@stat-contour-filled, \@geom-contour
#let geom-contour-filled(
  mapping: none,
  data: none,
  bins: 10,
  binwidth: none,
  breaks: auto,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  inherit-aes: true,
) = make-layer(
  "polygon",
  mapping: mapping,
  data: data,
  params: (
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
  ),
  stat: stat-contour-filled(bins: bins, binwidth: binwidth, breaks: breaks),
  inherit-aes: inherit-aes,
)
