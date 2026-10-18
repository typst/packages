// Title page, colophon, dedication, and abstract pages.

#let title-page(
  title: none,
  author: none,
  degree: none,
  university: none,
  faculty: none,
  department: none,
  supervisors: (),
  location: none,
  date: none,
  version: none,
  draft: false,
) = {
  page(header: none, footer: none)[
    #set align(center)
    #v(3cm)
    #text(size: 22pt, weight: "bold", title)
    #v(1.5cm)
    #text(size: 14pt, author)
    #v(1fr)
    #text(size: 11pt)[
      A dissertation submitted in partial fulfillment of the requirements \
      for the degree of #degree at \
      #university
      #if faculty != none [ \ #faculty ]
      #if department != none [ \ #department ]
    ]
    #v(1cm)
    #if supervisors.len() > 0 {
      text(size: 11pt)[Supervised by \ #supervisors.join(", ")]
    }
    #v(1cm)
    #text(size: 11pt)[
      #if location != none [#location, ]
      #if date != none [#date.display("[month repr:long] [year]")]
    ]
    #v(1cm)
  ]
  // colophon (back of the title page)
  page(header: none, footer: none)[
    #set align(left + bottom)
    #set text(size: 9pt)
    #if draft [Draft #version — compiled #datetime.today().display("[year]-[month]-[day]") \ ]
    © #if date != none [#date.year() ] #author \
    Typeset with Typst.
  ]
}

#let dedication-page(body) = page(
  header: none,
  footer: none,
  align(center + horizon, emph(body)),
)

#let abstract-page(body) = {
  pagebreak(to: "odd", weak: true)
  heading(level: 1, outlined: false, [Abstract])
  body
}
