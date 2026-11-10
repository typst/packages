///! Minimal theme preset.
///!
///! White panel with thin light grey gridlines, no axis lines, no tick marks.

#import "defaults.typ": _tr-ink, _tr-paper, minimal-surfaces
#import "elements.typ": element-rect
#import "theme.typ": _preset

/// Minimal theme: white panel, light grey gridlines, no axis lines.
///
/// This is the gribouille default theme.
///
/// \@category Themes
/// \@subcategory Complete themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@param ink Foreground colour (text). Default: `black`.
///
/// \@param paper Plot canvas fill. Default: transparent (no canvas drawn). Pass an explicit colour to paint the canvas behind the otherwise-blank panel.
///
/// \@param accent Accent colour driving layer defaults like \@geom-smooth's stroke. Default: `rgb("#3366FF")`.
///
/// \@param ..fields Extra overrides forwarded to \@theme; see its docs for the full catalogue of structured and flat keys.
///
/// \@returns Theme dictionary consumed by \@plot.
///
/// \@examples Minimal style: faint gridlines, no axis lines or tick marks.
/// ```
/// //| alt: "Scatter plot of y against x with faint grey gridlines and no axis lines or tick marks for a minimal style."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-minimal(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Pair the minimal theme with a coloured `accent` for slide
/// decks where you still want a brand colour.
/// ```
/// //| alt: "Scatter plot of y against x on the minimal theme with a steel-blue accent recolouring data ink for branded slides."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-minimal(accent: rgb("#1f77b4")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Paint the canvas behind the otherwise-blank panel by passing
/// an explicit `paper` colour.
/// ```
/// //| alt: "Scatter plot of y against x on the minimal theme with a warm cream canvas painted behind the otherwise-blank panel."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-minimal(paper: rgb("#fff7e6")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Spot-override individual elements without rebuilding the
/// theme from scratch.
/// ```
/// //| alt: "Scatter plot of y against x on the minimal theme with axis titles rendered in a larger 14pt font via a spot override."
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-minimal(axis-title: element-text(size: 14pt)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-classic, \@theme-void, \@theme
#let theme-minimal(
  ink: _tr-ink,
  paper: auto,
  accent: rgb("#3366FF"),
  ..fields,
) = {
  let _paper = if paper == auto { _tr-paper } else { paper }
  let surfaces = if paper == auto {
    minimal-surfaces(ink, _paper)
  } else {
    (
      ..minimal-surfaces(ink, _paper),
      plot-background: element-rect(fill: _paper),
    )
  }
  _preset("minimal", ink, _paper, accent, surfaces, fields)
}
