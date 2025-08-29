#let section-block(title, content) = [
  #grid(
    columns: (2.8fr, 13.8fr),
    smallcaps(text(font: "Cronos Pro", size: 14.5pt, title)), content,
  )
  #v(20pt)
]

#let edu-heading(department: [], location: [], role: [], time: []) = [
  #grid(
    columns: (3fr, 1fr),
    align: (left, right),
    row-gutter: 10pt,
    [#strong(department) \ #emph(role)], [#location \ #time],
  )
]

#let proj-heading(title: [], institution: [], time: []) = [
  #grid(
    columns: (3fr, 1fr),
    align: (left, right),
    grid.cell(
      colspan: 2,
      strong(title),
    ),
    row-gutter: 8pt,
    emph(institution), time,
  )
]

#let intern-heading(company: [], location: [], time: []) = [
  #grid(
    columns: (3fr, 1fr),
    align: (left, right),
    [
      #strong(company)
      #if location != [] [
        | #location]],
    time,
  )
]


#let award(title: [], time: []) = [
  #grid(
    columns: (3fr, 1fr),
    align: (left, right),
    [- #title], time,
  )
]
