#import "nasin-sitelen.typ"
#import "extra.typ"

#let accept = state(extra.localize-label("dyn", "accept"), ())

#let punct = state(extra.localize-label("dyn", "punct"), (
  "_": (
    ".": [.],
    ",": [,],
    ":": [:],
    "!": [!],
    "?": [?],
    "\"": smartquote(),
    "(": [(],
    ")": [)],
  ),
  la: (
    ".": [.],
    ",": [,],
    ":": [:],
    "!": [!],
    "?": [?],
    "\"": smartquote(),
    "(": [(],
    ")": [)],
  ),
  sp: (
    ".": [.#h(1mm)],
    ",": [,#h(1mm)],
    ":": [:#h(1mm)],
    "!": [!#h(1mm)],
    "?": [?#h(1mm)],
    "\"": smartquote(quotes: (" te ", " to ")),
    "(": [ ~ #nasin-sitelen.Lasina[---]],
    ")": [#nasin-sitelen.Lasina[---] ~ ],
  ),
))

#let fetch-punct(label, sym) = context {
  punct.get().at(label).at(sym)
}

#let o-ante-e-sitelen-lili(label, upd) = {
  punct.update(punct => {
    for (sym, new) in upd {
      punct.at(label).at(sym) = new
    }
    punct
  })
}

// TODO: this does not yet affect spelling
#let o-oke-e-nimi(..words) = {
  import "nimi.typ"
  accept.update(ok => {
    for word in words.pos() {
      if word not in nimi.ale { panic("Word does not exist") }
      ok.push(word)
    }
    ok
  })
}

