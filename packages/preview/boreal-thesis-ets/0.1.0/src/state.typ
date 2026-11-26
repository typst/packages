// ============================================================
// thETS — États partagés entre les modules du gabarit.
// ============================================================

// Langue du document : "fr" ou "en".
#let doc-lang = state("thets-lang", "fr")

// Type de document (valeur canonique anglaise) :
//   thesis | manuscriptbasedthesis | masterdegreethesis
//   | manuscriptbasedmasterdegreethesis | projectreport
#let doc-type = state("thets-type", "thesis")

// Titre et auteur, réutilisés par le résumé et l'abstract.
#let doc-title = state("thets-title", [])
#let doc-author = state("thets-author", "")

// Partie courante : "body" | "annex" | "appendix".
// Pilote la numérotation des chapitres et des flottants.
#let doc-part = state("thets-part", "body")

// Compteur unifié algorithmes + extraits de code (comme \thETScodeblock).
#let algo-counter = counter("thets-algorithm")

// Alias de types documents acceptés en entrée (français et anglais).
#let type-aliases = (
  "these": "thesis",
  "thesis": "thesis",
  "thesepararticles": "manuscriptbasedthesis",
  "manuscriptbasedthesis": "manuscriptbasedthesis",
  "memoire": "masterdegreethesis",
  "masterdegreethesis": "masterdegreethesis",
  "memoirepararticles": "manuscriptbasedmasterdegreethesis",
  "manuscriptbasedmasterdegreethesis": "manuscriptbasedmasterdegreethesis",
  "rapportprojet": "projectreport",
  "projectreport": "projectreport",
)

#let normalize-type(t) = {
  assert(
    t in type-aliases,
    message: "thETS : type de document inconnu « "
      + t
      + " ». "
      + "Valeurs acceptées : "
      + type-aliases.keys().join(", "),
  )
  type-aliases.at(t)
}

#let normalize-lang(l) = {
  let map = (
    "fr": "fr",
    "french": "fr",
    "francais": "fr",
    "en": "en",
    "english": "en",
  )
  assert(l in map, message: "thETS : langue inconnue « " + l + " » (fr ou en).")
  map.at(l)
}

// Familles de documents, utilisées pour choisir les libellés.
#let is-doctorate(t) = t in ("thesis", "manuscriptbasedthesis")
#let is-masters(t) = (
  t in ("masterdegreethesis", "manuscriptbasedmasterdegreethesis")
)
#let is-project(t) = t == "projectreport"
