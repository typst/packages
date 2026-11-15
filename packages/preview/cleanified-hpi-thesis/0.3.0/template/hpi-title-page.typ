#let value-type = type

#let render-people(people, field) = {
  assert(
    value-type(people) == array,
    message: field + " must be an ordered tuple, for example (\"Name\",)",
  )
  people.map(person => [#person]).join(linebreak())
}

#let hpi-title-page(
  professors: (),
  advisors: (),
  chair: "",
  name: "",
  title: "",
  translation: "",
  study-program: "",
  date: none,
  type: "",
  accent-color: rgb("#4f5358"),
  university-logo: "up-logo.svg",
  institute-logo: "hpi-logo.svg",
  labels: (:),
) = {
  assert(
    type in ("Bachelor", "Master", ""),
    message: "type must be 'Bachelor' or 'Master'",
  )

  let rendered-professors = render-people(professors, "professors")
  let rendered-advisors = render-people(advisors, "advisors")
  let examiner-label = labels.at(
    if professors.len() == 1 { "examiner" } else { "examiners" },
  )
  let advisor-label = labels.at(
    if advisors.len() == 1 { "advisor" } else { "advisors" },
  )

  let (thesis-kind, degree, abbreviation) = if type == "Master" {
    (
      labels.at("master-thesis-kind"),
      labels.at("master-degree"),
      labels.at("master-abbreviation"),
    )
  } else {
    (
      labels.at("bachelor-thesis-kind"),
      labels.at("bachelor-degree"),
      labels.at("bachelor-abbreviation"),
    )
  }

  page(footer: [])[
    // Title page
    #grid(
      columns: (1fr, 1fr),
      rows: (80pt, 80pt),
      grid.cell(image(university-logo, alt: "University logo")),
      grid.cell(align(right, image(
        institute-logo,
        alt: "Institute logo",
      ))),
    )

    #align(center, block(
      width: 100%,
      inset: (x: 1em, y: 2em),
      stroke: (
        top: 0.75pt + accent-color,
        bottom: 0.75pt + accent-color,
      ),
    )[
      #text(2em, weight: "bold", title)
      #if translation != "" [\ #v(0.5em) #text(1.5em, translation)]
    ])

    #align(center, text(1.5em, weight: "bold", name))

    #align(center, block[
      #thesis-kind\
      #labels.at("thesis-purpose")
    ])

    #align(center, text(1.5em, block[
      #degree \
      #text(style: "italic", "(" + abbreviation + ")")
    ]))

    #align(center, block[
      #labels.at("study-program-label") \
      #study-program
    ])

    #align(center, block[
      #labels.at("submitted-on") #date #labels.at("submitted-on-suffix") \
      #labels.at("chair-label") #chair #labels.at("chair-suffix") \
      #labels.at("faculty") \
      #labels.at("university")
    ])

    #v(1cm)
    #align(center, grid(
      columns: (1fr, 1.8fr),
      rows: (auto, auto),
      row-gutter: 6pt,
      grid.cell(align(left + top, text(weight: "bold", examiner-label))),
      grid.cell(align(left + top, rendered-professors)),
      grid.cell(align(left + top, text(weight: "bold", advisor-label))),
      grid.cell(align(left + top, rendered-advisors)),
    ))
  ]
}
