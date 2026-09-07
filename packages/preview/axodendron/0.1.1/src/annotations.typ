// Typst-native annotation value constructors.

#import "protocol.typ": _required, _positive, _nonnegative-length, _length-offset

/// Construct a Typst-native node label annotation. `offset.x` and `offset.y`
/// shift the label after projection; positive values move right and down.
///
/// - body (content): Label content.
/// - node (int): Node ID to annotate.
/// - offset (dictionary): Typst `x` and `y` length offsets from the projected node.
/// -> dictionary
#let label(body, node: none, offset: (x: 4pt, y: -4pt)) = (
  kind: "label",
  node: _required("node", node),
  body: body,
  offset: offset,
)

/// Construct a node-anchored marker. If `body` is omitted, a circle is drawn.
///
/// - node (int): Node ID to mark.
/// - body (none, content): Optional marker content; `none` draws a circle.
/// - offset (dictionary): Typst `x` and `y` length offsets from the projected node.
/// - size (length): Marker width and height.
/// - fill (any): Circle fill accepted by Typst.
/// - stroke (any): Circle stroke accepted by Typst.
/// -> dictionary
#let marker(
  node: none,
  body: none,
  offset: (x: 0pt, y: 0pt),
  size: 5pt,
  fill: white,
  stroke: 0.8pt + black,
) = (
  kind: "marker",
  node: _required("node", node),
  body: body,
  offset: offset,
  size: size,
  fill: fill,
  stroke: stroke,
)

/// Construct a CeTZ leader label. `offset` and every `via` entry are relative
/// to the projected node in Typst screen coordinates: positive x moves right
/// and positive y moves down. Side leaders leave the text at its typographic
/// vertical center. Leaders are straight or follow `via` line segments unless
/// the caller explicitly supplies one or two CeTZ Bezier `controls`. The
/// optional white label fill prevents dense morphology geometry from showing
/// through the text without drawing a frame.
///
/// - body (content): Label content.
/// - node (int): Node ID targeted by the leader.
/// - offset (dictionary): Typst `x` and `y` lengths from the node to the label.
/// - via (array): Optional relative polyline vertices as `x` and `y` length dictionaries.
/// - controls (array): Zero, one, or two relative CeTZ Bezier control points.
/// - anchor (auto, str): Automatic or explicit CeTZ anchor for the label content.
/// - padding (length): Non-negative padding around the label content.
/// - fill (any): Label background fill accepted by CeTZ.
/// - label-stroke (any): Optional label frame stroke accepted by CeTZ.
/// - arrow-stroke (any): Leader stroke accepted by CeTZ.
/// - arrow-fill (any): Arrowhead fill accepted by CeTZ.
/// - mark (none, str): CeTZ end-mark name, or `none` for no arrowhead.
/// - mark-scale (int, float): Positive CeTZ end-mark scale.
/// - target-gap (length): Non-negative gap between the leader endpoint and target node.
/// -> dictionary
#let cetz-label(
  body,
  node: none,
  offset: (x: 16mm, y: -10mm),
  via: (),
  controls: (),
  anchor: auto,
  padding: 2pt,
  fill: white,
  label-stroke: none,
  arrow-stroke: 0.7pt + black,
  arrow-fill: black,
  mark: "stealth",
  mark-scale: 0.7,
  target-gap: 0pt,
) = {
  let offset = _length-offset("cetz-label.offset", offset)
  if type(via) != array {
    panic("Axodendron: `cetz-label.via` must be an array of x/y length dictionaries")
  }
  let via = via.enumerate().map(((index, point)) => {
    _length-offset("cetz-label.via." + str(index), point)
  })
  if type(controls) != array or controls.len() not in (0, 1, 2) {
    panic("Axodendron: `cetz-label.controls` must contain zero, one, or two x/y length dictionaries")
  }
  let controls = controls.enumerate().map(((index, point)) => {
    _length-offset("cetz-label.controls." + str(index), point)
  })
  if controls != () and via != () {
    panic("Axodendron: `cetz-label.controls` and `cetz-label.via` cannot be combined")
  }
  if anchor != auto and type(anchor) != str {
    panic("Axodendron: `cetz-label.anchor` must be `auto` or a CeTZ anchor string")
  }
  if offset.at("x") == 0pt and offset.at("y") == 0pt {
    panic("Axodendron: a CeTZ leader label needs a non-zero offset")
  }
  let route-offsets = (offset,) + via + ((x: 0pt, y: 0pt),)
  for index in range(route-offsets.len() - 1) {
    let current = route-offsets.at(index)
    let next = route-offsets.at(index + 1)
    if current.at("x") == next.at("x") and current.at("y") == next.at("y") {
      panic("Axodendron: consecutive CeTZ leader points must not coincide")
    }
  }
  if (type(mark-scale) != int and type(mark-scale) != float) or mark-scale <= 0 {
    panic("Axodendron: `cetz-label.mark-scale` must be a positive number")
  }
  if mark != none and type(mark) != str {
    panic("Axodendron: `cetz-label.mark` must be a CeTZ mark string or none")
  }
  (
    kind: "cetz-label",
    node: _required("node", node),
    body: body,
    offset: offset,
    via: via,
    controls: controls,
    anchor: anchor,
    padding: _nonnegative-length("cetz-label.padding", padding),
    fill: fill,
    label-stroke: label-stroke,
    arrow-stroke: arrow-stroke,
    arrow-fill: arrow-fill,
    mark: mark,
    mark-scale: mark-scale,
    target-gap: _nonnegative-length("cetz-label.target-gap", target-gap),
  )
}

/// Construct a compact categorical legend.
///
/// - entries (array): Legend entries containing `color` and `label` fields.
/// - position (any): Typst alignment used to place the legend.
/// - inset (length): Distance from the selected render edge.
/// -> dictionary
#let legend(entries: none, position: top + right, inset: 8pt) = (
  entries: _required("entries", entries),
  position: position,
  inset: inset,
)

/// Construct a scalar color bar using the same named palette as the renderer.
/// `label-gap` controls the vertical space between its label and palette strip.
///
/// - min (int, float): Scalar value shown at the low end of the palette.
/// - max (int, float): Scalar value shown at the high end of the palette.
/// - label (none, content, str): Optional color-bar label.
/// - label-gap (length): Non-negative vertical gap below the label.
/// - colormap (str): Named scalar palette, either `"viridis"` or `"magma"`.
/// - position (any): Typst alignment used to place the color bar.
/// - inset (length): Distance from the selected render edge.
/// -> dictionary
#let color-bar(
  min: none,
  max: none,
  label: none,
  label-gap: 4pt,
  colormap: "viridis",
  position: bottom + right,
  inset: 8pt,
) = (
  min: _required("min", min),
  max: _required("max", max),
  label: label,
  label-gap: _nonnegative-length("label-gap", label-gap),
  colormap: colormap,
  position: position,
  inset: inset,
)

/// Construct a physical scale bar. `value` is in the morphology's units.
///
/// - value (int, float): Positive physical length represented by the bar.
/// - label (none, content, str): Optional replacement for the generated unit label.
/// - inset (length): Distance from the bottom-left render edges.
/// - stroke (any): Scale-bar line stroke accepted by Typst.
/// -> dictionary
#let scale-bar(value: none, label: none, inset: 8pt, stroke: 1pt) = (
  value: _positive("value", value),
  label: label,
  inset: inset,
  stroke: stroke,
)
