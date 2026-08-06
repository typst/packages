#import "@preview/wordometer:0.1.4": total-words, word-count
#let today = { datetime.today().display("[day] [month repr:long], [year]") }

#let title-page(unit_code: "", title: "", authors: (), date: none) = {
  set page(numbering: none)
  set align(center)

  text(size: 18pt, weight: "bold")[#unit_code Engineering Research Project]
  v(3em)
  text(size: 18pt, weight: "bold")[#title]
  linebreak()
  linebreak()
  text(size: 18pt, weight: "bold")[#date]

  v(10em)
  text(size: 14pt)[
    Word Count: #context total-words
  ]
  v(10em)

  if authors.len() > 0 [
    #for author in authors [
      #text(size: 14pt, weight: "bold")[#author.name]\
      #if author.email != none [
        #text(size: 14pt)[#author.email]\
      ]
      #text(size: 14pt, weight: "light")[#author.department]
      #v(0.5em)
    ]
  ]

  v(5em)

  text(size: 14pt, weight: "bold")[School of Engineering]
  linebreak()
  text(size: 14pt, weight: "bold")[The University of Western Australia]

  pagebreak()
}

#let uwa-thesis(
  unit_code: "",
  title: "",
  short_title: "",
  authors: (),
  date: today,
  body,
) = {
  set document(title: title)
  set text(font: "New Computer Modern", size: 11pt, lang: "en")

  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 3cm),
  )

  title-page(unit_code: unit_code, title: title, authors: authors, date: date)

  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 3cm),
    numbering: "i",
    header: align(right, short_title),
  )

  outline(title: "Table of Contents", depth: 3)
  outline(title: "List of Figures", target: figure.where(kind: image))
  outline(title: "List of Tables", target: figure.where(kind: table))
  counter(page).update(1)

  v(1.5em)

  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 3cm),
    numbering: "1",
    header: align(right, short_title),
  )
  set heading(numbering: "1.1")
  set par(justify: true, leading: 0.65em)

  // The actual document content gets inserted here
  counter(page).update(1)
  show: word-count.with(exclude: (heading, outline, table, image))
  body
}
