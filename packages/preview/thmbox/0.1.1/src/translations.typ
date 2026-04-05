/*
For future consistency we will just order the languages
alphabetically. The exception being English, which will
go first.

If you speak a language that is not already here (or you
spotted a mistake) you are more than welcome to contribute
your changes!

And thank you to all who already did!
*/

/* Start of the part containing the translations */

#let variants = (
  "theorem": (
    "en": "Theorem",
    "ca": "Teorema",
    "de": "Satz",
    "fr": "Théorème",
    "es": "Teorema",
  ),
  "proposition": (
    "en": "Proposition",
    "ca": "Proposició",
    "de": "Proposition",
    "fr": "Proposition",
    "es": "Proposición",
  ),
  "lemma": (
    "en": "Lemma",
    "ca": "Lema",
    "de": "Lemma",
    "fr": "Lemme",
    "es": "Lema",
  ),
  "corollary": (
    "en": "Corollary",
    "ca": "Corol·lari",
    "de": "Korollar",
    "fr": "Corollaire",
    "es": "Corolario",
  ),
  "definition": (
    "en": "Definition",
    "ca": "Definició",
    "de": "Definition",
    "fr": "Définition",
    "es": "Definición",
  ),
  "example": (
    "en": "Example",
    "ca": "Exemple",
    "de": "Beispiel",
    "fr": "Exemple",
    "es": "Ejemplo",
  ),
  "remark": (
    "en": "Remark",
    "ca": "Observació",
    "de": "Bemerkung",
    "fr": "Remarque",
    "es": "Observación",
  ),
  "note": (
    "en": "Note", 
    "ca": "Nota",
    "de": "Notiz",
    "fr": "Note",
    "es": "Nota",
  ),
  "exercise": (
    "en": "Exercise",
    "ca": "Exercici",
    "de": "Übung",
    "fr": "Exercice",
    "es": "Ejercicio",
  ),
  "algorithm": (
    "en": "Algorithm",
    "ca": "Algorisme",
    "de": "Algorithmus",
    "fr": "Algorithme",
    "es": "Algoritmo",
  ),
  "claim": (
    "en": "Claim", 
    "ca": "Afirmació",
    "de": "Behauptung",
    "fr": "Assertion",
    "es": "Afirmación",
  ),
  "axiom": (
    "en": "Axiom", 
    "ca": "Axioma",
    "de": "Axiom",
    "fr": "Axiome",
    "es": "Axioma",
  ),
)

#let proof-dict = (
  "en": "Proof", 
  "ca": "Demostració",
  "de": "Beweis", 
  "fr": "Démonstration", 
  "es": "Demostración",
)

/* End of translations */

#let variant(key) = {
  let lang-dict = variants.at(key, default: key)
  // If default value was returned
  return if type(lang-dict) == str {
    lang-dict
  } else {
    context lang-dict.at(text.lang, default: lang-dict.at("en", default: key))
  }
}

#let proof = context proof-dict.at(text.lang, default: "proof")

// This is currently useless, as automatic rtl
// is not implemented in this package
#let rtl-list = ("ar",)