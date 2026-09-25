#import "@preview/abbrev:0.2.0": *
// or locally:
//#import "./lib.typ": *
#let this-page = context counter(page).get().at(0)
= Test of new functionalities
This is page #this-page.

// Default category : abbreviations
#abbrev-def("GPU", "Graphics Processing Unit")
#abbrev-def((
  "CPU": "Central Processing Unit",
  "XML": "Extensible Markup Language",
))
#abbrev-def("ie", (short: to-nnbsp("i. e."), long: "id est"))
#abbrev-def("etc", (short: "etc.", long: "et cetera"))

// Glossaire
#term-def("API", "Application Programming Interface")
#term-def(
  "Typst",
  (
    short: [#text(
      "Typst",
      size: 1.05em,
      //font: "Buenard",
      weight: "bold",
      fill: rgb("#239dad"),
    )],
    long: [A *langage* for _typesetting_ documents],
  ),
)

// Symboles
#symbol-def(
  "H2O",
  (
    short: [H#sub("2")O],
    long: [water],
  ),
)
#symbol-def("NaCl", "sodium chloride")
#symbol-def("$", "Canadian dolar")
#symbol-def("€", "Euro")

// Acronymes
#acronym-def(
  "NASA",
  "National Aeronautics and Space Administration",
)
#acronym-def(
  "laser",
  "light amplification by stimulated emission of radiation",
)

// Catégorie personnalisée
#add-category("unit", title: "Units")
#abbrev-def("km", "kilometre", category: "unit")
#abbrev-def("kg", "kilogram", category: "unit")


== Abbreviations
Use the default category (`"abbrev"`) for anything, or only for abbreviations (like "#abbrev("ie")").

Short form: #abbrev("GPU").

Long form: #abbrev("GPU", form: "long").

Full form: #abbrev("GPU", form: "full").

With a suffix: #abbrev("CPU", suffix: "s").

With an alternative long form:
#abbrev(
  "GPU",
  form: "long",
  alt-long: [Processeur graphique],
) is French for #abbrev("GPU", form: "full").


== Glossary
Use the glossary term category (`"term"`) to reference some specific words.

Short form: #term-entry("API").

Long form: #term-entry("API", form: "long").

Full form: #term-entry("API", form: "full").

Definition with styled content :
#term-entry("Typst", form: "full").


== Symbols
Use the symbol category (`"symbol"`) for chemical or other types of symbols, like currency symbols.

Short form: #symbol-entry("H2O").

Long form: #symbol-entry("H2O", form: "long").

Full form: #symbol-entry("H2O", form: "full").

Other symbols: #symbol-entry("NaCl", form: "full"), #symbol-entry("$", form: "full").


== Acronyms
Use the acronym category (`"acronym"`) for abbreviations that are possible to pronounce like words.

Short form: #acronym-entry("NASA").

Long form: #acronym-entry("NASA", form: "long").

Full form: #acronym-entry("laser", form: "full").


== Custom category
Create your own category (for example, `"unit"`).

Short form: #abbrev("km", category: "unit").

Long form: #abbrev("kg", form: "long", category: "unit").

Full form: #abbrev("km", form: "full", category: "unit").


#pagebreak()

== Catalogues' outlines
This is page #this-page.

#abbrev-outline(
  title: [Abbreviations and initialisms],
  level: 3,
)

#term-outline(
  title: [Glossary],
  level: 3,
  show-pages: false,
)

#symbol-outline(level: 3)

#acronym-outline(
  title: [Acronyms],
  level: 3,
)

#abbrev-outline(
  title: [Units],
  category: "unit",
  level: 3,
  separator: [:],
  fill: line(length: 100%, start: (0%, 0.65em)),
  gutter: 2em,
)

#pagebreak()
== Use abbreviations anywhere in the document
This is page #this-page.

You can reference your abbreviations, glossary terms anywhere, #abbrev("etc") in your document, but you must define them before their use.

For example: #abbrev("GPU", form: "full") as know as _#abbrev("GPU", alt-long: "Processeur graphique", form: "long")_ in French, #abbrev("etc")

This costs 23 #symbol-entry("$"). If you want 23 #abbrev("kg", category: "unit") of #symbol-entry("H2O") maybe you are thirsty.


