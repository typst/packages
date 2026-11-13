#let scheme(file) = {
  // used to make base16 work with base24
  let base16_fallback_lut = (
    base10: "base00",
    base11: "base00",
    base12: "base08",
    base13: "base0A",
    base14: "base0B",
    base15: "base0C",
    base16: "base0D",
    base17: "base0E",
  )
  let color_aliases = (
    // basic bg/fg colors
    background: "base00",
    foreground: "base05",

    // action types
    critical: "base08",
    error: "base08",
    destructive: "base08",
    warning: "base0A",
    affirmative: "base0B",

    // idk if anyone actually uses base0F for dark red
    // i know i don't
    accent: "base0F",

    // color names from Base24 styling docs
    red: "base08",
    orange: "base09",
    yellow: "base0A",
    green: "base0B",
    cyan: "base0C",
    blue: "base0D",
    magenta: "base0E",
    bright-red: "base12",
    bright-yellow: "base13",
    bright-green: "base14",
    bright-cyan: "base15",
    bright-blue: "base16",
    bright-magenta: "base17",
  )

  import "helpers.typ": format_byte, copy_or_else, to_struct
  let palette = yaml(file)
  let final = (:)

  // i wish typst could throw errors
  final = copy_or_else(palette, "system", final,
    _else: "base16")
  final = copy_or_else(palette, "scheme", final,
    _else: "Unknown Scheme")
  final = copy_or_else(palette, "slug", final,
    _else: lower(final.scheme).split(" ").join("-"))
  final = copy_or_else(palette, "author", final,
    _else: "Unknown Author")
  final = copy_or_else(palette, "variant", final)

  // we have an old base16
  if "palette" not in palette.keys() {
    // check base16 colors
    for i in range(0, 16) {
      let key = "base" + format_byte(i)
      // is invalid if not in the file
      assert(key in palette.keys(), message:
        "`" + key + "` not found in `"+ file + "`")
      final.insert(key, to_struct(palette.at(key).replace("#", "")))
    }

    // technically, there shouldn't be base24 colors in an old base16 theme,
    // but it doesn't hurt to check. especially if you're like me and thought that
    // base24 was written in the same way the original base16 was written (yea, i'm kinda
    // stupid for that lmao, but hey, you learn) and also compat with base24
    for i in range(16, 24) {
      let key = "base" + format_byte(i)
      // if the key is in the palette, then we know that it's base24 (probably)
      final = copy_or_else(palette, key, final,
        _else: final.at(base16_fallback_lut.at(key),
        c_apply: it => to_struct(it.replace("#", ""))))
      if final.base00.raw != final.base10.raw { final.system = "base24" }
    }
  // we have a new base16/base24
  } else {
    // check for base16 colors
    for i in range(0, 16) {
      let key = "base" + format_byte(i)
      // is invalid if not in the file
      assert(key in palette.palette.keys(), message:
        "`" + key + "` not found in `"+ file + "`")
      final.insert(key, to_struct(palette.palette.at(key).replace("#", "")))
    }

    // fill in base24 colors
    for i in range(16, 24) {
      // fallbacks in case theme is only base16 compliant
      let key = "base" + format_byte(i)
      // if the key is in the palette, then we know that it's base24 (probably)
      final = copy_or_else(palette.palette, key, final,
        _else: final.at(base16_fallback_lut.at(key)),
        c_apply: it => to_struct(it.replace("#", "")))
      if final.base00 != final.base10 { final.system = "base24" }
    }
  }

  for (k, v) in color_aliases {

  }

  return final
}
