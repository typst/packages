#let _plugin = plugin("decasify.wasm")

#let decasify-string(text, case, lang, style) = {
  str(_plugin.case(bytes(text), bytes(case), bytes(lang), bytes(style)))
}

#let decasify(body, case, style: "default") = {
  show regex(".+"): it => decasify(it.text, case, text.lang, style)
  body
}

#let titlecase-string(text, lang, style) = {
  str(_plugin.titlecase(bytes(text), bytes(lang), bytes(style)))
}

#let titlecase(body, style: "default") = {
  show regex(".+"): it => titlecase-string(it.text, text.lang, style)
  body
}

#let lowercase-string(text, lang) = {
  str(_plugin.lowercase(bytes(text), bytes(lang)))
}

#let lowercase(body) = {
  show regex(".+"): it => lowercase-string(it.text, text.lang)
  body
}

#let uppercase-string(text, lang) = {
  str(_plugin.uppercase(bytes(text), bytes(lang)))
}

#let uppercase(body) = {
  show regex(".+"): it => uppercase-string(it.text, text.lang)
  body
}

#let sentencecase-string(text, lang) = {
  str(_plugin.sentencecase(bytes(text), bytes(lang)))
}

#let sentencecase(body) = {
  show regex(".+"): it => sentencecase-string(it.text, text.lang)
  body
}
