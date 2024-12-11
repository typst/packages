// Elements that can be split and have a 'body' field.
#let splittable = (strong, emph, underline, stroke, overline, highlight, smallcaps)

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
  } else if body.func() == super {
    let body-string = to-string(body.body)
    if body-string != none and regex("^[0-9+\-=\(\)ni\s]+$") in body-string {
      body-string
        .replace("1", "¹")
        .replace("2", "²")
        .replace("3", "³")
        .replace(regex("[04-9]"), it => str.from-unicode(0x2070 + int(it.text)))
        .replace("+", "\u{207A}")
        .replace("-", "\u{207B}")
        .replace("=", "\u{207C}")
        .replace("(", "\u{207D}")
        .replace(")", "\u{207E}")
        .replace("n", "\u{207F}")
        .replace("i", "\u{2071}")
    }
  } else if body.func() == sub {
    let body-string = to-string(body.body)
    if body-string != none and regex("^[0-9+\-=\(\)aehk-pstx\s]+$") in body-string {
      body-string
        .replace(regex("[0-9]"), it => str.from-unicode(0x2080 + int(it.text)))
        .replace("+", "\u{208A}")
        .replace("-", "\u{208B}")
        .replace("=", "\u{208C}")
        .replace("(", "\u{208D}")
        .replace(")", "\u{208E}")
        .replace("a", "\u{2090}")
        .replace("e", "\u{2091}")
        .replace("o", "\u{2092}")
        .replace("x", "\u{2093}")
        .replace("h", "\u{2095}")
        .replace("k", "\u{2096}")
        .replace("l", "\u{2097}")
        .replace("m", "\u{2098}")
        .replace("n", "\u{2099}")
        .replace("p", "\u{209A}")
        .replace("s", "\u{209B}")
        .replace("t", "\u{209C}")
    }
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

// Returns whether the element is displayed inline.
//
// Requires context.
#let inline(element) = {
  element != none and measure(h(0.1pt) + element).width > measure(element).width
}
