#let supported = (
  abstract_t: (fr: "Résumé", en: "Abstract"),
  supervision_t: (fr: "Sous la supervision de", en: "Under the supervision of"),
  keywords_t: (fr: "Mots-clés", en: "Keywords"),
)

#let i18n(key, lang) = {
  if key in supported and lang in supported.at(key) {
    supported.at(key).at(lang)
  }
}
