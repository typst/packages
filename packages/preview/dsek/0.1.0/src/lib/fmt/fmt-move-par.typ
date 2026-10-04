#import "../misc/text.typ": to-text

#let move-par(it) = context {
  let pattern = regex(
    if text.lang == "sv" {
      "(?i)yrka(.*)(på|beslut(a?))"
    } else if text.lang == "en" {
      "(?i)(move(s?)|decide)"
    } else {
      "a^"
    },
  )
  if to-text(it).ends-with(pattern) {
    v(1em)
    it
  } else {
    it
  }
}
