// General attachment and named-anchor resolution for placed elements.

#import "../../shared/vector.typ"

#let split-anchor-reference(reference) = {
  let reference-parts = reference.split(".")
  assert(
    reference-parts.len() <= 2,
    message: "typed-physics: \"" + reference + "\" is not an attachment point; write \"name\" or \"name.anchor\"",
  )
  (
    element: reference-parts.first(),
    anchor: if reference-parts.len() == 2 { reference-parts.at(1) } else {
      auto
    },
  )
}

// The element an attachment reference names, or `none` when it names a bare
// coordinate. This is how a declaration that only says where something is can
// still be read as saying what it reaches.
#let attachment-element-name(attachment) = {
  if type(attachment) == dictionary {
    return attachment.at("on", default: none)
  }
  if type(attachment) != str { return none }
  split-anchor-reference(attachment).element
}

#let surface-anchor-positions(surface) = {
  let anchor-positions = (
    start: surface.start,
    end: surface.end,
    surface: surface.midpoint,
  )
  if surface.kind == "ramp" {
    anchor-positions += (
      foot: surface.foot,
      apex: surface.apex,
      base: surface.base-corner,
    )
  }
  anchor-positions
}

#let body-anchor-positions(body) = (
  center: body.center,
  contact: body.contact,
  top: (body.center.at(0), body.center.at(1) + body.half-extent-normal),
  bottom: (body.center.at(0), body.center.at(1) - body.half-extent-normal),
  left: (body.center.at(0) - body.half-extent-along, body.center.at(1)),
  right: (body.center.at(0) + body.half-extent-along, body.center.at(1)),
)

#let pulley-anchor-positions(placed-pulley) = (
  center: placed-pulley.center,
  top: (placed-pulley.center.at(0), placed-pulley.center.at(1) + placed-pulley.radius),
  bottom: (placed-pulley.center.at(0), placed-pulley.center.at(1) - placed-pulley.radius),
  left: (placed-pulley.center.at(0) - placed-pulley.radius, placed-pulley.center.at(1)),
  right: (placed-pulley.center.at(0) + placed-pulley.radius, placed-pulley.center.at(1)),
)

#let structure-anchor-positions(placed-structure) = {
  if placed-structure.kind == "rod" {
    return (
      start: placed-structure.start,
      end: placed-structure.end,
      center: placed-structure.center,
      center-of-mass: placed-structure.center-of-mass,
    )
  }
  if placed-structure.kind == "pendulum" {
    return (
      pivot: placed-structure.pivot,
      bob: placed-structure.bob,
      center: placed-structure.bob,
    )
  }
  (center: placed-structure.center,)
}

#let point-on-surface-at-ratio(surface, ratio-along-surface) = {
  if surface.kind != "arc" {
    return vector.point-along(
      surface.start,
      surface.direction,
      surface.length * (ratio-along-surface / 100%),
    )
  }
  let position-angle = (
    surface.start-angle
      + surface.sweep-angle * (ratio-along-surface / 100%)
  )
  vector.point-along(
    surface.center,
    vector.direction-from-angle(position-angle),
    surface.radius,
  )
}

// Resolves an attachment point against whatever has been placed so far. The
// `declared-by` name only ever appears in error messages, so an unresolvable
// attachment says which element asked for it.
#let resolve-attachment-point(
  attachment,
  placed-surfaces,
  placed-bodies,
  placed-pulleys,
  declared-by,
  placed-structures: (:),
) = {
  if type(attachment) == dictionary {
    let attached-element-name = attachment.at("on")
    let ratio-along-element = attachment.at("at", default: 50%)
    if attached-element-name in placed-structures {
      let placed-structure = placed-structures.at(attached-element-name)
      assert(
        placed-structure.kind == "rod",
        message: "typed-physics: " + declared-by + " can use (on:, at:) only along a surface or rod",
      )
      return vector.point-along(
        placed-structure.start,
        placed-structure.direction,
        placed-structure.length * (ratio-along-element / 100%),
      )
    }
    assert(
      attached-element-name in placed-surfaces,
      message: "typed-physics: " + declared-by + " attaches to \"" + attached-element-name + "\", which is not a surface or rod declared before it",
    )
    let surface = placed-surfaces.at(attached-element-name)
    return point-on-surface-at-ratio(surface, ratio-along-element)
  }

  assert(
    type(attachment) == str,
    message: "typed-physics: " + declared-by + " needs an attachment point such as \"ceiling\" or (on: \"ceiling\", at: 40%)",
  )
  let (element, anchor) = split-anchor-reference(attachment)

  let anchor-positions = if element in placed-surfaces {
    surface-anchor-positions(placed-surfaces.at(element))
  } else if element in placed-pulleys {
    pulley-anchor-positions(placed-pulleys.at(element))
  } else if element in placed-bodies {
    body-anchor-positions(placed-bodies.at(element))
  } else if element in placed-structures {
    structure-anchor-positions(placed-structures.at(element))
  } else {
    panic(
      "typed-physics: "
        + declared-by
        + " attaches to \""
        + element
        + "\", which is not an element declared before it",
    )
  }

  let default-anchor = if element in placed-surfaces { "surface" } else {
    "center"
  }
  let requested-anchor = if anchor == auto { default-anchor } else { anchor }
  assert(
    requested-anchor in anchor-positions,
    message: (
      "typed-physics: \""
        + element
        + "\" has no anchor called \""
        + requested-anchor
        + "\"; it has "
        + anchor-positions.keys().join(", ")
    ),
  )
  anchor-positions.at(requested-anchor)
}

// ── Surfaces ─────────────────────────────────────────────────────────────────
