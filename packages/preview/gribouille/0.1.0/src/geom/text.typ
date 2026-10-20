///! Text labels at `(x, y)` positions.
///!
///! The label string comes from the `label` aesthetic. For a boxed variant
///! with a fill and border, use \@geom-label.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/label-draw.typ": draw-segment, prepare-draw, row-centre
#import "../utils/typst-markup.typ": eval-as-markup
#import "../theme/theme.typ": geom-colour-default, geom-defaults

/// Text label layer reading strings from the `label` aesthetic.
///
/// One text block is drawn per row at the mapped `(x, y)` with an optional
/// offset via `dx` and `dy`. Per-row offsets in data units may be mapped via
/// the `nudge-x` and `nudge-y` aesthetics. Setting `segment: true` draws a
/// connector back to the anchor point, routed to avoid the other labels of
/// the same layer.
///
/// \@category Geoms
/// \@subcategory Text and annotations
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `y`, and `label`. May map `nudge-x` and `nudge-y` for per-row offsets in data units.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param size Text size (a Typst length).
///
/// \@param colour Fixed text colour. `auto` inherits the theme `ink`. Used when no colour mapping is active.
///
/// \@param alpha Text opacity in `[0, 1]`. `auto` honours any mapped alpha aesthetic.
///
/// \@param anchor CeTZ anchor (e.g., `"center"`, `"west"`) controlling placement.
///
/// \@param dx Horizontal offset, as a number (canvas units, 1 = 1cm) or a Typst length (e.g., `4pt`, `2mm`).
///
/// \@param dy Vertical offset, as a number (canvas units, 1 = 1cm) or a Typst length (e.g., `4pt`, `2mm`).
///
/// \@param segment Draw a connector from each label back to its anchor point. When `true`, the connector is routed to avoid the AABBs of other labels of the same layer; the connector is dropped when no L-bend clears the obstacles.
///
/// \@param segment-colour Connector paint. `auto` inherits the theme `ink`.
///
/// \@param segment-stroke Connector thickness (a Typst length).
///
/// \@param min-segment-length Connectors shorter than this distance (canvas units, 1 = 1cm) are suppressed to avoid tiny stubs.
///
/// \@param arrow Draw a small V-mark at the anchor end of the connector.
///
/// \@param arrow-length Arrow stroke length (a Typst length).
///
/// \@param box-padding Extra cm padding added around each measured label box when routing connectors and clipping to the label edge.
///
/// \@param repel Repel labels off each other (and off their anchor points) via an iterative force-based layout, ggrepel-style. Pair with `segment: true` to keep the visual link to each anchor.
///
/// \@param point-padding Minimum clearance (cm) between a label and any anchor point when `repel` is on.
///
/// \@param max-iter Maximum number of repulsion iterations.
///
/// \@param force-pull Strength of the spring pull that keeps each label near its anchor.
///
/// \@param force-push Strength of the repulsion between overlapping labels.
///
/// \@param force-segment Strength of the penalty that pushes a label off another label's connector path.
///
/// \@param seed Random seed for the small initial jitter applied to coincident anchors. Same seed produces the same layout.
///
/// \@param stat Statistical transform name. Usually `"identity"`.
///
/// \@param position Position adjustment name. Usually `"identity"`; pass `"nudge"` to shift labels off their points.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Labels nudged above their points via `dy`.
/// ```
/// //| alt: "Three point markers at (x, y) with plain text labels (a, b, c) nudged above each point via a vertical offset."
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
///     geom-text(dy: 0.2),
///   ),
///   scales: (scale-y-continuous(expand: 15%),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Per-row offsets via `nudge-x`/`nudge-y` plus connectors back
/// to each anchor.
/// ```
/// //| alt: "Three points with text labels shifted by per-row offsets and connected back to their anchor by thin segments."
/// #let d = (
///   (x: 1, y: 2, name: "a", nx: 0.5, ny: 0.4),
///   (x: 2, y: 4, name: "b", nx: -0.4, ny: 0.5),
///   (x: 3, y: 3, name: "c", nx: 0.4, ny: -0.4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "name", nudge-x: "nx", nudge-y: "ny"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-text(segment: true),
///   ),
///   scales: (scale-x-continuous(expand: 40%),scale-y-continuous(expand: 40%),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-label, \@aes
#let geom-text(
  mapping: none,
  data: none,
  size: 8pt,
  colour: auto,
  alpha: auto,
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
  "text",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    colour: colour,
    alpha: alpha,
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
  let const-label = layer.params.at("label", default: none)
  let use-const = const-label != none
  let label-col = mapping.at("label", default: none)
  if not use-const and label-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let theme-colour = geom-colour-default(geom-defaults(ctx.theme))
  let label-typst = layer
    .at("typst-marks", default: (:))
    .at("label", default: false)
  let state = prepare-draw(layer, ctx, mapping, data, theme-colour)

  for (idx, row) in data.enumerate() {
    let centre = row-centre(state, ctx, mapping, idx, row)
    if centre == none { continue }
    let label = if use-const { const-label } else {
      row.at(label-col, default: none)
    }
    if label == none { continue }
    if label-typst { label = eval-as-markup(label) }
    let colour = resolve-channel(
      "colour",
      layer,
      mapping,
      ctx,
      row,
      theme-colour,
    )
    let text-size = resolve-channel(
      "size",
      layer,
      mapping,
      ctx,
      row,
      layer.params.size,
    )
    if state.segment-on {
      draw-segment(idx, state.placements.at(idx), state.aabbs, state.seg-cfg)
    }
    cetz.draw.content(
      centre,
      text(size: text-size, fill: colour)[#label],
      anchor: layer.params.anchor,
    )
  }
}
