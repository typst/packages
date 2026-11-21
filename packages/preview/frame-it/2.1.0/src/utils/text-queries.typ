#let lang-is-left-to-right() = {
  let rtl-langs = (
    "ar",
    "dv",
    "fa",
    "he",
    "ks",
    "pa",
    "ps",
    "sd",
    "ug",
    "ur",
    "yi",
  )
  text.lang not in rtl-langs
}

#let text-is-left-to-right() = if text.dir == auto {
  lang-is-left-to-right()
} else {
  text.dir == ltr
}

#let real-text-direction() = if text-is-left-to-right() { ltr } else { rtl }

