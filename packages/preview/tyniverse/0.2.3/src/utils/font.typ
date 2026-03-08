/* Font settings for all presets */

#let fonts = (
  base: (
    math: (
      "Libertinus Math",
    ),
    serif: (
      "Libertinus Serif",
    ),
    sans-serif: (
      "Libertinus Sans",
    ),
    italic: (
      "Libertinus Serif",
    ),
  ),
  zh: (
    serif: (
      "SimSun", // Windows
      "Songti SC", // MacOS
      "FandolSong", // Linux
      // fallback
      "Source Han Serif SC",
      "Noto Serif CJK SC",
    ),
    sans-serif: (
      "SimHei", // Windows
      "Heiti SC", // MacOS
      "FandolHei", // Linux
      // fallback
      "Source Han Sans SC",
      "Noto Sans CJK SC",
    ),
    italic: (
      "SimKai SC", // Windows
      "Kaiti SC", // MacOS
      "FandolKai", // Linux
      "Source Han Serif SC",
      "Noto Serif CJK SC",
    ),
  ),
)

#let set-font(lang: "en", body) = {
  assert(lang == "en" or lang in fonts.keys(), message: "Font for language " + lang + " not supported")
  let keys = if lang == "en" { ("base",) } else { ("base", lang) }
  let serif-fonts = keys.map(key => fonts.at(key).serif).flatten()
  let sans-serif-fonts = keys.map(key => fonts.at(key).sans-serif).flatten()
  let italic-fonts = keys.map(key => fonts.at(key).italic).flatten()

  show math.equation: set text(font: (..fonts.base.math, ..serif-fonts))
  set text(font: serif-fonts, lang: lang)
  show emph: set text(font: italic-fonts)

  body
}
