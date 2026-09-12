///! Boxed text labels at `(x, y)` positions.
///!
///! Like \@geom-text but wraps the label in a rectangle with configurable
///! fill, stroke, inset, and corner radius.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/label-draw.typ": draw-segment, prepare-draw, row-centre
#import "../utils/stroke.typ": build-stroke
#import "../utils/typst-markup.typ": eval-as-markup
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
)

/// Boxed text label layer reading strings from the `label` aesthetic.
///
/// One boxed text block is drawn per row at the mapped `(x, y)`. The box takes its own fill, stroke, inset, and corner radius. Per-row data-unit offsets are read from the `nudge-x` and `nudge-y` aesthetics; setting `segment: true` draws a connector back to the anchor that avoids the other label boxes of the same layer.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`, and `label`. May map `nudge-x` and `nudge-y` for per-row offsets in data units.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - size: Text size (a Typst length).
/// - colour: Paint applied to both the box outline and the label text. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// - fill: Box fill colour. `auto` resolves via the fill scale, falling back to the theme `paper` only when neither `colour` nor `fill` is set.
/// - stroke: Box outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// - alpha: Box and text opacity in `[0, 1]`. `auto` honours any mapped alpha aesthetic.
/// - inset: Padding between text and box border (a Typst length).
/// - radius: Corner radius of the box (a Typst length).
/// - anchor: CeTZ anchor (e.g., `"center"`, `"west"`) controlling placement.
/// - dx: Horizontal offset, as a number (canvas units, 1 = 1cm) or a Typst length (e.g., `4pt`, `2mm`).
/// - dy: Vertical offset, as a number (canvas units, 1 = 1cm) or a Typst length (e.g., `4pt`, `2mm`).
/// - segment: Draw a connector from each box back to its anchor point. When `true`, the connector is routed to avoid the AABBs of other boxes of the same layer; dropped when no L-bend clears the obstacles.
/// - segment-colour: Connector paint. `auto` inherits the theme `ink`.
/// - segment-stroke: Connector thickness (a Typst length).
/// - min-segment-length: Connectors shorter than this distance (canvas units, 1 = 1cm) are suppressed.
/// - arrow: Draw a small V-mark at the anchor end of the connector.
/// - arrow-length: Arrow stroke length (a Typst length).
/// - box-padding: Extra cm padding added around each measured box when routing connectors.
/// - repel: Repel boxes off each other (and off their anchor points) via an iterative force-based layout, ggrepel-style. Pair with `segment: true` to keep the visual link to each anchor.
/// - point-padding: Minimum clearance (cm) between a box and any anchor point when `repel` is on.
/// - max-iter: Maximum number of repulsion iterations.
/// - force-pull: Strength of the spring pull that keeps each box near its anchor.
/// - force-push: Strength of the repulsion between overlapping boxes.
/// - force-segment: Strength of the penalty that pushes a box off another label's connector path.
/// - seed: Random seed for the small initial jitter applied to coincident anchors.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`; pass `"nudge"` to shift labels off their points.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-text`, `aes`.
///
/// Default boxed labels nudged above their points.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, name: "a"),
///   (x: 2, y: 4, name: "b"),
///   (x: 3, y: 3, name: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "name"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-label(dy: 0.25),
///   ),
///   scales: (scale-y-continuous(expand: 15%),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Customise `fill`, `stroke`, and `radius` to match a coloured callout style.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, name: "alpha"),
///   (x: 2, y: 4, name: "beta"),
///   (x: 3, y: 3, name: "gamma"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "name"),
///   layers: (
///     geom-label(
///       fill: rgb("#fff7e6"),
///       colour: rgb("#cc7a00"),
///       stroke: 0.6pt,
///       radius: 3pt,
///       inset: 4pt,
///       dy: 0.3,
///     ),
///   ),
///   scales: (scale-y-continuous(expand: 15%),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-label(
  mapping: none,
  data: none,
  size: 8pt,
  colour: auto,
  fill: auto,
  stroke: 0.4pt,
  alpha: auto,
  inset: 2pt,
  radius: 1pt,
  anchor: "center",
  dx: 0,
  dy: 0,
  segment: false,
  segment-colour: auto,
  segment-stroke: 0.4pt,
  min-segment-length: 0.05,
  arrow: false,
  arrow-length: 4pt,
  box-padding: 0.05,
  repel: false,
  point-padding: 0.05,
  max-iter: 100,
  force-pull: 0.1,
  force-push: 0.2,
  force-segment: 0.3,
  seed: 0,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "label",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
    inset: inset,
    radius: radius,
    anchor: anchor,
    dx: dx,
    dy: dy,
    segment: segment,
    segment-colour: segment-colour,
    segment-stroke: segment-stroke,
    min-segment-length: min-segment-length,
    arrow: arrow,
    arrow-length: arrow-length,
    box-padding: box-padding,
    repel: repel,
    point-padding: point-padding,
    max-iter: max-iter,
    force-pull: force-pull,
    force-push: force-push,
    force-segment: force-segment,
    seed: seed,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.at("x", default: none) == none { return }
  if mapping.at("y", default: none) == none { return }
  let label-col = mapping.at("label", default: none)
  if label-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let g-defaults = resolve-geom-defaults(ctx.theme)
  let theme-colour = resolve-geom-colour(g-defaults)
  // `none` font keeps the document font; only pass `text(font: ...)` when set.
  let font-args = if g-defaults.font != none { (font: g-defaults.font) } else {
    (:)
  }
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    theme-colour,
    resolve-geom-fill(g-defaults, role: "paper"),
  )
  let label-typst = layer
    .at("typst-marks", default: (:))
    .at("label", default: false)
  let state = prepare-draw(layer, ctx, mapping, data, theme-colour)

  for (idx, row) in data.enumerate() {
    let centre = row-centre(state, ctx, mapping, idx, row)
    if centre == none { continue }
    let label = row.at(label-col, default: none)
    if label == none { continue }
    if label-typst { label = eval-as-markup(label) }
    // Resolve text colour with `theme-colour` as the unconditional fallback so
    // the label stays visible even when the exclusive-default rule suppresses
    // the box outline; the outline follows `default-colour` and is dropped
    // when only `fill` is set.
    let text-paint = resolve-channel(
      "colour",
      layer,
      mapping,
      ctx,
      row,
      theme-colour,
    )
    let box-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let stroke-spec = if default-colour == none {
      none
    } else {
      build-stroke(layer.params.stroke, text-paint)
    }
    let text-size = resolve-channel(
      "size",
      layer,
      mapping,
      ctx,
      row,
      layer.params.size,
    )
    let body = box(
      fill: box-fill,
      stroke: stroke-spec,
      inset: layer.params.inset,
      radius: layer.params.radius,
      text(size: text-size, fill: text-paint, ..font-args)[#label],
    )
    if state.segment-on {
      draw-segment(idx, state.placements.at(idx), state.aabbs, state.seg-cfg)
    }
    cetz.draw.content(
      centre,
      body,
      anchor: layer.params.anchor,
    )
  }
}
