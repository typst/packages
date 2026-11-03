#import "../lib.typ": sizes

#let cover(
  title: none,
  subtitle: none,
  title-size: sizes.chapter,
  university: none,
  date: datetime.today(),
  course-code: none,
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

  let logo_image = if logo == none {
    // use the default path
    image("../figures/logo.svg", width: logo-width)
  } else if type(logo) == str {
    // use the user-provided path string
    image(logo, width: logo-width)
  } else if type(logo) == content {
    // the user provided their own image() or drawing
    logo
  } else {
    panic("Expected str or content for 'logo', found " + str(type(logo)))
  }

  align(center + top, [
    #figure(
      logo_image,
      numbering: none,
      caption: none,
    )
    #v(3em)
  ])

  align(center, [
    #v(5em)
    #text(weight: "black", size: title-size)[#title]
    #if subtitle != none {
      linebreak()
      v(1em)
      text(size: sizes.subsection)[#subtitle]
    }

    #if is-thesis {
      text(size: sizes.subsubsection)[#thesis-type]
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
      let authors-title = "STUDENT"

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

    #v(10em)
    #if course-code != none {
      text(weight: "bold", size: sizes.section)[#course-code]
      linebreak()
    }

    #if course != none {
      text(weight: "bold", size: sizes.section)[#course]
      linebreak()
    }
  ])

  align(center + bottom, [
    #department
    #linebreak()
    #university
    #linebreak()
    Date
    #linebreak()
    #date.display("[day]/[month]/[year]")
  ])
}