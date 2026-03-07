// TODO: idk, is kinda wonky to use
#let insert-list-of-abbrv-symbol(
  lang: "en",
  abbreviations: none,
  symbols: none,
) = {
  let title = if lang == "en" {
    "List of Abbreviations and Symbols"
  } else {
    "Lijst van Afkortingen en Symbolen"
  }
  let abbrv = if lang == "en" {
    "Abbreviations"
  } else {
    "Afkortingen"
  }

  let symb = if lang == "en" {
    "Symbols"
  } else {
    "Symbolen"
  }
  set par(first-line-indent: 0em)
  heading(numbering: none, bookmarked: true, level: 1, title)
  if abbreviations != none {
    text(black, weight: "bold", size: 1.3em)[#abbrv]
    v(1em)

    abbreviations
  }

  if symbols != none {
    text(black, weight: "bold", size: 1.3em)[#symb]
    v(1em)

    symbols
  }
}

