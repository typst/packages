#let confidentiality-statement(authors, title, university, university-location, date) = {
    v(2em)
    text(size: 20pt, weight: "bold", "Confidentiality Statement")
    v(1em)
    text("The Thesis on hand")
    v(1em)
    align(center,
      text(weight: "bold", title)
    )
    v(1em)
    let insitution
    if (authors.map(author => author.company.name).dedup().len() == 1) {
      insitution = "insitution"
    } else {
      insitution = "insitutions"
    }
    let companies = authors.map(author => author.company.name).dedup().join(", ", last: " and ")
    par(justify: true, [
      contains internal respective confidential data of #companies. It is intended solely for inspection by the assigned examiner, the head of the mobile computer science department and, if necessary, the Audit Committee at the #university #university-location.
      
      The content of this thesis may not be made available, either in its entirety or in excerpts, to persons outside of the examination process and the evaluation process, unless otherwise authorized by the training #insitution (#companies).
    ])
  
    v(3em)
    text([#authors.map(author => author.company.city).dedup().join(", ", last: " and "), #date.display(
      "[day].[month].[year]"
    )])
  
    for author in authors {
      v(5em)
      line(length: 40%)
      author.name
    }
}