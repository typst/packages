#import "../core/model.typ": id

/// Reference a named anchor on an object.
#let connect(object, anchor) = (
  kind: "anchor",
  object: object.id,
  anchor: anchor,
)

/// Describe a rope wrapping around a pulley.
/// Tangency points are resolved from the adjacent connected objects.
#let wrap(pulley, side: "upper", entry: auto, exit: auto) = {
  assert(side == "upper" or side == "lower",
    message: "wrap side must be `upper` or `lower`")
  (
    kind: "wrap",
    object: pulley.id,
    side: side,
    entry: entry,
    exit: exit,
  )
}

/// Construct a rope connection from anchors and pulley wraps.
#let rope(
  connection-id,
  path,
  label: none,
  label-position: 50%,
  label-offset: (0, 0.22),
  label-anchor: "center",
  color: none,
  stroke: 0.8pt,
) = {
  assert(type(path) == array and path.len() >= 2,
    message: "A rope path requires at least two items")
  assert(path.first().kind == "anchor" and path.last().kind == "anchor",
    message: "A rope path must start and end at object anchors")
  for (index, item) in path.enumerate() {
    assert(item.kind == "anchor" or item.kind == "wrap",
      message: "Unknown rope path item: " + item.kind)
    if item.kind == "wrap" {
      assert(index > 0 and index + 1 < path.len(),
        message: "A pulley wrap requires adjacent anchors")
      assert(path.at(index - 1).kind == "anchor" and path.at(index + 1).kind == "anchor",
        message: "A pulley wrap must be between object anchors")
    }
  }
  (
    kind: "rope",
    id: id(connection-id),
    path: path,
    label: label,
    label-position: label-position,
    label-offset: label-offset,
    label-anchor: label-anchor,
    color: color,
    stroke: stroke,
  )
}
