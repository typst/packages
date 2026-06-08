#let line-height(leading) = {
  leading - 0.75em
}

#let i18n(label, lang: auto) = {
  let translations = yaml("i18n.yaml")
  let translation-error = text(fill: red, weight: "bold", "Translation not found")
  
  if translations.keys().contains(label) {
    context {
      let lang = lang
      
      if (lang == auto) {
        lang = text.lang
      }
      
      if translations.at(label).keys().contains(lang) {
        translations.at(label).at(lang)
      }
      else {
        translation-error
      }
    }
  }
  else {
    translation-error
  }
}