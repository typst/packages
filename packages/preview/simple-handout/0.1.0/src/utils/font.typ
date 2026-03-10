#let _support-font-family = (
  "SongTi",
  "HeiTi",
  "KaiTi",
  "FangSong",
  "Mono",
  "Math",
)

#let font-check(font) = {
  if type(font) == dictionary {
    for key in font.keys() {
      assert(
        key in _support-font-family,
        message: "Font family not supported, ensure the font family keys contain " + _support-font-family.join(", "),
      )
    }
  } else if type(font) == array {
    for font in font {
      assert(
        _support-font-family.contains(font),
        message: "Font family not supported, ensure the font family keys contain " + _support-font-family.join(", "),
      )
    }
  } else if type(font) == str {
    assert(
      _support-font-family.contains(font),
      message: "Font family not supported, ensure the font family keys contain " + _support-font-family.join(", "),
    )
  } else {
    assert(false, message: "Invalid font type, expected dictionary, array or string.")
  }

  font
}

#let trim-en(font) = { font.slice(1) }

#let _use-font(font, name) = { font-check(font).at(name) }

#let _use-cjk-font(font, name) = { trim-en(_use-font(font, name)) }

/// Word compatible font size for CJK
#let _builtin-font-size = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

#let _support-font-size = _builtin-font-size.keys()

#let size-check(size) = {
  if type(size) == str { assert(_support-font-size.contains(size), message: "Unsupported font size: " + size) } else {
    assert(type(size) == length, message: "Invalid font size type.")
  }

  size
}

#let use-size(size) = {
  size = size-check(size)
  if type(size) == str { _builtin-font-size.at(size) } else { size }
}
