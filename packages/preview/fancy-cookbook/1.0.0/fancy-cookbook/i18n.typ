// =============== i18n =====================
// --------- Given Translations -------------
#let translations = state(
  "translations",
  (
    fr: (
      toc: "Table des Matières",
      ingredients: "INGRÉDIENTS",
      preparation: "PRÉPARATION",
      notes: "NOTES DU CHEF",
      author: "AUTEUR",
      annexes: "Annexes",
      index: "Index Thématique"
    ),
    en: (
      toc: "Table of Contents",
      ingredients: "INGREDIENTS",
      preparation: "PREPARATION",
      notes: "CHEF'S NOTES",
      author: "AUTHOR",
      annexes: "Appendices",
      index: "Thematic Index"
    ),
    es: (
      toc: "Tabla de Contenido",
      ingredients: "INGREDIENTES",
      preparation: "PREPARACIÓN",
      notes: "NOTAS DEL CHEF",
      author: "AUTOR",
      annexes: "Anexidades",
      index: "Índice temático"
    ),
    por: (
      toc: "Índice",
      ingredients: "INGREDIENTES",
      preparation: "PREPARAÇÃO",
      notes: "NOTAS DO CHEF",
      author: "AUTOR",
      annexes: "Anexos",
      index: "Índice Temático"
    )
  )
)

// -------------- Gears of translation --------------------
// like an enum to use when needed
#let i18n = (
  toc: "toc",
  ingredients: "ingredients",
  preparation: "preparation",
  notes: "notes",
  author: "author",
  annexes: "annexes",
  index: "index"
)

// To merge the given dictionary with a custom one
#let update-translation(t) = context {
  let base = translations.get()
  let lang-key = t.keys().first()        
  let previous = base.at(lang-key, default: (:))  // find the language already given

  // Merge it with the custom values
  let merged-lang = previous + t.at(lang-key)

  // Merge the full dictionary and save it
  let merged = base
  merged.insert(lang-key, merged-lang)
  translations.update(merged)
}

// translate the labels with text.lang ("en" by default)
#let translate(key) = context {
  let lang = if text.lang != none {
      text.lang
    } else {
      "en"
    }
  let dict = translations.get().at(lang, default: translations.get().at("en"))
  dict.at(key, default: key)
}