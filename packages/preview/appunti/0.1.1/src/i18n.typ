/// Localized strings
#let translations = (
    en: (
        chapter: "Chapter",
        algorithm: "Algorithm",
    ),
    it: (
        chapter: "Capitolo",
        algorithm: "Algoritmo",
    ),
)

/// Active language
#let current-language = state("language", "en")

/// Returns the strings for `language`, falling back to English.
///
/// - language (str): Language code.
/// -> dictionary
#let translate(language) = translations.at(language, default: translations.en)
