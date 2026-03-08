#let abstract-page(
  two-langs: true,
  abstract: "",
  abstract-translation: ""
) = {
  heading("Zusammenfassung")

  text(abstract)

  if two-langs == true {
    heading("Abstract")

    text(abstract-translation)
  }

  pagebreak()
}