#let declaration-of-authorship(authors, title, date) = {
  pagebreak()
  v(2em)
  text(size: 20pt, weight: "bold", "Declaration of Authorship")
  v(1em)
  par(justify: true, [
    according to item 1.1.13 of Annex 1 to §§ 3, 4, and 5 of the Examination Regulations for the Bachelor's Degree Programs in the Technology Department of the Baden-Württemberg Cooperative State University dated September 29, 2017. I hereby certify that I have composed the thesis on the topic:
  ])
  v(1em)
  align(center,
    text(weight: "bold", title)
  )
  v(1em)
  par(justify: true, [
    independently and have not used any sources and aids other than those stated in the document. I also certify that the submitted electronic version matches the printed version.
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