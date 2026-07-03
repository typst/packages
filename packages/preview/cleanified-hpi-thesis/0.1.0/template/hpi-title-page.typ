#let hpi-title-page(
  professor: "",
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
  assert(type in ("Bachelor", "Master", ""), message: "type must be 'Bachelor' or 'Master'")

  let (thesis-kind, degree, abbreviation) = if type == "Master" {
    (labels.at("master-thesis-kind"), labels.at("master-degree"), labels.at("master-abbreviation"))
  } else {
    (labels.at("bachelor-thesis-kind"), labels.at("bachelor-degree"), labels.at("bachelor-abbreviation"))
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

    #align(center, block[
      #line(length: 100%, stroke: 0.75pt + accent-color)\
      #text(2em, weight: "bold", title) \ \
      #text(1.5em, translation) \ \
      #line(length: 100%, stroke: 0.75pt + accent-color)
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
      rows: (18pt, 18pt),
      grid.cell(align(left, text(weight: "bold", labels.at("examiner")))),
      grid.cell(align(left, professor)),
      grid.cell(align(left, text(weight: "bold", labels.at("advisor")))),
      grid.cell(align(left, advisors.join(", "))),
    ))
  ]
}
