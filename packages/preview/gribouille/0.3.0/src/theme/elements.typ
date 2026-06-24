///! Structured theme elements.
///!
///! `element_*` constructors. \@theme translates these into the flat theme
///! fields consumed internally by `merge-theme`.

#import "../utils/errors.typ": assert-halign

/// Text element: font size, weight, colour, and angle.
///
/// Pass the result to `theme` under keys like `axis-text`, `axis-title`, `legend-text`, or `legend-title`.
///
/// - size: Text size (a Typst length), or `none` to inherit.
/// - weight: Font weight (e.g., `"regular"`, `"bold"`), or `none` to inherit.
/// - colour: Text colour, or `none` to inherit.
/// - angle: Rotation angle (a Typst angle), or `none` to inherit. Honoured on axis tick labels (`axis-text`, seeding the `guide-axis` `angle`, which overrides it) and on the plot title, subtitle, and caption. Legend and strip text ignore this field.
/// - font: Font family (e.g., `"sans"`, `"serif"`), or `none` to inherit.
/// - margin: Per-side spacing built with `margin`. Each side accepts a Typst length (absolute or relative); `em` is preferred so spacing scales with the surface font size. Sides left at `auto` fall through to the renderer default. `none` keeps every side at the default.
/// - align: Horizontal alignment of the text within its surface as a Typst alignment (`left`, `center`, `right`), or `none` to use the per-surface default (title and subtitle left, caption right, axis titles and strip text centred, legend title left, legend entry labels centred in horizontal legends and left in vertical legends). Independent of the surrounding container's alignment. Axis tick labels (`axis-text`) are positioned by anchor and ignore this field.
///
/// Returns: Element dictionary consumed by `theme`.
///
/// See also: `theme`, `element-line`, `element-rect`, `element-blank`, `element-typst`, `margin`.
///
/// Bigger axis-title font passed via `theme`.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(axis-title: element-text(size: 14pt)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Combine multiple text fields and a rotation angle on axis tick labels.
///
/// ```typst
/// #let d = (
///   (q: "Q1", y: 3), (q: "Q2", y: 5), (q: "Q3", y: 4), (q: "Q4", y: 6),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y"),
///   layers: (geom-col(),),
///   theme: theme(axis-text: element-text(
///     size: 9pt,
///     angle: 30deg,
///     colour: rgb("#1f77b4"),
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Widen the gap between the axis tick labels and the axis title using a relative margin that tracks the title font size.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(axis-title: element-text(
///     size: 11pt,
///     margin: margin(top: 1.6em, right: 1.6em),
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let element-text(
  size: none,
  weight: none,
  colour: none,
  angle: none,
  font: none,
  margin: none,
  align: none,
) = {
  assert-halign("element-text", align)
  (
    kind: "element-text",
    size: size,
    weight: weight,
    colour: colour,
    angle: angle,
    font: font,
    margin: margin,
    align: align,
  )
}

/// Typst-markup text element: same fields as `element-text` plus automatic Typst-markup evaluation for plain strings reaching this surface.
///
/// Drop-in replacement for `element-text` on any text key. Strings supplied via `labs`, scale names, or scale `labels:` callbacks are evaluated as Typst markup before rendering, so users do not need to wrap each value with `typst`. Per-call `typst`() and content (`[…]`) values still pass through unchanged.
///
/// - size: Text size (a Typst length), or `none` to inherit.
/// - weight: Font weight (e.g., `"regular"`, `"bold"`), or `none`.
/// - colour: Text colour, or `none` to inherit.
/// - angle: Rotation angle (a Typst angle), or `none` to inherit. Honoured on axis tick labels (`axis-text`, seeding the `guide-axis` `angle`, which overrides it) and on the plot title, subtitle, and caption. Legend and strip text ignore this field.
/// - font: Font family, or `none` to inherit.
/// - margin: Per-side spacing built with `margin`. Each side accepts a Typst length (absolute or relative); `em` is preferred so spacing scales with the surface font size. Sides left at `auto` fall through to the renderer default. `none` keeps every side at the default.
/// - align: Horizontal alignment of the text within its surface as a Typst alignment (`left`, `center`, `right`), or `none` to use the per-surface default (title and subtitle left, caption right, axis titles and strip text centred, legend title left, legend entry labels centred in horizontal legends and left in vertical legends). Independent of the surrounding container's alignment. Axis tick labels (`axis-text`) are positioned by anchor and ignore this field.
///
/// Returns: Element dictionary consumed by `theme`.
///
/// See also: `theme`, `element-text`, `typst`, `margin`.
///
/// Enable Typst markup for every plot title in a session by setting `plot-title: element-typst()` on the theme.
///
/// ```typst
/// #let d = ((x: 1, y: 1), (x: 2, y: 4), (x: 3, y: 9))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   labs: labs(title: "Mean $bar(x)$ over Time"),
///   theme: theme(plot-title: element-typst(size: 14pt, weight: "bold")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Mix typst and non-typst surfaces in the same theme:
///
/// ```typst
/// #let d = ((x: 1, y: 1), (x: 2, y: 4), (x: 3, y: 9))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   labs: labs(title: "Mean $bar(x)$", x: "Time (s)"),
///   theme: theme(
///     plot-title: element-typst(),
///     axis-title: element-text(),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let element-typst(
  size: none,
  weight: none,
  colour: none,
  angle: none,
  font: none,
  margin: none,
  align: none,
) = {
  assert-halign("element-typst", align)
  (
    kind: "element-typst",
    size: size,
    weight: weight,
    colour: colour,
    angle: angle,
    font: font,
    margin: margin,
    align: align,
  )
}

/// Line element: colour and stroke thickness.
///
/// Pass the result to `theme` under keys like `panel-grid` or `axis-line`.
///
/// - colour: Line colour, or `none` to inherit.
/// - stroke: Line thickness (a Typst length), or `none`.
///
/// Returns: Element dictionary consumed by `theme`.
///
/// See also: `theme`, `element-text`, `element-rect`, `element-blank`.
///
/// Recolour the panel grid via `theme`.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(panel-grid: element-line(colour: rgb("#d9cfbf"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Strengthen the axis line by setting both `colour` and `stroke`.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(axis-line: element-line(
///     colour: rgb("#cc0000"),
///     stroke: 1pt,
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let element-line(colour: none, stroke: none) = (
  kind: "element-line",
  colour: colour,
  stroke: stroke,
)

/// Rectangle element: fill, outline colour, stroke thickness, and per-side margins. `inset` is honoured on `plot-background` (Typst `block(inset:)` pads the content inward, and grows the painted fill outward past it when a fill or stroke is set) and on `legend-background` (grows the legend rect outward from the guide-stack bbox so the rectangle frames the legend with extra inner padding). `panel-background` and `legend-bar` ignore `inset` so the rect cannot bleed onto neighbours. `outset` reserves outer whitespace by widening the chrome slot on `panel-background`, `legend-background`, and `legend-bar`; on `plot-background` it wraps the rendered block in `pad(...)`. On `legend-background`, the panel-facing outset side also widens the visible gap between panel and legend. On `plot-background`, both `inset` and `outset` apply whether or not a fill or stroke is set, so they reserve plot padding on their own. `strip-background` ignores both fields -- the facet band has no surrounding slot to grow or reserve into.
///
/// Pass the result to `theme` under keys like `panel-background`.
///
/// - fill: Rectangle fill colour, or `none` to inherit.
/// - colour: Outline colour, or `none` to inherit.
/// - stroke: Outline thickness (a Typst length), or `none` for no outline.
/// - inset: Inner padding `margin` honoured by `plot-background` and `legend-background` (grows the painted rect outward), or `none`. Ignored on `panel-background`, `strip-background`, and `legend-bar`.
/// - outset: Outer margin `margin` reserving outer whitespace (panel canvas shrinks on cetz surfaces; the rendered block is wrapped in `pad(...)` on `plot-background`), or `none`. Ignored on `strip-background`.
///
/// Returns: Element dictionary consumed by `theme`.
///
/// See also: `theme`, `margin`, `element-text`, `element-line`, `element-blank`.
///
/// Tinted panel background via `theme`.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(panel-background: element-rect(fill: rgb("#f7f0e7"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Add a stroke to frame the panel as well as fill it.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(panel-background: element-rect(
///     fill: rgb("#fff7e6"),
///     colour: rgb("#cc7a00"),
///     stroke: 1pt,
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pad a legend background so its tinted rectangle frames the guide content with breathing room (inner padding).
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5, k: if calc.rem(i, 2) == 0 { "a" } else { "b" }))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "k"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(legend-background: element-rect(
///     fill: rgb("#f7f0e7"),
///     inset: margin(top: 0.3em, right: 0.4em, bottom: 0.3em, left: 0.4em),
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let element-rect(
  fill: none,
  colour: none,
  stroke: none,
  inset: (kind: "margin", top: 5pt, right: 5pt, bottom: 5pt, left: 5pt),
  outset: none,
) = (
  kind: "element-rect",
  fill: fill,
  colour: colour,
  stroke: stroke,
  inset: inset,
  outset: outset,
)

/// Blank element: hides the corresponding theme element.
///
/// Pass the result to `theme` under keys like `panel-grid` or `axis-line` to turn them off entirely. On a text surface (`axis-title`, `plot-title`, `legend-title`, ...) it also collapses the space the text would reserve, so the data panel grows into the freed area.
///
/// Returns: Element dictionary consumed by `theme`.
///
/// See also: `theme`, `element-text`, `element-line`, `element-rect`.
///
/// Hide the panel grid entirely.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(panel-grid: element-blank()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Combine `element-blank` with other overrides to remove multiple non-data marks at once.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(
///     panel-grid: element-blank(),
///     axis-line: element-blank(),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Blank a text surface to drop its ink and reclaim its space; here the axis titles collapse while tick labels stay.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   labs: labs(x: "Index", y: "Value"),
///   theme: theme(axis-title: element-blank()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let element-blank() = (kind: "element-blank")

/// Per-side spacing record consumed by `element-text` / `element-typst` (text margin to neighbours) and `element-rect` (`inset` / `outset` offsets around the painted rectangle).
///
/// Each side accepts a Typst length (e.g., `1cm`, `8pt`, `0.3em`), a ratio (e.g., `5%`), a relative (e.g., `5% + 1cm`), or `auto`. On rect surfaces, `%` / `relative` sides resolve against the plot canvas dimensions (`width-units` for horizontal sides, `height-units` for vertical) at both draw time (`inset`) and layout time (`outset`). `auto` falls through to the consuming surface's renderer default (text gap) or to a zero offset (rect inset / outset). Bare `margin()` leaves every side at `auto`.
///
/// - top: Top margin (Typst length or `auto`).
/// - right: Right margin.
/// - bottom: Bottom margin.
/// - left: Left margin.
///
/// Returns: Margin dictionary consumed by `element-text`, `element-typst`, and `element-rect`.
///
/// See also: `element-text`, `element-typst`, `element-rect`, `theme`.
///
/// Loosen the gap between the y-axis tick labels and the axis-title via `element-text`'s `margin`.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   labs: labs(y: "Cumulative Response"),
///   theme: theme(axis-title-y-left: element-text(margin: margin(right: 0.6em))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pad a panel background so its rectangle frames the data region with extra breathing room (inner padding via `inset`).
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(panel-background: element-rect(
///     fill: rgb("#f7f0e7"),
///     inset: margin(top: 0.4cm, right: 0.4cm, bottom: 0.4cm, left: 0.4cm),
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Reserve outer whitespace around a tinted panel background; the panel canvas shrinks but the rectangle still surrounds the data.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(panel-background: element-rect(
///     fill: rgb("#f7f0e7"),
///     outset: margin(top: 0.4cm, right: 0.4cm, bottom: 0.4cm, left: 0.4cm),
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let margin(top: auto, right: auto, bottom: auto, left: auto) = (
  kind: "margin",
  top: top,
  right: right,
  bottom: bottom,
  left: left,
)

/// Layer-default aesthetics shared across geoms.
///
/// Pass the result to `theme` under the `geom` key to set defaults that the supporting geoms will pick up unless their own parameters override them. Mirrors plotnine's `element_geom()`. `fill` and `colour` are *global overrides* that win for every supporting geom; `ink`, `paper`, `accent` are *role* colours that geoms fall back to when the global override is unset, with each geom declaring which role drives its default (`ink` for line/text geoms, `accent` for `geom-smooth`, `paper` for `geom-boxplot`/`geom-crossbar`/`geom-point`/`geom-label`, a `col-mix(ink, paper, …)` tint for the bar/area/rect/tile family).
///
/// - fill: Global override for every filled geom's default fill colour.
/// - colour: Global override for every geom's default stroke or text colour, including `geom-smooth`.
/// - linewidth: Default stroke thickness for line and outline geoms (Typst length).
/// - font: Default font family for the text-drawing geoms (`geom-text`, `geom-label`, `geom-typst`). Falls back to the base `text` element family, then the document font.
/// - ink: Geom `ink` role: default stroke/text colour for almost every geom and the dark stop of the bar/area body-fill tint. Falls back to `theme.ink`.
/// - paper: Geom `paper` role: default fill for `geom-boxplot`, `geom-crossbar`, `geom-point`, `geom-label`, and the light stop of the bar/area body-fill tint. Falls back to `theme.paper`.
/// - accent: Geom `accent` role: default colour for `geom-smooth` (when `colour` is unset). Falls back to `theme.accent`.
///
/// Returns: Element dictionary consumed by `theme`.
///
/// See also: `theme`, `element-text`, `element-line`, `element-rect`, `element-blank`.
///
/// Pin a brand fill and bumped stroke thickness across the supporting geoms.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-col(),),
///   theme: theme(geom: element-geom(
///     fill: rgb("#cc3333"),
///     linewidth: 1pt,
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Shift the role colours so every unset default re-tints together: `ink` recolours stroke and text geoms and the dark stop of the bar fill; `paper` recolours boxplot/point/label fills and the light stop; `accent` recolours `geom-smooth`.
///
/// ```typst
/// #let d = range(0, 20).map(i => (x: i, y: i * 0.4 + calc.sin(i * 0.5)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-col(), geom-smooth(se: false)),
///   theme: theme(geom: element-geom(
///     ink: rgb("#2c3e50"),
///     paper: rgb("#fff7e6"),
///     accent: rgb("#cc6600"),
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Set the font for the text-drawing geoms (`geom-text`, `geom-label`, `geom-typst`) without touching the axis or title surfaces.
///
/// ```typst
/// #let d = range(0, 6).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt), geom-text(mapping: aes(label: "x"))),
///   theme: theme(geom: element-geom(font: "DejaVu Sans Mono")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let element-geom(
  fill: none,
  colour: none,
  linewidth: none,
  font: none,
  ink: none,
  paper: none,
  accent: none,
) = (
  kind: "element-geom",
  fill: fill,
  colour: colour,
  linewidth: linewidth,
  font: font,
  ink: ink,
  paper: paper,
  accent: accent,
)
