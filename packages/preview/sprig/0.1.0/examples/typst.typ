// Un cas concret : la carte de Typst lui-même.
//
// Style « documentation » : moyeu sombre en boîte arrondie, feuilles en
// fiches (`note`), palette froide, tiges presque droites — l'ondulation
// convient au tableau de classe, moins à un aide-mémoire technique.
#import "@preview/sprig:0.1.0": *

#set page(width: 25cm, height: auto, margin: 1.1cm, fill: white)
#set text(font: "New Computer Modern", size: 9pt)
#set par(justify: false, leading: 0.68em)
#show raw: set text(font: "DejaVu Sans Mono", size: 0.9em)

#let ic(c, g) = text(fill: c, weight: "bold", size: 1.1em, g)

#mindmap(
  [*Typst*],
  hub-shape: "rounded", hub-ratio: 1.5, radius: 1.55,
  hub-fill: rgb("#0B3C7A"),
  palette: "cool", shape: "note",
  leaf-width: 3.6, weight: 1.05pt, wave: 0.018, stalk: 0.30,
  dist: 6.2,
  start: 90deg,

  branch(title: [Balisage], icon: ic(rgb("#0E7C86"), [◆]), children: (
    branch[#raw("= Titre")],
    branch[#raw("*gras*")],
    branch[#raw("- liste")],
  ))[Le texte s'écrit tel quel ; la syntaxe reste courte.],

  branch(title: [Règles], icon: ic(rgb("#2A9D8F"), [◆]), children: (
    branch[#raw("set")], branch[#raw("show")],
  ))[#raw("#set") règle, #raw("#show") transforme.],

  branch(title: [Script], icon: ic(rgb("#3D5A80"), [◆]), children: (
    branch[#raw("#let")], branch[#raw("#for")], branch[#raw("context")],
  ))[Un vrai langage : fonctions, boucles, valeurs typées.],

  branch(title: [Maths], icon: ic(rgb("#5C80BC"), [◆]))[
    #raw("$ x = (-b + sqrt(Δ)) / (2a) $") — la même syntaxe
    en ligne et hors-ligne.
  ],

  branch(title: [Références], icon: ic(rgb("#6C91BF"), [◆]), children: (
    branch[#raw("<clé>")], branch[#raw("@clé")],
  ))[Étiquettes, renvois, bibliographie Hayagriva ou BibTeX.],

  branch(title: [Paquets], icon: ic(rgb("#7B8CDE"), [◆]), children: (
    branch[Universe], branch[#raw("@local")],
  ))[#raw("#import \"@preview/sprig:0.1.0\": *")],

  branch(title: [Compilation], icon: ic(rgb("#4C956C"), [◆]))[
    #raw("typst compile doc.typ") — ou #raw("watch") pour
    l'aperçu vivant.
  ],
)
