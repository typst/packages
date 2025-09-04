#let print-page-break(print: bool, to: "even") = {
  set page(footer: none, header: none)
  if print {
    pagebreak(to: to)
  } else {
    pagebreak()
  }
}