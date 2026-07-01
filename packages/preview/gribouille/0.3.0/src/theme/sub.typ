///! Shortcut groups for theme element overrides.
///!
///! Each `theme-sub-*` constructor wraps \@theme with the prefixed surface
///! keys for one family.

#import "theme.typ": theme

#let _axis-sub(suffix, title, text, line, ticks) = theme(
  ..(
    (
      ("axis-title" + suffix): title,
      ("axis-text" + suffix): text,
      ("axis-line" + suffix): line,
      ("axis-ticks" + suffix): ticks,
    )
  ),
)

/// Shortcut for both axes' title, text, line, and ticks.
///
/// - title: `element-text` or `element-typst` for `axis-title`.
/// - text: `element-text` or `element-typst` for `axis-text`.
/// - line: `element-line` or `element-blank` for `axis-line`.
/// - ticks: `element-line` or `element-blank` for `axis-ticks`.
///
/// Returns: Theme dictionary with the named overrides applied.
///
/// See also: `theme`, `theme-sub-axis-x`, `theme-sub-axis-y`.
///
/// Red ink on every axis title and tick label, mirrored on the axis line and tick marks.
///
/// ```typst
/// #let red-text = element-text(colour: rgb("#cc0000"))
/// #let red-line = element-line(colour: rgb("#cc0000"))
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-axis(
///     title: red-text,
///     text: red-text,
///     line: red-line,
///     ticks: red-line,
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-axis(title: none, text: none, line: none, ticks: none) = (
  _axis-sub("", title, text, line, ticks)
)

/// Shortcut for both x axes (top + bottom).
///
/// - title: `element-text` or `element-typst` for `axis-title-x`.
/// - text: Same for `axis-text-x`.
/// - line: `element-line` for `axis-line-x`.
/// - ticks: `element-line` for `axis-ticks-x`.
///
/// Returns: Theme dictionary with the named x-axis overrides applied.
///
/// See also: `theme-sub-axis`, `theme-sub-axis-y`, `theme-sub-axis-bottom`, `theme-sub-axis-top`.
///
/// Tint both x-axis edges in red while leaving the y axis alone.
///
/// ```typst
/// #let red-text = element-text(colour: rgb("#cc0000"))
/// #let red-line = element-line(colour: rgb("#cc0000"))
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-axis-x(
///     title: red-text,
///     text: red-text,
///     line: red-line,
///     ticks: red-line,
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-axis-x(title: none, text: none, line: none, ticks: none) = (
  _axis-sub("-x", title, text, line, ticks)
)

/// Shortcut for both y axes (left + right).
///
/// - title: `element-text` or `element-typst` for `axis-title-y`.
/// - text: Same for `axis-text-y`.
/// - line: `element-line` for `axis-line-y`.
/// - ticks: `element-line` for `axis-ticks-y`.
///
/// Returns: Theme dictionary with the named y-axis overrides applied.
///
/// See also: `theme-sub-axis`, `theme-sub-axis-x`, `theme-sub-axis-left`, `theme-sub-axis-right`.
///
/// Tint both y-axis edges in red while leaving the x axis alone.
///
/// ```typst
/// #let red-text = element-text(colour: rgb("#cc0000"))
/// #let red-line = element-line(colour: rgb("#cc0000"))
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-axis-y(
///     title: red-text,
///     text: red-text,
///     line: red-line,
///     ticks: red-line,
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-axis-y(title: none, text: none, line: none, ticks: none) = (
  _axis-sub("-y", title, text, line, ticks)
)

/// Shortcut for the bottom x axis only.
///
/// - title: Element override for the bottom x axis title.
/// - text: Element override for the bottom x axis tick labels.
/// - line: Element override for the bottom x axis line.
/// - ticks: Element override for the bottom x axis ticks.
///
/// Returns: Theme dictionary scoped to the bottom x axis.
///
/// See also: `theme-sub-axis-x`, `theme-sub-axis-top`.
///
/// Tint only the bottom x axis in red; the rest stays default.
///
/// ```typst
/// #let red-text = element-text(colour: rgb("#cc0000"))
/// #let red-line = element-line(colour: rgb("#cc0000"))
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-axis-bottom(
///     title: red-text,
///     text: red-text,
///     line: red-line,
///     ticks: red-line,
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-axis-bottom(
  title: none,
  text: none,
  line: none,
  ticks: none,
) = _axis-sub("-x-bottom", title, text, line, ticks)

/// Shortcut for the top x axis only.
///
/// - title: Element override for the top x axis title.
/// - text: Element override for the top x axis tick labels.
/// - line: Element override for the top x axis line.
/// - ticks: Element override for the top x axis ticks.
///
/// Returns: Theme dictionary scoped to the top x axis.
///
/// See also: `theme-sub-axis-x`, `theme-sub-axis-bottom`.
///
/// Tint only the top x axis in red; the rest stays default.
///
/// ```typst
/// #let red-text = element-text(colour: rgb("#cc0000"))
/// #let red-line = element-line(colour: rgb("#cc0000"))
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-axis-top(
///     title: red-text,
///     text: red-text,
///     line: red-line,
///     ticks: red-line,
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-axis-top(
  title: none,
  text: none,
  line: none,
  ticks: none,
) = _axis-sub("-x-top", title, text, line, ticks)

/// Shortcut for the left y axis only.
///
/// - title: Element override for the left y axis title.
/// - text: Element override for the left y axis tick labels.
/// - line: Element override for the left y axis line.
/// - ticks: Element override for the left y axis ticks.
///
/// Returns: Theme dictionary scoped to the left y axis.
///
/// See also: `theme-sub-axis-y`, `theme-sub-axis-right`.
///
/// Tint only the left y axis in red; the rest stays default.
///
/// ```typst
/// #let red-text = element-text(colour: rgb("#cc0000"))
/// #let red-line = element-line(colour: rgb("#cc0000"))
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-axis-left(
///     title: red-text,
///     text: red-text,
///     line: red-line,
///     ticks: red-line,
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-axis-left(
  title: none,
  text: none,
  line: none,
  ticks: none,
) = _axis-sub("-y-left", title, text, line, ticks)

/// Shortcut for the right y axis only.
///
/// - title: Element override for the right y axis title.
/// - text: Element override for the right y axis tick labels.
/// - line: Element override for the right y axis line.
/// - ticks: Element override for the right y axis ticks.
///
/// Returns: Theme dictionary scoped to the right y axis.
///
/// See also: `theme-sub-axis-y`, `theme-sub-axis-left`.
///
/// Tint only the right y axis in red; the rest stays default.
///
/// ```typst
/// #let red-text = element-text(colour: rgb("#cc0000"))
/// #let red-line = element-line(colour: rgb("#cc0000"))
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-axis-right(
///     title: red-text,
///     text: red-text,
///     line: red-line,
///     ticks: red-line,
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-axis-right(
  title: none,
  text: none,
  line: none,
  ticks: none,
) = _axis-sub("-y-right", title, text, line, ticks)

/// Shortcut for legend text and title.
///
/// - text: `element-text` or `element-typst` for `legend-text`.
/// - title: Same for `legend-title`.
///
/// Returns: Theme dictionary with the named legend overrides applied.
///
/// See also: `theme`.
///
/// Bold legend titles via the shortcut group.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5, k: if calc.even(i) { "a" } else { "b" }))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "k"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-legend(title: element-text(weight: "bold")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-legend(text: none, title: none) = theme(
  legend-text: text,
  legend-title: title,
)

/// Shortcut for panel grid and background.
///
/// - grid: `element-line` or `element-blank` for `panel-grid`.
/// - background: `element-rect` or `element-blank` for `panel-background`.
///
/// Returns: Theme dictionary with the named panel overrides applied.
///
/// See also: `theme`.
///
/// Cream panel with a muted brown grid via the panel shortcut.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme-sub-panel(
///     background: element-rect(fill: rgb("#fff7e6")),
///     grid: element-line(colour: rgb("#d9cfbf")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-panel(grid: none, background: none) = theme(
  panel-grid: grid,
  panel-background: background,
)

/// Shortcut for plot title, subtitle, caption, and outer margin.
///
/// - title: `element-text` or `element-typst` for `plot-title`.
/// - subtitle: Same for `plot-subtitle`.
/// - caption: Same for `plot-caption`.
/// - tag: Same for `plot-tag` (the per-panel tag drawn by`compose`).
///
/// Returns: Theme dictionary with the named plot overrides applied.
///
/// See also: `theme`.
///
/// Bold plot title and smaller subtitle via the plot shortcut.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   labs: labs(title: "Series A", subtitle: "y as a linear function of x"),
///   theme: theme-sub-plot(
///     title: element-text(weight: "bold"),
///     subtitle: element-text(size: 9pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-plot(
  title: none,
  subtitle: none,
  caption: none,
  tag: none,
) = theme(
  plot-title: title,
  plot-subtitle: subtitle,
  plot-caption: caption,
  plot-tag: tag,
)

/// Shortcut for facet strip text and background.
///
/// - text: `element-text` or `element-typst` for `strip-text`.
/// - background: `element-rect` or `element-blank` for `strip-background`.
///
/// Returns: Theme dictionary with the named strip overrides applied.
///
/// See also: `theme`.
///
/// Bold strip text on a cream background; faceting makes the strip visible.
///
/// ```typst
/// #let d = range(0, 10).map(i => (
///   x: i,
///   y: i * 0.5,
///   g: if calc.even(i) { "a" } else { "b" },
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("g"),
///   theme: theme-sub-strip(
///     text: element-text(weight: "bold"),
///     background: element-rect(fill: rgb("#fff7e6")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme-sub-strip(text: none, background: none) = theme(
  strip-text: text,
  strip-background: background,
)
