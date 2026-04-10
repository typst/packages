#import "util.typ": to-string
#import "global.typ" as global

#let display(abbr, display, link-glossary: false) = {
  link(if link-glossary { label("ABBR_G_" + abbr) } else {
    label("ABBR_DES_" + abbr)
  })[#display#label("ABBR_" + abbr)]
  // Create footnote
  let abbr_state = global.abbr.get().at(abbr)
  let desc = abbr_state.at(
    "footnote",
    default: abbr_state.at("description", default: none),
  )
  if state("noted_" + abbr).get() == none and desc != none {
    state("noted_" + abbr).update(true)
    footnote([#emph(abbr_state.at("long").at("singular")): #desc])
  }
}

#let link(abbr, length, form) = context {
  let name = to-string(abbr)
  let abbr-dict = global.abbr.get().at(name, default: none)
  if abbr-dict == none {
    panic("Abbreviation '" + name + "' does not exist!")
  }
  let form-dict = abbr-dict.at(length, default: none)
  if form-dict == none {
    panic(length + " for '" + name + "' does not exist!")
  }
  let value = form-dict.at(form, default: none)
  if value == none {
    panic(length + " for '" + name + "' does not exist in " + form + " form!")
  }
  display(name, value, link-glossary: not abbr-dict.keys().contains("short"))
}

#let short(abbr) = {
  link(abbr, "short", "singular")
}

#let shortpl(abbr) = {
  link(abbr, "short", "plural")
}

#let long(abbr) = {
  link(abbr, "long", "singular")
}

#let longpl(abbr) = {
  link(abbr, "long", "plural")
}

#let full(abbr) = {
  [#long(abbr) (#short(abbr))]
}

#let fullpl(abbr) = {
  [#longpl(abbr) (#shortpl(abbr))]
}
