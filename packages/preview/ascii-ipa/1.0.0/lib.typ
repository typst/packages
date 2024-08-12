#import("util/xsampa.typ"): *
#import("util/praat.typ"): *
#import("util/branner.typ"): *
#import("util/sil.typ"): *

#let replacer = (val, rpl, reverse: false) => {
  let (a, b) = if reverse {( 1, 0 )} else {( 0, 1 )}

  for pair in rpl {
    val = val.replace(pair.at(a), pair.at(b))
  }

  val
}

#let font-overrider = (content, override: false) => {
  if (override) {
    set text(font: "Linux Libertine")
    content
  }
  else {
    content
  }
}

#let xsampa = (val, reverse: false, override-font: false) => {
  font-overrider(
    replacer(val, xsampa-translations, reverse: reverse),
    override: override-font,
  )
}

#let praat = (val, reverse: false, override-font: false) => {
  font-overrider(
    replacer(val, praat-translations, reverse: reverse),
    override: override-font,
  )
}

#let branner = (val, reverse: false, override-font: false) => {
  font-overrider(
    replacer(val, branner-translations, reverse: reverse),
    override: override-font,
  )
}

#let sil = (val, reverse: false, override-font: false) => {
  font-overrider(
    replacer(val, sil-translations, reverse: reverse),
    override: override-font,
  )
}

#let phonetic = (val) => {[
  [#val]
]}
#let phnt = phonetic

#let phonemic = (val) => {[
  /#val/
]}
#let phnm = phonemic

#let orthographic = (val) => {[
  ⟨#val⟩
]}
#let orth = orthographic

#let prosodic = (val) => {[
  {#val}
]}
#let prsd = prosodic
