#import "../style/heading.typ": none-heading

#let conclusion-page(
  body,
) = {
  show: none-heading
  v(2em)
  heading(level: 1)[结论]
  v(2em)
  body
  pagebreak(weak: true)
}

