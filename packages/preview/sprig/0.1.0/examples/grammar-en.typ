// A third concrete map, in English: the parts of speech.
//
// Style «carnet» : mode dessiné (`rough`), palette encre, feuilles
// déchirées, moyeu circulaire — la carte qu'on griffonne au tableau, pas
// celle qu'on imprime en couverture.
//
// Sept branches PLUS un second rang : `dist` est relevé à la main. La
// valeur automatique tient compte des cartes du premier rang, pas de la
// couronne d'enfants qui les entoure — un choix délibéré, sans quoi une
// carte à trois rangs partirait très loin pour rien.
#import "@preview/sprig:0.1.0": *

#set page(width: 29cm, height: auto, margin: 1.2cm, fill: rgb("#FBFAF6"))
#set text(font: "New Computer Modern", size: 9.5pt, lang: "en")
#set par(justify: false, leading: 0.70em)

#let ic(c, g) = text(fill: c, weight: "bold", size: 1.1em, g)

#mindmap(
  [*English\ Grammar*],
  rough: true, roughness: 1.2, bowing: 0.9,
  hub-round: true,
  palette: "ink", shape: "torn",
  leaf-width: 3.5, weight: 1.1pt, wave: 0.05, stalk: 0.32,
  dist: 7.4, radius: 1.5,
  start: 90deg,

  branch(title: [Noun], icon: ic(rgb("#5E81AC"), [●]),
    child-dist: 3.0, child-width: 1.7, children: (
      branch[common], branch[proper],
  ))[A person, place or thing: _teacher_, _Algiers_, _idea_.],

  branch(title: [Adjective], icon: ic(rgb("#81A1C1"), [●]),
    child-dist: 3.4, child-width: 1.9, children: (
      branch[comparative], branch[superlative],
  ))[Describes a noun: _a long day_.],

  branch(title: [Verb], icon: ic(rgb("#8FBCBB"), [●]),
    child-dist: 3.5, child-width: 1.7, children: (
      branch(title: [tense], children: (branch[past], branch[present])),
      branch[modal],
  ))[Action or state: _she writes_, _she must write_.],

  branch(title: [Adverb], icon: ic(rgb("#A3BE8C"), [●]),
    child-dist: 3.1, child-width: 1.5, children: (
      branch[manner], branch[time], branch[place],
  ))[Modifies a verb: _he writes neatly_.],

  branch(title: [Pronoun], icon: ic(rgb("#B48EAD"), [●]))[
    Stands for a noun: _I, you, she, it, they_.
  ],

  branch(title: [Preposition], icon: ic(rgb("#D08770"), [●]))[
    Places a noun in time or space: _in, on, at, since_.
  ],

  branch(title: [Conjunction], icon: ic(rgb("#4C566A"), [●]))[
    Joins clauses: _and, but, because, although_.
  ],
)
