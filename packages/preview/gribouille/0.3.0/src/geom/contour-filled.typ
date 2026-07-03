///! Filled-contour geom. Wraps \@stat-contour-filled over polygon fills.

#import "../layer.typ": make-layer
#import "../stat/contour-filled.typ": stat-contour-filled

/// Filled iso-band layer: marching-squares cell clipping over a regular `(x, y, z)` grid. Pair with a continuous fill scale on `_level` to shade each band by its lower bound.
///
/// Default `stroke: none` so adjacent cell polygons tile seamlessly. Set `stroke` explicitly to outline every cell, which is rarely useful unless you want to inspect the partition.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`, and `z`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - bins: Target band count.
/// - binwidth: Fixed step between successive levels. Overrides `bins`.
/// - breaks: Explicit array of level boundaries. Overrides the rest.
/// - colour: Cell outline colour. Honoured only when `stroke` is set.
/// - fill: Cell fill colour. `auto` lets the fill scale paint by `_level`.
/// - stroke: Outline thickness or stroke dictionary. Defaults to `none`.
/// - alpha: Cell opacity in `[0, 1]`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `stat-contour-filled`, `geom-contour`.
///
/// Ten bands on a radial-wave field, shaded by level.
///
/// ```typst
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
