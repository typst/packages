#import "../utils.typ": *
#import "../study-info.typ": *
#import "../translations.typ": *

#let titlepage(
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
) = {
  align(center, [
    #v(1cm)

    #image("../media/HM_logo.png", width: 45%)

    #translations.hm \
    #study-info.fk

    #v(2cm)

    #text(size: 14pt)[#study-info.thesis-type \ #translations.for-the-degree-of \ #study-info.degree]

    #text(size: 16pt, weight: "bold", if (title != none) {
      title
    } else {
      todo[#translations.title]
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
          #translations.draft \
          #translations.as-of: #date-today]
      } else {
        [
          Abgabetermin \
          #date
        ]
      }
    ]

    #v(1fr)

    #let gendered-author = ""

    #if (author != none) {
      [#author-translation(gender: gender): #author]
    } else { todo[#author-translation("m")] }

    #if (id != none) { [#translations.student-id: #id] } else { todo[Matrikelnummer] }

    #translations.study-program: #study-info.name

    #if (supervisors != none) {
      if type(supervisors) == array [
        [#translations.examiners:]
        #supervisors.join(", ")
      ] else [
        #examiner-translation(gender: examiner-gender): #supervisors
      ]
    } else {
      todo[#examiner-translation("m")]
    }

  ])
  pagebreak()
}
