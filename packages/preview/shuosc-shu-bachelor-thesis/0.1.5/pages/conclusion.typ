#import "../style/heading.typ": none-heading

#let conclusion-page(
  body,
) = {
  show: none-heading
  heading(level: 1)[结论]
  body
  pagebreak(weak: true)
}

