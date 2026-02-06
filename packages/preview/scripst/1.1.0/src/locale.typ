#let localize(dict-label, lang: "zh") = {
  let local-word = yaml("locale/locale.yml").at(lang).at(dict-label)
  return local-word
}
