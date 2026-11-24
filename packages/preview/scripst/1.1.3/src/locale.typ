#import "locale/locale.typ": *
#import "locale/countblock.typ": countblock-locales

#let localize(dict-label, lang: "zh") = {
  let local-word = locale-settings.at(lang).at(dict-label)
  return local-word
}

#let localize-countblock(info, lang: "en") = {
  if type(info) != dictionary { return info }

  if "key" in info {
    let labels = countblock-locales.at(lang, default: countblock-locales.at("en"))
    return labels.at(info.at("key"), default: countblock-locales.at("en").at(info.at("key")))
  }

  if lang in info { return info.at(lang) }
  if "en" in info { return info.at("en") }
  info.values().first()
}
