#let declaration-of-authorship(authors, title, date, language) = {
  pagebreak()
  v(2em)
  text(size: 20pt, weight: "bold", if (language == "de") {
    "Selbstständigkeitserklärung"
  } else {
    "Declaration of Authorship"
  })
  v(1em)
  par(justify: true, [
    emäß Ziffer 1.1.13 der Anlage 1 zu §§ 3, 4 und 5 der Studien- und Prüfungsordnung für die Bachelorstudiengänge im Studienbereich Technik der Dualen Hochschule Baden- Württemberg vom 29.09.2017. Ich versichere hiermit, dass ich meine Arbeit mit dem Thema:
  ])
  v(1em)
  align(center,
    text(weight: "bold", title)
  )
  v(1em)
  par(justify: true, [
    selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe. Ich versichere zudem, dass die eingereichte elektronische Fassung mit der gedruckten Fassung übereinstimmt.
  ])

  v(3em)
  text([#if (language == "de") {
    [#authors.map(author => author.company.city).dedup().join(", ", last: " und "), #date.display(
    "[day].[month].[year]"
  )]} else {
    [#authors.map(author => author.company.city).dedup().join(", ", last: " and "), #date.display(
    "[day].[month].[year]"
  )]}])

  for author in authors {
    v(5em)
    line(length: 40%)
    author.name
  }
}