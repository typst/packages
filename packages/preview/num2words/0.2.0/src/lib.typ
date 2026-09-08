/// Typst num2words: convert numbers to their written word form.
#import "errors.typ"
#import "langs/en.typ"
#import "langs/es.typ"
#import "langs/ca.typ"

#let converters = (
  en: en.convert,
  es: es.convert,
  ca: ca.convert,
)

/// Validates the shape of a `fallback` argument and normalizes it to an array. Accepts a single string, a single
/// `none`, or an array whose entries are strings or `none`.
#let _normalize-fallback(fallback) = {
  let chain = if type(fallback) == array { fallback } else { (fallback,) }
  for (i, item) in chain.enumerate() {
    let t = type(item)
    if not (item == none or t == str) {
      panic(
        "num2words: 'fallback' entries must be strings or `none`, got " + str(t) + " at index " + str(i),
      )
    }
  }
  chain
}

/// Converts a number to its written word form.
///
/// - number (int): The number to convert.
/// - lang (str, auto): The language code (e.g., `"en"`). When `auto`, uses the current `text.lang`.
/// - fallback (str, none, array): The fallback chain, where `none` can be used to return an empty result instead of
///   panicking.
/// - ..args: Additional arguments forwarded to the language-specific converter.
/// -> content
#let num2words(number, lang: auto, fallback: none, ..args) = {
  errors.assert-type("number", int, number)
  let chain = _normalize-fallback(fallback)

  return context {
    let resolved-lang = if lang == auto { text.lang } else { lang }
    errors.assert-type("lang", str, resolved-lang)

    let candidates = (resolved-lang,) + chain
    let result = none
    let matched = false
    let attempted = ()
    for cand in candidates {
      if matched { continue }
      if cand == none {
        result = ""
        matched = true
      } else {
        attempted.push(cand)
        if cand in converters {
          result = converters.at(cand)(number, ..args)
          matched = true
        }
      }
    }
    if not matched {
      panic(
        "num2words: no supported language in fallback chain (tried: "
          + attempted.map(c => "'" + c + "'").join(", ")
          + ")",
      )
    }
    result
  }
}
