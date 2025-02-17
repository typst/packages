#import "../style/heading.typ":appendix-first-heading, none-heading
#let appendix(
  body,
) = {
  show: none-heading
  show: appendix-first-heading

  body
}
