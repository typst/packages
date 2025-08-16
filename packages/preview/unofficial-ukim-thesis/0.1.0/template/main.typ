#import "uthesis.typ": *

#show: uthesis.with(
  title-mk: "Рамански спектри на кофеин",
  title-en: "Raman spectra of caffeine",
  institution: "Институт за хемија, Природно-математички факултет, Универзитет „Св. Кирил и Методиј“ Скопје ",
  logo: image("logo.png", width: 30%),
  author: "Студент Студентовски", 
  year: "2025",
  location: "Скопје",
  mentor: "Ментор: Проф. д-р Ментор",
  committee: (
    "Членови на комисијата:       Член 1",
    "                                                               Член 2", 
    "                                                               Член 3"
  ),
  defense-date: "Датум на одбраната: 01.01.2025",
  promotion-date: "Датум на промоција: 01.01.2025",
  abstract-mk: [
    Апстракт на македонски.
  ],
  keywords-mk: ("клучен збор 1", "клучен збор 2", "клучен збор 3"),
  abstract-en: [
    Abstract written in English. 
  ],
  keywords-en: ("keyword 1", "keyword 2", "keyword 3"),
  dedication: none
)

#abbreviations()

#pagebreak()

#intro()

#pagebreak()

#theory()

#pagebreak()

#experimental() 

#pagebreak()

#results()

#pagebreak()

#conclusion()

#pagebreak()

#bibliography("biblio.yml", title: "Користена литература")
