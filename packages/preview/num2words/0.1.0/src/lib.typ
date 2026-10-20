/// Typst num2words: convert numbers to their written word form.

#import "errors.typ"
#import "langs/en.typ"

#let converters = (en: en.convert)

/// Converts a number to its written word form.
///
/// - number (int): The number to convert.
/// - lang (str, auto): The language code (e.g., `"en"`). When `auto`, uses the current `text.lang`.
/// - ..args: Additional arguments forwarded to the language-specific converter.
/// -> content
#let num2words(number, lang: auto, ..args) = {
  errors.assert-type("number", int, number)

  return context {
    let resolved-lang = if lang == auto { text.lang } else { lang }
    errors.assert-type("lang", str, resolved-lang)
    errors.assert-lang(resolved-lang, converters)

    let convert = converters.at(resolved-lang)
    convert(number, ..args)
  }
}
