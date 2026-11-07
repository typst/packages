/// The genitive form used in most major Germanic languages.
/// Normally, adds an s to the last word.
/// If the name ends with an s/z/x/ß, adds an apostrophe or
/// nothing (if `apostrophe: false`).
/// "Et al." citations remain unmarked.
///
/// A rather cursed algorithm that adds a symbol
/// to mark the end, then hides the symbol.
#let average-germanic-genitive(s, apostrophe: true) = {
    show "@": ""
    show regex(".*[szxß]@"): it => it + "’"
    show regex(".*?[^.szxß’]@"): it => it + "s"
    s + "@"
}

/// A dictionary of form `(lang: func)`,
/// where `func :: content -> content` takes an author's name
/// and creates a genitive form from it.
///
/// == Examples
/// `(genitives.en)[Kripke]` -> Kripke's
#let genitives = (
  en: c => {
    show regex(".+"): it => it + "’"
    show regex(".+[^s]’"): it => it + "s"
    c
  },
  de: average-germanic-genitive,
  nl: average-germanic-genitive,
  sv: average-germanic-genitive.with(apostrophe: false),
  no: average-germanic-genitive,
  da: average-germanic-genitive,
  fo: average-germanic-genitive,
)
