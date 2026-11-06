///! Text geom that always evaluates its `label` aesthetic as Typst markup.

#import "../layer.typ": make-layer
#import "./text.typ" as text-geom

/// Text label layer whose `label` aesthetic is always evaluated as Typst markup.
///
/// Sibling of `geom-text`. Use this when every label string must be interpreted as Typst markup at the call site, without wrapping each column reference in `typst`.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x` and `y`. Map `label` to a column when each row carries its own label, or pass `label:` directly to use a single constant value for every row.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - size: Text size (a Typst length).
/// - colour: Fixed text colour. `auto` inherits the theme `ink`. Used when no colour mapping is active.
/// - alpha: Text opacity in `[0, 1]`. `auto` honours any mapped alpha aesthetic.
/// - anchor: CeTZ anchor (e.g., `"center"`, `"west"`) controlling placement.
/// - dx: Horizontal offset, as a number (canvas units, 1 = 1cm) or a Typst length.
/// - dy: Vertical offset, as a number (canvas units, 1 = 1cm) or a Typst length.
/// - label: Constant label drawn at every row's `(x, y)`. Accepts a Typst content block (`[#math.alpha]`, `[*bold*]`) or a markup string (`"$alpha$"`) eval'd as Typst at render time. When `none`, the label is read from the `label` aesthetic mapping.
/// - segment: Draw a connector from each label back to its anchor point. When `true`, the connector is routed to avoid the AABBs of other labels of the same layer; dropped when no L-bend clears the obstacles.
/// - segment-colour: Connector paint. `auto` inherits the theme `ink`.
/// - segment-stroke: Connector thickness (a Typst length).
/// - min-segment-length: Connectors shorter than this distance (canvas units, 1 = 1cm) are suppressed.
/// - arrow: Draw a small V-mark at the anchor end of the connector.
/// - arrow-length: Arrow stroke length (a Typst length).
/// - box-padding: Extra cm padding around each measured label when routing connectors.
/// - repel: Repel labels off each other (and off their anchor points) via an iterative force-based layout, ggrepel-style. Pair with `segment: true` to keep the visual link to each anchor.
/// - point-padding: Minimum clearance (cm) between a label and any anchor point when `repel` is on.
/// - max-iter: Maximum number of repulsion iterations.
/// - force-pull: Strength of the spring pull that keeps each label near its anchor.
/// - force-push: Strength of the repulsion between overlapping labels.
/// - force-segment: Strength of the penalty that pushes a label off another label's connector path.
/// - seed: Random seed for the small initial jitter applied to coincident anchors.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-text`, `typst`, `annotate`.
///
/// Each row's `label` column carries Typst markup that is evaluated in place; no `typst()` wrapper is needed at the call site.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, t: "$alpha$"),
///   (x: 2, y: 2, t: "*bold*"),
///   (x: 3, y: 3, t: "#emph[italic]"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", label: "t"),
///   layers: (geom-typst(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Use a constant content block as the label at every row.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1),
///   (x: 2, y: 2),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-typst(label: [#math.alpha]),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-typst(
  mapping: none,
  data: none,
  size: 10pt,
  colour: auto,
  alpha: auto,
  anchor: "center",
  dx: 0,
  dy: 0,
  label: none,
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
  "typst",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    colour: colour,
    alpha: alpha,
    anchor: anchor,
    dx: dx,
    dy: dy,
    label: label,
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
  let new = layer
  let marks = layer.at("typst-marks", default: (:))
  marks.insert("label", true)
  new.insert("typst-marks", marks)
  text-geom.draw(new, ctx)
}
