// Proper Hungarian quotes based on nesting level.
// XXX: panic is not the right solution here...
#let _nest = counter("nesting")

#let hq(body) = {
  context {
    let n = _nest.get().first()
    _nest.step()

    if n == 0 {
      "„"
    } else if n == 1 {
      "»"
    } else if n == 2 {
      "’"
    } else {
      panic("nesting is too deep")
    }

    body

    if n == 0 {
      "”"
    } else if n == 1 {
      "«"
    } else if n == 2 {
      "’"
    } else {
      panic("nesting is too deep")
    }

    _nest.update(n => n - 1)
  }
}

