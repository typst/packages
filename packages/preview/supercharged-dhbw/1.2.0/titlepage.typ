#let titlepage(authors, title, language, date, at-dhbw, logo-left, logo-right, left-logo-height, right-logo-height, university, university-location, supervisor, heading-font) = {
  stack(dir: ltr,
    spacing: 1fr,
   // Logo at top left if given
    align(horizon,
      if logo-left != none {
        set image(height: left-logo-height)
        logo-left
      }
    ),

    // Logo at top right if given
    align(horizon,
      if logo-right != none {
        set image(height: right-logo-height)
        logo-right
      }
    )
  )
  
  v(1.5fr)

  align(center, text(weight: "semibold", font: heading-font, 2.2em, title))
  v(4em)
  align(center, text(1.2em, [#if (language == "de") {
    [aus dem Studiengang #authors.map(author => author.course-of-studies).dedup().join(" | ")]
  } else {
    [from the course of studies #authors.map(author => author.course-of-studies).dedup().join(" | ")]
  }]))
  v(1em)
  align(center, text(1.2em, [#if (language == "de") {
    [an der #university #university-location]
  } else {
    [at the #university #university-location]
  }]))
  v(3em)
  align(center, text(1em, if (language == "de") {
    "von"
  } else {
    "by"
  }))
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
      columns: (if (language == "de") {
        200pt
      } else {
        180pt
      }, auto),
      gutter: 11pt,
      text(weight: "semibold", if (language == "de") {
        [Matrikelnummer, Studiengang:]
      } else {
        [Student ID, Course:]
      }),
      stack(
        dir: ttb,
        for author in authors {
          text([#author.student-id, #author.course])
          linebreak()
        }
      ),
      text(weight: "semibold", if (language == "de") {
        "Beteuer:"
      } else {
        "Supervisor:"
      }),
    )
  } else {
    grid(
      columns: (if (language == "de") {
        200pt
      } else {
        180pt
      }, auto),
      gutter: 11pt,
      text(weight: "semibold", if (language == "de") {
        [Matrikelnummer, Studiengang:]
      } else {
        [Student ID, Course:]
      }),
      stack(
        dir: ttb,
        for author in authors {
          text([#author.student-id, #author.course])
          linebreak()
        }
      ),
      text(weight: "semibold", if (language == "de") {
        "Unternehmen:"
      } else {
        "Company:"
      }),
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
      text(weight: "semibold", if (language == "de") {
        "Beteuer im Unternehmen:"
      } else {
        "Supervisor in the Company:"
      }),
      text[#supervisor]
    )
  }

  pagebreak()
}