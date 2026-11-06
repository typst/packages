// Validation for diagram and element style dictionaries.

#import "validation-core.typ" as core

#let _value = core.value-representation
#let _stroke-type = type(1pt + black)
#let fail = core.fail
#let validate-positive-number = core.validate-positive-number

#let validate-style-dictionary(style, source-description) = {
  assert(
    type(style) == dictionary,
    message: (
      "typed-physics: "
        + source-description
        + " needs `style:` as a dictionary, got "
        + _value(style)
        + "; pass `style: (:)` or a style builder"
    ),
  )
  none
}

#let validate-paint(value, source-description, argument, allow-none: false) = {
  let paint-type = repr(type(value))
  let is-valid = (
    paint-type in ("color", "gradient", "pattern")
      or (allow-none and value == none)
  )
  if not is-valid {
    fail(
      source-description,
      argument,
      value,
      "expected a color, gradient, or pattern" + if allow-none { ", or none" } else { "" },
      "pass a Typst paint value such as rgb(\"#336699\")",
    )
  }
  none
}

#let validate-stroke(value, source-description, argument, allow-none: true) = {
  let value-type = type(value)
  let is-valid = (
    value-type in (length, color, dictionary, _stroke-type)
      or (allow-none and value == none)
  )
  if not is-valid {
    fail(
      source-description,
      argument,
      value,
      "expected a Typst stroke, length, color, or stroke dictionary",
      "pass a value such as `0.8pt + black`",
    )
  }
  if value-type == dictionary {
    let allowed-stroke-fields = (
      "paint", "thickness", "dash", "cap", "join", "miter-limit",
    )
    for field in value.keys() {
      assert(
        field in allowed-stroke-fields,
        message: (
          "typed-physics: "
            + source-description
            + " `"
            + argument
            + ":` stroke has unknown field \""
            + field
            + "\"; accepted fields are "
            + allowed-stroke-fields.join(", ")
        ),
      )
    }
    if "thickness" in value {
      assert(
        type(value.thickness) == length and value.thickness >= 0pt,
        message: "typed-physics: " + source-description + " `" + argument + ":` stroke thickness must be a non-negative length",
      )
    }
    if "paint" in value {
      validate-paint(
        value.paint,
        source-description + " " + argument + " stroke",
        "paint",
      )
    }
  }
  none
}

#let validate-element-style(style, allowed-keys, source-description) = {
  validate-style-dictionary(style, source-description)
  for key in style.keys() {
    assert(
      key in allowed-keys,
      message: (
        "typed-physics: "
          + source-description
          + " has unknown style key \""
          + key
          + "\"; accepted keys are "
          + allowed-keys.join(", ")
      ),
    )
  }
  for numeric-key in ("hatch-spacing", "hatch-length", "length") {
    if numeric-key in style {
      validate-positive-number(
        style.at(numeric-key),
        source-description + " style",
        numeric-key,
      )
    }
  }
  for text-key in ("label-text", "text") {
    if text-key in style {
      assert(
        type(style.at(text-key)) == dictionary,
        message: "typed-physics: " + source-description + " style `" + text-key + ":` must be a text-style dictionary",
      )
    }
  }
  for paint-key in ("fill", "color") {
    if paint-key in style {
      validate-paint(
        style.at(paint-key),
        source-description + " style",
        paint-key,
        allow-none: paint-key == "fill",
      )
    }
  }
  for stroke-key in ("stroke", "hatch-stroke") {
    if stroke-key in style {
      validate-stroke(
        style.at(stroke-key),
        source-description + " style",
        stroke-key,
      )
    }
  }
  none
}

// ── Situation schemas and references ────────────────────────────────────────
