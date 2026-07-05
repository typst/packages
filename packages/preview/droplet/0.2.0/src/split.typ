#import "util.typ": attach-label, space, splittable

// Gets the number of breakpoints in the given content.
//
// A breakpoints must always be at a space. For example, the sequece
//   ([Hello], [ ], [my world!])
// has two breakpoints:
//  1. ([Hello],) - ([my world!],)
//  2. ([Hello my], [ ]) - ([world!],)
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
    body.children.map(breakpoints).sum()
  } else if body.func() in splittable {
    breakpoints(body.body)
  } else if body.func() == space {
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
    return (body, none)
  }

  // Handle string content.
  if type(body) == str {
    let words = body.split(" ")
    let first = words.slice(0, index).join(" ")
    let second = words.slice(index).join(" ")
    return (first, second)
  }

  // Handle text content.
  if body.has("text") {
    let (text, ..fields) = body.fields()
    let label = if "label" in fields { fields.remove("label") }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (first, second) = split(text, index)
    return attach-label((func(first), func(second)), label)
  }

  // Handle content with "body" field.
  if body.func() in splittable {
    let (body: text, ..fields) = body.fields()
    let label = if "label" in fields { fields.remove("label") }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (first, second) = split(text, index)
    return attach-label((func(first), func(second)), label)
  }

  // Handle styled content. Unfortunately, we cannot preserve the style
  // information here, so it is dropped.
  if body.has("child") {
    let (first, second) = split(body.child, index)
    return (first, second)
  }

  // Handle sequences.
  if body.has("children") {
    let first = ()
    let second = ()

    // Find child containing the breakpoint and split it.
    let sub-index = index
    for (i, child) in body.children.enumerate() {
      let child-breakpoints = breakpoints(child)

      // Check if current child contains splitting point.
      if sub-index <= child-breakpoints {
        if child != [ ] {
          // Push split child (skip trailing spaces)
          let (child-first, child-second) = split(child, sub-index)
          first.push(child-first)
          second.push(child-second)
        }

        second += body.children.slice(i + 1)
        break
      }

      sub-index -= child-breakpoints
      first.push(child)
    }

    return (first.join(), second.join())
  }

  // Handle unbreakable content.
  return if index == 0 { (none, body) } else { (body, none) }
}
