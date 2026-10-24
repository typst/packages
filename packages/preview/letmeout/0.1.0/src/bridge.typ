// The paged branch returns the native element without installing show rules.
// Only HTML gets a local show rule, so adapters see resolved native defaults.
#let bridge(native, element, render) = context {
  if target() != "html" { native }
  else {
    show element: it => context {
      if target() == "html" { render(it) } else { it }
    }
    native
  }
}
