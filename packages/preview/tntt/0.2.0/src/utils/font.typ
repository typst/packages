/// Built-in font family for CJK
#let _support-font-family = (
  "SongTi",
  "HeiTi",
  "KaiTi",
  "FangSong",
  "Mono",
)

#let font-check(font) = {
  for key in font.keys() {
    assert(
      key in _support-font-family,
      message: "Font family not supported, ensure the font family keys contain " + _support-font-family.join(", "),
    )
  }

  font
}

/// Word compatible font size for CJK
#let font-size = (
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

#let _support-font-size = font-size.keys()

#let size-check(size) = {
  if type(size) == str { assert(_support-font-size.contains(size), message: "Unsupported font size: " + size) } else {
    assert(type(size) == length, message: "Invalid font size type.")
  }

  size
}

#let use-size(size) = {
  size = size-check(size)
  if type(size) == str { font-size.at(size) } else { size }
}
