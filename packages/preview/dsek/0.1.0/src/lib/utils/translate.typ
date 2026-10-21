/// Returns Swedish or English content based on the active document language.
///
/// - swedish (content): Shown when `text.lang == "sv"`.
/// - english (content): Shown when `text.lang == "en"`.
///
/// -> content
#let translate(swedish, english) = context {
  let lang = text.lang
  if lang == "sv" {
    swedish
  } else if lang == "en" {
    english
  } else {
    panic("language `" + lang + "` is not supported for name translations")
  }
}

/// Returns Swedish or English string based on the active document language.
///
///  *This needs to be ran in context.*
///
/// - swedish (str): Shown when `text.lang == "sv"`.
/// - english (str): Shown when `text.lang == "en"`.
///
/// -> str
#let translate-str(swedish, english) = {
  let lang = text.lang
  if lang == "sv" {
    swedish
  } else if lang == "en" {
    english
  } else {
    panic("language `" + lang + "` is not supported for name translations")
  }
}
