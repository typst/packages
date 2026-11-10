#import "locale.typ": *

#let confidentiality-statement(
  authors,
  title,
  confidentiality-statement-content,
  university,
  university-location,
  date,
  language,
  many-authors,
  date-format,
) = {
  let authors-by-city = authors.map(author => author.company.city).dedup()

  heading(level: 1, CONFIDENTIALITY_STATEMENT_TITLE.at(language))
  v(1em)

  if (confidentiality-statement-content != none) {
    confidentiality-statement-content
  } else {
    let authors-by-company = authors.map(author => author.company.name).dedup()
    let authors-by-study = authors.map(author => author.course-of-studies).dedup()
    let companies = authors-by-company.join(", ", last: AND.at(language))

    let institution = if (authors-by-company.len() == 1) {
      INSTITUTION_SINGLE.at(language)
    } else {
      INSTITUTION_PLURAL.at(language)
    }

    text(CONFIDENTIALITY_STATEMENT_SECTION_A.at(language))
    v(1em)
    align(
      center,
      text(weight: "bold", title),
    )

    v(1em)

    par(
      justify: true,
      CONFIDENTIALITY_STATEMENT_SECTION_B.at(language) + [ ] + companies + CONFIDENTIALITY_STATEMENT_SECTION_C.at(language) + [ ] + authors-by-study.join(" | ") + CONFIDENTIALITY_STATEMENT_SECTION_D.at(language) + university + [ ] + university-location + CONFIDENTIALITY_STATEMENT_SECTION_E.at(language) + institution + [ (#companies)] + CONFIDENTIALITY_STATEMENT_SECTION_F.at(language),
    )
  }

  let end-date = if (type(date) == datetime) {
    date
  } else {
    date.at(1)
  }

  v(2em)
  text(authors-by-city.dedup().join(", ", last: AND.at(language)) + [ ] + end-date.display(date-format))

  v(0.5em)
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
