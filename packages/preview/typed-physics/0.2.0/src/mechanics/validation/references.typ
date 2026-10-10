// Attachment syntax, anchor vocabulary, and placement dependencies.

#import "../../shared/validation-core.typ" as core
#import "schema.typ" as schema

#let _value = core.value-representation
#let fail = core.fail
#let validate-ratio = core.validate-ratio
#let _named-kind = schema.named-kind
#let _category-of-kind = schema.category-of-kind
#let _default-anchor = schema.default-anchor
#let _anchors-for-kind = schema.anchors-for-kind
#let _span-anchors-for-kind = schema.span-anchors-for-kind
#let _element-span-anchor = schema.element-span-anchor

#let validate-simple-reference(reference, source-description, argument) = {
  assert(
    type(reference) == str and reference.len() > 0 and not reference.contains("."),
    message: (
      "typed-physics: "
        + source-description
        + " needs `"
        + argument
        + ":` as an element name such as \"A\", got "
        + _value(reference)
        + "; do not include an anchor in this argument"
    ),
  )
  none
}

#let validate-anchored-reference(reference, source-description, argument) = {
  assert(
    type(reference) == str,
    message: (
      "typed-physics: "
        + source-description
        + " needs `"
        + argument
        + ":` as an element name such as \"A\" or \"A.top\", got "
        + _value(reference)
    ),
  )
  let parts = reference.split(".")
  assert(
    parts.len() <= 2 and parts.all(part => part.len() > 0),
    message: (
      "typed-physics: "
        + source-description
        + " has malformed `"
        + argument
        + ":` "
        + _value(reference)
        + "; write \"name\" or \"name.anchor\", for example \"beam.end\""
    ),
  )
  none
}

// A displacement is written in world units as a number, or as an absolute
// length that converts to them.
#let validate-offset(declared-offset, source-description, argument) = {
  assert(
    type(declared-offset) == array and declared-offset.len() == 2,
    message: (
      "typed-physics: "
        + source-description
        + " needs `"
        + argument
        + ":` as an (x, y) pair, got "
        + _value(declared-offset)
    ),
  )
  for offset-component in declared-offset {
    assert(
      type(offset-component) in (int, float)
        or type(offset-component) == type(1pt),
      message: (
        "typed-physics: "
          + source-description
          + " needs `"
          + argument
          + ":` components as numbers in world units or absolute lengths, got "
          + _value(offset-component)
      ),
    )
    if type(offset-component) == type(1pt) {
      assert(
        offset-component.abs == offset-component,
        message: (
          "typed-physics: "
            + source-description
            + " needs `"
            + argument
            + ":` in absolute lengths such as 3pt or 2mm; "
            + _value(offset-component)
            + " is relative to the font size"
        ),
      )
    }
  }
  none
}

#let validate-attachment(
  attachment,
  source-description,
  argument,
  allow-none: false,
  allow-auto: false,
  allow-coordinate: false,
  allow-ratio: false,
) = {
  if attachment == none and allow-none { return none }
  if attachment == auto and allow-auto { return none }
  if type(attachment) == ratio and allow-ratio {
    validate-ratio(attachment, source-description, argument)
    return none
  }
  if (
    allow-coordinate
      and type(attachment) == array
      and attachment.len() == 2
      and attachment.all(coordinate => type(coordinate) in (int, float))
  ) {
    return none
  }
  if type(attachment) == str {
    let parts = attachment.split(".")
    assert(
      parts.len() <= 2 and parts.all(part => part.len() > 0),
      message: (
        "typed-physics: "
          + source-description
          + " has malformed `"
          + argument
          + ":` "
          + _value(attachment)
          + "; write \"name\" or \"name.anchor\", for example \"beam.end\""
      ),
    )
    return none
  }
  if type(attachment) == dictionary {
    for key in attachment.keys() {
      assert(
        key in ("on", "at", "offset"),
        message: (
          "typed-physics: "
            + source-description
            + " has unknown `"
            + argument
            + ":` reference field \""
            + key
            + "\"; a reference dictionary accepts `on:`, `at:`, and `offset:`"
        ),
      )
    }
    assert(
      "on" in attachment,
      message: (
        "typed-physics: "
          + source-description
          + " needs `"
          + argument
          + ":` reference "
          + _value(attachment)
          + " to include `on:` an element name"
      ),
    )
    validate-anchored-reference(
      attachment.on,
      source-description,
      argument + ".on",
    )
    if "at" in attachment {
      validate-ratio(attachment.at, source-description, argument + ".at")
    }
    if "offset" in attachment {
      validate-offset(
        attachment.offset,
        source-description,
        argument + ".offset",
      )
    }
    return none
  }
  fail(
    source-description,
    argument,
    attachment,
    (
      "expected \"name\", \"name.anchor\", or (on: \"name.anchor\", at: 50%, offset: (0, 0.2))"
        + if allow-coordinate { ", or an (x, y) numeric coordinate" } else { "" }
        + if allow-ratio { ", or a ratio between 0% and 100%" } else { "" }
        + if allow-auto { ", or auto" } else { "" }
        + if allow-none { ", or none" } else { "" }
    ),
    "use one of the supported attachment forms",
  )
}

