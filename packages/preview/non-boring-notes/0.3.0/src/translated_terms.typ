#let get_translation(translations) = {
  if type(translations) != dictionary { return translations }
  return context {
    let current_lang = if text.lang != none and text.lang in translations {
      text.lang
    } else {
      "en"
    }

    let localized_string = translations.at(current_lang, default: translations.at("en", default: ""))
    if localized_string == "" and "en" in translations {
      localized_string = translations.at("en")
    }
    return localized_string
  }
}

#let translated_terms = (
  contents: (
    de: "Inhaltsverzeichnis",
    en: "Contents",
    es: "Contenido",
    it: "Indice",
  ),
  references: (
    de: "Quellen",
    en: "References",
    es: "Referencias",
    it: "Riferimenti bibliografici",
  ),
  chapter: (
    de: "Kapitel",
    en: "Chapter",
    es: "Capítulo",
    it: "Capitolo",
  ),
  lof: (
    de: "Abbildungsverzeichnis",
    en: "List of Figures",
    es: "Índice de Figuras",
    it: "Indice delle figure",
  ),
  lot: (
    de: "Tabellenverzeichnis",
    en: "List of Tables",
    es: "Índice de Tablas",
    it: "Indice delle tabelle",
  ),
  lecture: (
    de: "Vorlesung",
    en: "Lecture",
    es: "Clase",
    it: "Lezione",
  ),
  lol: (
    de: "Quellcodeverzeichnis",
    en: "List of Listings",
    es: "Índice de Listados",
    it: "Indice dei listati",
  ),
  created: (
    de: "Erstellt",
    en: "Created",
    es: "Creado",
    it: "Creato",
  ),
  last_updated: (
    de: "Zuletzt aktualisiert",
    en: "Last updated",
    es: "Última actualización",
    it: "Ultimo aggiornamento",
  ),
  abstract: (
    de: "Zusammenfassung",
    en: "Abstract",
    es: "Resumen",
    it: "Sommario",
  ),
  conjunction: (
    de: "und",
    en: "and",
    es: "y",
    it: "e",
  ),
  assumption: (
    de: "Annahme",
    en: "Assumption",
    es: "Suposición",
    it: "Assunzione",
  ),
  attention: (
    de: "Achtung",
    en: "Attention",
    es: "Atención",
    it: "Attenzione",
  ),
  axiom: (
    de: "Axiom",
    en: "Axiom",
    es: "Axioma",
    it: "Assioma",
  ),
  caution: (
    de: "Vorsicht",
    en: "Caution",
    es: "Precaución",
    it: "Prudenza",
  ),
  conclusion: (
    de: "Fazit",
    en: "Conclusion",
    es: "Conclusión",
    it: "Conclusione",
  ),
  corollary: (
    de: "Korollar",
    en: "Corollary",
    es: "Corolario",
    it: "Corollario",
  ),
  definition: (
    de: "Definition",
    en: "Definition",
    es: "Definición",
    it: "Definizione",
  ),
  example: (
    de: "Beispiel",
    en: "Example",
    es: "Ejemplo",
    it: "Esempio",
  ),
  exercise: (
    de: "Übung",
    en: "Exercise",
    es: "Ejercicio",
    it: "Esercizio",
  ),
  hypothesis: (
    de: "Hypothese",
    en: "Hypothesis",
    es: "Hipótesis",
    it: "Ipotesi",
  ),
  important: (
    de: "Wichtig",
    en: "Important",
    es: "Importante",
    it: "Importante",
  ),
  lemma: (
    de: "Lemma",
    en: "Lemma",
    es: "Lema",
    it: "Lemma",
  ),
  note: (
    de: "Hinweis",
    en: "Note",
    es: "Nota",
    it: "Nota",
  ),
  postulate: (
    de: "Postulat",
    en: "Postulate",
    es: "Postulado",
    it: "Postulato",
  ),
  problem: (
    de: "Problem",
    en: "Problem",
    es: "Problema",
    it: "Problema",
  ),
  proof: (
    de: "Beweis",
    en: "Proof",
    es: "Demostración",
    it: "Dimostrazione",
  ),
  property: (
    de: "Eigenschaft",
    en: "Property",
    es: "Propiedad",
    it: "Proprietà",
  ),
  proposition: (
    de: "Proposition",
    en: "Proposition",
    es: "Proposición",
    it: "Proposizione",
  ),
  quote: (
    de: "Zitat",
    en: "Quote",
    es: "Cita",
    it: "Citazione",
  ),
  remark: (
    de: "Bemerkung",
    en: "Remark",
    es: "Observación",
    it: "Osservazione",
  ),
  solution: (
    de: "Lösung",
    en: "Solution",
    es: "Solución",
    it: "Soluzione",
  ),
  theorem: (
    de: "Satz",
    en: "Theorem",
    es: "Teorema",
    it: "Teorema",
  ),
  tip: (
    de: "Tipp",
    en: "Tip",
    es: "Consejo",
    it: "Suggerimento",
  ),
  warning: (
    de: "Warnung",
    en: "Warning",
    es: "Advertencia",
    it: "Avvertimento",
  ),
  topic: (
    de: "Thema",
    en: "Topic",
    es: "Tema",
    it: "Argomento",
  ),
  unit: (
    de: "Einheit",
    en: "Unit",
    es: "Unidad",
    it: "Unità",
  ),
  question: (
    de: "Frage",
    en: "Question",
    es: "Pregunta",
    it: "Domanda",
  ),
)

// Joins items with commas and a translated "and" before the last one.
// Only English uses a serial comma ("A, B, and C").
#let join_with_and(items) = context {
  let lang = if text.lang in translated_terms.conjunction { text.lang } else { "en" }
  let conjunction = translated_terms.conjunction.at(lang)
  let last = if lang == "en" and items.len() > 2 { ", " + conjunction } else { conjunction }
  items.join(", ", last: last)
}
