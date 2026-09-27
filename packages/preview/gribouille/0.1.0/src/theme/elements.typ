///! Structured theme elements.
///!
///! `element_*` constructors. \@theme translates these into the flat theme
///! fields consumed internally by `merge-theme`.

/// Text element: font size, weight, colour, and angle.
///
/// Pass the result to \@theme under keys like `axis-text`, `axis-title`,
/// `legend-text`, or `legend-title`.
///
/// \@category Themes
/// \@subcategory Theme elements
/// \@stability stable
/// \@since 0.0.1
///
/// \@param size Text size (a Typst length), or `none` to inherit.
///
/// \@param weight Font weight (e.g., `"regular"`, `"bold"`), or `none` to inherit.
///
/// \@param colour Text colour, or `none` to inherit.
///
/// \@param angle Rotation angle (a Typst angle), or `none` to inherit.
///
/// \@param family Font family (e.g., `"sans"`, `"serif"`), or `none` to inherit.
///
/// \@param margin Per-side spacing built with \@margin. Each side accepts
///   a Typst length (absolute or relative); `em` is preferred so spacing scales
///   with the surface font size. Sides left at `auto` fall through to the
///   renderer default. `none` keeps every side at the default.
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Bigger axis-title font passed via \@theme.
/// ```
/// //| alt: "Scatter plot of y against x with axis titles enlarged to 14pt via element-text passed to theme."
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
/// \@examples Combine multiple text fields and a rotation angle on axis
/// tick labels.
/// ```
/// //| alt: "Bar chart of y across quarterly categories with axis tick labels rendered in blue 9pt text rotated 30 degrees."
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
/// \@examples Widen the gap between the axis tick labels and the axis title
/// using a relative margin that tracks the title font size.
/// ```
/// //| alt: "Scatter plot of y against x with extra 1.6em padding above and to the right of the axis titles so they sit further from the ticks."
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
///
/// \@see \@theme, \@element-line, \@element-rect, \@element-blank, \@element-typst, \@margin
#let element-text(
  size: none,
  weight: none,
  colour: none,
  angle: none,
  family: none,
  margin: none,
) = (
  kind: "element-text",
  size: size,
  weight: weight,
  colour: colour,
  angle: angle,
  family: family,
  margin: margin,
)

/// Typst-markup text element: same fields as \@element-text plus
/// automatic Typst-markup evaluation for plain strings reaching this
/// surface.
///
/// Drop-in replacement for \@element-text on any text key. Strings
/// supplied via \@labs, scale names, or scale `labels:` callbacks are
/// evaluated as Typst markup before rendering, so users do not need to
/// wrap each value with \@typst. Per-call \@typst() and content (`[…]`)
/// values still pass through unchanged.
///
/// \@category Themes
/// \@subcategory Theme elements
/// \@stability stable
/// \@since 0.1.0
///
/// \@param size Text size (a Typst length), or `none` to inherit.
///
/// \@param weight Font weight (e.g., `"regular"`, `"bold"`), or `none`.
///
/// \@param colour Text colour, or `none` to inherit.
///
/// \@param angle Rotation angle (a Typst angle), or `none` to inherit.
///
/// \@param family Font family, or `none` to inherit.
///
/// \@param margin Per-side spacing built with \@margin. Each side accepts
///   a Typst length (absolute or relative); `em` is preferred so spacing scales
///   with the surface font size. Sides left at `auto` fall through to the
///   renderer default. `none` keeps every side at the default.
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Enable Typst markup for every plot title in a session by
/// setting `plot-title: element-typst()` on the theme.
/// ```
/// //| alt: "Scatter plot of y against x titled \"Mean x-bar over Time\" with the title rendered as 14pt bold Typst markup including a math glyph."
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
/// \@examples Mix typst and non-typst surfaces in the same theme:
/// ```
/// //| alt: "Scatter plot of y against x with a Typst-evaluated plot title rendering math glyphs while the axis titles stay as plain text."
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
///
/// \@see \@theme, \@element-text, \@typst, \@margin
#let element-typst(
  size: none,
  weight: none,
  colour: none,
  angle: none,
  family: none,
  margin: none,
) = (
  kind: "element-typst",
  size: size,
  weight: weight,
  colour: colour,
  angle: angle,
  family: family,
  margin: margin,
)

