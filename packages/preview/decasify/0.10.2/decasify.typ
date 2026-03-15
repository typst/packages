// SPDX-FileCopyrightText: © 2024 Caleb Maclennan <caleb@alerque.com>
// SPDX-License-Identifier: LGPL-3.0-only

#let _plugin = plugin("decasify.wasm")

#let decasify-string(text, case, lang, style, overrides: none) = {
  let overrides = if overrides != none { bytes(overrides.join(",")) } else { bytes("") }
  str(_plugin.case(bytes(text), bytes(case), bytes(lang), bytes(style), overrides))
}

#let decasify(body, case, style: "default", overrides: none) = {
  show regex(".+"): it => decasify-string(it.text, case, text.lang, style, overrides: overrides)
  body
}

#let titlecase-string(text, lang, style, overrides: none) = {
  let overrides = if overrides != none { bytes(overrides.join(",")) } else { bytes("") }
  str(_plugin.titlecase(bytes(text), bytes(lang), bytes(style), overrides))
}

#let titlecase(body, style: "default", overrides: none) = {
  show regex(".+"): it => titlecase-string(it.text, text.lang, style, overrides: overrides)
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
