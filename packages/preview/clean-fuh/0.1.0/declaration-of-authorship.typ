#import "locale.typ": *

#let declaration-of-authorship(
  authors,
  title,
  declaration-of-authorship-content,
  date,
  language,
  many-authors,
  city,
  date-format,
) = {
  heading(level: 1, DECLARATION_OF_AUTHORSHIP_TITLE.at(language))
  v(1em)

  if (declaration-of-authorship-content != none) {
    declaration-of-authorship-content
  } else {
    if (authors.len() == 1) {
      par(justify: true, DECLARATION_OF_AUTHORSHIP_SECTION_A_SINGLE.at(language))
      v(1em)
      align(center, text(weight: "bold", title))
      v(1em)
      par(justify: true, DECLARATION_OF_AUTHORSHIP_SECTION_B_SINGLE.at(language))
    } else {
      par(justify: true, DECLARATION_OF_AUTHORSHIP_SECTION_A_PLURAL.at(language))
      v(1em)
      align(center, text(weight: "bold", title))
      v(1em)
      par(justify: true, DECLARATION_OF_AUTHORSHIP_SECTION_B_PLURAL.at(language))
    }
  }

  let end-date = if (type(date) == datetime) {
    date
  } else {
    date.at(1)
  }

  v(1em)
  if (many-authors) {
    grid(
      columns: (1fr, 1fr),
      gutter: 20pt,
      ..authors.map(author => {
        rect(
          width: 80%, height: 3.5em, inset: 1pt,
          stroke: (top: none, y: none, bottom: black),
          if author.keys().contains("signature") {
            box(author.signature)
          }
        )
        author.name
      })
    )
  } else {
    for author in authors {
      rect(
        width: 40%, height: 4em, inset: 1pt,
        stroke: (top: none, y: none, bottom: black),
        if author.keys().contains("signature") {
            box(author.signature)
        }
      )
      author.name
    }
  }

}
