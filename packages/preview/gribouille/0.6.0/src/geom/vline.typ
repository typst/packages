///! Vertical reference line(s) at given x intercepts.
///!
///! Works only with a continuous x scale. `xintercept` accepts a single value
///! or an array for drawing multiple reference lines at once.
///! Under \@coord-flip the line is drawn as a horizontal reference at the
///! same data value because the x axis becomes the rendered vertical axis.

#import "../layer.typ": make-layer, split-aes-params
#import "ref-line.typ": _draw-axis-lines

/// Vertical reference line at one or more x intercepts.
///
/// `xintercept` can be a scalar or an array drawing one line per value. To drive the lines from data instead, bind `xintercept` (and optionally `colour`, `alpha`, `linewidth`, `linetype`) through `aes` and pass `data`; one line is then drawn per row, with aesthetics resolved per row.
///
/// - mapping: Aesthetic mapping built with `aes`. Bind `xintercept` to a column to draw a data-driven line per row.
/// - data: Layer-specific dataset for the mapped `xintercept` column, or `none`.
/// - xintercept: Scalar or array of x values at which to draw vertical lines, used when `xintercept` is not mapped. Values may be numeric or ISO-8601 date/datetime/time strings when a temporal x scale is active.
/// - colour: Line colour. `auto` inherits the theme `ink`.
/// - stroke: Line thickness (a Typst length).
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword (e.g., `"solid"`, `"dashed"`). `auto` honours the linetype scale.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
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
///
/// Drive reference lines from data: bind `xintercept` and `colour` through `aes` so each event row draws its own coloured line.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #let events = (
///   (at: 2, grp: "a"),
///   (at: 5, grp: "b"),
///   (at: 8, grp: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-vline(mapping: aes(xintercept: "at", colour: "grp"), data: events),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-vline(
  mapping: none,
  data: none,
  xintercept: none,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  key: auto,
  inherit-aes: false,
  ..args,
) = make-layer(
  "vline",
  mapping: mapping,
  data: data,
  params: (
    xintercept: xintercept,
    colour: colour,
    stroke: stroke,
    alpha: alpha,
    linetype: linetype,
  )
    + split-aes-params("geom-vline", args),
  key: key,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  _draw-axis-lines(layer.params.xintercept, "x", layer, ctx)
}
