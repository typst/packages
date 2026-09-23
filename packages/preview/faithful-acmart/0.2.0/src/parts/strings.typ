// Language settings and localized labels from acmart and Babel.

#let _langs = (
  english: (code: "en",
    keywords: "Additional Key Words and Phrases",
    keywords_proceedings: "Keywords",
    acks: "Acknowledgements", proof: "Proof", table: "Table", abstract: "Abstract",
    references: "References"),
  french: (code: "fr",
    keywords: "Mots Clés et Phrases Supplémentaires",
    keywords_proceedings: "Mots clés",
    acks: "Remerciements", proof: "Démonstration", table: "Table", abstract: "Résumé",
    references: "Références"),
  german: (code: "de",
    keywords: "Zusätzliche Schlagwörter und Phrasen",
    keywords_proceedings: "Schlagwörter",
    acks: "Danksagungen", proof: "Beweis", table: "Tabelle", abstract: "Zusammenfassung",
    references: "Literatur"),
  spanish: (code: "es",
    keywords: "Palabras y Frases Claves Adicionales",
    keywords_proceedings: "Palabras claves",
    acks: "Expresiones de gratitud", proof: "Demostración", table: "Cuadro", abstract: "Resumen",
    references: "Referencias"),
)

// Explicit English loads Babel's British spelling; the class default uses American spelling.
#let default-strings = (
  code: "en",
  keywords: "Additional Key Words and Phrases",
  keywords_proceedings: "Keywords",
  acks: "Acknowledgments", proof: "Proof", table: "Table", abstract: "Abstract",
  references: "References",
)

#let supported-languages = _langs.keys()

#let lang-record(name) = {
  assert(name in _langs,
    message: "faithful-acmart: unsupported language " + repr(name) + "; supported: "
      + repr(supported-languages))
  _langs.at(name)
}

#let resolve-language(language) = {
  if language == none {
    return (..default-strings, main: none)
  }
  assert(type(language) == str, message: "faithful-acmart: `language` must be a single "
    + "language name; secondary languages go in `translations`.")
  (..lang-record(language), main: language)
}
