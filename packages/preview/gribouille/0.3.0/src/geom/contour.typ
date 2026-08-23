///! Contour-line geom. Wraps \@stat-contour over the grouped-path renderer.

#import "../layer.typ": make-layer
#import "../stat/contour.typ": stat-contour

/// Contour-line layer: marching-squares iso-lines over a regular `(x, y, z)` grid. Pair with a continuous colour scale on `_level` to shade by height.
///
/// `bins`, `binwidth`, and `breaks` control level placement (precedence `breaks` > `binwidth` > `bins`).
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`, and `z`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - bins: Target contour-level count.
/// - binwidth: Fixed step between levels. Overrides `bins`.
/// - breaks: Explicit array of contour levels. Overrides `bins` and `binwidth`.
/// - stroke: Line thickness.
/// - colour: Fixed line colour. `auto` resolves via the colour scale.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `stat-contour`, `geom-bin-2d`.
///
/// Contour lines over a 30-by-30 grid sampling `sin(x) * cos(y)`.
///
/// ```typst
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
