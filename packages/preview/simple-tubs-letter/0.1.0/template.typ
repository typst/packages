#let tubs-letter(
  lang: "en",
  tubs-logo: rect(width: 50pt, height: 20pt),
  logo-dx: 10%,
  logo-dy: 5%,
  institute-logo: rect(width: 50pt, height: 20pt),
  institute-name: none,
  institute-name-en: none,
  institute-prof: "",
  author: "",
  phone-nr: none,
  fax-nr: none,
  email: none,
  website: none,
  institute-address-header: none,
  to-address: "",
  date: "",
  subject: "",
  body,
  our-ref: none,
  your-ref: none,
) = {
  set document(title: [#subject], author: author)
  set text(font: "Nimbus Sans", lang: lang)

  set page(paper: "a4", number-align: right, numbering: "1/1")

  place(
    top + left,
    line(start: (0%, 7%), end: (110%, 7%), stroke: rgb("#cf363e")),
  )
  place(top + left, tubs-logo, dx: -5%)
  place(top + right, institute-logo, dx: logo-dx, dy: logo-dy)
  let folding_line_x1 = -5%
  let folding_line_x2 = -9%
  place(top + left, line(
    start: (folding_line_x2, 33%),
    end: (folding_line_x1, 33%),
    stroke: 0.2pt + rgb("#cf363e"),
  ))
  let dy = 0.2%
  place(top + left, line(
    start: (folding_line_x2, 50% - dy),
    end: (folding_line_x1, 50% - dy),
    stroke: 0.2pt + rgb("#cf363e"),
  ))
  place(top + left, line(
    start: (folding_line_x2, 50% + dy),
    end: (folding_line_x1, 50% + dy),
    stroke: 0.2pt + rgb("#cf363e"),
  ))

  place(
    top + left,
    dx: 80%,
    dy: 10%,
    text(
      size: 7pt,
      dir: ltr,
    )[
      Technische Universität Braunschweig\

      #if lang == "de" [#institute-name] else if lang == "en" [#institute-name-en] else [#text(fill: ref)[UKNOWN LANGUAGE]]\

      #v(1em)
      #institute-prof
      #v(1em)
      Beethovenstraße 51a\
      38106 Braunschweig\
      Germany\
      #v(1em)
      #if lang == "de" [Verfasst von:] else if lang == "en" [Author:] else [#text(fill: ref)[UKNOWN LANGUAGE]]\
      #author\
      Tel. #phone-nr\
      Fax #fax-nr\
      #email\
      #website

    ],
  )

  place(top + left, text(size: 6pt, weight: "bold")[
    #institute-address-header
  ], dx: 0%, dy: 11%)

  place(top + left, text(size: 10pt)[
    #to-address
  ], dx: 0%, dy: 18%)

  let header_dy = 38.5%

  

  place(
    top + left,
    text(
      weight: "bold",
      size: 7.5pt,
    )[
      #if lang == "de" [Datum: #date] else if lang == "en" [Date: #date] else [#text(fill: ref)[UKNOWN LANGUAGE]]\
    ],
    dx: 80%,
    dy: header_dy,
  )

  place(top + left, text(weight: "bold", size: 10pt)[
    #subject
  ], dx: 0%, dy: 43%)

  set par(justify: true)

  v(48%)

  body
}
