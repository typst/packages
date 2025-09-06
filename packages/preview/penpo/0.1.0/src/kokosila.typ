#import "extra.typ"
#import "dyn.typ"

/// This toggles the value of the variable `kokosila`,
/// which among other things is queried by `pakala.typ`
/// to determine if error messages should be printed
/// in English or toki pona.
#let toggle() = dyn.kokosila.update(b => not b)

#import "dyn.typ": o-ante-e-sitelen-lili as update-punct, o-oke-e-nimi as allow-words
#import "nimisin.typ": nimisin as spelling, nimisin-mute as spellings
#import "pakala.typ": open as begin-log, pini as end-log
#import "pona.typ": nanpa-ala-li-nanpa as default-sp-variant

