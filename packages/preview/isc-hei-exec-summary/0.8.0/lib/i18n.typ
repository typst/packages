// Internationalisation: resolve user-visible strings from i18n.json.
// Thanks @LordBaryhobal for the original idea.

#let langs = json("../i18n.json")

#let i18n(lang, key, extra-i18n: none) = {
  let langs = langs
  if type(extra-i18n) == dictionary {
    for (lng, keys) in extra-i18n {
      if not lng in langs {
        langs.insert(lng, (:))
      }
      langs.at(lng) += keys
    }
  }

  let keys = langs.at(lang)

  assert(key in keys, message: "I18n key " + str(key) + " doesn't exist")
  return keys.at(key)
}
