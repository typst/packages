#let declaration-of-authorship(authors, title, date, language, many-authors) = {
  pagebreak()
  v(2em)
  text(size: 20pt, weight: "bold", if (language == "de") {
    "Selbstständigkeitserklärung"
  } else {
    "Declaration of Authorship"
  })

  v(1em)
  if (language == "de") {
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
  } else {
    par(justify: true, [
      According to item 1.1.13 of Annex 1 to §§ 3, 4, and 5 of the Examination Regulations for the Bachelor's Degree Programs in the Technology Department of the Baden-Württemberg Cooperative State University dated September 29, 2017. I hereby certify that I have composed the thesis on the topic:
    ])
    v(1em)
    align(center,
      text(weight: "bold", title)
    )
    v(1em)
    par(justify: true, [
      independently and have not used any sources and aids other than those stated in the document. I also certify that the submitted electronic version matches the printed version.
    ])
  }

  v(2em)
  text([#if (language == "de") {
    [#authors.map(author => author.company.city).dedup().join(", ", last: " und "), #date.display(
    "[day].[month].[year]"
  )]} else {
    [#authors.map(author => author.company.city).dedup().join(", ", last: " and "), #date.display(
    "[day].[month].[year]"
  )]}])

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