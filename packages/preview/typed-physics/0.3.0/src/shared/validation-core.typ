// Shared validation and diagnostics for every public boundary.
//
// Constructors validate values that are meaningful in isolation. Situation
// validation then checks declaration schemas, names, references, ordering, and
// cross-element compatibility before placement turns anything into geometry.

#let _value(value) = repr(value)
#let value-representation(value) = _value(value)
#let _stroke-type = type(1pt + black)

#let _is-finite-number(value) = {
  if type(value) == int { return true }
  (
    type(value) == float
      and value == value
      and value != float.inf
      and value != -float.inf
  )
}

#let fail(source-description, argument, value, requirement, correction) = {
  panic(
    "typed-physics: "
      + source-description
      + " has invalid `"
      + argument
      + ":` "
      + _value(value)
      + "; "
      + requirement
      + ". "
      + correction,
  )
}

#let validate-name(name, source-description: "element") = {
  assert(
    type(name) == str and name.len() > 0,
    message: (
      "typed-physics: "
        + source-description
        + " needs a non-empty string name, got "
        + _value(name)
        + "; use a name such as \"A\" or \"incline\""
    ),
  )
  assert(
    not name.contains("."),
    message: (
      "typed-physics: "
        + source-description
        + " name "
        + _value(name)
        + " cannot contain \".\" because dots select anchors; use a name such as \""
        + name.replace(".", "-")
        + "\""
    ),
  )
  none
}

#let validate-enum(value, accepted, source-description, argument) = {
  if value not in accepted {
    fail(
      source-description,
      argument,
      value,
      "accepted values are " + accepted.map(repr).join(", "),
      "choose one of those values",
    )
  }
  none
}

#let validate-boolean(value, source-description, argument, allow-auto: false) = {
  let is-valid = type(value) == bool or (allow-auto and value == auto)
  if not is-valid {
    fail(
      source-description,
      argument,
      value,
      if allow-auto { "expected true, false, or auto" } else {
        "expected true or false"
      },
      "pass an explicit boolean" + if allow-auto { " or auto" } else { "" },
    )
  }
  none
}

#let validate-angle(value, source-description, argument, allow-auto: false) = {
  let is-valid = type(value) == std.angle or (allow-auto and value == auto)
  if not is-valid {
    fail(
      source-description,
      argument,
      value,
      if allow-auto { "expected an angle or auto" } else {
        "expected an angle such as 30deg"
      },
      "pass " + if allow-auto { "auto or " } else { "" } + "a value with an angle unit",
    )
  }
  none
}

#let validate-positive-number(value, source-description, argument) = {
  if not _is-finite-number(value) or value <= 0 {
    fail(
      source-description,
      argument,
      value,
      "expected a positive number greater than zero",
      "pass a positive numeric value",
    )
  }
  none
}

#let validate-nonnegative-number(value, source-description, argument) = {
  if not _is-finite-number(value) or value < 0 {
    fail(
      source-description,
      argument,
      value,
      "expected a non-negative number",
      "pass zero or a positive numeric value",
    )
  }
  none
}

#let validate-positive-integer(value, source-description, argument) = {
  if type(value) != int or value < 1 {
    fail(
      source-description,
      argument,
      value,
      "expected a positive integer",
      "pass a whole number of at least 1",
    )
  }
  none
}

#let validate-ratio(value, source-description, argument, allow-endpoints: true) = {
  if type(value) != ratio {
    fail(
      source-description,
      argument,
      value,
      "expected a ratio between 0% and 100%",
      "pass a percentage such as 50%",
    )
  }
  let lower-bound-is-valid = if allow-endpoints { value >= 0% } else {
    value > 0%
  }
  let upper-bound-is-valid = if allow-endpoints { value <= 100% } else {
    value < 100%
  }
  if not lower-bound-is-valid or not upper-bound-is-valid {
    fail(
      source-description,
      argument,
      value,
      (
        "expected a ratio between "
          + if allow-endpoints { "0% and 100%, inclusive" } else {
            "0% and 100%, exclusive"
          }
      ),
      "pass a percentage such as 50%",
    )
  }
  none
}

// Numeric physical quantities must be positive. Content is deliberately
// accepted as a symbolic value and `none` remains valid where the quantity is
// optional.
#let validate-physical-scalar(
  value,
  source-description,
  argument,
  allow-none: false,
  allow-zero: false,
) = {
  if value == none and allow-none { return none }
  let value-is-symbolic = type(value) == content
  let value-is-number = _is-finite-number(value)
  let numeric-value-is-valid = (
    value-is-number and if allow-zero { value >= 0 } else { value > 0 }
  )
  if not value-is-symbolic and not numeric-value-is-valid {
    fail(
      source-description,
      argument,
      value,
      (
        "expected "
          + if allow-none { "none, " } else { "" }
          + if allow-zero { "a non-negative number" } else {
            "a positive number"
          }
          + ", or symbolic content such as $m$"
      ),
      "pass a physically meaningful number or a Typst math symbol",
    )
  }
  none
}
