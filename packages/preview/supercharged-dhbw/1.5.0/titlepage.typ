#let titlepage(authors, title, language, date, at-dhbw, logo-left, logo-right, left-logo-height, right-logo-height, university, university-location, supervisor, heading-font, many-authors) = {
  if (many-authors) {
    v(-1em)
  }

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
  
  if (many-authors) {
    v(1fr)
  } else {
    v(1.5fr)
  }

  align(center, text(weight: "semibold", font: heading-font, 2em, title))

  if (many-authors) {
    v(1.5em)
  } else {
    v(4em)
  }

  align(center, text(1.2em, [#if (language == "de") {
    [aus dem Studiengang #authors.map(author => author.course-of-studies).dedup().join(" | ")]
  } else {
    [from the course of studies #authors.map(author => author.course-of-studies).dedup().join(" | ")]
  }]))

  if (many-authors) {
    v(0.75em)
  } else {
    v(1em)
  }

  align(center, text(1.2em, [#if (language == "de") {
    [an der #university #university-location]
  } else {
    [at the #university #university-location]
  }]))

  if (many-authors) {
    v(0.8em)
  } else {
    v(3em)
  }

  align(center, text(1em, if (language == "de") {
    "von"
  } else {
    "by"
  }))
  
    if (many-authors) {
    v(0.8em)
  } else {
    v(2em)
  }

  grid(
    columns: 100%,
    rows: auto,
    gutter: if (many-authors) {
      14pt
    } else {
      18pt
    },
    ..authors.map(author => align(center, {
      text(weight: "medium", 1.25em, [#author.name])
    }))
  )

  if (many-authors) {
    v(0.8em)
  } else {
    v(2em)
  }

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
        "Betreuer an der DHBW:"
      } else {
        "Supervisor at DHBW:"
      }),
      text[#supervisor]
    )
  } else {
    grid(
      columns: (180pt, auto),
      gutter: 11pt,
      text(weight: "semibold", if (language == "de") {
        [Matrikelnummer, Kurs:]
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
          let company-address = ""

          if (
            "name" in author.company and
            author.company.name != none and
            author.company.name != ""
            ) {
            company-address+= author.company.name
          } else {
            if (not at-dhbw) {
              panic("Author '" + author.name + "' is missing a company name. Add the 'name' attribute to the company object.")
            }
          }

          if (
            "post-code" in author.company and
            author.company.post-code != none and
            author.company.post-code != ""
            ) {
            company-address+= text([, #author.company.post-code])
          }

          if (
            "city" in author.company and
            author.company.city != none and
            author.company.city != ""
            ) {
            company-address+= text([, #author.company.city])
          } else {
            if (not at-dhbw) {
              panic("Author '" + author.name + "' is missing the city of the company. Add the 'city' attribute to the company object.")
            }
          }

          if (
            "country" in author.company and
            author.company.country != none and
            author.company.country != ""
            ) {
            company-address+= text([, #author.company.country])
          }
          
          company-address
          linebreak()
        }
      ),
      text(weight: "semibold", if (language == "de") {
        "Betreuer im Unternehmen:"
      } else {
        "Supervisor in the Company:"
      }),
      text[#supervisor]
    )
  }
}