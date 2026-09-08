#import "/src/fonts.typ": *


#let appendix-page(body) = {
  set heading(numbering: none)
  show heading.where(level: 2): set text(font: heiti)
  [= 附录（附图）]
  body
  pagebreak()
}
