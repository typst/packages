// Editor-visible package diagnostics and primitive public-input validation.

// ---------------------------------------------------------------------------
// Diagnostics
// ---------------------------------------------------------------------------

#let _score-error(
  location,
  problem,
  value: auto,
  expected: none,
  fix: none,
) = {
  let message = "typed-scores error in " + location + ": " + problem
  if value != auto {
    message += "; got " + repr(value)
  }
  if expected != none {
    message += "; expected " + expected
  }
  if fix != none {
    message += "; fix: " + fix
  }
  panic(message)
}

// ---------------------------------------------------------------------------
// Primitive public-input validators
// ---------------------------------------------------------------------------

#let _required-string(value, label) = {
  if type(value) != str {
    _score-error(
      label,
      "value must be a string",
      value: value,
      expected: "quoted text",
      fix: "replace the value with a string",
    )
  }
  value
}

#let _required-nonempty-string(value, label) = {
  let validated = _required-string(value, label)
  if validated.trim() == "" {
    _score-error(
      label,
      "string must contain at least one musical token",
      value: value,
      expected: "a note, chord, rest, group, or automatic-rest token",
      fix: "add the intended event or remove the empty voice",
    )
  }
  validated
}

#let _positive-number(value, label, optional: false) = {
  if optional and value == none { return }
  if (
    type(value) not in (int, float)
      or value != value
      or value in (float.inf, -float.inf)
      or value <= 0
  ) {
    _score-error(
      label,
      "value must be a positive number",
      value: value,
      expected: "an integer or float greater than zero",
      fix: "use a positive staff-space value",
    )
  }
}

#let _nonnegative-number(value, label) = {
  if (
    type(value) not in (int, float)
      or value != value
      or value in (float.inf, -float.inf)
      or value < 0
  ) {
    _score-error(
      label,
      "value must be a non-negative number",
      value: value,
      expected: "an integer or float greater than or equal to zero",
      fix: "use zero or a positive staff-space value",
    )
  }
}


#let _validate-marking(value, label, optional: true) = {
  if optional and value == none { return value }
  if type(value) not in (str, content) {
    _score-error(
      label,
      "value must be text or content",
      value: value,
      expected: "a string, content value, or none",
      fix: "quote plain text or wrap styled material as Typst content",
    )
  }
  if type(value) == str and value.trim() == "" {
    _score-error(
      label,
      "text must not be empty",
      value: value,
      fix: "provide visible text or remove the argument",
    )
  }
  value
}

#let _validate-system-gap(value) = {
  if type(value) != length {
    _score-error(
      "score system-gap",
      "value must be a non-negative length",
      value: value,
      expected: "a Typst length such as 1.2em or 12pt",
      fix: "add a length unit and use zero or a positive value",
    )
  }
  if (
    value != value
      or value in (float.inf * 1pt, -float.inf * 1pt)
      or value < 0pt
  ) {
    _score-error(
      "score system-gap",
      "value must be a finite non-negative length",
      value: value,
      expected: "a finite length greater than or equal to zero",
      fix: "replace the value with a normal length such as 1.2em or 12pt",
    )
  }
}
