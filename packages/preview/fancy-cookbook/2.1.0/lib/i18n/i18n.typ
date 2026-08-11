#import "translations.typ": translations 

#let language-state = state("lang", "en")

#let set-language(lang) = context {
  if lang != none {
    language-state.update(lang)
  } else {
    language-state.update(text.lang)
  }
  
}

// To merge the given dictionary with a custom one
#let update-translation(t) = context {
  let base = translations.get()
  let lang-key = t.keys().first()        
  let previous = base.at(lang-key, default: (:))  // find the language already given

  // Merge it with the custom values
  let merged-lang = previous + t.at(lang-key)

  // Merge the full dictionary and save it
  let merged = base
  merged.insert(lang-key, merged-lang)
  translations.update(merged)
}

// translate the labels with text.lang ("en" by default)
#let translate(key) = context {
  let lang = language-state.get()
  let dict = translations.get().at(lang, default: translations.get().at("en"))
  dict.at(key, default: key)
}