#import "components.typ": body-font, variable-pagebreak

#let oot-abstract(lang: "en", is-doublesided: none, body) = {
  set text(lang: lang)

  v(0.1fr)

  align(center, text(
    font: body-font,
    1em,
    weight: "semibold",
    if lang == "de" [Zusammenfassung] else [Abstract],
  ))
  linebreak()
  text(body)

  v(1fr)

  variable-pagebreak(is-doublesided)
}