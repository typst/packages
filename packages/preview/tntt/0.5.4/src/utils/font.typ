//! Built-in font utilities for CJK
//!
//! Currently, there are already many related packages available to implement similar functions.
//! So you should explore and use them instead of relying on this built-in implementation.
//! since the current implementation is not perfect. All except `use-size` is not exported.

#let _builtin-font-family = ("SongTi", "HeiTi", "KaiTi", "FangSong", "Mono", "Math")

// TODO: enhance the handling of en/cjk fonts
#let _builtin-get-en-font(fonts) = fonts.at(0)
#let _builtin-get-cjk-fonts(fonts) = fonts.slice(1)

#let _unwrap-font(font) = if type(font) == str { font } else { font.name }

/// Get the font configuration from the fonts dictionary by font family name.
///
/// - fonts (dict): the fonts configuration dictionary.
/// - name (str): the font family name, must be one of fonts.
/// -> array
#let _use-fonts(fonts, name) = {
  assert(
    _builtin-font-family.all(k => k in fonts),
    message: "Required font families: " + _builtin-font-family.filter(k => k not in fonts).join(", "),
  )
  assert(name in fonts, message: "Unsupported font family for fonts: " + name)
  fonts.at(name)
}

/// Get the en font configuration from the fonts dictionary.
///
/// - fonts (dict): the fonts configuration dictionary.
/// - name (str): the font family name, must be one of fonts.
/// -> str
#let _use-en-font(fonts, name) = _unwrap-font(_builtin-get-en-font(_use-fonts(fonts, name)))

/// Get the cjk font configuration from the fonts dictionary.
///
/// - fonts (dict): the fonts configuration dictionary.
/// - name (str): the font family name, must be one of fonts.
/// -> array
#let _use-cjk-fonts(fonts, name) = _builtin-get-cjk-fonts(_use-fonts(fonts, name)).map(_unwrap-font)

/// Microsoft Word compatible font size for CJK.
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

/// Make cjk font size compatible with normal size.
///
/// - size (str, length): the font size to use, available cjk font sizes.
/// -> length
#let use-size(size) = if type(size) == length { size } else {
  assert(size in _builtin-font-size, message: "Unsupported font size: " + size)
  _builtin-font-size.at(size)
}

