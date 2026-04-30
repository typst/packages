#import "@preview/cuti:0.2.1": show-cn-fakebold

// Generic résumé/CV template for postgraduate admission applications.
#let theme-color = rgb("#3d538c")
#let highlight-red = rgb("#C00000")

#let cv(
  accent-color: theme-color,
  paper: "a4",
  margin: (left: 1.5cm, right: 1.5cm, top: 1.5cm, bottom: 1.16cm),
  header-logo: none,
  header-logo-height: auto,
  header-title: [Postgraduate Admission CV],
  header-title-size: 16pt,
  header-gutter: 1em,
  footer: none,
  doc,
) = {
  show: show-cn-fakebold

  let page-header = if header-title == none and header-logo == none {
    none
  } else [
    #set align(center + horizon)
    #rect(
      width: 116.8%,
      height: 1.5cm,
      fill: accent-color,
      inset: 8pt,
      [
        #if header-logo == none [
          #align(center + horizon)[
            #text(fill: white, size: header-title-size)[#header-title]
          ]
        ] else [
          #grid(
            columns: (auto, 1fr),
            gutter: header-gutter,
            image(header-logo, height: header-logo-height),
            align(right + horizon)[
              #text(fill: white, size: header-title-size)[#header-title]
            ],
          )
        ]
      ],
    )
  ]

  let page-footer = if footer == none {
    none
  } else [
    #set align(center)
    #rect(
      width: 200%,
      fill: accent-color,
      radius: 4pt,
      inset: 8pt,
      [
        #text(fill: white, size: 10pt)[#footer]
      ],
    )
  ]

  set page(
    paper: paper,
    margin: margin,
    header: page-header,
    footer: page-footer,
  )

  set text(font: ("Times New Roman", "STKaiti", "SimSun"), size: 10.5pt)
  set par(justify: true, leading: 0.65em)
  set list(indent: 0pt, body-indent: 0.5em, marker: "•")
  show list: set block(spacing: 0.65em)

  doc
}

#let cv-header(
  name,
  subtitle,
  contact,
  avatar: none,
  avatar-width: 2.35cm,
  name-size: 22pt,
  name-font: "STKaiti",
  info-size: 9.5pt,
) = {
  align(center)[
    #text(size: name-size, font: name-font, weight: "bold")[#name]\

    #text(size: info-size)[#subtitle]

    #text(size: info-size)[#contact]
  ]

  if avatar != none {
    place(top + right, dy: 0cm)[
      #image(avatar, width: avatar-width)
    ]
  }
}

#let section(title, icon, accent-color: theme-color) = {
  v(1.2em, weak: true)
  block[
    #text(size: 13pt, weight: "bold", fill: accent-color)[#icon #h(0.2em) #title]
    #v(-0.6em)
    #line(length: 100%, stroke: 1.2pt + accent-color)
  ]
  v(0.5em, weak: true)
}

#let item(left-content, right-content) = {
  block(width: 100%)[
    #left-content #h(1fr) #right-content
  ]
}

#let resume = cv
#let resume-header = cv-header
