#import "../translations.typ": translations

#let abstract_page(
  author: "",
  title: "",
  keywords: (),
  abstract: "",
) = {
  let custom_title(title) = {
    text(title, weight: "bold")
  }

  set par(justify: true)

  stack(
    spacing: 10mm,
    custom_title(author),

    v(9mm),

    custom_title(translations.title-thesis),
    v(6mm),
    text(title),

    v(9mm),

    custom_title(translations.keywords),
    v(6mm),
    if type(keywords) == array {
      text(keywords.join(", "))
    } else {
      text(keywords)
    },

    v(9mm),

    custom_title(translations.abstract),
    v(6mm),
    text(abstract),
  )
}
