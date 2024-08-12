#import "translations/branner.typ": *
#import "translations/praat.typ": *
#import "translations/sil.typ": *
#import "translations/xsampa.typ": *

#let apply-translations(content, translations, reverse) = {
  let (from, to) = if reverse {( 1, 0 )} else {( 0, 1 )}

  for translation in translations {
    content = content.replace(translation.at(from), translation.at(to))
  }

  return content
}

#let translate(content, translations, reverse, override-font) = {
  let translation = apply-translations(content, translations, reverse)

  return if override-font {
    set text(font: "Linux Libertine")
    translation
  } else {
    translation
  }
}

#let branner(content, reverse: false, override-font: false) = translate(content, branner-translations, reverse, override-font)
#let praat(content, reverse: false, override-font: false) = translate(content, praat-translations, reverse, override-font)
#let sil(content, reverse: false, override-font: false) = translate(content, sil-translations, reverse, override-font)
#let xsampa(content, reverse: false, override-font: false) = translate(content, xsampa-translations, reverse, override-font)

#let phonetic(content) = [[#content]]
#let phonemic(content) = [/#content/]
#let orthographic(content) = [⟨#content⟩]
#let prosodic(content) = [{#content}]

#let phnt = phonetic
#let phnm = phonemic
#let orth = orthographic
#let prsd = prosodic
