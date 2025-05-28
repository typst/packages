#import "../translations.typ": translations

#let declaration_of_independent_processing(submission-date: datetime(year: 2025, month: 8, day: 10)) = {
  set page(numbering: none)
  heading(
    outlined: false,
    bookmarked: false,
    numbering: none,
    translations.declaration-of-independent-processing,
  )

  text(translations.declaration-of-independent-processing-content)

  v(20pt)

  grid(
    columns: 3,
    gutter: 10pt,
    align: center,
    "Wiesbaden",
    submission-date.display("[day]. [month repr:long] [year]"),
    "",
    line(length: 85pt, stroke: 1pt),
    line(length: 85pt, stroke: 1pt),
    line(length: 150pt, stroke: 1pt),
    align(center, text(translations.place, size: 9pt)),
    align(center, text(translations.date, size: 9pt)),
    align(center, text(translations.signature, size: 9pt)),
  )
}