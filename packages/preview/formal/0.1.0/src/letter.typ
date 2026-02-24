#import "general.typ": accent-color, formal-general, formal-syntax, ghost, ghost-color

#let formal-letter(
  frame-thickness: 5mm,
  margin: 3cm,
  body,
) = {
  // Styles

  show: formal-general.with(frame-thickness: frame-thickness)
  show: formal-syntax
  set page(margin: margin)
  show heading: set align(center)

  body
}

