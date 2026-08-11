///! Linedraw theme preset.
///!
///! White panel framed by a heavier black border, with very faint grid lines.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper
#import "elements.typ": element-line, element-rect, element-text
#import "theme.typ": _preset

/// Linedraw theme: white panel, strong black axes, very faint grid.
///
/// \@category Themes
/// \@subcategory Complete themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@param ink Foreground colour (axis lines, text). Default: `black`.
///
/// \@param paper Background colour. Default: `white`.
///
/// \@param accent Accent colour. Default: `rgb("#3366FF")`.
///
/// \@param ..fields Extra overrides forwarded to \@theme; see its docs for the full catalogue of structured and flat keys.
///
/// \@returns Theme dictionary consumed by \@plot.
///
/// \@examples Strong black border around a white panel with faint grid.
/// ```
/// //| alt: "Scatter plot of y against x on a white panel ringed by a heavy black axis frame with very faint grid lines."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-linedraw(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Switch `ink` to a softer hue for a less stark publication
/// look while keeping the heavy axis frame.
/// ```
/// //| alt: "Scatter plot of y against x on the linedraw theme with dark navy ink softening the heavy axis frame for publication."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-linedraw(ink: rgb("#2c3e50")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Rotate axis tick labels on top of the linedraw preset.
/// ```
/// //| alt: "Scatter plot of y against x on the linedraw theme with axis tick labels rotated 30 degrees beneath the heavy frame."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-linedraw(axis-text: element-text(angle: 30deg)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-minimal, \@theme-classic, \@theme-bw, \@theme-void, \@theme
#let theme-linedraw(
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),
  ..fields,
) = _preset(
  "linedraw",
  ink,
  paper,
  accent,
  (
    panel-background: element-rect(fill: paper),
    panel-grid: element-line(
      colour: col-mix(ink, paper, 0.7),
      stroke: 0.3pt,
    ),
    axis-line: element-line(colour: ink, stroke: 0.8pt),
    axis-text: element-text(colour: ink),
  ),
  fields,
)
