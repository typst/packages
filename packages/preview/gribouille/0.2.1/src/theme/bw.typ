///! Black-and-white theme preset.
///!
///! White panel framed by a thin black border, with light grey grid lines.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper
#import "elements.typ": element-line, element-rect
#import "theme.typ": _preset

/// Black-and-white theme: white panel, black axes, light grey grid.
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
/// \@examples Default black-on-white theme with a thin panel border.
/// ```
/// //| alt: "Scatter plot of y against x on a white panel framed by a thin black border with light grey grid lines."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-bw(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Override `accent` to recolour data ink and key glyphs while
/// keeping the high-contrast panel.
/// ```
/// //| alt: "Scatter plot of y against x on the bw theme with a red accent recolouring data ink against the high-contrast white panel."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-bw(accent: rgb("#cc0000")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Recolour the panel background on top of the bw preset.
/// ```
/// //| alt: "Scatter plot of y against x on the bw theme with an orange panel background replacing the default white fill."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-bw(panel-background: element-rect(fill: rgb("#ff9900"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-minimal, \@theme-classic, \@theme-void, \@theme
#let theme-bw(
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),
  ..fields,
) = _preset(
  "bw",
  ink,
  paper,
  accent,
  (
    panel-background: element-rect(fill: paper),
    panel-grid: element-line(
      colour: col-mix(ink, paper, 0.7),
      stroke: 0.4pt,
    ),
    axis-line: element-line(colour: ink, stroke: 0.5pt),
  ),
  fields,
)
