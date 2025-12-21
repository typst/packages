#import "../lib.typ": sizes

#let cover(
  title: none,
  subtitle: none,
  title-size: sizes.chapter,
  university: none,
  academic-year: none,
  course: none,
  department: none,
  supervisors: (),
  logo: none,
  logo-width: 110pt,
  is-thesis: false,
  thesis-type: none,
  authors: (),
) = {
  set page(numbering: none)

  if logo == none {
    logo = "../figures/logo.svg"
  }

  align(center + top, [
    #figure(
      image(logo, width: logo-width),
      numbering: none,
      caption: none,
    )
    #strong(department)
    #linebreak()
    #strong(course)
    #linebreak()
    #strong(university)
    #if is-thesis {
      v(3em)
      upper(thesis-type)
    }
    #v(3em)
  ])

  align(center, [
    #text(weight: "bold", size: title-size)[#title]
    #if subtitle != none {
      linebreak()
      v(1em)
      subtitle
    }
    #v(5em)

    #if supervisors.len() == 0 and authors.len() > 0 {
      let ncols = calc.min(authors.len(), 3)
      set text(size: sizes.subsubsubsection)
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 15pt,
        ..authors.map(a => [
          #if type(a) == dictionary {
            for key in a.keys() {
              a.at(key)
              linebreak()
            }
          } else {
            a
          }
        ])
      )
    }
    #if supervisors.len() > 0 and authors.len() > 0 {
      let supervisors-title = "SUPERVISOR"
      let authors-title = "CANDIDATE"

      if authors.len() > 1 {
        authors-title += "S"
      }
      if supervisors.len() > 1 {
        supervisors-title += "S"
      }

      grid(
        columns: (1fr, 1fr),
        row-gutter: 10pt,
        align(left, [
          #text(size: sizes.subsubsubsection, weight: "bold")[#supervisors-title]
        ]),
        align(right, [
          #text(size: sizes.subsubsubsection, weight: "bold")[#authors-title#v(0.5em)]
        ]),
      )

      grid(
        align: top,
        columns: (1fr, 1fr),
        align(left, grid(
          columns: 1fr,
          row-gutter: 15pt,
          ..supervisors.map(s => [#text(size: sizes.body, s)])
        )),
        align(right, grid(
          columns: 1fr,
          row-gutter: 15pt,
          ..authors.map(a => [
            #text(size: sizes.body)[
              #if type(a) == dictionary {
                for key in a.keys() {
                  a.at(key)
                  linebreak()
                }
              } else {
                a
              }
            ]
          ])
        )),
      )
    }
  ])

  if academic-year != none {
    align(center + bottom, [
      Academic year #academic-year
    ])
  }
  pagebreak()
}
