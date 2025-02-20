#let abstract_page(
  language: "en",
  author: "",
  title: "",
  keywords: (),
  abstract: "",
) = {
  // TODO Needed, because context creates empty pages with wrong numbering
  set page(
    numbering: "i",
  )

  let custom_title(title) = {
    text(title, weight: "bold")
  }

  set par(justify: true)

  stack(
    spacing: 10mm,
    custom_title(author),

    v(9mm),

    custom_title(if language == "en" {"Title of thesis"} else {"Thema der Arbeit"}),
    v(6mm),
    text(title),

    v(9mm),

    custom_title(if language == "en" {"Keywords"} else {"Stichworte"}),
    v(6mm),
    text(keywords.join(", ")),

    v(9mm),

    custom_title(if language == "en" {"Abstract"} else {"Kurzzusammenfassung"}),
    v(6mm),
    text(abstract),
  )
}