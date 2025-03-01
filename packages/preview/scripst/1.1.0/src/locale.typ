#let localize(dict_label, lang: "zh") = {
  let local_word = yaml("locale/locale.yml").at(lang).at(dict_label);
  return local_word
}