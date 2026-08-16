// https://en.wikipedia.org/wiki/International_Phonetic_Alphabet#Brackets_and_transcription_delimiters

#let phonetic(text) = "[" + text + "]"
#let phnt = phonetic

#let precise(text) = "⟦" + text + "⟧"
#let prec = precise

#let phonemic(text) = "/" + text + "/"
#let phnm = phonemic

#let morphophonemic(text) = "⫽" + text + "⫽"
#let mphn = morphophonemic

#let indistinguishable(text) = "(" + text + ")"
#let idst = indistinguishable

#let obscured(text) = "⸨" + text + "⸩"
#let obsc = obscured

#let orthographic(text) = "⟨" + text + "⟩"
#let orth = orthographic

#let transliterated(text) = "⟪" + text + "⟫"
#let trlt = transliterated

#let prosodic(text) = "{" + text + "}"
#let prsd = prosodic
