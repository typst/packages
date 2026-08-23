///! Horizontal reference line(s) at given y intercepts.
///!
///! Works only with a continuous y scale. `yintercept` accepts a single value
///! or an array for drawing multiple reference lines at once.
///! Under \@coord-flip the line is drawn as a vertical reference at the same
///! data value because the y axis becomes the rendered horizontal axis.

#import "../layer.typ": make-layer
#import "../utils/ref-line.typ": _draw-axis-lines

/// Horizontal reference line at one or more y intercepts.
///
/// `yintercept` can be a scalar or an array. The layer does not inherit the plot mapping by default; it draws purely from the `yintercept` parameter.
///
/// - yintercept: Scalar or array of y values at which to draw horizontal lines.
/// - colour: Line colour. `auto` inherits the theme `ink`.
/// - stroke: Line thickness (a Typst length).
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword. Defaults to `"solid"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping. Defaults to `false`.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-vline`, `geom-abline`.
///
/// Single horizontal reference line at `y = 5`.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i + 2))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-hline(yintercept: 5, colour: rgb("#cc0000")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pass an array of intercepts to draw several reference lines at once.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i + 2))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-hline(yintercept: (3, 6, 9), colour: rgb("#888888")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-hline(
  yintercept: none,
  colour: auto,
  stroke: auto,
  alpha: auto,
  linetype: "solid",
  inherit-aes: false,
) = make-layer(
  "hline",
  params: (
    yintercept: yintercept,
    colour: colour,
    stroke: stroke,
    alpha: alpha,
    linetype: linetype,
  ),
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  _draw-axis-lines(layer.params.yintercept, "y", layer, ctx)
}
