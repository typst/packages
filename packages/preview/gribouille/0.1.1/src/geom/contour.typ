///! Contour-line geom. Wraps \@stat-contour over the grouped-path renderer.

#import "../layer.typ": make-layer
#import "../stat/contour.typ": stat-contour

/// Contour-line layer: marching-squares iso-lines over a regular `(x, y, z)`
/// grid. Pair with a continuous colour scale on `_level` to shade by height.
///
/// `bins`, `binwidth`, and `breaks` control level placement (precedence
/// `breaks` > `binwidth` > `bins`).
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
/// \@param bins Target contour-level count.
///
/// \@param binwidth Fixed step between levels. Overrides `bins`.
///
/// \@param breaks Explicit array of contour levels. Overrides `bins` and `binwidth`.
///
/// \@param stroke Line thickness.
///
/// \@param colour Fixed line colour. `auto` resolves via the colour scale.
///
/// \@param alpha Line opacity in `[0, 1]`.
///
/// \@param linetype Dash keyword.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Contour lines over a 30-by-30 grid sampling `sin(x) * cos(y)`.
/// ```
/// //| alt: "Contour lines over x and y from -3 to 3 tracing iso-levels of the field sin(x) * cos(y) with ten levels."
/// #let n = 30
/// #let d = ()
/// #for i in range(n) { for j in range(n) {
///   let x = -3 + 6 * i / (n - 1)
///   let y = -3 + 6 * j / (n - 1)
///   d.push((x: x, y: y, z: calc.sin(x) * calc.cos(y)))
/// } }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", z: "z"),
///   layers: (geom-contour(bins: 10),),
///   width: 11cm,
///   height: 7cm,
/// )
/// ```
///
/// \@see \@stat-contour, \@geom-bin-2d
#let geom-contour(
  mapping: none,
  data: none,
  bins: 10,
  binwidth: none,
  breaks: auto,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  inherit-aes: true,
) = make-layer(
  "path",
  mapping: mapping,
  data: data,
  params: (
    stroke: stroke,
    stroke-fallback: 0.6pt,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
  ),
  stat: stat-contour(bins: bins, binwidth: binwidth, breaks: breaks),
  inherit-aes: inherit-aes,
)
