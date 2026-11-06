#import "@preview/cetz:0.5.2": draw as cetz-draw
#import cetz-draw: *
#import "projection.typ": project-face-content

#let _projection-target(value, required: true) = {
  if type(value) != str {
    assert(
      not required,
      message: "project must be a layer face anchor such as \"metal.front\"",
    )
    return none
  }
  let parts = value.split(".")
  let valid = (
    parts.len() == 2
      and parts.at(0) != ""
      and parts.at(1) in ("front", "back", "left", "right", "top", "bottom")
  )
  assert(
    valid or not required,
    message: "project must be a layer face anchor such as \"metal.front\"",
  )
  if not valid {
    return none
  }
  (layer: parts.at(0), face: parts.at(1))
}

#let _projection-from-coordinate(value) = {
  if type(value) == str {
    _projection-target(value, required: false)
  } else if type(value) == dictionary and "to" in value {
    _projection-from-coordinate(value.to)
  } else if (
    type(value) == dictionary
      and "name" in value
      and "anchor" in value
      and type(value.name) == str
      and type(value.anchor) == str
  ) {
    _projection-target(
      value.name + "." + value.anchor,
      required: false,
    )
  } else {
    none
  }
}

/// CeTZ's content function, with optional projection onto a semiconductor
/// layer face. Placement and projection remain independent: the first
/// coordinate is resolved by CeTZ, while `project` selects the local plane.
/// By default, a central layer-face placement such as `"metal.front"` also
/// supplies its projection plane.
#let content(
  ..args-style,
  project: auto,
  angle: 0deg,
  anchor: none,
  name: none,
) = {
  let args = args-style.pos()
  let projection = if project == auto {
    if args.len() > 0 {
      _projection-from-coordinate(args.first())
    } else {
      none
    }
  } else if project == none {
    none
  } else {
    _projection-target(project)
  }

  if projection == none {
    return cetz-draw.content(
      ..args-style,
      angle: angle,
      anchor: anchor,
      name: name,
    )
  }

  let style = args-style.named()
  assert(
    args.len() in (2, 3),
    message: "draw.content expects 2 or 3 positional arguments",
  )
  let placement = args.slice(0, args.len() - 1)
  let body = args.last()

  cetz-draw.get-ctx(ctx => {
    let state = ctx.shared-state.at("semi", default: none)
    assert(
      state != none,
      message: "projected draw.content must be used inside layer-stack",
    )
    assert(
      projection.layer in state.layers,
      message: "unknown projection layer: " + repr(projection.layer),
    )
    let body = project-face-content(
      body,
      state.camera,
      projection.face,
      anchor: anchor,
    )
    cetz-draw.content(
      ..placement,
      body,
      ..style,
      angle: angle,
      anchor: anchor,
      name: name,
    )
  })
}
