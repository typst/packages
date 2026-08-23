///! Grey theme preset.
///!
///! Light grey panel background with white gridlines and thin black axes.
///! Derives element colours from `ink` and `paper` via `col-mix`.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper
#import "elements.typ": element-line, element-rect, element-text
#import "theme.typ": _preset

/// Grey theme: light grey panel with white gridlines.
///
/// \@category Themes
/// \@subcategory Complete themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@param ink Foreground colour (text, axis lines). Default: `black`.
///
/// \@param paper Background colour. Default: `white`.
///
/// \@param accent Accent colour. Default: `rgb("#3366FF")`.
///
/// \@param ..fields Extra overrides forwarded to \@theme; see its docs for the full catalogue of structured and flat keys.
///
/// \@returns Theme dictionary consumed by \@plot.
///
/// \@examples Light grey panel with white gridlines.
/// ```
/// //| alt: "Scatter plot of y against x on the grey theme with a light grey panel, white gridlines and thin black axes."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-grey(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Override `ink` and `paper` for a tinted theme without
/// switching theme function.
/// ```
/// //| alt: "Scatter plot of y against x with dark navy ink on a warm cream background, recolouring the grey theme without changing function."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-grey(ink: rgb("#2c3e50"), paper: rgb("#fdf6e3")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Tweak a single field on top of the preset using a flat key.
/// ```
/// //| alt: "Scatter plot of y against x on the grey preset with the panel background replaced by a warm cream fill via the flat key."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-grey(panel-background: element-rect(fill: rgb("#f7f0e7"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-minimal, \@theme-classic, \@theme-void, \@theme
#let theme-grey(
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),
  ..fields,
) = _preset(
  "grey",
  ink,
  paper,
  accent,
  (
    panel-background: element-rect(fill: col-mix(ink, paper, 0.92)),
    panel-grid: element-line(
      colour: col-mix(ink, paper, 0.7),
      stroke: 0.5pt,
    ),
    axis-line: element-line(colour: ink, stroke: 0.5pt),
    axis-text: element-text(colour: col-mix(ink, paper, 0.302)),
    strip-background: element-rect(fill: col-mix(ink, paper, 0.85)),
  ),
  fields,
)
