// Compatibility rules that depend on more than one declaration.

#import "../../shared/validation-core.typ" as core
#import "references.typ" as references

#let _value = core.value-representation
#let attachment-element-name = references.attachment-element-name

#let declared-body-support(body-declaration, declarations-by-name) = {
  if body-declaration.on != none { return body-declaration.on }
  if (
    body-declaration.touching == none
      or body-declaration.touching not in declarations-by-name
  ) {
    return none
  }
  let neighbouring-declaration = declarations-by-name.at(
    body-declaration.touching,
  )
  if neighbouring-declaration.kind != "body" { return none }
  declared-body-support(neighbouring-declaration, declarations-by-name)
}

#let validate-cross-element-compatibility(
  declaration,
  declarations-by-name,
) = {
  let kind = declaration.kind
  if kind == "body" and declaration.touching != none {
    let neighbouring-body = declarations-by-name.at(declaration.touching)
    let neighbouring-support = declared-body-support(
      neighbouring-body,
      declarations-by-name,
    )
    assert(
      neighbouring-support != none,
      message: (
        "typed-physics: body \""
          + declaration.name
          + "\" touches \""
          + declaration.touching
          + "\", which does not rest on a surface; choose a supported neighbouring body"
      ),
    )
    if declaration.on != none {
      assert(
        neighbouring-support != none and declaration.on == neighbouring-support,
        message: (
          "typed-physics: body \""
            + declaration.name
            + "\" says `on: \""
            + declaration.on
            + "\"` but touches \""
            + declaration.touching
            + "\", which rests on "
            + if neighbouring-support == none { "no surface" } else {
              "\"" + neighbouring-support + "\""
            }
            + "; use the same supporting surface or remove `on:`"
        ),
      )
    }
  }

  if (
    kind in ("ground", "ceiling", "ramp", "arc")
      and declaration.from != none
  ) {
    let source-surface = declarations-by-name.at(
      attachment-element-name(declaration.from),
    )
    // A wall without `from:` stands at the outer edge of the other surfaces,
    // so it is placed after them and cannot be the point another surface starts
    // from. The wall is left unattached and the other surface is written to
    // meet it at the corner.
    let corner-instruction = if kind == "ceiling" {
      "remove `from:` from \"" + declaration.name + "\" and give it a `height:` equal to the wall's `height:`, so the two meet at their tops"
    } else {
      "remove `from:` from \"" + declaration.name + "\" too, so both start at the origin"
    }
    assert(
      source-surface.kind != "wall",
      message: (
        "typed-physics: "
          + kind
          + " \""
          + declaration.name
          + "\" cannot continue `from:` wall \""
          + source-surface.name
          + "\", because walls are placed after the surfaces they stand beside. Declare \""
          + source-surface.name
          + "\" without `from:`, so it stands at the edge of the other surfaces, and "
          + corner-instruction
      ),
    )
  }

  if kind in ("force", "torque") {
    let target = declarations-by-name.at(declaration.on)
    assert(
      target.kind == "body" or target.kind == "rod",
      message: (
        "typed-physics: "
          + kind
          + "() targets "
          + target.kind
          + " \""
          + declaration.on
          + "\", which cannot accept an applied "
          + kind
          + "; target a body or rod"
      ),
    )
    if target.kind == "body" {
      assert(
        declaration.at == auto,
        message: (
          "typed-physics: "
            + kind
            + "() on body \""
            + declaration.on
            + "\" has `at:` "
            + _value(declaration.at)
            + ", but body loads currently act at the center; use `at: auto` so the application point is not ignored"
        ),
      )
    } else if declaration.at != auto and type(declaration.at) != ratio {
      let application-element = attachment-element-name(declaration.at)
      assert(
        application-element == declaration.on,
        message: (
          "typed-physics: "
            + kind
            + "() on rod \""
            + declaration.on
            + "\" applies at "
            + _value(declaration.at)
            + ", which belongs to another element; use a ratio or an anchor on \""
            + declaration.on
            + "\""
        ),
      )
    }
  }
}
