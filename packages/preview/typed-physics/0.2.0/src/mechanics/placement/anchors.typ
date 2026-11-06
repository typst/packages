// General attachment and named-anchor resolution for placed elements.
//
// An attachment names an element, optionally one of its anchors, optionally a
// ratio along that anchor when the anchor is a span rather than a single point,
// and optionally a displacement away from the point that results. Every form
// resolves here, so one spelling means the same thing wherever it is written.

#import "../../shared/vector.typ"

// ── Anchors that are points, and anchors that are spans ──────────────────────

// A span is a line or an arc that `at:` can run along. Keeping it as data
// rather than as a closure lets an unresolvable reference name what it found.
#let segment-span(span-start, span-end) = (
  kind: "segment",
  start: span-start,
  end: span-end,
)

#let arc-span(center, radius, start-angle, sweep-angle) = (
  kind: "arc",
  center: center,
  radius: radius,
  start-angle: start-angle,
  sweep-angle: sweep-angle,
)

#let point-along-span(span, ratio-along-span) = {
  if span.kind == "segment" {
    return vector.lerp(span.start, span.end, ratio-along-span / 100%)
  }
  vector.point-along(
    span.center,
    vector.direction-from-angle(
      span.start-angle + span.sweep-angle * (ratio-along-span / 100%),
    ),
    span.radius,
  )
}

#let point-anchor(position) = (position: position, span: none)

// A span's own position is its midpoint, so an anchor reads the same whether or
// not the author goes on to take a ratio along it.
#let span-anchor(span) = (position: point-along-span(span, 50%), span: span)

#let surface-span(surface) = if surface.kind == "arc" {
  arc-span(
    surface.center,
    surface.radius,
    surface.start-angle,
    surface.sweep-angle,
  )
} else {
  segment-span(surface.start, surface.end)
}

// ── Anchor vocabularies ──────────────────────────────────────────────────────

#let surface-anchors(surface) = {
  let anchors = (
    start: point-anchor(surface.start),
    end: point-anchor(surface.end),
    surface: span-anchor(surface-span(surface)),
  )
  if surface.kind == "ramp" {
    anchors += (
      foot: point-anchor(surface.foot),
      apex: point-anchor(surface.apex),
      base: point-anchor(surface.base-corner),
    )
  }
  anchors
}

#let body-corners(body) = {
  let half-tangent-span = vector.scale(body.direction, body.half-extent-along)
  let half-normal-span = vector.scale(
    body.outward-normal,
    body.half-extent-normal,
  )
  (
    vector.subtract(
      vector.subtract(body.center, half-tangent-span),
      half-normal-span,
    ),
    vector.subtract(
      vector.add(body.center, half-tangent-span),
      half-normal-span,
    ),
    vector.add(
      vector.add(body.center, half-tangent-span),
      half-normal-span,
    ),
    vector.add(
      vector.subtract(body.center, half-tangent-span),
      half-normal-span,
    ),
  )
}

// The upright box a body occupies. Naming a body's side or corner means the
// side or corner a reader sees, so those anchors are measured on world axes
// even when the body itself is tilted, and a round body reports the box that
// encloses it.
#let body-bounding-box(body) = {
  let extreme-points = if body.shape == "block" {
    body-corners(body)
  } else {
    (
      vector.subtract(
        body.center,
        (body.half-extent-along, body.half-extent-normal),
      ),
      vector.add(body.center, (body.half-extent-along, body.half-extent-normal)),
    )
  }
  let horizontal-positions = extreme-points.map(point => point.at(0))
  let vertical-positions = extreme-points.map(point => point.at(1))
  (
    left: calc.min(..horizontal-positions),
    right: calc.max(..horizontal-positions),
    bottom: calc.min(..vertical-positions),
    top: calc.max(..vertical-positions),
  )
}

// The faces a body presents in the frame it was placed in, which is what a
// rope tied to its uphill side means on a slope where "left" and "right" no
// longer describe the same thing. A round body meets each of them at one point.
#let _body-frame-anchors(body) = {
  let face-center(along-tangent, along-normal) = vector.add(
    body.center,
    vector.add(
      vector.scale(body.direction, along-tangent * body.half-extent-along),
      vector.scale(body.outward-normal, along-normal * body.half-extent-normal),
    ),
  )
  if body.shape != "block" {
    return (
      uphill: point-anchor(face-center(1, 0)),
      downhill: point-anchor(face-center(-1, 0)),
      outward: point-anchor(face-center(0, 1)),
    )
  }
  let (contact-downhill, contact-uphill, outward-uphill, outward-downhill) = (
    body-corners(body)
  )
  (
    // Each face runs from the corner nearest the contact surface, and the
    // outward face from its downhill end, so a ratio along one reads the same
    // whichever way the slope climbs.
    uphill: span-anchor(segment-span(contact-uphill, outward-uphill)),
    downhill: span-anchor(segment-span(contact-downhill, outward-downhill)),
    outward: span-anchor(segment-span(outward-downhill, outward-uphill)),
  )
}