/// Line element: colour and stroke thickness.
///
/// Pass the result to \@theme under keys like `panel-grid` or `axis-line`.
///
/// \@category Themes
/// \@subcategory Theme elements
/// \@stability stable
/// \@since 0.0.1
///
/// \@param colour Line colour, or `none` to inherit.
///
/// \@param stroke Line thickness (a Typst length), or `none`.
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Recolour the panel grid via \@theme.
/// ```
/// //| alt: "Scatter plot of y against x with the panel gridlines recoloured pale stone via element-line on the panel-grid surface."
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
/// \@examples Strengthen the axis line by setting both `colour` and
/// `stroke`.
/// ```
/// //| alt: "Scatter plot of y against x with axis lines drawn 1pt thick in red via element-line on the axis-line surface."
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
///
/// \@see \@theme, \@element-text, \@element-rect, \@element-blank
#let element-line(colour: none, stroke: none) = (
  kind: "element-line",
  colour: colour,
  stroke: stroke,
)

/// Rectangle element: fill, outline colour, stroke thickness, and per-side
/// margins. `inset` is honoured on `plot-background` (grows the painted
/// fill outward past the content via Typst `block(inset:)`) and on
/// `legend-background` (grows the legend rect outward from the guide-stack
/// bbox so the rectangle frames the legend with extra inner padding).
/// `panel-background` and `legend-bar` ignore `inset` so the rect cannot
/// bleed onto neighbours. `outset` reserves outer whitespace by widening
/// the chrome slot on `panel-background`, `legend-background`, and
/// `legend-bar`; on `plot-background` it wraps the rendered block in
/// `pad(...)`. On `legend-background`, the panel-facing outset side also
/// widens the visible gap between panel and legend. `strip-background`
/// ignores both fields -- the facet band has no surrounding slot to grow
/// or reserve into.
///
/// Pass the result to \@theme under keys like `panel-background`.
///
/// \@category Themes
/// \@subcategory Theme elements
/// \@stability stable
/// \@since 0.0.1
///
/// \@param fill Rectangle fill colour, or `none` to inherit.
///
/// \@param colour Outline colour, or `none` to inherit.
///
/// \@param stroke Outline thickness (a Typst length), or `none` for no outline.
///
/// \@param inset Inner padding \@margin honoured by `plot-background` and `legend-background` (grows the painted rect outward), or `none`. Ignored on `panel-background`, `strip-background`, and `legend-bar`.
///
/// \@param outset Outer margin \@margin reserving outer whitespace (panel canvas shrinks on cetz surfaces; the rendered block is wrapped in `pad(...)` on `plot-background`), or `none`. Ignored on `strip-background`.
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Tinted panel background via \@theme.
/// ```
/// //| alt: "Scatter plot of y against x with the panel background tinted warm cream via element-rect on the panel-background surface."
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
/// \@examples Add a stroke to frame the panel as well as fill it.
/// ```
/// //| alt: "Scatter plot of y against x with a cream-filled panel ringed by a 1pt amber stroke via element-rect fill, colour, and stroke."
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
/// \@examples Pad a legend background so its tinted rectangle frames the
/// guide content with breathing room (inner padding).
/// ```
/// //| alt: "Scatter plot of y against x with a tinted legend backdrop padded via inner inset margins so the rectangle frames the guide with breathing room."
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
///
/// \@see \@theme, \@margin, \@element-text, \@element-line, \@element-blank
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
/// Pass the result to \@theme under keys like `panel-grid` or `axis-line`
/// to turn them off entirely.
///
/// \@category Themes
/// \@subcategory Theme elements
/// \@stability stable
/// \@since 0.0.1
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Hide the panel grid entirely.
/// ```
/// //| alt: "Scatter plot of y against x with the panel grid hidden via element-blank, leaving only axis lines and tick labels."
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
/// \@examples Combine `element-blank` with other overrides to remove
/// multiple non-data marks at once.
/// ```
/// //| alt: "Scatter plot of y against x with both panel grid and axis lines hidden via element-blank, removing the chart frame at once."
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
/// \@see \@theme, \@element-text, \@element-line, \@element-rect
#let element-blank() = (kind: "element-blank")

