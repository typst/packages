// =============================================================================
// src/components/front-matter.typ: ABET front matter table and authors rendering
// =============================================================================

#import "../utils.typ": normalize-color, to-plain-string

/// Renders a single author entry, displaying name and optional student code and email.
///
/// - a (str, dictionary, content, none): Author information.
/// -> content
#let render-author(a) = {
  if a == none {
    "—"
  } else if type(a) in (str, content) {
    a
  } else if type(a) == dictionary {
    let name = a.at("name", default: "—")
    let extras = ("code", "email")
      .map(k => a.at(k, default: none))
      .filter(v => v != none)
      .map(v => to-plain-string(v).trim())
      .filter(s => s != "")
    if extras.len() > 0 [#name (#extras.join(", "))] else [#name]
  } else {
    to-plain-string(a)
  }
}

/// Renders the ABET "INFORMACIÓN BÁSICA" front matter table and document header title.
///
/// - title (str, content): Laboratory practice title.
/// - lab-number (str, int, content): Laboratory number.
/// - course (str, content): Course name.
/// - semester (str, content): Semester code.
/// - academic-year (str, content): Academic year.
/// - date (str, content): Presentation date string.
/// - time (str, content): Presentation time string.
/// - authors (array): Normalized array of authors.
/// - instructor (str, content): Instructor name.
/// - primary-color (color, str): Primary theme accent color.
/// - main-title (str, content): Document main title.
/// -> content
#let render-front-matter(
  title: "",
  lab-number: "1",
  course: "",
  semester: "",
  academic-year: "",
  date: "",
  time: "",
  authors: (),
  instructor: "",
  primary-color: rgb("#C8310E"),
  main-title: "INFORME DE LABORATORIO",
) = {
  let front-matter-table = table(
    align: left + horizon,
    stroke: black + 0.5pt,
    inset: 0.5em,
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    table.cell(
      colspan: 6,
      fill: normalize-color(primary-color),
      align: center + horizon,
      text(weight: "bold", size: 11pt, fill: white)[INFORMACIÓN BÁSICA],
    ),
    [*Asignatura:*], table.cell(colspan: 5, [#course]),
    [*Título de la práctica:*], table.cell(colspan: 5, [#title]),
    [*Número de la práctica:*], [#lab-number],
    [*Año lectivo:*], [#academic-year],
    [*Nro. semestre:*], [#semester],
    [*Fecha de presentación:*], [#date],
    [*Hora de presentación:*], table.cell(colspan: 3, [#time]),
    table.cell(
      colspan: 4,
      [
        *Integrante(s):*
        #set list(marker: "-")
        #if authors.len() > 0 {
          for a in authors [
            - #render-author(a)
          ]
        } else [
          - —
        ]
      ],
    ),
    [*NOTA:*], [Nota colocada por el docente],
    table.cell(
      colspan: 6,
      [
        *Docente:*\
        #instructor
      ],
    ),
  )

  align(center)[#text(size: 13pt, weight: "bold", fill: black)[#main-title]]
  v(0.5em)

  block(width: 100%)[
    #set text(size: 8.5pt, hyphenate: false)
    #set par(justify: false)
    #front-matter-table
  ]

  v(1em)
}
