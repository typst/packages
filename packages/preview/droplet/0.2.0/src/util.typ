// Elements that can be split and have a 'body' field.
#let splittable = (strong, emph, underline, stroke, overline, highlight)

// Element function of spaces.
#let space = [ ].func()

// Converts the given content to a string.
#let to-string(body) = {
  if type(body) == str {
    body
  } else if body.has("text") {
    to-string(body.text)
  } else if body.has("child") {
    to-string(body.child)
  } else if body.has("children") {
    body.children.map(to-string).join()
  } else if body.func() in splittable {
    to-string(body.body)
  } else if body.func() == smartquote {
    // Unfortunately, we can only use "dumb" quotes here.
    if body.double { "\"" } else { "'" }
  } else if body.func() == enum.item {
    if body.has("number") {
      str(body.number) + ". " + to-string(body.body)
    } else {
      "+ " + to-string(body.body)
    }
  } else if body.func() == space {
    " "
  }
}

// Attaches a label after the split elements.
//
// The label is only attached to one of the elements, preferring the second
// one. If both elements are empty, the label is discarded. If the label is
// empty, the elements remain unchanged.
#let attach-label((first, second), label) = {
  if label == none {
    (first, second)
  } else if second != none {
    (first, [#second#label])
  } else if first != none {
    ([#first#label], second)
  } else {
    (none, none)
  }
}
