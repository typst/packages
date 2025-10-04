#let report(
  doc-title: [Title],
  doc-author: ("Author1", "Author2"),
  doc-date: auto,
  page-paper: "a4",
  page-numbering: "1",
  text-size: 12pt,
  text-lang: "fr",
  text-font: "New Computer Modern",
  par-justify: true,
  heading-numbering: "11",
  show-outline: true,
  outline-title: "Sommaire",
  course-name: "Course name",
  doc,
) = {
  set document(
    title: doc-title,
    author: doc-author,
    date: doc-date,
  )
  set page(
    paper: page-paper,
  )
  set text(
    font: text-font,
    lang: text-lang,
    size: text-size,
  )
  set par(
    justify: par-justify,
  )
  set heading(
    numbering: heading-numbering,
  )
  let date = datetime.today()
  if type(doc-date) == datetime {
    date = doc-date
  }
  let year = date.display("[year repr:last_two]")
  let month = date.display("[month]")
  let semester = if month < "09" {
    text("P")
  } else {
    text("A")
  }
  v(15%)
  align(center)[
    #image("../assets/utbm_logo.jpg", width: 40%)
  ]
  align(center)[
    #text(size: 20pt, weight: "bold")[#doc-title]
    #linebreak()
    #text(size: 20pt)[#course-name]
    #linebreak()
    #text(
      size: 20pt,
    )[
      #if type(doc-author) == str {
        doc-author
      } else {
        box(
          width: 50%,
          par(
            justify: false,
          )[
            #doc-author.join(" - ")
          ],
        )
      }
    ]
  ]
  v(40%)
  align(center)[
    #text(size: 16pt)[#semester#year]
  ]
  if show-outline {
    pagebreak()
    outline(
      indent: auto,
      title: "Sommaire",
    )
  }
  pagebreak()
  set page(
    numbering: page-numbering,
  )
  doc
}
