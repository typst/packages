// Cover ported from the BHT LaTeX template (bhtThesis.sty, S. Tschirley),
// https://prof.bht-berlin.de/tschirley/latex-werkzeuge
#let bht-title-page(
  title: "",
  subtitle: "",
  name: "",
  student-id: "",
  department: "",
  study-program: "",
  degree: "",
  date: none,
  committee: (),
  accent-color: rgb("#004282"),
  cover-font: ("Arial", "Helvetica", "Liberation Sans"),
  bht-logo: "assets/bht-logo-vertical.svg",
  bht-logo-width: 2.25cm,
  bht-elements: "assets/bht-elements.svg",
  bht-studiere: "assets/bht-studiere-vertical.svg",
  labels: (:),
) = {
  assert(degree in ("Bachelor", "Master", ""), message: "degree must be 'Bachelor' or 'Master'")

  let (thesis-kind, degree-name, degree-abbreviation) = if degree == "Master" {
    (labels.at("master-thesis-kind"), labels.at("master-degree"), labels.at("master-abbreviation"))
  } else {
    (labels.at("bachelor-thesis-kind"), labels.at("bachelor-degree"), labels.at("bachelor-abbreviation"))
  }

  let committee-rows = committee.map(entry => if type(entry) == str {
    (role: "", name: entry, institution: "")
  } else {
    (
      role: entry.at("role", default: ""),
      name: entry.at("name", default: ""),
      institution: entry.at("institution", default: ""),
    )
  })

  // Consecutive entries sharing a role are grouped under one bold role header.
  let committee-grid = if committee-rows.len() > 0 {
    let cells = ()
    let previous-role = none
    for row in committee-rows {
      if row.role != "" and row.role != previous-role {
        if previous-role != none {
          cells.push(grid.cell(colspan: 2, v(0.3em)))
        }
        cells.push(grid.cell(colspan: 2, text(weight: "bold", row.role)))
        previous-role = row.role
      }
      cells.push(grid.cell(row.name))
      cells.push(grid.cell(row.institution))
    }
    grid(
      columns: (auto, auto),
      column-gutter: 2em,
      row-gutter: 0.6em,
      ..cells,
    )
  }

  page(header: none, footer: none, numbering: none)[
    #set text(font: cover-font, size: 11pt)
    #set par(justify: true, leading: 0.6em, spacing: 0.6em)

    #grid(
      columns: (1fr, bht-logo-width),
      column-gutter: 8mm,
      align: (left + bottom, right + top),
      {
        text(size: 17.3pt, weight: "bold", fill: accent-color, title)
        if subtitle != "" {
          v(1em, weak: true)
          text(size: 14.4pt, weight: "bold", fill: accent-color, subtitle)
        }
      },
      image(bht-logo, width: bht-logo-width, alt: "BHT logo"),
    )

    #v(1fr)

    #grid(
      columns: (1fr, 15mm),
      column-gutter: 8mm,
      align: (left + bottom, center + bottom),
      {
        labels.at("submitted-by")
        v(1.25em, weak: true)
        text(size: 14.4pt, name)
        v(1.25em, weak: true)
        if student-id != "" {
          labels.at("student-id-label") + ": " + student-id
          v(1.25em, weak: true)
        }
        labels.at("department-prefix") + " " + department
        linebreak()
        labels.at("university-prefix") + " " + labels.at("university")
        linebreak()
        labels.at("thesis-submission") + " " + thesis-kind
        linebreak()
        labels.at("thesis-purpose")
        v(0.95em, weak: true)
        text(weight: "bold", degree-name + " (" + degree-abbreviation + ")")
        v(0.95em, weak: true)
        labels.at("study-program-label")
        v(0.95em, weak: true)
        text(weight: "bold", study-program)
        v(2.8em, weak: true)
        labels.at("date-label") + " "
        date
      },
      image(bht-elements, height: 5.7cm, alt: ""),
    )

    #v(1fr)

    #grid(
      columns: (1fr, 15mm),
      column-gutter: 8mm,
      align: (left + bottom, center + bottom),
      committee-grid,
      image(bht-studiere, height: 4.3cm, alt: "Studiere Zukunft"),
    )
  ]
}
