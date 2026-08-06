#import "../core/model.typ": id
#import "../geometry/lib.typ": magnitude as vector-magnitude

/// Construct a force attached to an object anchor.
#let force(
  force-id,
  object,
  direction,
  magnitude: 1.5,
  anchor: "center",
  label: none,
  label-position: 55%,
  label-offset: (0, 0.22),
  color: none,
) = {
  assert(magnitude > 0, message: "Force magnitude must be positive")
  assert(vector-magnitude(direction) > 0,
    message: "Force direction cannot be the zero vector")
  (
    kind: "force",
    id: id(force-id),
    object: object.id,
    direction: direction,
    magnitude: magnitude,
    anchor: anchor,
    label: label,
    label-position: label-position,
    label-offset: label-offset,
    color: color,
  )
}

/// Weight force directed vertically downwards.
#let weight(
  force-id,
  object,
  magnitude: 1.5,
  label: $P$,
  label-position: 55%,
  label-offset: (0, 0.22),
) = force(
  force-id,
  object,
  (0, -1),
  magnitude: magnitude,
  label: label,
  label-position: label-position,
  label-offset: label-offset,
)
