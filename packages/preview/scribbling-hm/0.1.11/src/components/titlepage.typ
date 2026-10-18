#import "../utils.typ": *
#import "../study-info.typ": *

#let thesis-titlepage(
  title: none,
  title-translation: none,
  date: none,
  author: none,
  id: none,
  supervisors: none,
  study-info: none,
  gender: none,
  examiner-gender: none,
  draft: true,
  date-today: none,
  t: none,
) = {
  align(center, [
    #v(1cm)

    #image("../media/HM_logo.png", width: 45%)

    #t.hm \
    #study-info.fk

    #v(2cm)

    #text(size: 14pt)[#study-info.thesis-type \ #t.for-the-degree-of \ #study-info.degree]

    #text(size: 16pt, weight: "bold", if (title != none) {
      title
    } else {
      todo[#t.title]
    })

    #context {
      text(size: 14pt, if (title-translation != none) {
        title-translation
      } else { if (text.lang == "de") { todo[Title] } })
    }

    #v(0.5cm)

    #text(size: 14pt)[
      #if draft {
        text(hm-color)[
          #t.draft \
          #t.as-of: #date-today]
      } else {
        [
          #t.submission-date \
          #date
        ]
      }
    ]

    #v(1fr)

    #grid(
      columns: (auto, auto),
      row-gutter: 1em,
      column-gutter: 1.5em,
      align: (right, left),

      [#(t.author)(gender: gender)], [#if (author != none) { author } else { todo[#(t.author)("m")] }],

      [#t.student-id], [#if (id != none) { id } else { todo[Matrikelnummer] }],

      [#t.study-program], [#study-info.name],

      [
        #if (supervisors != none) {
          if type(supervisors) == array {
            t.examiners
          } else {
            (t.examiner)(gender: examiner-gender)
          }
        } else {
          (t.examiner)("m")
        }
      ],
      [
        #if (supervisors != none) {
          if type(supervisors) == array {
            supervisors.join("\n")
          } else {
            supervisors
          }
        } else {
          todo[#(t.examiner)("m")]
        }
      ],
    )

  ])
  pagebreak()
}

#let modularbeit-titlepage(
  subject: none,
  project-description: none,
  authors: (),
  draft: true,
  date-today: none,
  study-info: none,
  t: none,
) = {
  align(center, [
    #v(1cm)

    #image("../media/HM_logo.png", width: 45%)

    #t.hm \
    #study-info.fk

    #v(2cm)

    #text(size: 16pt, weight: "bold", if (subject != none) {
      subject
    } else {
      todo[#t.subject]
    })

    #text(size: 14pt)[#t.project-documentation]

    #project-description

    #v(0.5cm)

    #if draft {
      text(hm-color)[
        #t.draft \
        #t.as-of: #date-today]
    } else {
      [
        #t.as-of: #date-today
      ]
    }

    #v(1fr)

    #if (authors != none) {
      if type(authors) == array {
        authors.join("\n")
      } else {
        authors
      }
    }

  ])
  pagebreak()
}
