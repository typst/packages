///! Vertical reference line(s) at given x intercepts.
///!
///! Works only with a continuous x scale. `xintercept` accepts a single value
///! or an array for drawing multiple reference lines at once.
///! Under \@coord-flip the line is drawn as a horizontal reference at the
///! same data value because the x axis becomes the rendered vertical axis.

#import "../layer.typ": make-layer
#import "../utils/ref-line.typ": _draw-axis-lines

/// Vertical reference line at one or more x intercepts.
///
/// `xintercept` can be a scalar or an array. The layer does not inherit the plot mapping by default; it draws purely from the `xintercept` parameter.
///
/// - xintercept: Scalar or array of x values at which to draw vertical lines.
/// - colour: Line colour. `auto` inherits the theme `ink`.
/// - stroke: Line thickness (a Typst length).
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword. Defaults to `"solid"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping. Defaults to `false`.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-hline`, `geom-abline`.
///
/// Two vertical reference lines at `x = 3` and `x = 6`.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-vline(xintercept: (3, 6), colour: rgb("#4c78a8")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// A single dashed reference line at the data midpoint.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-vline(xintercept: 4.5, stroke: 1pt, colour: rgb("#cc0000")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-vline(
  xintercept: none,
  colour: auto,
  stroke: auto,
  alpha: auto,
  linetype: "solid",
  inherit-aes: false,
) = make-layer(
  "vline",
  params: (
    xintercept: xintercept,
    colour: colour,
    stroke: stroke,
    alpha: alpha,
    linetype: linetype,
  ),
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  _draw-axis-lines(layer.params.xintercept, "x", layer, ctx)
}
