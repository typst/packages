#import "@preview/paris-saclay-thesis-flat:1.0.2": paris-saclay-thesis, prune

///////////////////////////////////////////
// 1/3 If not already done, download the
//     "Segoe UI This" font (see README)
/////////////////////////////////////////// 

///////////////////////////////////////////
// 2/3 Change the value of the following
//     parameters to edit the first two pages.
//     All parameters have a default value, so
//     you can remove some to highlight which
//     ones are still missing.
/////////////////////////////////////////// 

#show: paris-saclay-thesis.with(
  candidate-name: [Frodon Sacquet],
  title-fr: [Propriétés et conséquences psychiques, magiques et géopoliques du métal Au lorsque forgé en Anneau Unique],
  title-en: [Properties and psychic, magical and geopolitical consequences of Au metal when forged into the One Ring],
  keywords-fr: ("Or", "montagne du Destin", "Magie occulte"),
  keywords-en: ("Gold","Mount Doom", "Occult magic"),
  abstract-fr: lorem(200),
  abstract-en: lorem(200),
  NNT: [1955UPASX000],
  doctoral-school: [École doctorale n°573 : INTERFACES - approches interdisciplinaires,\ fondements, applications et innovation],
  doctoral-school-code: "INTERFACES", // for the logo to insert
  specialty: [Spécialité de doctorat : Sciences des matériaux],
  graduate-school: [Graduate School : Physique],
  university-component: [Référent : Faculté des sciences d'Orsay],
  research-unit-and-advisors: [
    Thèse préparée dans l'unité de recherche *Fondcombe*,\ sous la direction d'*Elrond*, seigneur de Fondcombe,\ 
    et l'encadrement de *Gandalf*, magicien de l'ordre des Istari.
  ],
  defense-date: [20 octobre 1955],
  thesis-examiners: (
    (
      name: [*Aragorn*],
      title: [Roi du Gondor],
      status: [Président]
    ),
    (
      name: [*Legolas*],
      title: [Prince des Elfes Sylvains],
      status: [Rapporteur &\ Examinateur]
    ),
    (
      name: [*Gimli*],
      title: [Guerrier du royaume d'Erebor],
      status: [Rapporteur &\ Examinateur]
    ),
    (
      name: [*Faramir*],
      title: [Intendant du Gondor],
      status: [Examinateur]
    ),
  ),
  // You can also adjust spacings in the first page with
  // `vertical-spacing-1` to `vertical-spacing-5`
  // and `horizontal-spacing-1` to `horizontal-spacing-2`
)

///////////////////////////////////////////
// 3/3 Starting from here, the third page,
//     no formatting is imposed.
//     However here are some tweaks you
//     might like.
///////////////////////////////////////////

// Switch to a serif font family, size 11

#set text(
  font: "Libertinus Serif",
  size: 11pt
)

// Show links in blue

#show link: set text(fill: blue)

// Show numbers in references (to a bibliography entry, a section, a figure) in blue
// thanks Eric Biedert https://github.com/typst/typst/discussions/4143

#show cite: it => {
  // reference to a bibliography entry -> color only the number, not square brackets, not the potential supplement
  show regex("\[",): set text(fill: black) // enforce square brackets in black
  show regex("^\[(\d+)",): set text(fill: blue) // only the first number, in case there is a number in the supplement
  it
}
#show ref: it => {
  if it.element == none {
    // reference to a bibliography entry -> manage by `#show cite` above
    return it
  }
  // reference to a section or a figure
  show regex("[\d]+[\.]?[\d]*[\.]?[\d]*"): set text(fill: blue) // find something like "1", "1.2" or "1.3"
  it
}

// Figure legends in italic and with smaller font size

#show figure.caption: it => [
  #text(size: 10pt, style: "italic")[#it]
]

// Headings numbering & refer to a section with "Chapitre X" instead of "Section X"

#set heading(numbering: "1.1", supplement: "Chapitre")

// Refer to an equation with "Équation X" instead of "Equation X"

#set math.equation(supplement: "Équation")

// Headings formatting

#let heading_text_size = (none, 18pt, 15pt, 12pt, 11pt) // for each heading level
#show heading.where(level: 1): header => {
  set text(
    size: heading_text_size.at(1),
    fill: prune,
    font: "Segoe UI This",
    weight: "bold"
  )
  let number = context counter(heading).display("1 • ") // prefix format
  pagebreak(weak: true) // start level 1 headings on a new page
  block(breakable: false)[
    #if header.numbering != none [ #number ]
    #upper(header.body)
  ]
  v(heading_text_size.at(1)) // same height spacing as the font size
}
#show heading.where(level: 2): header => {
  set text(
    size: heading_text_size.at(2),
    font: "Segoe UI This",
    weight: "bold"
  )
  v(heading_text_size.at(2)) // same height spacing as the font size
  box()[
    #counter(heading).display()~
    #upper(header.body)
  ]
  v(heading_text_size.at(2)) // same height spacing as the font size
}
#show heading.where(level: 3): header => {
  set text(
    size: heading_text_size.at(3),
    font: "Segoe UI This",
    weight: "bold"
  )
  v(heading_text_size.at(3)) // same height spacing as the font size
  box()[
    #h(10pt) // small indent
    #counter(heading).display()~
    #header.body
  ]
  v(heading_text_size.at(3)) // same height spacing as the font size
}

// Headings formatting in the outline

#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true) // small spacing before
  strong(it) // in bold
}
#show outline.entry.where(level: 3): it => {
  text(size: 10pt)[#it] // slightly smaller
}

// Footer with the page number

#set page(footer: context [
    #set align(center)
    #text(
      fill: black,
      size: 12pt,
      weight: "regular"
    )[
      #counter(page).display("1")
    ]
  ]
)

// Text justification

#set par(
  justify: true,
  linebreaks: "optimized"
)

// A "Remarque : " text box

#let remarque(number: none, body) = {
  block(stroke: (left: 1pt), inset: 0.5em)[
    #smallcaps[Remarque #number :] #body
  ] 
}

// "En résumé" & "Publications et communications scientifiques" boxes

#import "@preview/colorful-boxes:1.4.1": colorbox

#let en_résumé(body) = {
  colorbox(
    title: text(font: "Segoe UI This")[En résumé],
    radius: 2pt,
    width: auto,
    color: "default"
  )[
    #body
    #v(2pt)
  ]
}

#let publications(body) = {
  colorbox(
    title: text(font: "Segoe UI This")[Publications et communications scientifiques],
    radius: 2pt,
    width: auto,
    box-colors: (
      prune: (stroke: prune, fill: white, title: white),
    ),
    color: "prune"
  )[
    #body
    #v(2pt)
  ]
}

// Display the outline

#outline(
  title: [Table des matières],
  indent: 1em
)

///////////////////////////////////////////
// Write your thesis below. Bon courage !
///////////////////////////////////////////

= Chapitre <ch:chapitre>

#lorem(50)

#en_résumé[
  #lorem(25)
]

#publications[
  - #lorem(12)
  - #lorem(12)
  - #lorem(12)
]

== Sous-chapitre <ch:sous-chapitre>

#lorem(25)

=== Sous-sous-chapitre <ch:sous-sous-chapitre>

#lorem(50) @bib:concerning-hobbits

#remarque[
  #lorem(25)
]

#lorem(50)

#bibliography("bib.yml", title: [Bibliographie])