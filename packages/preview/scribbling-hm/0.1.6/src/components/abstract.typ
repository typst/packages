#import "../utils.typ": *

#let abstract-page(
  two-langs: true,
  abstract: none,
  abstract-translation: none
) = {
  heading("Zusammenfassung")

  text(if abstract != none {abstract} else {todo[Zusammenfassung]})

  if two-langs == true {
    heading("Abstract")

    text(if abstract-translation != none {abstract-translation} else {todo[Abstract]})
  }

  pagebreak()
}