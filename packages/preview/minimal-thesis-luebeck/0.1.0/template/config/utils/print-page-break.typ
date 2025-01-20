#let print-page-break(print: bool, to: "even") = {
  if print {
    pagebreak(to: to)
  } else {
    pagebreak()
  }
}