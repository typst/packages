#import "../style/heading.typ": appendix-first-heading, none-heading
#import "../style/figures.typ": figures
#let appendix(
  body,
) = {
  show: none-heading
  show: appendix-first-heading
  show: figures.with(appendix: true)
  set par(
    first-line-indent: 2em,
    leading: 21pt - 1em,
    spacing: 21pt - 1em,
    justify: true,
  )
  body
}
