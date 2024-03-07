#import "@preview/polylux:0.3.1": *

#let primaryColor = rgb("#31a250")

#let ifsclean-footer = state("ifsclean-footer", [])

#let footer = [
  #set align(right + bottom);
  #set text(size: .6em, fill: rgb("#b2b2b2"))

  #pad(0.5em)[
    #counter(page).display("1 / 1", both: true)
  ]
]

#let ifsclean-theme(aspect-ratio: "16-9", body) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    margin: 0em,
    header: none,
    footer: none,
  )

  set text(size: 2em, font: "FreeSans")

  show footnote.entry: set text(size: .6em)

  ifsclean-footer.update(footer)

  body
}

#let title-slide(
  title: "IFSC Polylux",
  subtitle: "Uma tema clean para apresentações",
  authors: ((name: "Rafael Rinaldi", email: "ifsc@example.com")),
  date: "12/12/2012",
) = {
  set text(white)

  box(
    fill: primaryColor,
    width: 100.1%,
    height: 100.1%,
    inset: (x: 4em, top: 5em, bottom: 2em),
  )[
      #box()[#text([*#title*], size: 2em)]
      #v(0.25em)
      #box()[#text(subtitle)]

      #align(right + bottom)[
        *#authors.name* \
        #authors.email \
        #date
      ]

      #align(left + bottom)[
        #image("/assets/ifsc-logo-h-branco.png", width: 8em)
      ]
    ]
}

#let slide(title: none, body) = {
  if title != none {
    [*#title*]
  } else {
    [*#utils.current-section*]
  }

  utils.current-section
  body

  ifsclean-footer.display()
}

#let new-section-slide(name: "section") = {
  set page(fill: primaryColor, margin: (x: 1.5em, y: 2.5em))
  set align(left + bottom)
  set text(fill: white, size: 2.5em)

  utils.register-section(name)

  [*#name*]
}