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
/// - ink: Foreground colour (text). Default: `black`.
/// - paper: Plot canvas fill. Default: transparent (no canvas drawn). Pass an explicit colour to paint the canvas behind the otherwise-blank panel.
/// - accent: Accent colour driving layer defaults like `geom-smooth`'s stroke. Default: `rgb("#3366FF")`.
/// - fields: Extra overrides forwarded to `theme`; see its docs for the full catalogue of structured and flat keys.
///   - text: Override for the `text` element.
///   - line: Override for the `line` element.
///   - rect: Override for the `rect` element.
///   - plot-title: Override for the `plot-title` element.
///   - plot-subtitle: Override for the `plot-subtitle` element.
///   - plot-caption: Override for the `plot-caption` element.
///   - plot-tag: Override for the `plot-tag` element.
///   - plot-background: Override for the `plot-background` element.
///   - axis-title: Override for the `axis-title` element.
///   - axis-text: Override for the `axis-text` element.
///   - axis-line: Override for the `axis-line` element.
///   - axis-ticks: Override for the `axis-ticks` element.
///   - panel-grid: Override for the `panel-grid` element.
///   - panel-background: Override for the `panel-background` element.
///   - legend-title: Override for the `legend-title` element.
///   - legend-text: Override for the `legend-text` element.
///   - legend-ticks: Override for the `legend-ticks` element.
///   - legend-background: Override for the `legend-background` element.
///   - legend-bar: Override for the `legend-bar` element.
///   - strip-text: Override for the `strip-text` element.
///   - strip-background: Override for the `strip-background` element.
///   - geom: Override for the `geom` element.
///
/// Returns: Theme dictionary consumed by `plot`.
///
/// See the package reference for the full theme key catalogue.
///
/// See also: `theme-grey`, `theme-classic`, `theme-void`, `theme`.
///
/// Minimal style: faint gridlines, no axis lines or tick marks.
///
/// ```typst
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
/// Pair the minimal theme with a coloured `accent` for slide decks where you still want a brand colour.
///
/// ```typst
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
/// Paint the canvas behind the otherwise-blank panel by passing an explicit `paper` colour.
///
/// ```typst
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
/// Spot-override individual elements without rebuilding the theme from scratch.
///
/// ```typst
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
