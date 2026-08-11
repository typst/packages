///! Light theme preset.
///!
///! Light grey panel with white grid lines and a subtle grey border.

#import "../utils/colour.typ": col-mix
#import "defaults.typ": _tr-ink, _tr-paper
#import "elements.typ": element-line, element-rect, element-text
#import "theme.typ": _preset

/// Light theme: light grey panel, white grid, soft grey axes.
///
/// - ink: Foreground colour (text). Default: `black`.
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
/// See also: `theme-grey`, `theme-minimal`, `theme-classic`, `theme-dark`, `theme-void`, `theme`.
///
/// Soft grey axes on a tinted panel.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-light(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Override `accent` to give the data ink a custom highlight colour without losing the soft panel.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-light(accent: rgb("#1b9e77")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Tinted panel background on top of the soft preset.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-light(panel-background: element-rect(fill: rgb("#fff7e6"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-light(
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),
  ..fields,
) = _preset(
  "light",
  ink,
  paper,
  accent,
  (
    panel-background: element-rect(fill: col-mix(ink, paper, 0.9216)),
    panel-grid: element-line(
      colour: col-mix(ink, paper, 0.7),
      stroke: 0.5pt,
    ),
    axis-line: element-line(colour: col-mix(ink, paper, 0.8), stroke: 0.5pt),
    axis-text: element-text(colour: col-mix(ink, paper, 0.302)),
  ),
  fields,
)
