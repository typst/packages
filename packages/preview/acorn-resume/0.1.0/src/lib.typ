#let resume(
  author: none,
  font: "Calibri",
  font_size: 11pt,
  link_style: (
    color: black,
    underline: true
  ),
  margin: (
    x: 1.5cm,
    y: 1.5cm
  ),
  body,
) = {

  set document(
    author: author,
    title: author
  )

  set text(
    font: font,
    size: font_size,
    hyphenate: false,
    ligatures: false
  )

  set page(
    margin: margin
  )

  show link: it => {
    set text(
      fill: link_style.color
    )

    if link_style.underline {
      underline(it, offset: 3pt)
    } else {
      it
    }
  }

  show heading.where(level: 1):it => [
    #set text(
      size: 26pt,
      tracking: 1pt
    )
    #upper(it)
  ]

  show heading.where(level: 2):it => [
    #pad(top: 0.15em, bottom: -0.8em, upper(it.body))
    #line(length: 100%)
  ]

  set par(justify: true)

  body
}

#let header(name: none, contacts: none, position: center) = align(
  position,
  [
    = #name
    #contacts.map(((url, label)) => link(url)[#label]).join(" | ")
  ]
)

#let section_header(title, date, subtitle, location: none) = grid(
  columns: (1fr, auto),
  gutter: 8pt, [*#title*],
  align(right, date),
  subtitle,
  align(right, location)
)

#let padding_top = 0.15em

#let exp(role: none, date: none, organization: none, location: none, details: none) = {
  pad(
    top: padding_top,
    section_header(role, date, organization, location: location),
  )
  details
}

#let edu(degree: none, date: none, institution: none, gpa: none, location: none) = {
  let subtitle = if gpa != none [
    #institution | GPA: #gpa
  ] else [
    #institution
  ]

  pad(
    top: padding_top,
    section_header(degree, date, subtitle, location: location)
  )
}

#let project(name: none, technologies: none, liveUrl: none, repoUrl: none, details: none) = {
  let links = ()
  if liveUrl != none {
    links.push(link(liveUrl)[*Live*])
  }
  if repoUrl != none {
    links.push(link(repoUrl)[*GitHub*])
  }

  pad(
    top: padding_top,
    grid(columns: (1fr, auto),
    [
      *#name* | #technologies.map(it => emph(it)).join(", ")
    ],
    align(right, links.join(" | ")))
  )
  details
}
