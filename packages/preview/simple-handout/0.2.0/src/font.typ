//! Currently, there are already many related packages available to implement similar functions.
//! So you should explore and use them instead of relying on this built-in implementation.
//! since the current implementation is not perfect. All inherits from tntt and is not exported.

#let _builtin-font-family = ("SongTi", "HeiTi", "KaiTi", "FangSong", "Mono", "Math")

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
