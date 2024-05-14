#let titlepage(authors, title, date, at-dhbw, logo-left, logo-right, course-of-studies, university, university-location, supervisor, heading-font) = {
  stack(dir: ltr,
    spacing: 1fr,
   // Logo at top left if given
    align(horizon,
      if logo-left != none {
        set image(width: 6cm)
        logo-left
      }
    ),

    // Logo at top right if given
    align(horizon,
      if logo-right != none {
        set image(width: 6cm)
        logo-right
      }
    )
  )
  
  v(1.5fr)

  align(center, text(weight: "semibold", font: heading-font, 2.2em, title))
  v(4em)
  align(center, text(1.2em, [from the Course of Studies #authors.map(author => author.course-of-studies).dedup().join(" | ")]))
  v(1em)
  align(center, text(1.2em, [at the #university #university-location]))
  v(3em)
  align(center, text(1em, "by"))
  v(2em)
  grid(
    columns: 100%,
    rows: auto,
    gutter: 18pt,
    ..authors.map(author => align(center, {
      text(weight: "medium", 1.5em, [#author.name])
    }))
  )
  v(2em)
  align(center, text(1.2em, date.display(
    "[day].[month].[year]"
  )))

  v(1fr)

  // Author information.
  if (at-dhbw) {
    grid(
      columns: (180pt, auto),
      gutter: 11pt,
      text(weight: "semibold", [Student ID, Course:]),
      stack(
        dir: ttb,
        for author in authors {
          text([#author.student-id, #author.course])
          linebreak()
        }
      ),
      text(weight: "semibold", "Supervisor:"),
      text[#supervisor]
    )
  } else {
    grid(
      columns: (180pt, auto),
      gutter: 11pt,
      text(weight: "semibold", [Student ID, Course:]),
      stack(
        dir: ttb,
        for author in authors {
          text([#author.student-id, #author.course])
          linebreak()
        }
      ),
      text(weight: "semibold", [Company:]),
      stack(
        dir: ttb,
        for author in authors {
          let company-address = text([#author.company.name, #author.company.post-code, #author.company.city])
          if (author.company.country != "") {
            company-address+= text([, #author.company.country])
          }
          
          company-address
          linebreak()
        }
      ),
      text(weight: "semibold", "Supervisor in the Company:"),
      text[#supervisor]
    )
  }

  pagebreak()
}