#let _reference-string(attachment) = if type(attachment) == dictionary {
  attachment.on
} else {
  attachment
}

#let attachment-element-name(attachment) = {
  let reference = _reference-string(attachment)
  if type(reference) == str { return reference.split(".").first() }
  none
}

#let attachment-anchor-name(attachment) = {
  let reference = _reference-string(attachment)
  if type(reference) != str { return auto }
  let parts = reference.split(".")
  if parts.len() == 2 { parts.at(1) } else { auto }
}


#let reference-specifications(declaration) = {
  let kind = declaration.kind
  let source-description = if _named-kind(kind) {
    kind + " \"" + declaration.name + "\""
  } else {
    kind + "()"
  }
  let specifications = ()
  let declared-reference(
    argument,
    attachment,
    categories,
    ratio-categories: ("surface", "structure", "body", "pulley"),
  ) = {
    if attachment == none or attachment == auto { return () }
    ((
      argument: argument,
      attachment: attachment,
      categories: categories,
      ratio-categories: ratio-categories,
      source-description: source-description,
    ),)
  }
  if kind in ("ground", "wall", "ceiling", "ramp", "arc") {
    specifications += declared-reference(
      "from",
      declaration.from,
      ("surface",),
      ratio-categories: ("surface",),
    )
  } else if kind == "body" {
    specifications += declared-reference(
      "on",
      declaration.on,
      ("surface",),
      ratio-categories: (),
    )
    specifications += declared-reference(
      "touching",
      declaration.touching,
      ("body",),
      ratio-categories: (),
    )
    specifications += declared-reference(
      "hanging",
      declaration.hanging,
      ("surface", "body", "pulley"),
    )
  } else if kind == "rod" {
    specifications += declared-reference(
      "from",
      declaration.from,
      ("surface", "body", "pulley", "structure"),
    )
    specifications += declared-reference(
      "to",
      declaration.to,
      ("surface", "body", "pulley", "structure"),
    )
  } else if kind in ("pivot", "support", "pendulum") {
    specifications += declared-reference(
      if kind == "pendulum" { "from" } else { "at" },
      if kind == "pendulum" { declaration.from } else { declaration.at },
      ("surface", "body", "pulley", "structure"),
    )
  } else if kind == "pulley" {
    specifications += declared-reference(
      "at",
      declaration.at,
      ("surface", "pulley"),
    )
  } else if kind in ("rope", "spring") {
    specifications += declared-reference(
      "from",
      declaration.from,
      ("surface", "body", "pulley", "structure"),
    )
    specifications += declared-reference(
      "to",
      declaration.to,
      ("surface", "body", "pulley", "structure"),
    )
    if kind == "rope" {
      specifications += declared-reference(
        "over",
        declaration.over,
        ("pulley",),
        ratio-categories: (),
      )
    }
  } else if kind in ("force", "torque", "velocity", "angular-velocity") {
    specifications += declared-reference(
      "on",
      declaration.on,
      if kind in ("force", "torque") { ("body", "structure") } else {
        ("body",)
      },
      ratio-categories: (),
    )
  }
  specifications
}

