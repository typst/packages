#let timesheet(
  name: "",
  month: "",
  year: "",
  content
) = {

  // Document setup
  set document(author: name, title: "Stundenzettel")
  set page(
    paper: "a4",
    margin: (left: 2cm, right: 2cm, top: 2cm, bottom: 2cm),
  )


  // Header
  align(center)[
    #text(17pt, weight: "bold")[Stundenzettel]
    #v(5mm)
    
    #grid(
      columns: (1fr, 1fr),
      gutter: 3mm,
      align(left)[
        *Name:* #name \
        *Monat:* #month \
        *Jahr:* #year
      ],
    )
  ]

  // Table header
  v(5mm)
  line(length: 100%)
  v(3mm)

  // Table
  grid(
    columns: (auto, 1fr, auto, auto),
    gutter: 5mm,
    [*Datum*], [*Tätigkeit*], [*Stunden*], [*Stundensatz*],
      ..content
  )
  line(length: 100%)

  // Content

set align(bottom)
  // Footer
  v(10mm)
  line(length: 100%)
  v(5mm)

}