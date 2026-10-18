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
    en: "Contents",
    es: "Contenido",
  ),
  references: (
    en: "References",
    es: "Referencias",
  ),
  chapter: (
    en: "Chapter",
    es: "Capítulo",
  ),
  lof: (
    en: "List of Figures",
    es: "Índice de Figuras",
  ),
  lot: (
    en: "List of Tables",
    es: "Índice de Tablas",
  ),
  lecture: (
    en: "Lecture",
    es: "Clase",
  ),
  lol: (
    en: "List of Listings",
    es: "Índice de Listados",
  ),
  created: (
    en: "Created",
    es: "Creado",
  ),
  last_updated: (
    en: "Last updated",
    es: "Última actualización",
  ),
  assumption: (
    en: "Assumption",
    es: "Suposición",
  ),
  attention: (
    en: "Attention",
    es: "Atención"
  ),
  axiom: (
    en: "Axiom",
    es: "Axioma",
  ),
  caution: (
    en: "Caution",
    es: "Precaución",
  ),
  conclusion: (
    en: "Conclusion",
    es: "Conclusión",
  ),
  corollary: (
    en: "Corollary",
    es: "Corolario",
  ),
  definition: (
    en: "Definition",
    es: "Definición",
  ),
  example: (
    en: "Example",
    es: "Ejemplo",
  ),
  exercise: (
    en: "Exercise",
    es: "Ejercicio",
  ),
  hypothesis: (
    en: "Hypothesis",
    es: "Hipótesis"
  ),
  important: (
    en: "Important",
    es: "Importante",
  ),
  lemma: (
    en: "Lemma",
    es: "Lema",
  ),
  note: (
    en: "Note",
    es: "Nota",
  ),
  postulate: (
    en: "Postulate",
    es: "Postulado",
  ),
  problem: (
    en: "Problem",
    es: "Problema",
  ),
  proof: (
    en: "Proof",
    es: "Demostración",
  ),
  property: (
    en: "Property",
    es: "Propiedad",
  ),
  proposition: (
    en: "Proposition",
    es: "Proposición",
  ),
  quote: (
    en: "Quote",
    es: "Cita"
  ),
  remark: (
    en: "Remark",
    es: "Observación",
  ),
  solution: (
    en: "Solution",
    es: "Solución",
  ),
  theorem: (
    en: "Theorem",
    es: "Teorema",
  ),
  tip: (
    en: "Tip",
    es: "Consejo",
  ),
  warning: (
    en: "Warning",
    es: "Advertencia",
  ),
)
