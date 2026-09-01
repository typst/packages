// ---------------------------------------------------------------------------
// --------------------------------TITLEPAGE----------------------------------
// ---------------------------------------------------------------------------

/// Renders the thesis title page.
///
/// The title page contains the university logo, institution information,
/// thesis title and type, author and supervisor names, and the submission date.
///
/// The number of author/supervisor rows is determined by the longer of the two
/// supplied lists. Missing entries are rendered as empty strings.
///
/// - `authors`: Array of author names.
/// - `date`: Formatted submission date.
/// - `department`: Name of the department.
/// - `industrial-advisors`: Array of industrial advisors' names.
/// - `lang-consts`: Localized strings used on the title page.
/// - `supervisors`: Array of supervisor names.
/// - `thesis-type`: Thesis type key, such as `"bsc"` or `"msc"`.
#let titlepage(
  authors,
  date,
  department,
  industrial-advisor,
  lang-consts,
  supervisors,
  thesis-type,
) = {
  align(top + center)[
    #image("./../assets/bme_logo.pdf", width: 6cm)

    #text(weight: "bold")[#lang-consts.university] \
    #lang-consts.faculty \
    #department

    #v(5.4cm)

    #show title: set text(size: 21pt)

    #title() \
    #text(size: 14pt)[
      #upper(lang-consts.at(thesis-type, default: thesis-type))
    ]

    #v(4cm)
  ]

  align(center)[
    #let row-count = calc.max(authors.len(), supervisors.len())

    #grid(
      columns: (1fr, 1fr),
      row-gutter: 0.2cm,

      text(style: "italic")[#lang-consts.authors],
      text(style: "italic")[#lang-consts.supervisor],

      ..range(0, row-count)
        .map(i => (
          text(authors.at(i, default: "")),
          text(supervisors.at(i, default: "")),
        ))
        .flatten(),
    )

    #if (industrial-advisor.len() != 0) {
      v(0.5cm)

      grid(
        columns: (1fr, 1fr),
        row-gutter: 0.2cm,
        [],
        text(style: "italic")[#lang-consts.industrial-advisor],

        ..range(0, row-count)
          .map(i => (
            [],
            text(industrial-advisor.at(i, default: "")),
          ))
          .flatten(),
      )
    }
  ]

  align(bottom + center)[
    #text(date)
  ]

  pagebreak()
}