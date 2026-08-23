///! Void theme preset.
///!
///! No axes, grid, or panel background. Useful when the plot stands on its
///! own without an axis frame (e.g., maps, annotated figures).

#import "defaults.typ": _tr-ink
#import "elements.typ": element-blank, element-rect, element-text
#import "theme.typ": _preset

/// Void theme: no axes, no grid, no panel background.
///
/// - ink: Foreground colour. Default: `black`.
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
/// See also: `theme-grey`, `theme-minimal`, `theme-classic`, `theme`.
///
/// Strip away axes, grid, and panel background entirely.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-void(),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Useful behind a custom annotated figure where axes would be visual noise; pass an explicit `paper` for a solid background.
///
/// ```typst
/// #let d = range(0, 12).map(i => (
///   x: calc.cos(i * 0.5), y: calc.sin(i * 0.5), t: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "t"),
///   layers: (geom-path(stroke: 1.4pt),),
///   theme: theme-void(paper: rgb("#fff7e6")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Restore a faint panel background while keeping the void preset's stripped-down axes.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-void(panel-background: element-rect(fill: rgb("#f7f0e7"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-void(
  ink: _tr-ink,
  paper: auto,
  accent: rgb("#3366FF"),
  ..fields,
) = {
  let _paper = if paper == auto { rgb(0, 0, 0, 0) } else { paper }
  let _plot-bg = if paper == auto {
    element-rect()
  } else {
    element-rect(fill: _paper)
  }
  _preset(
    "void",
    ink,
    _paper,
    accent,
    (
      panel-background: element-blank(),
      plot-background: _plot-bg,
      panel-grid: element-blank(),
      axis-line: element-blank(),
      axis-title: element-text(size: 0pt),
      tick-length: 0cm,
      tick-labels: false,
    ),
    fields,
  )
}