/// Per-side spacing record consumed by \@element-text / \@element-typst
/// (text margin to neighbours) and \@element-rect (`inset` / `outset`
/// offsets around the painted rectangle).
///
/// Each side accepts a Typst length (e.g., `1cm`, `8pt`, `0.3em`), a
/// ratio (e.g., `5%`), a relative (e.g., `5% + 1cm`), or `auto`. On rect
/// surfaces, `%` / `relative` sides resolve against the plot canvas
/// dimensions (`width-units` for horizontal sides, `height-units` for
/// vertical) at both draw time (`inset`) and layout time (`outset`).
/// `auto` falls through to the consuming surface's renderer default (text
/// gap) or to a zero offset (rect inset / outset). Bare `margin()` leaves
/// every side at `auto`.
///
/// \@category Themes
/// \@subcategory Theme elements
/// \@stability stable
/// \@since 0.4.0
///
/// \@param top Top margin (Typst length or `auto`).
///
/// \@param right Right margin.
///
/// \@param bottom Bottom margin.
///
/// \@param left Left margin.
///
/// \@returns Margin dictionary consumed by \@element-text, \@element-typst, and \@element-rect.
///
/// \@examples Loosen the gap between the y-axis tick labels and the
/// axis-title via `element-text`'s `margin`.
/// ```
/// //| alt: "Scatter plot of y against x with a wider 0.6em right-hand gap between the y-axis-title text and the axis labels via element-text margin."
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
/// \@examples Pad a panel background so its rectangle frames the data
/// region with extra breathing room (inner padding via `inset`).
/// ```
/// //| alt: "Scatter plot of y against x with the panel background tinted cream and grown outward 0.4cm on every side via element-rect inset (inner padding)."
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
/// \@examples Reserve outer whitespace around a tinted panel background;
/// the panel canvas shrinks but the rectangle still surrounds the data.
/// ```
/// //| alt: "Scatter plot of y against x with a tinted panel background and 0.4cm of reserved outer whitespace on every side via element-rect outset; the panel canvas shrinks accordingly."
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
///
/// \@see \@element-text, \@element-typst, \@element-rect, \@theme
#let margin(top: auto, right: auto, bottom: auto, left: auto) = (
  kind: "margin",
  top: top,
  right: right,
  bottom: bottom,
  left: left,
)

/// Layer-default aesthetics shared across geoms.
///
/// Pass the result to \@theme under the `geom` key to set defaults that the
/// supporting geoms will pick up unless their own parameters override them.
/// Mirrors plotnine's `element_geom()`.
/// `fill` and `colour` are *global overrides* that win for every supporting
/// geom; `ink`, `paper`, `accent` are *role* colours that geoms fall back to
/// when the global override is unset, with each geom declaring which role
/// drives its default (`ink` for line/text geoms, `accent` for \@geom-smooth,
/// `paper` for \@geom-boxplot/\@geom-crossbar/\@geom-point/\@geom-label, a
/// `col-mix(ink, paper, …)` tint for the bar/area/rect/tile family).
///
/// \@category Themes
/// \@subcategory Theme elements
/// \@stability stable
/// \@since 0.5.0
///
/// \@param fill Global override for every filled geom's default fill colour.
///
/// \@param colour Global override for every geom's default stroke or text colour, including \@geom-smooth.
///
/// \@param linewidth Default stroke thickness for line and outline geoms (Typst length).
///
/// \@param ink Geom `ink` role: default stroke/text colour for almost every geom and the dark stop of the bar/area body-fill tint. Falls back to `theme.ink`.
///
/// \@param paper Geom `paper` role: default fill for \@geom-boxplot, \@geom-crossbar, \@geom-point, \@geom-label, and the light stop of the bar/area body-fill tint. Falls back to `theme.paper`.
///
/// \@param accent Geom `accent` role: default colour for \@geom-smooth (when `colour` is unset). Falls back to `theme.accent`.
///
/// \@returns Element dictionary consumed by \@theme.
///
/// \@examples Pin a brand fill and bumped stroke thickness across the
/// supporting geoms.
/// ```
/// //| alt: "Bar chart of y against x with bars filled deep red and outlined 1pt thick via the element-geom layer defaults."
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
/// \@examples Shift the role colours so every unset default re-tints together:
/// `ink` recolours stroke and text geoms and the dark stop of the bar fill;
/// `paper` recolours boxplot/point/label fills and the light stop; `accent`
/// recolours \@geom-smooth.
/// ```
/// //| alt: "Bar chart of y against x with a re-tinted navy and cream colour role pairing and a warm orange smooth trend line via geom-smooth."
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
/// \@see \@theme, \@element-text, \@element-line, \@element-rect, \@element-blank
#let element-geom(
  fill: none,
  colour: none,
  linewidth: none,
  ink: none,
  paper: none,
  accent: none,
) = (
  kind: "element-geom",
  fill: fill,
  colour: colour,
  linewidth: linewidth,
  ink: ink,
  paper: paper,
  accent: accent,
)
