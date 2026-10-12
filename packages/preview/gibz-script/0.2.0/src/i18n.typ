// i18n: central place for all translatable strings
#import "../src/state.typ": gibz-lang

// Translation table
#let _L = (
  de: (
    exercise: "Aufgabe",
    results-recording: "Ergebnissicherung",
    evaluation: "Auswertung",
    individual-work: "Einzelarbeit",
    partner-work: "Partnerarbeit",
    minutes: "Minuten",
    supplementary-material: "Zusatzmaterial",
    table-of-contents: "Inhalt",
    module-word: "Modul",
  ),
  en: (
    exercise: "Exercise",
    results-recording: "Results recording",
    evaluation: "Evaluation",
    individual-work: "Individual work",
    partner-work: "Partner work",
    minutes: "minutes",
    supplementary-material: "Supplementary Material",
    table-of-contents: "Table of Contents",
    module-word: "Module",
  ),
)

// Resolve a label by key. Language resolution order:
// explicit `lang` > state `gibz-lang` > "de"
#let t(key, lang: none) = {
  let L = if lang != none { lang } else { gibz-lang.get() }

  // Get dictionary for this language, or English fallback
  let dict = if _L.at(L) != none { _L.at(L) } else { _L.at("en") }

  // Lookup key in chosen dict
  if dict.at(key) != none {
    dict.at(key)
  } else if _L.at("en").at(key) != none {
    // Fallback to English if key missing in chosen language
    _L.at("en").at(key)
  } else {
    // Last-resort: show the key
    str(key)
  }
}
