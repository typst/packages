/// Construct an error message for invalid parameters.
#let invalid(name, expected, provided) = {
  let repr = el => {
    if type(el) == type { repr(el) }
    else { "`" + repr(el) + "`" }
  }

  let invalid-type = false
  let expected = if type(expected) == array {
    invalid-type = type(expected.at(0, default: none)) == type
    expected.map(repr).join(", ", last: " or ")
  } else {
    invalid-type = type(expected) == type
    repr(expected)
  }

  if " " not in name { name = "`" + name + "`" }

  "invalid " + name + ": "
  "expected " + expected + ", "
  "got " + if invalid-type { repr(type(provided)) } else { repr(provided) }
}

/// Validate the `side` parameter of the `sidenote` function.
#let validate-side(side) = {
  let expected = (
    "outside", "inside", "start", "end", "left", "right", start, end, left, right, auto
  )
  assert(side in expected, message: invalid("side", expected, side))
}

/// Validate the `dy` parameter of the `sidenote` function.
#let validate-dy(dy) = {
  let expected = (length, ratio, relative)
  assert(type(dy) in expected, message: invalid("dy", expected, dy))
}

/// Validate the `padding` parameter of the `sidenote` function.
#let validate-padding(padding) = {
  let expected = (length, dictionary)
  assert(type(padding) in expected, message: invalid("padding", expected, padding))

  if type(padding) == dictionary {
    let uses-inside-outside = "inside" in padding or "outside" in padding
    let uses-start-end = "start" in padding or "end" in padding
    let uses-left-right = "left" in padding or "right" in padding
    assert(
      int(uses-inside-outside) + int(uses-start-end) + int(uses-left-right) == 1,
      message: {
        "invalid `padding`: "
        "either use `start`/`end`, `left`/`right` or `inside`/`outside`"
      }
    )
    for key in padding.keys() {
      let expected = ("inside", "outside", "start", "end", "left", "right")
      assert(
        key in expected,
        message: invalid("`padding` key", expected, key)
      )
    }
    for el in padding.values() {
      assert(type(el) == length, message: invalid("padding", length, el))
    }
  }
}

/// Validate the `gap` parameter of the `sidenote` function.
#let validate-gap(gap) = {
  let expected = (length, type(none))
  assert(type(gap) in expected, message: invalid("gap", expected, gap))
}

/// Validate the `numbering` parameter of the `sidenote` function.
#let validate-numbering(numbering) = {
  let expected = (str, function, type(none))
  assert(
    type(numbering) in expected,
    message: invalid("numbering", expected, numbering)
  )
}

/// Validate the `counter` parameter of the `sidenote` function.
#let validate-counter(counter_) = {
  assert(
    type(counter_) == counter,
    message: invalid("counter", counter, counter_)
  )
}

/// Validate the `format` parameter of the `sidenote` function.
#let validate-format(format) = {
  assert(type(format) == function, message: invalid("format", function, format))
}

/// Validate all parameters of the `sidenote` function.
#let validate(..parameters) = {
  parameters = parameters.named()

  // Check for required parameters.
  let expected = (
    "side", "dy", "padding", "gap", "numbering", "counter", "format", "body"
  )
  for key in expected {
    assert(key in parameters, message: "missing parameter: " + key)
  }
  for key in parameters.keys() {
    assert(key in expected, message: "unexpected parameter: " + key)
  }

  // Validate parameters.
  validate-side(parameters.side)
  validate-dy(parameters.dy)
  validate-padding(parameters.padding)
  validate-gap(parameters.gap)
  validate-numbering(parameters.numbering)
  validate-counter(parameters.counter)
  validate-format(parameters.format)
}
