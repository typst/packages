#import "util.typ": attach-label, space, splittable

// Joins the given children into a single content.
//
// If the children list is empty, an empty content is returned instead of none.
#let join(children) = {
  if children.len() == 0 {
    []
  } else {
    children.join()
  }
}

// Gets the number of breakpoints in the given content.
//
// A breakpoints must always be at a space. For example, the sequece
//   ([Hello], [ ], [my world!])
// has two inner breakpoints:
//  1. ([Hello],) - ([my world!],) - (sep: [ ])
//  2. ([Hello my],) - ([world!],) - (sep: " ")
//
// Returns: The number of breakpoints.
#let breakpoints(body) = {
  if type(body) == str {
    body.split(" ").len() - 1
  } else if body.has("text") {
    breakpoints(body.text)
  } else if body.has("child") {
    breakpoints(body.child)
  } else if body.has("children") {
    body.children.map(breakpoints).sum(default: 0)
  } else if body.func() in splittable {
    breakpoints(body.body)
  } else if body.func() in (space, linebreak, parbreak) {
    1
  } else {
    0
  }
}

// Splits the given content at a given breakpoint index.
//
// Content is split at spaces. A sequence can be split at any of its childrens'
// breakpoints (spaces), but in general not between children.
//
// Returns: A tuple of the first and second part.
#let split(body, index) = {
  // Shortcut for out-of-bounds indices.
  if index > breakpoints(body) {
    return (body, none, none)
  }

  if index < 0 {
    return split(body, calc.max(0, breakpoints(body) + index + 1))
  }

  // Handle string content.
  if type(body) == str {
    let words = body.split(" ")
    let first = words.slice(0, index).join(" ")
    let second = words.slice(index).join(" ")
    return (first, second, " ")
  }

  // Handle text content.
  if body.has("text") {
    let (text, ..fields) = body.fields()
    if "label" in fields { fields.remove("label") }
    let label = if body.has("label") { body.label }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (first, second, sep) = split(text, index)
    return (..attach-label((func(first), func(second)), label), sep)
  }

  // Handle content with "body" field.
  if body.func() in splittable {
    let (body: text, ..fields) = body.fields()
    if "label" in fields { fields.remove("label") }
    let label = if body.has("label") { body.label }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (first, second, sep) = split(text, index)
    return (..attach-label((func(first), func(second)), label), sep)
  }

  // Handle styled content.
  if body.has("child") {
    let (child, styles, ..fields) = body.fields()
    if "label" in fields { fields.remove("label") }
    let label = if body.has("label") { body.label }
    let func(it) = if it != none { body.func()(it, styles) }
    let (first, second, sep) = split(child, index)
    return (..attach-label((func(first), func(second)), label), sep)
  }

  // Handle sequences.
  if body.has("children") {
    let first = ()
    let second = ()
    let sep = none

    // Find child containing the breakpoint and split it.
    let sub-index = index
    for (i, child) in body.children.enumerate() {
      let child-breakpoints = breakpoints(child)

      // Check if current child contains splitting point.
      if sub-index <= child-breakpoints {
        if child.func() not in (space, linebreak, parbreak) {
          // Push split child (skip trailing spaces)
          let (child-first, child-second, child-sep) = split(child, sub-index)
          first.push(child-first)
          second.push(child-second)
          sep = child-sep
        } else {
          sep = child
        }

        second += body.children.slice(i + 1)
        break
      }

      sub-index -= child-breakpoints
      first.push(child)
    }

    return (join(first), join(second), sep)
  }

  // Handle unbreakable content.
  return if index == 0 { (none, body, none) } else { (body, none, none) }
}
