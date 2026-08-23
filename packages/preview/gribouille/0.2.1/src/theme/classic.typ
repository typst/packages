///! Classic theme preset.
///!
///! White panel background with visible axis borders and no gridlines.

#import "defaults.typ": _tr-ink, _tr-paper
#import "elements.typ": element-blank, element-line, element-rect
#import "theme.typ": _preset

/// Classic theme: white panel, axis borders, no gridlines.
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
/// \@examples Classic axis borders with no gridlines.
/// ```
/// //| alt: "Scatter plot of y against x with visible black axis borders, a white panel and no gridlines."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-classic(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Switch `paper` to a tinted background while keeping the
/// classic axis style.
/// ```
/// //| alt: "Scatter plot of y against x on a warm cream panel with the classic black axis borders and no gridlines."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-classic(paper: rgb("#fff7e6")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Bump the axis title size on top of the classic preset.
/// ```
/// //| alt: "Scatter plot of y against x on the classic theme with axis titles rendered in a larger 14pt font."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-classic(axis-title: element-text(size: 14pt)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-minimal, \@theme-void, \@theme
#let theme-classic(
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),
  ..fields,
) = _preset(
  "classic",
  ink,
  paper,
  accent,
  (
    panel-background: element-rect(fill: paper),
    panel-grid: element-blank(),
    axis-line: element-line(colour: ink, stroke: 0.6pt),
  ),
  fields,
)
