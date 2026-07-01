#import "../translations.typ": translations

#let declaration_of_independent_processing() = {
  heading(
    outlined: true,
    numbering: none,
    bookmarked: true,
    translations.declaration-of-independent-processing,
  )

  text(translations.declaration-of-independent-processing-content)

  v(40pt)

  grid(
    columns: 3,
    gutter: 10pt,
    line(length: 85pt, stroke: 1pt),
    line(length: 85pt, stroke: 1pt),
    line(length: 150pt, stroke: 1pt),
    align(center, text(translations.place, size: 9pt)),
    align(center, text(translations.date, size: 9pt)),
    align(center, text(translations.signature, size: 9pt)),
  )
}