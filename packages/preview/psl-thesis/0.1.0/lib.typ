#import "@preview/linguify:0.4.2": *

#let database = toml("lang.toml")

#let colors = (
  psl: rgb(36, 56, 142),
)

#let psl-front-cover(
  // The thesis title.
  title: [PhD title],
  // The thesis author.
  author: [Thesis author],
  // The institution name.
  institute: [Institute name],
  // Path to the institute logo, or none.
  institute-logo: none,
  // The doctoral school name and number.
  doctoral-school: (
    name: [Doctoral school name],
    number: [Doctoral school number],
  ),
  // The thesis specialty.
  specialty: [Thesis specialty],
  // The defense date.
  date: [Defense date],
  // The jury members.
  jury: (
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "President",
    ),
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "Referee",
    ),
  ),
) = {
  // Page setup.
  set page(
    background: image("assets/front-bg.jpg"),
    margin: (left: 2cm, right: 1.5cm, top: 2cm, bottom: 6cm),
    footer: [
      #if institute-logo != none {
        align(center)[#institute-logo]
      }
    ],
  )
  set text(size: 14pt)

  // Institute name.
  v(5.6cm)
  block(text(linguify("conducted_at", from: database) + [ #institute], fill: colors.psl), width: 10cm)

  // Thesis title.
  v(1cm)
  align(center)[
    #text([*#title*], size: 16pt)
  ]

  // Thesis author, doctoral school, specialty, and jury members.
  v(0.5cm)

  let make-jury-table = {
    set text(size: 11pt)
    table(
      columns: (1fr, 0.6fr),
      stroke: none,
      align: (left, right),
      inset: 0cm,
      row-gutter: 0.5cm,
      column-gutter: 1cm,
      ..jury
        .map(member => {
          (
            [#member.firstname #smallcaps([#member.lastname])\ #member.title],
            [_#member.role _],
          )
        })
        .flatten()
    )
  }

  set rect(
    inset: 0.3cm,
    fill: luma(240),
    width: 100%,
  )

  grid(
    columns: (0.6fr, 1fr),
    rows: 3,
    gutter: 1cm,
    [
      #v(0.3cm)
      #text(linguify("presented_by", from: database), fill: colors.psl)\
      #text([*#author*], size: 16pt)\
      #date
    ],
    grid.cell(
      rowspan: 3,
      rect[
        #text(linguify("jury", from: database), fill: colors.psl)\
        #make-jury-table
      ],
    ),
    [
      #text(linguify("doctoral_school", from: database) + [ #doctoral-school.number], fill: colors.psl)\
      #text([*#doctoral-school.name*], size: 16pt)
    ],
    [
      #text(linguify("specialty", from: database), fill: colors.psl)\
      #text([*#specialty*], size: 16pt)
    ],
  )

  pagebreak()
}

#let psl-back-cover(
  // The thesis abstracts, in French and English.
  abstracts: (
    fr: [Résumé],
    en: [Abstract],
  ),
  // The thesis keywords, in French and English.
  keywords: (
    fr: [mot clé 1, mot clé 2, mot clé 3, mot clé 4],
    en: [keyword 1, keyword 2, keyword 3, keyword 4],
  ),
) = {
  pagebreak()

  set page(
    background: place(top + left, image("assets/back-bg.png")),
    margin: (left: 2cm, right: 1.5cm, top: 2cm, bottom: 4.5cm),
  )

  show heading: it => {
    set text(fill: colors.psl, weight: "light")
    block(smallcaps(it.body))
    v(-0.5cm)
    line(length: 100%, stroke: colors.psl)
  }

  set par(justify: true)
  align(horizon)[
    #heading(level: 1, outlined: false)[Résumé]
    #text(size: 0.9em)[#abstracts.fr]

    #heading(level: 1, outlined: false)[Mots clés]
    #text(size: 0.9em)[#keywords.fr]

    #heading(level: 1, outlined: false)[Abstract]
    #text(size: 0.9em)[#abstracts.en]

    #heading(level: 1, outlined: false)[Keywords]
    #text(size: 0.9em)[#keywords.en]
  ]

  context place(
    bottom + right,
    dx: page.margin.right + 2cm,
    dy: page.margin.bottom + 2cm,
    circle(radius: 2cm, fill: colors.psl),
  )
}

#let psl-thesis-covers(
  // The thesis title.
  title: [PhD title],
  // The thesis author.
  author: [Thesis author],
  // The defense date.
  date: [Defense date],
  // The institute where the thesis was prepared.
  institute: [Institute name],
  // A content (e.g. result of the `image` function) to place in the front cover footer,
  // or none.
  institute-logo: none,
  // The doctoral school name and number.
  doctoral-school: (
    name: [Doctoral school name],
    number: [Doctoral school number],
  ),
  // The thesis specialty.
  specialty: [Thesis specialty],
  // The jury members.
  jury: (
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "President",
    ),
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "Referee",
    ),
  ),
  // The thesis abstracts, in French and English.
  abstracts: (
    fr: [Abstract in French],
    en: [Abstract in English],
  ),
  // The thesis keywords, in French and English.
  keywords: (
    fr: [Keywords in French],
    en: [Keywords in English],
  ),
  // The thesis body.
  doc,
) = {
  psl-front-cover(
    author: author,
    title: title,
    institute: institute,
    institute-logo: institute-logo,
    doctoral-school: doctoral-school,
    specialty: specialty,
    date: date,
    jury: jury,
  )

  doc

  pagebreak(to: "odd", weak: false)
  psl-back-cover(abstracts: abstracts, keywords: keywords)
}
