#import "extra.typ"
#import "nimi.typ"
#import "nasin-sitelen.typ"
#import "pakala.typ"
#import "kipisi.typ"
#import "dyn.typ"

#let localize-label(lab) = extra.localize-label("nimisin", lab)

#let spellings = state(localize-label("spellings"), (:))
#let shortenable = state(localize-label("shortenable"), (:))
#let initials = state(localize-label("initials"), (:))

#let nimisin-lili-forget() = {
  shortenable.update(_ => (:))
  initials.update(_ => (:))
}

#let nimisin-kama-lili(nimi, lili, spelling) = context {
  if lili == none {
    return
  }
  shortenable.update(seen => {
    seen.insert(nimi, ())
    seen
  })
  let seen = initials.get()
  let key = lili.join(" ")
  if key in seen {
    if nimi != seen.at(key) {
      pakala.sama-sitelen-wan(key, (nimi, spelling), initials.get().at(key))
    }
  } else {
    initials.update(seen => {
      seen.insert(key, (nimi, spelling))
      seen
    })
  }
}

#let nimisin(word, letters, _lili: auto) = context {
  let errors = ()
  let letters = letters.split(" ").filter(w => w != "")
  if word.len() != letters.len() {
    pakala.nanpa-ante(word, letters)
    return
  }
  if not ("A" <= word.at(0) and word.at(0) <= "Z") {
    pakala.lili-ike(word.at(0), word)
  }
  for l in word.slice(1) {
    if not ("a" <= l and l <= "z") {
      pakala.suli-ike(l, word)
    }
  }
  let chars = ()
  for char in letters {
    let (base, var) = kipisi.kipisi(char)
    let word = if base in nimi.ale {
      let err = if base in dyn.accept.get() { none } else { pakala.pu-ala-pu(base, nanpa-ante: var) }
      if err != none {
        errors.push(err.log)
      }
      char + extra.str-some(var)
    } else {
      errors.push(pakala.sitelen-ala(char))
      "???"
    }
    chars.push(base + extra.str-some(var))
  }
  for (letter, hieroglyph) in word.clusters().zip(chars) {
    if hieroglyph.at(0) != "?" and lower(letter) != hieroglyph.at(0) {
      errors.push(pakala.sitelen-ante(letter, hieroglyph, word, letters))
    }
  }
  for error in errors {
    error
  }
  let short = if _lili == auto {
    chars.slice(0, 1)
  } else if _lili == none {
    none
  } else if type(_lili) == int {
    chars.slice(0, _lili)
  } else if type(_lili) == str {
    let short = ()
    for char in _lili.split(" ") {
      let (base, var) = kipisi.kipisi(char)
      let word = if base in nimi.ale {
        let err = if base in dyn.accept.get() { none } else { pakala.pu-ala-pu(base, nanpa-ante: var) }
        // TODO: use bad
        if err != none {
          errors.push(err.log)
        }
        word + extra.str-some(var)
      } else {
        errors.push(pakala.sitelen-ala(char))
        "???" // TODO: make it red in the text
      }
      short.push(base + extra.str-some(var))
    }
    short
  } else {
    panic("_lili of type '" + str(type(_lili)) + "' cannot be interpreted.")
  }
  spellings.update(nimi => {
    nimi.insert(word, (full: chars, short: short))
    nimi
  })
  shortenable.update(short => {
    if word in short {
      let _ = short.remove(word)
    }
    short
  })
  initials.update(init => {
    if word in init {
      let _ = init.remove(word)
    }
    init
  })
}

#let nimisin-mute(_lili: auto, ..args) = {
  for (key, val) in args.named() {
    nimisin(key, val, _lili: _lili)
  }
}
