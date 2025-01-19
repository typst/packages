#let print_page_break(print: bool, to: "even") = {
  if print {
    pagebreak(to: to)
  } else {
    pagebreak()
  }
}