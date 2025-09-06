#import "nasin-sitelen.typ"

#import "pakala.typ"

#import "nimisin.typ": nimisin, nimisin-mute

#import "dyn.typ"
#import dyn: o-ante-e-sitelen-lili, o-oke-e-nimi

#let esc(ct) = {
  text(lang: "en")[#nasin-sitelen.Lasina[#ct]]
}

#let only(filter, ct) = context {
  if type(filter) == str {
    let cur = text.lang
    if cur == "t" + filter {
      ct
    }
  } else {
    panic("Invalid filter")
  }
}

#import "lasina.typ"
#import "pona.typ"
