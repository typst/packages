#let report(
  doc_title: [Title],
  doc_author: ("Author1", "Author2"),
  doc_date: auto,
  page_paper: "a4",
  page_numbering: "1",
  text_size: 12pt,
  text_lang: "fr",
  text_font: "New Computer Modern",
  par_justify: true,
  heading_numbering: "11",
  show_outline: true,
  outline_title: "Sommaire",
  course_name: "Course name",
  doc,
) = {
  set document(
    title: doc_title,
    author: doc_author,
    date: doc_date,
  )
  set page(
    paper: page_paper,
  )
  set text(
    font: text_font,
    lang: text_lang,
    size: text_size,
  )
  set par(
    justify: par_justify,
  )
  set heading(
    numbering: heading_numbering,
  )
  let date = datetime.today()
  if type(doc_date) == datetime {
    date = doc_date
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
    #text(size: 20pt, weight: "bold")[#doc_title]
    #linebreak()
    #text(size: 20pt)[#course_name]
    #linebreak()
    #text(
      size: 20pt,
    )[
      #if type(doc_author) == str {
        doc_author
      } else {
        box(
          width: 50%,
          par(
            justify: false,
          )[
            #doc_author.join(" - ")
          ],
        )
      }
    ]
  ]
  v(40%)
  align(center)[
    #text(size: 16pt)[#semester#year]
  ]
  if show_outline {
    pagebreak()
    outline(
      indent: auto,
      title: "Sommaire",
    )
  }
  pagebreak()
  set page(
    numbering: page_numbering,
  )
  doc
}
