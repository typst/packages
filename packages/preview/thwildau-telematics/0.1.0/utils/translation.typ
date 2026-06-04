#let translations-dict = json("translations.json")

#let translation(string, override-lang: none) = {
  context {
    let lang = if override-lang != none { override-lang } else { str(text.lang) }

    // check if entry exists, even if no translation is needed
    assert(string in translations-dict, message: "Entry \"" + string + "\" not found in translations file!")

    // if english, keep original
    if lang == "en" { return string }

    // use language specific translation
    assert(lang in translations-dict.at(string), message: "Entry \"" + string + "\" has no translation to \"" + lang + "\"!")
    return translations-dict.at(string).at(lang)
  }
}
