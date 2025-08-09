#import "../styles/fonts.typ": fonts, fontsize
#import "../styles/heading.typ": none-heading, appendix-first-heading
#import "../styles/figures.typ": figures, tablex
#import "@preview/numbly:0.1.0": numbly

#let appendix(
  body,
) = {
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: 20pt - 1em,
    spacing: 20pt - 1em,
    justify: true,
  )
  set page(numbering: none,footer: none)
  show heading: set align(center)
  show: appendix-first-heading
  pagebreak(weak: true)
  show: figures.with(appendix: true)
  show heading: set heading(outlined: false)
  show heading.where(level: 1): set heading(outlined: true, numbering: none)
  body
}
