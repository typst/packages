// Dependency-leaf parsing and evaluation for incremental ranges and states.
#import "../shared.typ": fail

#let states = ("visible", "hidden", "dimmed", "removed")

#let validate-state(value, name) = {
  if value not in states {
    fail(
      name + " must be one of "
        + states.map(repr).join(", ")
        + ", received " + repr(value),
    )
  }
  value
}

#let validate-states(before, after) = (
  validate-state(before, "before"),
  validate-state(after, "after"),
)

// `name` names the value quoted in diagnostics when it differs from `value`,
// as it does for one endpoint of a parsed range.
#let validate-positive-int(value, name: none) = {
  let name = if name == none { value } else { name }
  let parsed = if type(value) == int {
    value
  } else {
    if type(value) != str or value.match(regex("^\\d+$")) == none {
      fail("invalid step range " + repr(name))
    }
    int(value)
  }
  if parsed < 1 {
    fail("step numbers must be positive, received " + repr(name))
  }
  parsed
}

#let validate-range(value) = {
  if type(value) == int {
    let step = validate-positive-int(value)
    return (start: step, end: step)
  }
  if type(value) != str {
    fail(
      "step range must be an integer or a string such as "
        + "\"2-\", \"-2\", or \"2-4\", received " + repr(value),
    )
  }
  let source = value.trim()
  if source == "" {
    fail("step range must not be empty")
  }
  let parts = source.split("-")
  if parts.len() == 1 {
    let step = validate-positive-int(parts.first(), name: value)
    return (start: step, end: step)
  }
  if parts.len() != 2 or (parts.first() == "" and parts.last() == "") {
    fail("invalid step range " + repr(value))
  }
  let start = if parts.first() == "" {
    1
  } else {
    validate-positive-int(parts.first(), name: value)
  }
  let end = if parts.last() == "" {
    none
  } else {
    validate-positive-int(parts.last(), name: value)
  }
  if end != none and start > end {
    fail("step range starts after it ends: " + repr(value))
  }
  (start: start, end: end)
}

#let range-last(range) = {
  let parsed = validate-range(range)
  if parsed.end == none { parsed.start } else { parsed.end }
}

#let status(range, before, after, step) = {
  let (start, end) = validate-range(range)
  if step < start {
    before
  } else if end != none and step > end {
    after
  } else {
    "visible"
  }
}
