// Internationalization dictionaries and translation utilities.

#let built-in-dicts = (
  en: (
    chapter: "Chapter",
    collection: "A collection by",
    contents: "Contents",
    ingredients: "INGREDIENTS",
    utensils: "UTENSILS",
    chefs-note: "CHEF'S NOTE",
    note: "NOTE",
    preparations: "PREPARATION",
  ),
  nl: (
    chapter: "Hoofdstuk",
    collection: "Een collectie van",
    contents: "Inhoudsopgave",
    ingredients: "INGREDIËNTEN",
    utensils: "KEUKENGEREI",
    chefs-note: "NOTITIE VAN DE CHEF",
    note: "NOTITIE",
    preparations: "BEREIDINGSWIJZE",
  ),
  de: (
    chapter: "Kapitel",
    collection: "Eine Sammlung von",
    contents: "Inhaltsverzeichnis",
    ingredients: "ZUTATEN",
    utensils: "KÜCHENUTENSILIEN",
    chefs-note: "ANMERKUNG DES KOCHS",
    note: "HINWEIS",
    preparations: "ZUBEREITUNG",
  ),
  pl: (
    chapter: "Rozdział",
    collection: "Kolekcja autorstwa",
    contents: "Spis treści",
    ingredients: "SKŁADNIKI",
    utensils: "PRZYBORY",
    chefs-note: "NOTATKA SZEFA KUCHNI",
    note: "UWAGA",
    preparations: "PRZYGOTOWANIE",
  ),
  fr: (
    chapter: "Chapitre",
    collection: "Une collection de",
    contents: "Sommaire",
    ingredients: "INGRÉDIENTS",
    utensils: "USTENSILES",
    chefs-note: "NOTE DU CHEF",
    note: "NOTE",
    preparations: "PRÉPARATION",
  ),
  es: (
    chapter: "Capítulo",
    collection: "Una colección de",
    contents: "Índice",
    ingredients: "INGREDIENTES",
    utensils: "UTENSILIOS",
    chefs-note: "NOTA DEL CHEF",
    note: "NOTA",
    preparations: "PREPARACIÓN",
  ),
  it: (
    chapter: "Capitolo",
    collection: "Una raccolta di",
    contents: "Indice",
    ingredients: "INGREDIENTI",
    utensils: "UTENSILI",
    chefs-note: "NOTE DELLO CHEF",
    note: "NOTA",
    preparations: "PREPARAZIONE",
  ),
)

// State for user-provided custom dictionaries.
#let user-dicts = state("chef-cookbook-i18n-from-user", (:))

// Resolve a translation key for the current language.
// Checks user-provided dictionaries first, then built-in ones,
// and falls back to the raw key if nothing is found.
#let translate(key) = context {
  let lang = text.lang
  let from-user = user-dicts.get()

  // 1. Check user-provided dict for this lang
  if lang in from-user and key in from-user.at(lang) {
    return from-user.at(lang).at(key)
  }

  // 2. Fallback to built-in dict for this lang
  let default-dict = built-in-dicts.at(lang, default: built-in-dicts.at("en"))

  // 3. Return the value, or the raw key if nothing is found
  return default-dict.at(key, default: key)
}
