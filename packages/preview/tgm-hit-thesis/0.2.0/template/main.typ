#import "lib.typ": *

#show: thesis(
  title: [Keine Panik!],
  subtitle: [Mit Typst durch die Diplomarbeit],
  authors: (
    // ATTENTION: chapters/vorwort.typ:76 references this list of example authors. When changing
    // this list, you need to adjust/remove that line!
    (name: "Arthur Dent", class: [5xHIT], subtitle: [Untertitel des Themengebiets von Arthur Dent]),
    (name: "Ford Prefect", class: [5xHIT], subtitle: [Untertitel des Themengebiets von Ford Prefect]),
    (name: "Tricia McMillan", class: [5xHIT], subtitle: [Untertitel des Themengebiets von Tricia McMillan]),
    (name: "Zaphod Beeblebrox", class: [5xHIT], subtitle: [Untertitel des Themengebiets von Zaphod Beeblebrox]),
  ),
  // the German default supervisor label is the non-gendered "Betreuer", so you can override it here
  // as necessary
  supervisor-label: [Betreuer:in],
  supervisor: [DSc MSc Deep Thought],
  date: datetime(year: 2018, month: 4, day: 4),
  year: [2017/18],
  division: [Medientechnik, Systemtechnik],
  logo: assets.logo(width: 3cm),
  bibliography: bibliography("bibliography.bib"),

  // language: "en",
  // current-authors: "only",
  // strict-chapter-end: true,
)

#include "glossaries.typ"

#declaration(context if text.lang == "de" [
  Ich erkläre an Eides statt, dass ich die vorliegende Arbeit selbstständig verfasst, andere als die angegebenen Quellen/Hilfsmittel nicht benutzt und die den benutzten Quellen wörtlich und inhaltlich entnommenen Stellen als solche kenntlich gemacht habe.
  Für die Erstellung der Arbeit habe ich auch folgende Hilfsmittel generativer KI-Tools [z. B. ChatGPT, Grammarly Go, Midjourney] zu folgendem Zweck verwendet:

  - ChatGPT: eigentlich für eh alles
] else if text.lang == "en" [
  I declare that I have authored this thesis independently, that I have not used other than the declared sources and that I have explicitly marked all material which has been quoted either literally or by content from the used sources.
  I also used the following generative AI tools [e.g. ChatGPT, Grammarly Go, Midjourney] for the following purpose:

  - ChatGPT: for basically everything
] else {
  panic("no statutory declaration for that language!")
})

#include "chapters/kurzfassung.typ"

#show: main-matter()

#include "chapters/vorwort.typ"
// in the main-matter, currently all chapters need to have an explicit `#chapter-end()` to ensure
// correct headers and footers. This can hopefully be removed in the future
// (see https://github.com/typst/typst/issues/2722, https://github.com/typst/typst/issues/4438)
#chapter-end()

#include "chapters/danksagung.typ"
#chapter-end()

#include "chapters/einleitung.typ"
#chapter-end()

#include "chapters/studie.typ"
#chapter-end()

#include "chapters/konzept.typ"
#chapter-end()

#include "chapters/implementierung.typ"
#chapter-end()

#include "chapters/retrospektive.typ"
#chapter-end()

#include "chapters/conclusio.typ"
#chapter-end()
