#let translations(lang) = {
  let dict = (
    de: toml("locales/de.toml"),
    en: toml("locales/en.toml"),
  )
  
  // Falls die Sprache nicht gefunden wird, de als Fallback nutzen
  if lang in dict {
    dict.at(lang)
  } else {
    dict.de
  }
}
