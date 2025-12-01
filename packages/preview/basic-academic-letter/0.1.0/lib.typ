#let basic-academic-letter(
  body,
  main_color: navy,
  logo_frac: 1.2fr,
  info_frac: 1fr,
  logo_img: image,
  signature_img: image,
  school: content,
  university: content,
  site: content,
  phone: content,
  website: content,
  date: datetime.today().display(
    "[month repr:long] [day], [year]"
  ),
  per_name: str,
  per_homepage: str,
  per_school: str,
  per_university: str,
  per_title: str,
  per_email: str,
  // Content parameters
  salutation: "To Whom It May Concern,",
  closing: "Sincerely,",
  // Spacing parameters
  header_bottom_margin: 0cm,
  date_bottom_margin: 0.5cm,
  salutation_bottom_margin: 0.5cm,
  body_bottom_margin: 0.5cm,
  closing_bottom_margin: 0cm,
  signature_bottom_margin: 0cm,
) = {
  set text(font: "Times New Roman", size: 11pt)
  set par(justify: true, leading: 0.65em)
  set page(
    paper: "a4",
    margin: (top: 1.8cm, bottom: 1.8cm, left: 2cm, right: 2cm)
  )
  show link: underline
  // show link: set text(fill: main_color.darken(50%))
  // Header with logo and info
  grid(
    columns: (logo_frac, info_frac),
    inset: 10pt,
    align: (center + horizon, left),
    grid.vline(x: 1, stroke: 1pt),
    // Left column - Logo (centered)
    [#figure(logo_img)],

    // Right column - info
    [
      #text(weight: "bold", fill: main_color, school) \
      #text(weight: "bold", fill: main_color, university) \
      #site \
      #text(weight: "bold", fill: main_color)[Tel]: #phone\
      #text(weight: "bold", fill: main_color)[Url]: #website
    ]
  )
  v(header_bottom_margin)
  
  date
  v(date_bottom_margin)
  
  text(weight: "bold")[#salutation]
  v(salutation_bottom_margin)

  body
  v(body_bottom_margin)
  
  text(weight: "bold")[#closing]
  v(closing_bottom_margin)

  align(left)[#signature_img]
  v(signature_bottom_margin)

  [
    #link(per_homepage)[#per_name] \
    #per_title \
    #per_school, \
    #per_university \
    #link("mailto:" + per_email)[#per_email]
  ]
}