#let body-anchors(body) = {
  let box = body-bounding-box(body)
  let bottom-left = (box.left, box.bottom)
  let bottom-right = (box.right, box.bottom)
  let top-left = (box.left, box.top)
  let top-right = (box.right, box.top)
  (
    center: point-anchor(body.center),
    contact: point-anchor(body.contact),
    top: span-anchor(segment-span(top-left, top-right)),
    bottom: span-anchor(segment-span(bottom-left, bottom-right)),
    left: span-anchor(segment-span(bottom-left, top-left)),
    right: span-anchor(segment-span(bottom-right, top-right)),
    "top-left": point-anchor(top-left),
    "top-right": point-anchor(top-right),
    "bottom-left": point-anchor(bottom-left),
    "bottom-right": point-anchor(bottom-right),
  ) + _body-frame-anchors(body)
}

#let pulley-anchors(placed-pulley) = {
  let center = placed-pulley.center
  let radius = placed-pulley.radius
  (
    center: point-anchor(center),
    top: point-anchor((center.at(0), center.at(1) + radius)),
    bottom: point-anchor((center.at(0), center.at(1) - radius)),
    left: point-anchor((center.at(0) - radius, center.at(1))),
    right: point-anchor((center.at(0) + radius, center.at(1))),
    rim: span-anchor(arc-span(center, radius, 0deg, 360deg)),
  )
}

#let structure-anchors(placed-structure) = {
  if placed-structure.kind == "rod" {
    return (
      start: point-anchor(placed-structure.start),
      end: point-anchor(placed-structure.end),
      center: point-anchor(placed-structure.center),
      "center-of-mass": point-anchor(placed-structure.center-of-mass),
      rod: span-anchor(
        segment-span(placed-structure.start, placed-structure.end),
      ),
    )
  }
  if placed-structure.kind == "pendulum" {
    return (
      pivot: point-anchor(placed-structure.pivot),
      bob: point-anchor(placed-structure.bob),
      center: point-anchor(placed-structure.bob),
      string: span-anchor(
        segment-span(placed-structure.pivot, placed-structure.bob),
      ),
    )
  }
  (center: point-anchor(placed-structure.center),)
}

// A connector is placed after everything it spans, so only a view resolves
// against one. Its span is the line a reader sees between its ends.
#let connector-anchors(placed-connector) = (
  start: point-anchor(placed-connector.start),
  end: point-anchor(placed-connector.end),
  center: point-anchor(
    vector.midpoint(placed-connector.start, placed-connector.end),
  ),
  line: span-anchor(segment-span(placed-connector.start, placed-connector.end)),
)

// Which anchor an attachment means when it names none, and which anchor an
// anchorless `at:` runs along.
#let default-anchor-name(element-category) = if element-category == "surface" {
  "surface"
} else {
  "center"
}

#let default-span-anchor-name(element-category) = if (
  element-category == "surface"
) {
  "surface"
} else if element-category == "rod" {
  "rod"
} else if element-category == "pendulum" {
  "string"
} else if element-category == "connector" {
  "line"
} else {
  none
}

// ── Reference syntax ─────────────────────────────────────────────────────────

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
    let attached-element = attachment.at("on", default: none)
    if type(attached-element) != str { return none }
    return split-anchor-reference(attached-element).element
  }
  if type(attachment) != str { return none }
  split-anchor-reference(attachment).element
}

// World units are centimetres, so a displacement written as a length converts
// to them and one written as a number is already in them.
#let offset-component-in-world-units(offset-component, declared-by) = {
  if type(offset-component) in (int, float) { return offset-component }
  assert(
    type(offset-component) == type(1pt),
    message: (
      "typed-physics: "
        + declared-by
        + " needs `offset:` as an (x, y) pair of numbers or absolute lengths, got "
        + repr(offset-component)
    ),
  )
  assert(
    offset-component.abs == offset-component,
    message: (
      "typed-physics: "
        + declared-by
        + " needs `offset:` in absolute lengths such as 3pt or 2mm; "
        + repr(offset-component)
        + " is relative to the font size"
    ),
  )
  offset-component.abs / 1cm
}

#let attachment-offset-in-world-units(attachment, declared-by) = {
  if type(attachment) != dictionary { return (0, 0) }
  let declared-offset = attachment.at("offset", default: (0, 0))
  assert(
    type(declared-offset) == array and declared-offset.len() == 2,
    message: (
      "typed-physics: "
        + declared-by
        + " needs `offset:` as an (x, y) pair, got "
        + repr(declared-offset)
    ),
  )
  declared-offset.map(
    offset-component => offset-component-in-world-units(
      offset-component,
      declared-by,
    ),
  )
}

