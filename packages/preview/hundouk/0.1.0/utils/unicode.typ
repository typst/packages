#let is-hiragana(text) = {
  text.match(regex("[\p{Hiragana}]")) != none
}

#let is-katakana(text) = {
  text.match(regex("[\p{Katakana}]")) != none
}

#let is-kanji(text) = {
  text.match(regex("[\p{Han}]")) != none
}
