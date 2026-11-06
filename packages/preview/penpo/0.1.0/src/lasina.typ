#import "nasin-sitelen.typ"
#import "extra.typ"
#import "kipisi.typ"

#import "pakala.typ"
#import "nimi.typ"
#import "nimisin.typ"

#import "dyn.typ"

/// Mode code: `"la"`.
///
/// The resulting content has `lang: "tok"`,
/// and internally `lang: "tla"` is used temporarily.
///
/// This function
/// - converts `/la/` to linebreak
/// - erases all other `/../`
/// - converts punctuation to the current value of
///   `o-ante-e-sitelen-lili("la", ...)`
/// - spellchecks words and erases the variant marker
#let sitelen(ct) = context {
  show text.where(lang: "tla"): tt => {
    set text(lang: "tok")
    show regex(" */../ *"): none
    show regex(" */la/ *"): linebreak()
    show "\"": dyn.fetch-punct("la", "\"")
    show ",": dyn.fetch-punct("la", ",")
    show ".": dyn.fetch-punct("la", ".")
    show ":": dyn.fetch-punct("la", ":")
    // " This line fixes the syntax highlighting on vim
    show "?": dyn.fetch-punct("la", "?")
    show "!": dyn.fetch-punct("la", "!")
    show "(": dyn.fetch-punct("la", "(")
    show ")": dyn.fetch-punct("la", ")")
    show regex("\w+(/\d+)?"): word => context {
      let (base,) = kipisi.kipisi(word.text)
      if base in nimi.ale {
        let err = if base in dyn.accept.get() { none } else { pakala.pu-ala-pu(base)}
        if err != none {
          err.log
          text(fill: err.color)[#base]
        } else {
          [#base]
        }
      } else if base == "te" {
        sym.quote.l.double
      } else if base == "to" {
        sym.quote.r.double
      } else if base in nimisin.spellings.get() {
        [#base]
      } else {
        let err = pakala.pu-ala-pu(base)
        err.log
        text(fill: err.color)[#base]
      }
    }
    tt
  }
  text(lang: "tla")[#nasin-sitelen.Lasina[#ct]]
}

