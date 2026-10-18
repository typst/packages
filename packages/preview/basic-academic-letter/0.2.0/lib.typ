#let basic-academic-letter(
  body,
  main-color: navy,
  logo-frac: 1.2fr,
  info-frac: 1fr,
  logo-img: image,
  signature-img: image,
  school: content,
  university: content,
  site: content,
  phone: content,
  website: content,
  date: datetime.today().display(
    "[month repr:long] [day], [year]"
  ),
  per-name: str,
  per-homepage: str,
  per-school: str,
  per-university: str,
  per-title: str,
  per-email: str,
  // Content parameters
  salutation: "To Whom It May Concern,",
  closing: "Sincerely,",
  // Spacing parameters
  header-bottom-margin: 0cm,
  date-bottom-margin: 0.5cm,
  salutation-bottom-margin: 0.5cm,
  body-bottom-margin: 0.5cm,
  closing-bottom-margin: 0cm,
  signature-bottom-margin: 0cm,
) = {
  set text(font: "Times New Roman", size: 11pt)
  set par(justify: true, leading: 0.65em)
  set page(
    paper: "a4",
    margin: (top: 1.8cm, bottom: 1.8cm, left: 2cm, right: 2cm)
  )
  show link: underline
  // show link: set text(fill: main-color.darken(50%))
  // Header with logo and info
  grid(
    columns: (logo-frac, info-frac),
    inset: 10pt,
    align: (center + horizon, left),
    grid.vline(x: 1, stroke: 1pt),
    // Left column - Logo (centered)
    [#figure(logo-img)],

    // Right column - info
    [
      #if school     != none [ #text(weight: "bold", fill: main-color, school) \ ]
      #if university != none [ #text(weight: "bold", fill: main-color, university) \ ]
      #if site       != none [ #site \ ]
      #if phone      != none [ #text(weight: "bold", fill: main-color)[Tel]: #phone\ ]
      #if website    != none [ #text(weight: "bold", fill: main-color)[Url]: #website ]
    ]
  )
  v(header-bottom-margin)
  
  date
  v(date-bottom-margin)
  
  text(weight: "bold")[#salutation]
  v(salutation-bottom-margin)

  body
  v(body-bottom-margin)
  
  text(weight: "bold")[#closing]
  v(closing-bottom-margin)

  align(left)[#signature-img]
  v(signature-bottom-margin)

  [
    #if per-homepage   != none [
        #link(per-homepage)[#per-name] \
    ] else [
        #per-name \
    ]
    #if per-title      != none [ #per-title \ ]
    #if per-school     != none [ #per-school, \ ]
    #if per-university != none [ #per-university \ ]
    #if per-email      != none [ #link("mailto:" + per-email)[#per-email] ]
  ]
}
