#let titlepage(
  authors,
  date,
  heading-font,
  language,
  left-logo-height,
  logo-left,
  logo-right,
  many-authors,
  right-logo-height,
  supervisor,
  title,
  type-of-degree,
  type-of-thesis,
  university,
  university-location,
  at-dhbw,
  date-format,
) = {
  if (many-authors) {
    v(-1.5em)
  } else {
    v(-1em)
  }

  // logos (optional)
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

  // title
  align(center, text(weight: "semibold", font: heading-font, 2em, title))

  if (many-authors) {
    v(0.5em)
  } else {
    v(1.5em)
  }

  // type of thesis (optional)
  if (type-of-thesis != none and type-of-thesis.len() > 0) {
    align(center, text(weight: "semibold", 1.25em, type-of-thesis))
    v(0.5em)
  }

  // type of degree (optional)
  if (type-of-degree != none and type-of-degree.len() > 0) {
    align(center, text(1em, [#if (language == "de") {
      [für den Erwerb des]
    } else {
      [for the]
    }]))

    v(-0.25em)
    align(center, text(weight: "semibold", 1.25em, type-of-degree))
  }
  v(1.5em)

  // course of studies
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

  // university
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

  // authors
  grid(
    columns: 100%,
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

  // date
  align(center, text(1.2em, if (type(date) == datetime) {
    date.display(date-format)
  } else {
    [#date.at(0).display(date-format) -- #date.at(1).display(date-format)]
  }))

  v(1fr)

  // author information
  grid(
    columns: (180pt, auto),
    gutter: 11pt,

    // students
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

    // company
    if (not at-dhbw) {
      text(weight: "semibold", if (language == "de") {
        "Unternehmen:"
      } else {
        "Company:"
      })
    },
    if (not at-dhbw) {
      stack(
        dir: ttb,
        for author in authors {
          let company-address = ""

          // company name
          if (
            "name" in author.company and
            author.company.name != none and
            author.company.name != ""
            ) {
            company-address+= author.company.name
          } else {
            panic("Author '" + author.name + "' is missing a company name. Add the 'name' attribute to the company object.")
          }

          // company address (optional)
          if (
            "post-code" in author.company and
            author.company.post-code != none and
            author.company.post-code != ""
            ) {
            company-address+= text([, #author.company.post-code])
          }

          // company city
          if (
            "city" in author.company and
            author.company.city != none and
            author.company.city != ""
            ) {
            company-address+= text([, #author.company.city])
          } else {
            panic("Author '" + author.name + "' is missing the city of the company. Add the 'city' attribute to the company object.")
          }

          // company country (optional)
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
      )
    },

    // supervisor
    if (at-dhbw) {
      text(weight: "semibold", if (language == "de") {
        "Betreuer an der DHBW:"
      } else {
        "Supervisor at DHBW:"
      })
    } else {
      text(weight: "semibold", if (language == "de") {
        "Betreuer im Unternehmen:"
      } else {
        "Supervisor in the Company:"
      })
    },
    text[#supervisor]
  )
}