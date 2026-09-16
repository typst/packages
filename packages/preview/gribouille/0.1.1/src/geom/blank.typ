///! Invisible layer that still trains scales.
///!
///! Renders nothing but contributes its data to scale training. Useful for
///! forcing axis training without drawing marks.

#import "../layer.typ": make-layer

/// Invisible layer used to extend trained scales without drawing marks.
///
/// Typical mappings are `x` and / or `y`; any aesthetic in the mapping
/// participates in scale training so the panel reserves room for the
/// implied range.
///
/// \@category Geoms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Falls back to the plot mapping when `none`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Two corner rows train the axes without drawing any marks.
/// ```
/// //| alt: "Empty plot panel with x axis from 0 to 10 and y axis from 0 to 5 trained by two corner rows but no marks drawn."
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
/// \@examples Stack a blank under \@geom-function to reserve room for the
/// curve's domain without overriding the function output.
/// ```
/// //| alt: "Parabola y = x^2 over x from -2 to 2 with a blank layer reserving the panel range from y = -1 to 4."
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
///
/// \@see \@geom-rug, \@geom-function
#let geom-blank(mapping: none, data: none, inherit-aes: true) = make-layer(
  "blank",
  mapping: mapping,
  data: data,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {}
