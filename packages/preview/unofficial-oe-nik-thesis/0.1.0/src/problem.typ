// A problem with the thesis, like a missing mandatory part: while drafting a red note in the document, otherwise an
// error. The error is in `context`, so Typst reports all of them at once instead of stopping at the first.

// the red note of a problem, the parts of the message between backticks are shown as code
#let note(message) = {
  text(red, message.split("`").enumerate().map(((i, part)) => if calc.odd(i) { raw(part) } else { part }).join())
}

// the note while drafting, an error otherwise
#let problem(draft, message) = {
  context assert(draft, message: message)
  note(message)
}