// ── Resolution ───────────────────────────────────────────────────────────────

#let _span-anchor-names(anchors) = anchors.pairs().filter(
  anchor-entry => anchor-entry.at(1).span != none,
).map(anchor-entry => anchor-entry.at(0))

#let _describe-span-anchors(element, anchors) = {
  let names = _span-anchor-names(anchors)
  if names.len() == 0 {
    return "\"" + element + "\" has no anchor a ratio can run along"
  }
  (
    "anchors of \""
      + element
      + "\" that a ratio can run along are "
      + names.map(anchor-name => "\"" + element + "." + anchor-name + "\"").join(
        ", ",
      )
  )
}

#let _anchors-of-element(
  element-name,
  placed-surfaces,
  placed-bodies,
  placed-pulleys,
  placed-structures,
  placed-connectors,
) = {
  if element-name in placed-surfaces {
    return (
      category: "surface",
      anchors: surface-anchors(placed-surfaces.at(element-name)),
    )
  }
  if element-name in placed-pulleys {
    return (
      category: "pulley",
      anchors: pulley-anchors(placed-pulleys.at(element-name)),
    )
  }
  if element-name in placed-bodies {
    return (
      category: "body",
      anchors: body-anchors(placed-bodies.at(element-name)),
    )
  }
  if element-name in placed-structures {
    let placed-structure = placed-structures.at(element-name)
    return (
      category: placed-structure.kind,
      anchors: structure-anchors(placed-structure),
    )
  }
  let placed-connector = placed-connectors.find(
    connector => connector.name == element-name,
  )
  if placed-connector != none {
    return (
      category: "connector",
      anchors: connector-anchors(placed-connector),
    )
  }
  none
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
  placed-connectors: (),
) = {
  let reference-is-dictionary = type(attachment) == dictionary
  assert(
    reference-is-dictionary or type(attachment) == str,
    message: "typed-physics: " + declared-by + " needs an attachment point such as \"ceiling\" or (on: \"ceiling\", at: 40%)",
  )
  let reference = if reference-is-dictionary {
    attachment.at("on", default: none)
  } else {
    attachment
  }
  assert(
    type(reference) == str,
    message: (
      "typed-physics: "
        + declared-by
        + " needs `on:` as an element name such as \"ceiling\" or \"ceiling.start\", got "
        + repr(reference)
    ),
  )
  let (element, anchor) = split-anchor-reference(reference)
  let ratio-along-anchor = if reference-is-dictionary {
    attachment.at("at", default: none)
  } else {
    none
  }

  let element-anchors = _anchors-of-element(
    element,
    placed-surfaces,
    placed-bodies,
    placed-pulleys,
    placed-structures,
    placed-connectors,
  )
  assert(
    element-anchors != none,
    message: (
      "typed-physics: "
        + declared-by
        + " attaches to \""
        + element
        + "\", which is not an element declared before it"
    ),
  )
  let anchors = element-anchors.anchors

  // An anchorless `at:` runs along the element itself, which is a different
  // anchor from the one an anchorless reference resolves to for anything whose
  // own extent is what a ratio measures.
  let requested-anchor = if anchor != auto {
    anchor
  } else if ratio-along-anchor != none {
    let element-span-anchor = default-span-anchor-name(element-anchors.category)
    assert(
      element-span-anchor != none,
      message: (
        "typed-physics: "
          + declared-by
          + " cannot take an `at:` ratio along \""
          + element
          + "\" itself; "
          + _describe-span-anchors(element, anchors)
      ),
    )
    element-span-anchor
  } else {
    default-anchor-name(element-anchors.category)
  }

  assert(
    requested-anchor in anchors,
    message: (
      "typed-physics: \""
        + element
        + "\" has no anchor called \""
        + requested-anchor
        + "\"; it has "
        + anchors.keys().join(", ")
    ),
  )
  let resolved-anchor = anchors.at(requested-anchor)

  let anchor-position = if ratio-along-anchor == none {
    resolved-anchor.position
  } else {
    assert(
      resolved-anchor.span != none,
      message: (
        "typed-physics: "
          + declared-by
          + " takes an `at:` ratio along \""
          + element
          + "."
          + requested-anchor
          + "\", which is a single point; "
          + _describe-span-anchors(element, anchors)
      ),
    )
    point-along-span(resolved-anchor.span, ratio-along-anchor)
  }

  vector.add(
    anchor-position,
    attachment-offset-in-world-units(attachment, declared-by),
  )
}
