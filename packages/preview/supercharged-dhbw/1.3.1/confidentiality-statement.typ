#let confidentiality-statement(authors, title, university, university-location, date, language, many-authors) = {
  v(2em)
  text(size: 20pt, weight: "bold", if (language == "de") {
    "Sperrvermerk"
  } else {
    "Confidentiality Statement"
  })
  v(1em)
  text(if (language == "de") {
    "Die vorliegende Arbeit mit dem Titel"
  } else {
    "The Thesis on hand"
  })
  v(1em)
  align(center,
    text(weight: "bold", title)
  )
  v(1em)
  let insitution
  let companies
  if (language == "de") {
    if (authors.map(author => author.company.name).dedup().len() == 1) {
      insitution = "Ausbildungsstätte"
    } else {
      insitution = "Ausbildungsstätten"
    }
    companies = authors.map(author => author.company.name).dedup().join(", ", last: " und ")
  } else {
    if (authors.map(author => author.company.name).dedup().len() == 1) {
      insitution = "insitution"
    } else {
      insitution = "insitutions"
    }
    companies = authors.map(author => author.company.name).dedup().join(", ", last: " and ")
  }
  par(justify: true, [#if (language == "de") {
    [enthält unternehmensinterne bzw. vertrauliche Informationen der #companies, ist deshalb mit einem Sperrvermerk versehen und wird ausschließlich zu Prüfungszwecken am Studiengang #authors.map(author => author.course-of-studies).dedup().join(" | ") der #university #university-location vorgelegt.

    Der Inhalt dieser Arbeit darf weder als Ganzes noch in Auszügen Personen außerhalb des Prüfungsprozesses und des Evaluationsverfahrens zugänglich gemacht werden, sofern keine anders lautende Genehmigung der #insitution (#companies) vorliegt.]
  } else {
    [contains internal respective confidential data of #companies. It is intended solely for inspection by the assigned examiner, the head of the #authors.map(author => author.course-of-studies).dedup().join(" | ") department and, if necessary, the Audit Committee at the #university #university-location.
    
    The content of this thesis may not be made available, either in its entirety or in excerpts, to persons outside of the examination process and the evaluation process, unless otherwise authorized by the training #insitution (#companies).]
  }])

  v(2em)
  text([#if (language == "de") {
    [#authors.map(author => author.company.city).dedup().join(", ", last: " und "), #date.display(
    "[day].[month].[year]"
  )]} else {
    [#authors.map(author => author.company.city).dedup().join(", ", last: " and "), #date.display(
    "[day].[month].[year]"
  )]}])

  v(0.5em)
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