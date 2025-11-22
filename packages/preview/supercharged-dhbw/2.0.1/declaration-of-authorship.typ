#let declaration-of-authorship(authors, title, date, language, many-authors, at-university, city, date-format) = {
  pagebreak()
  v(2em)
  text(size: 20pt, weight: "bold", if (language == "de") {
    "Selbstständigkeitserklärung"
  } else {
    "Declaration of Authorship"
  })

  v(1em)

  par(justify: true, [
    Gemäß Ziffer 1.1.13 der Anlage 1 zu §§ 3, 4 und 5 der Studien- und Prüfungsordnung für die Bachelorstudiengänge im Studienbereich Technik der Dualen Hochschule Baden- Württemberg vom 29.09.2017. Ich versichere hiermit, dass ich meine Arbeit mit dem Thema:
  ])
  v(1em)
  align(center,
    text(weight: "bold", title)
  )
  v(1em)
  par(justify: true, [
    selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe. Ich versichere zudem, dass die eingereichte elektronische Fassung mit der gedruckten Fassung übereinstimmt.
  ])

  let end-date = if (type(date) == datetime) {
    date
  } else {
    date.at(1)
  }

  v(2em)
  if (at-university) {
    text([#city, #end-date.display(date-format)])
  } else {
    let connection-string
    if (language == "de") {
      connection-string = " und "
    } else {
      connection-string = " and "
    }

    text([#authors.map(author => author.company.city).dedup().join(", ", last: connection-string), #end-date.display(date-format)])
  }

  v(1em)
  if (many-authors) {
    grid(
      columns: (1fr, 1fr),
      gutter: 20pt,
      ..authors.map(author => {
        v(3.5em)
        line(length: 80%)
        author.name
      })
    )
  } else {
    for author in authors {
      v(4em)
      line(length: 40%)
      author.name
    }
  }
}