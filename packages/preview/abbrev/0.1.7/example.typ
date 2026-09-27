#import "@preview/abbrev:0.1.7": *
// or locally:
// #import "./lib.typ": *

= Exemple of use
#define-abbreviations((
  "GPU": "Graphics Processing Unit",
  "XML": "Extensible Markup Language",
  "CPU": "Central Processing Unit",
))

#abbreviation-outline(
  title: [Abbreviations],
)

= Text

The first #abbr("GPU", form: "full") call can use the full form.
Later mentions can use #abbr("GPU") only.

You can also print another form, such as #abbr("XML", form: "long"), or add a suffix like #abbr("CPU", suffix: "s").

In French, #abbr("GPU") is called _#abbr("GPU", form: "long", alt-long: "Unité de traitement graphique")_.

This is page #context [#counter(page).display()].

#pagebreak()

More text can keep using #abbr("XML").

This is page #context [#counter(page).display()].

#pagebreak()

More text can keep using #abbr("GPU").

This is page #context [#counter(page).display()].

#pagebreak()

More text can keep using #abbr("GPU") and #abbr("XML").

This is page #context [#counter(page).display()].
