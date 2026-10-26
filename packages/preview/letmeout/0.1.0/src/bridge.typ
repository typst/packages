// A local show rule renders the native element, so adapters see resolved
// native defaults. In paged output it keeps the element. Not a `context`, so
// letmeout can still read the element where it stands, as for scroll areas.
#let bridge(native, element, render) = {
  show element: it => context {
    if target() == "html" { render(it) } else { it }
  }
  native
}
