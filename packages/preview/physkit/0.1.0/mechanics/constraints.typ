#import "../core/model.typ": id

/// Place a body on the free side of a surface.
#let on-surface(body, support, distance: none, position: none, gap: 0) = {
  assert(distance != none or position != none,
    message: "on-surface requires either `distance` or `position`")
  assert(not (distance != none and position != none),
    message: "Use either `distance` or `position`, not both")
  (
    kind: "on-surface",
    object: body.id,
    support: support.id,
    distance: distance,
    position: position,
    gap: gap,
  )
}

/// Fix an object to a surface using a straight support.
#let fixed-to(body, support, position: 50%, distance: 0.7) = (
  kind: "fixed-to",
  object: body.id,
  support: support.id,
  position: position,
  distance: distance,
)

/// Position a pulley and vertically move its support so the incoming rope is
/// parallel to a reference surface. The source is an anchor made with
/// `connect`, while `support` is currently a horizontal floor or ceiling.
#let align-rope-parallel(
  from: none,
  pulley: none,
  parallel-to: none,
  support: none,
  support-position: 50%,
  support-distance: 0.7,
  wrap-side: "upper",
) = {
  assert(from != none and pulley != none and parallel-to != none and support != none,
    message: "align-rope-parallel requires `from`, `pulley`, `parallel-to`, and `support`")
  assert(from.kind == "anchor",
    message: "align-rope-parallel requires an anchor made with `connect`")
  assert(wrap-side == "upper" or wrap-side == "lower",
    message: "wrap-side must be `upper` or `lower`")
  (
    kind: "align-rope-parallel",
    source: from,
    object: pulley.id,
    reference: parallel-to.id,
    support: support.id,
    support-position: support-position,
    support-distance: support-distance,
    wrap-side: wrap-side,
  )
}

/// Suspend a box from a pulley port.
/// `length` is the straight rope length between the pulley tangent point and
/// the selected anchor on the suspended body.
#let suspended-from(body, pulley, side: "right", length: 1.5) = {
  assert(side == "right" or side == "left",
    message: "suspended-from currently supports `right` or `left`")
  (
    kind: "suspended-from",
    object: body.id,
    support: pulley.id,
    side: side,
    length: length,
  )
}
