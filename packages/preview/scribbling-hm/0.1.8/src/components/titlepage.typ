#import "../utils.typ": *
#import "../study-info.typ": *

#let titlepage(
  title: none,
  title-translation: none,
  date: none,
  author: none,
  id: none,
  supervisors: none,
  study-info: none,
  gender: none,
  supervisor-gender: none,
  draft: true,
  date-today: none,
) = {
  align(center, [
    #v(1cm)

    #image("../media/HM_logo.png", width: 45%)

    Hochschule München \
    #study-info.fk

    #v(2cm)

    #text(size: 14pt)[#study-info.thesis-type \ zur Erlangung des akademischen Grades \ #study-info.degree]

    #text(size: 16pt, weight: "bold", if (title != none) {
      title
    } else {
      todo[Titel]
    })

    #text(size: 14pt, if (title-translation != none) {
      title-translation
    } else { todo[Title] })

    #v(0.5cm)

    #text(size: 14pt)[
      #if draft {
        text(hm-color)[
          ENTWURF \
          Stand: #date-today]
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
      if gender == "m" {
        [Autor: ]
      } else if gender == "w" {
        [Autorin: ]
      } else if gender == "d" or gender == none {
        [Verfassende Person: ]
      }
      author
    } else { todo[Autor] }

    #if (id != none) { [Matrikelnummer: #id] } else { todo[Matrikelnummer] }

    Studiengang: #study-info.name

    #if (supervisors != none) {
      if type(supervisors) == array [
        [Prüfende Personen:]
        #supervisors.join(", ")
      ] else [
        #if supervisor-gender == "m" {
          [Prüfer:]
        } else if supervisor-gender == "w" {
          [Prüferin:]
        } else if supervisor-gender == "d" or supervisor-gender == none {
          [Prüfende Person:]
        }
        #supervisors
      ]
    } else {
      todo[Prüfer]
    }

  ])
  pagebreak()
}
