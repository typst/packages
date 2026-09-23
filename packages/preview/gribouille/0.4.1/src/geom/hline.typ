///! Horizontal reference line(s) at given y intercepts.
///!
///! Works only with a continuous y scale. `yintercept` accepts a single value
///! or an array for drawing multiple reference lines at once.
///! Under \@coord-flip the line is drawn as a vertical reference at the same
///! data value because the y axis becomes the rendered horizontal axis.

#import "../layer.typ": make-layer, split-aes-params
#import "../utils/ref-line.typ": _draw-axis-lines

/// Horizontal reference line at one or more y intercepts.
///
/// `yintercept` can be a scalar or an array drawing one line per value. To drive the lines from data instead, bind `yintercept` (and optionally `colour`, `alpha`, `linewidth`, `linetype`) through `aes` and pass `data`; one line is then drawn per row, with aesthetics resolved per row.
///
/// - mapping: Aesthetic mapping built with `aes`. Bind `yintercept` to a column to draw a data-driven line per row.
/// - data: Layer-specific dataset for the mapped `yintercept` column, or `none`.
/// - yintercept: Scalar or array of y values at which to draw horizontal lines, used when `yintercept` is not mapped. Values may be numeric or ISO-8601 date/datetime/time strings when a temporal y scale is active.
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
///
/// Drive reference lines from data: bind `yintercept` and `colour` through `aes` so each threshold row draws its own coloured line.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i + 2))
/// #let thresholds = ((at: 4, lvl: "low"), (at: 8, lvl: "high"))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-hline(mapping: aes(yintercept: "at", colour: "lvl"), data: thresholds),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-hline(
  mapping: none,
  data: none,
  yintercept: none,
  colour: auto,
  stroke: auto,
  alpha: auto,
  linetype: auto,
  inherit-aes: false,
  ..args,
) = make-layer(
  "hline",
  mapping: mapping,
  data: data,
  params: (
    yintercept: yintercept,
    colour: colour,
    stroke: stroke,
    alpha: alpha,
    linetype: linetype,
  )
    + split-aes-params("geom-hline", args),
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  _draw-axis-lines(layer.params.yintercept, "y", layer, ctx)
}