#let validate-reference(
  specification,
  declaration-index,
  declarations-by-name,
  declaration-index-by-name,
) = {
  let attachment = specification.attachment
  let target-name = attachment-element-name(attachment)
  assert(
    target-name in declarations-by-name,
    message: (
      "typed-physics: "
        + specification.source-description
        + " has `"
        + specification.argument
        + ":` "
        + _value(attachment)
        + ", but there is no element called \""
        + target-name
        + "\"; available names are "
        + declarations-by-name.keys().sorted().join(", ")
    ),
  )
  let target = declarations-by-name.at(target-name)
  let target-category = _category-of-kind(target.kind)
  assert(
    target-category in specification.categories,
    message: (
      "typed-physics: "
        + specification.source-description
        + " has `"
        + specification.argument
        + ":` "
        + _value(attachment)
        + ", but \""
        + target-name
        + "\" is a "
        + target-category
        + "; compatible element types are "
        + specification.categories.join(", ")
    ),
  )
  let declared-anchor = attachment-anchor-name(attachment)
  if declared-anchor != auto {
    let available-anchors = _anchors-for-kind(target.kind)
    assert(
      declared-anchor in available-anchors,
      message: (
        "typed-physics: "
          + specification.source-description
          + " references unavailable anchor \""
          + target-name
          + "."
          + declared-anchor
          + "\"; "
          + target.kind
          + " \""
          + target-name
          + "\" has anchors "
          + available-anchors.join(", ")
      ),
    )
  }

  let takes-a-ratio = type(attachment) == dictionary and "at" in attachment
  if takes-a-ratio {
    assert(
      target-category in specification.ratio-categories,
      message: (
        "typed-physics: "
          + specification.source-description
          + " cannot use an `at:` ratio along "
          + target.kind
          + " \""
          + target-name
          + "\"; use a named anchor such as \""
          + target-name
          + "."
          + _anchors-for-kind(target.kind).first()
          + "\""
      ),
    )
    let ratio-anchor = if declared-anchor == auto {
      _element-span-anchor(target.kind)
    } else {
      declared-anchor
    }
    let span-anchors = _span-anchors-for-kind(target.kind)
    let available-spans = if span-anchors.len() == 0 {
      target.kind + " \"" + target-name + "\" has no anchor a ratio can run along"
    } else {
      (
        "anchors that a ratio can run along are "
          + span-anchors.map(
            anchor-name => "\"" + target-name + "." + anchor-name + "\"",
          ).join(", ")
      )
    }
    let named-anchor = if declared-anchor == auto { "" } else {
      "." + declared-anchor
    }
    assert(
      ratio-anchor in span-anchors,
      message: (
        "typed-physics: "
          + specification.source-description
          + " takes an `at:` ratio along \""
          + target-name
          + named-anchor
          + "\", which is a single point; "
          + available-spans
      ),
    )
  }
  assert(
    declaration-index-by-name.at(target-name) < declaration-index,
    message: (
      "typed-physics: "
        + specification.source-description
        + " references \""
        + target-name
        + "\" before it is available; move "
        + target.kind
        + " \""
        + target-name
        + "\" before this declaration"
    ),
  )
}

#let dependency-reaches(
  element-name,
  target-name,
  declarations-by-name,
  visited: (),
) = {
  if element-name == target-name { return true }
  if element-name in visited or element-name not in declarations-by-name {
    return false
  }
  let next-visited = visited + (element-name,)
  for specification in reference-specifications(
    declarations-by-name.at(element-name),
  ) {
    let dependency-name = attachment-element-name(specification.attachment)
    if dependency-reaches(
      dependency-name,
      target-name,
      declarations-by-name,
      visited: next-visited,
    ) {
      return true
    }
  }
  false
}
