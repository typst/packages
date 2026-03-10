#let print-title-page(title, type-of-work, author-list, info, department, department-en, strings) = {
  v(1.5cm)
  grid(
    columns: (auto, 1fr),
    column-gutter: 1cm,
    align: (top, left),
    image("../logo-h-brs.svg", height: 1.2cm),
    [
      #text(size: 14pt, weight: "bold")[Hochschule \ Bonn-Rhein-Sieg] \
      #text(size: 11pt)[University of Applied Sciences] \
      #v(0.3cm)
      #text(size: 11pt, weight: "bold")[#department] \
      #text(size: 11pt)[#department-en]
    ],
  )

  v(1fr)
  align(center)[
    #if type-of-work != "" {
      text(size: 13pt)[#type-of-work]
      v(0.6cm)
    }
    #text(size: 18pt, weight: "bold")[#title]
    #v(0.2cm)
    #text(size: 11pt)[#strings.author_preposition]
    #v(0.3cm)
    #for a in author-list [
      #text(size: 14pt)[#a] \
    ]
  ]

  v(1fr)
  align(center)[
    #for (label, value) in info [
      #text(size: 11pt, weight: "bold")[#label:] #text(size: 11pt)[#value] \
    ]
    #if info.len() > 0 { v(0.4cm) }
    #text(size: 11pt, weight: "bold")[Hochschule Bonn-Rhein-Sieg] \
    #text(size: 11pt, weight: "bold")[#department] \
    #text(size: 11pt)[Grantham-Allee 20] \
    #text(size: 11pt)[53757 Sankt Augustin]
  ]
  v(1.5cm)
}
