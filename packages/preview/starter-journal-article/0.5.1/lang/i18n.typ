#let translations = yaml("i18n.yaml")
#import "l10n.typ": l10n

#let lookup(key, dict, lang) = {
  let lookup = dict.at(lang, default: translations.en)
  let keys = key.split(".")
  for k in keys {
    if type(lookup) == dictionary and lookup.keys().contains(k) {
      lookup = lookup.at(k)
    } else {
      panic("Key not found: " + key)
    }
  }
  lookup
}

#let i18n(lang) = {
  (
    gettext: (key) => lookup(key, translations, lang),
    locale: (key) => lookup(key, l10n, lang),
  )
}
