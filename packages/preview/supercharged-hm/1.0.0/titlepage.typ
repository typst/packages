// Copyright 2024 Danny Seidel https://github.com/DannySeidel
// Copyright 2026 Felix Schladt https://github.com/FelixSchladt

#import "@preview/linguify:0.5.0": *

#import "colors.typ": *
#import "lang.typ": *
#import "libs/date.typ": format-date

#let titlepage(
  title: "Title",
  subtitle: "Subtitle",
  authors: "Authors",
  date: datetime.today(),
  submission-date: none,
  language: "de",
  logo: none,
  supervisor: none,
  type-of-degree: none,
  student-id: none,
  faculty: none,
  study-course: none,
  doc-type: none,
  date-format: auto,
  show-thesis-title-page: false,
  pagebreak-after: true,
) = {
  if (not show-thesis-title-page) {
    v(30pt)

    align(center)[
      #logo
      #v(40pt)
      #text(title, size: 24pt, weight: "bold", fill: hm-black)
      #linebreak()
      #v(1pt)
      #text(subtitle, size: 15pt, weight: "semibold")
      #v(0pt)
      #text(authors, size: 15pt)
      #v(0pt)
      #text(format-date(date, language, date-format), size: 15pt)
      #v(30pt)
    ]
  } else {
    if submission-date == none {
      panic("Thesis title page requires submission-date to be set")
    }

    context {
      set align(center)
      text(
        size: 18pt,
        smallcaps(
          linguify(
            "base_title_page_thesis-university",
            from: lang-db,
          ),
        )
      )
      linebreak()
      v(0pt)
      text(
        size: 15pt,
        smallcaps(faculty)
      )

      v(20pt)

      logo

      v(30pt)

      context {
        set text(size: 16pt)
        set par(spacing: 1.5em, leading: 1.5em)
        doc-type
        linebreak()
        linguify(
          "base_title_page_thesis-degree-text-0",
          from: lang-db
        )
        linebreak()
        type-of-degree
        linebreak()
        linguify(
          "base_title_page_thesis-degree-text-1",
          from: lang-db,
        )
        study-course
      }
      v(40pt)

      text(
        size: 20pt,
        title,
        weight: "bold"
      )

      v(120pt)

      line(length: 100%)

      v(20pt)
      set text(size: 14pt)
      set align(center)
      table(
        align: left,
        columns: (50%, 50%),
        fill: none,
        stroke: 0pt,
        table.header([],[]),
        linguify("base_title_page_thesis-author", from: lang-db), authors,
        linguify("base_title_page_thesis-student-id", from: lang-db), student-id,
        linguify("base_title_page_thesis-submission-date", from: lang-db), format-date(submission-date, language, date-format),
        linguify("base_title_page_thesis-supervisor", from: lang-db), supervisor,
      )
    }
  }

  if pagebreak-after {
    pagebreak()
  }
}
