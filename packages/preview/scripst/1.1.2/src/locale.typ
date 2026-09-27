#import "locale/locale.typ": *

#let localize(dict-label, lang: "zh") = {
  let local-word = locale-settings.at(lang).at(dict-label)
  return local-word
}
