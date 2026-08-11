///! Black-and-white theme preset.
///!
///! White panel framed by a thin black border, with light grey grid lines.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper
#import "elements.typ": element-line, element-rect
#import "theme.typ": _preset

/// Black-and-white theme: white panel, black axes, light grey grid.
///
/// - ink: Foreground colour (axis lines, text). Default: `black`.
/// - paper: Background colour. Default: `white`.
/// - accent: Accent colour. Default: `rgb("#3366FF")`.
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
/// See also: `theme-grey`, `theme-minimal`, `theme-classic`, `theme-void`, `theme`.
///
/// Default black-on-white theme with a thin panel border.
///
/// ```typst
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
/// Override `accent` to recolour data ink and key glyphs while keeping the high-contrast panel.
///
/// ```typst
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
/// Recolour the panel background on top of the bw preset.
///
/// ```typst
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
