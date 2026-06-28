#import "../utils.typ": *

#let titlepage(
  title: "",
  title-translation: "",
  date: none,
  author: "",
  id: none,
  supervisors: none,
  course-of-study: "Informatik",
  gender: none,
  supervisor-gender: none,
  draft: true
) = {
  align(center, [
    #v(1cm)

    #image("../media/HM_logo.jpg")

    Hochschule München \
    Fakultät für Informatik und Mathematik

    #v(2cm)

    #text(size: 14pt)[Bachelorarbeit]

    #text(size: 16pt, weight: "bold", title)

    #text(size: 14pt, title-translation)

    #v(0.5cm)

    #text(size: 14pt)[
      #if draft {
        emph(text()[ENTWURF])
      } else {
        [
          Abgabetermin \
          #date
        ]
      }
    ]

    #v(1fr)

    #if gender == "m" {
      [Autor:]
    } else if gender == "w" {
      [Autorin:]
    } else if gender == "d" or gender == none {
      [Verfassende Person:]
    }
    #author

    Matrikelnummer: #id

    Studiengang: #course-of-study

    #if type(supervisors) == array [
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

  ])
  pagebreak()
}
