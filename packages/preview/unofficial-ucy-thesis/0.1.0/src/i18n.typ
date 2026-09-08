#import "./utils.typ": tl, ucy-lang

#let localized-text(key) = context {
  let lang = ucy-lang.get()
  text(lang: lang, tl(key, lang))
}

/// Level-1 chapter heading in the document `primary-lang`.
#let chapter-lt(key) = context {
  let lang = ucy-lang.get()
  heading(level: 1, outlined: true, bookmarked: true)[
    #text(lang: lang, tl(key, lang))
  ]
}

/// Level-2 section heading in the document `primary-lang`.
#let section-lt(key) = context {
  let lang = ucy-lang.get()
  heading(level: 2, outlined: true, bookmarked: true)[
    #text(lang: lang, tl(key, lang))
  ]
}

/// Body paragraph from `lang.toml` in the document `primary-lang`.
#let body-lt(key) = context {
  let lang = ucy-lang.get()
  par[#text(lang: lang, tl(key, lang))]
}

/// Bullet list from translation keys.
#let bullets-lt(keys) = {
  for key in keys {
    [- #localized-text(key)]
  }
}
