//-------------------------------------
// Internationalization
//

/// Get a translation in the given language
///
/// - key (string): translation key
/// - lang (string): target language id
/// - extra-i18n (dictionary, none): extra i18n languages and keys (can override default translations)
/// -> string, content
#let i18n(
  key,
  lang: "en",
  extra-i18n: none
) = {
  let langs = json("i18n-package.json")
  if type(extra-i18n) == dictionary {
    for (lng, keys) in extra-i18n {
      if not lng in langs {
        langs.insert(lng, (:))
      }
      langs.at(lng) += keys
    }
  }
  if not lang in langs {
    lang = "en"
  }
  let keys = langs.at(lang)
  assert(
    key in keys,
    message: "I18n key " + str(key) + " doesn't exist"
  )
  return keys.at(key)
}

/// Get the figure complement for a given object
///
/// - lang (string): target language id
/// - it (content): object of which to get the complement
/// -> content, str, auto
#let get-supplement(
  lang: "en",
  it
) = {
  let f = it.func()
  if (f == image) {
    i18n("figure-name", lang: lang)
  } else if (f == table) {
    i18n("table-name", lang: lang)
  } else if (f == raw) {
    i18n("listing-name", lang: lang)
  } else if (f == math.equation) {
    i18n("equation-name", lang: lang)
  } else {
    auto
  }
}

/// Get a translation for the given gender and in the given language
///
/// - gender (string): target gender id
/// - key-base (string): base translation key
/// - lang (string): target language id
/// -> content, str
#let get-gendered-label(
  gender,
  key-base,
  lang: "en",
) = {
  if gender == "feminin" {
    i18n(key-base + "-f", lang: lang)
  } else if gender == "inclusive" {
    i18n(key-base + "-i", lang: lang)
  } else {
    i18n(key-base, lang: lang)
  }
}