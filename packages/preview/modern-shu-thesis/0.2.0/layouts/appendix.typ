#import "../style/heading.typ": appendix-first-heading, none-heading
#import "../style/figures.typ": figures
#let appendix(
  body,
) = {
  show: none-heading
  show: appendix-first-heading
  show: figures.with(appendix: true)
  show heading.where(level: 2): set heading(outlined: false)
  show heading.where(level: 3): set heading(outlined: false)
  set par(
    first-line-indent: 2em,
    leading: 20pt - 1em,
    spacing: 20pt - 1em,
    justify: true,
  )
  body
}