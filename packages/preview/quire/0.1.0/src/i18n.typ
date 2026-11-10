/// This module defines the localized strings used by the template.

/// Localized strings, keyed by ISO 639-1 language code. English is the reference and the fallback for unsupported
/// languages and missing keys.
#let _translations = (
  en: (
    part: "Part",
    chapter: "Chapter",
    appendix: "Appendix",
    section: "Section",
    subsection: "Subsection",
    bibliography: "Bibliography",
    contents: "Contents",
    abstract: "Abstract",
    keywords: "Keywords",
    acknowledgments: "Acknowledgments",
    author: "Author",
    authors: "Authors",
    typeset-with: "Typeset with",
    in-fonts: "in",
    conjunction: "and",
  ),
  es: (
    part: "Parte",
    chapter: "Capítulo",
    appendix: "Apéndice",
    section: "Sección",
    subsection: "Subsección",
    bibliography: "Bibliografía",
    contents: "Índice",
    abstract: "Resumen",
    keywords: "Palabras clave",
    acknowledgments: "Agradecimientos",
    author: "Autor",
    authors: "Autores",
    typeset-with: "Compuesto con",
    in-fonts: "en",
    conjunction: "y",
  ),
  ca: (
    part: "Part",
    chapter: "Capítol",
    appendix: "Apèndix",
    section: "Secció",
    subsection: "Subsecció",
    bibliography: "Bibliografia",
    contents: "Índex",
    abstract: "Resum",
    keywords: "Paraules clau",
    acknowledgments: "Agraïments",
    author: "Autor",
    authors: "Autors",
    typeset-with: "Compost amb",
    in-fonts: "en",
    conjunction: "i",
  ),
)

/// Returns the localized string for `key`, in the given language or else in the current text language.
///
/// -> str | content
#let translate(
  /// The key of the string (e.g. `"chapter"`).
  /// -> str
  key,
  /// The language. With `auto`, the current text language, which requires context: the result is then content
  /// that adapts to where it is placed.
  /// -> auto | str
  lang: auto,
) = {
  let fallback = _translations.en
  assert(key in fallback, message: "quire: unknown translation key '" + key + "'")
  let lookup(lang) = _translations.at(lang, default: fallback).at(key, default: fallback.at(key))
  if lang == auto { context lookup(text.lang) } else { lookup(lang) }
}
