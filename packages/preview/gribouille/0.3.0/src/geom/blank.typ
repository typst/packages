///! Invisible layer that still trains scales.
///!
///! Renders nothing but contributes its data to scale training. Useful for
///! forcing axis training without drawing marks.

#import "../layer.typ": make-layer

/// Invisible layer used to extend trained scales without drawing marks.
///
/// Typical mappings are `x` and / or `y`; any aesthetic in the mapping participates in scale training so the panel reserves room for the implied range.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-rug`, `geom-function`.
///
/// Two corner rows train the axes without drawing any marks.
///
/// ```typst
/// #let frame = ((x: 0, y: 0), (x: 10, y: 5))
/// #plot(
///   data: frame,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-blank(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Stack a blank under `geom-function` to reserve room for the curve's domain without overriding the function output.
///
/// ```typst
/// #let frame = ((x: -2, y: -1), (x: 2, y: 4))
/// #plot(
///   data: frame,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-blank(),
///     geom-function(fun: x => x * x),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-blank(mapping: none, data: none, inherit-aes: true) = make-layer(
  "blank",
  mapping: mapping,
  data: data,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {}
