/// Open fonts. Install locally or upload them to the Typst web project.
#let default-fonts = (
  english: "Libertinus Serif",
  chinese: "Noto Serif CJK SC",
  japanese: "Noto Serif CJK JP",
  korean: "Noto Serif CJK KR",
  mono: "DejaVu Sans Mono",
  sans: "Noto Sans CJK SC",
  math: "New Computer Modern Math",
)
#let book-fonts = state("neat-book.fonts", default-fonts)
#let font-list(value) = if type(value) == array { value } else { (value,) }

// Match one character at a time so long emphasized CJK text can still wrap.
// Keep Latin outside the transform: its font supplies genuine italic glyphs.
#let cjk-character = regex("[\\p{Han}\\p{Hiragana}\\p{Katakana}\\p{Hangul}\\u{3000}-\\u{303F}\\u{FF00}-\\u{FFEF}]")
#let show-cjk-oblique(body, angle: 12deg) = {
  if angle == none { return body }
  // Native emph toggles an internal emphasis flag, not text.style. Resolve the
  // toggle explicitly so character show rules can detect the requested style.
  show emph: it => context {
    set text(style: if text.style == "normal" { "italic" } else { "normal" })
    it.body
  }
  show cjk-character: it => context {
    if text.style in ("italic", "oblique") {
      box(skew(ax: -angle, origin: bottom + left, text(style: "normal", it)))
    } else { it }
  }
  body
}

// Explicit language spans also choose the correct regional Han glyphs.
#let language-span(key, lang, body) = context {
  let fonts = book-fonts.get()
  set text(font: font-list(fonts.at(key)) + font-list(fonts.english), lang: lang)
  body
}
/// Chinese text with the configured Chinese font.
#let zh(body) = language-span("chinese", "zh", body)
/// English text with the configured Latin font.
#let en(body) = language-span("english", "en", body)
/// Japanese text, including Japanese variants of shared Han characters.
#let ja(body) = language-span("japanese", "ja", body)
/// Korean text with the configured Korean font.
#let ko(body) = language-span("korean", "ko", body)
