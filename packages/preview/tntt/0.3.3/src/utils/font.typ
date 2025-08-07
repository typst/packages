/// Built-in font family for CJK
#let _support-font-family = (
  "SongTi",
  "HeiTi",
  "KaiTi",
  "FangSong",
  "Mono",
  "Math",
)

#let fonts-check(fonts) = {
  if type(fonts) == dictionary {
    for key in fonts.keys() {
      assert(
        key in _support-font-family,
        message: "Font family not supported, ensure the font family keys contain " + _support-font-family.join(", "),
      )
    }
  } else if type(fonts) == array {
    for font in fonts {
      assert(
        _support-font-family.contains(font),
        message: "Font family not supported, ensure the font family keys contain " + _support-font-family.join(", "),
      )
    }
  } else if type(fonts) == str {
    assert(
      _support-font-family.contains(fonts),
      message: "Font family not supported, ensure the font family keys contain " + _support-font-family.join(", "),
    )
  } else {
    assert(false, message: "Invalid font type, expected dictionary, array or string.")
  }

  fonts
}

#let _builtin-fonts-get-en(fonts) = fonts.at(0)

#let _builtin-fonts-trim-en(fonts) = fonts.slice(1)

#let _use-fonts(fonts, name) = fonts-check(fonts).at(name)

#let _use-en-font(fonts, name) = _builtin-fonts-get-en(_use-fonts(fonts, name))

#let _use-cjk-fonts(fonts, name) = _builtin-fonts-trim-en(_use-fonts(fonts, name))

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

/// Size type check with CJK font sizes.
///
/// - size (str | length): the font size to check, available cjk font sizes
/// -> str | length
#let size-check(size) = {
  if type(size) == str { assert(_support-font-size.contains(size), message: "Unsupported font size: " + size) } else {
    assert(type(size) == length, message: "Invalid font size type.")
  }

  size
}

/// Make cjk font size compatible with normal size
///
/// - size (str | length): the font size to use, available cjk font sizes
/// -> length
#let use-size(size) = {
  size = size-check(size)
  if type(size) == str { _builtin-font-size.at(size) } else { size }
}
