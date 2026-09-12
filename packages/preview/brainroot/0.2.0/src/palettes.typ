// Palettes: colours for the branches, the root and the text.

#import "util.typ": _merge

// --- Palettes --------------------------------------------------------------
//
// Every palette: eight branch colours, handed out in order, and a colour for
// the root. Boxes get the branch colour lightened by `tint`.

/// The built-in palettes: `poster`, `pastel`, `grayscale`, `mono`, `plain`,
/// `earth`, `ocean`, `sunset`, `forest`, `neon`. Each sets `colors` (an
/// array, handed out to the branches in order) and `root`; a palette may
/// also set `ink` (`auto` picks by the fill's luminance), `ink-dark`,
/// `ink-light` and `ink-threshold`. Take one as the starting point for your
/// own: `palette: (base: "ocean", root: black)`.
///
/// -> dictionary
#let palettes = (
  // Bright and bold, like markers on a whiteboard.
  poster: (colors: (rgb("#e8321e"), rgb("#f5a623"), rgb("#f2c230"), rgb("#3fc728"),
                    rgb("#1fc2ee"), rgb("#9b3fd6"), rgb("#f78fc0"), rgb("#2a7de1")),
           root: rgb("#7f9bff")),
  // Soft pastel, muted tones.
  pastel: (colors: (rgb("#e28f8f"), rgb("#e9b97a"), rgb("#d6cf7a"), rgb("#8fc79a"),
                    rgb("#7fb8d4"), rgb("#a99adb"), rgb("#d9a0c8"), rgb("#8fbfb5")),
           root: rgb("#9aa6d6")),
  // Greys only: steps from dark to medium.
  grayscale: (colors: (rgb("#222222"), rgb("#555555"), rgb("#333333"), rgb("#777777"),
                       rgb("#444444"), rgb("#888888"), rgb("#2b2b2b"), rgb("#666666")),
              root: rgb("#111111")),
  // One hue, blue, in varying lightness.
  mono: (colors: (rgb("#0b3d91"), rgb("#2a62c2"), rgb("#1749a8"), rgb("#4d80d6"),
                  rgb("#0f2f6e"), rgb("#6e9be0"), rgb("#1f56b5"), rgb("#3a70cc")),
         root: rgb("#082a66")),
  // Plain: one dark ink for everything, as if drawn with a fountain pen.
  plain: (colors: (rgb("#1a1a1a"),), root: rgb("#1a1a1a")),
  // Earth tones: terracotta, ochre, olive, sand.
  earth: (colors: (rgb("#b5532a"), rgb("#c98b2e"), rgb("#7a7a2f"), rgb("#8c5a3c"),
                   rgb("#a3762b"), rgb("#5d6b3a"), rgb("#c47a54"), rgb("#6b4e35")),
          root: rgb("#4e3a2a")),
  // Sea: turquoise, teal, sea green.
  ocean: (colors: (rgb("#0c7c8c"), rgb("#1ea8b5"), rgb("#155e75"), rgb("#2bb39a"),
                   rgb("#0e4d64"), rgb("#4cc3d2"), rgb("#1b8a7d"), rgb("#3b6fa0")),
          root: rgb("#0b3a4a")),
  // Evening sky: red, orange, pink, violet.
  sunset: (colors: (rgb("#c72c41"), rgb("#ee6f3b"), rgb("#f2a541"), rgb("#d9436b"),
                    rgb("#8e3b8f"), rgb("#f07f6f"), rgb("#b02a5c"), rgb("#e88d3a")),
           root: rgb("#5b1f4a")),
  // Forest: green with a little brown.
  forest: (colors: (rgb("#2d6a4f"), rgb("#40916c"), rgb("#1b4332"), rgb("#74a57f"),
                    rgb("#6b8e23"), rgb("#8a6e3a"), rgb("#52b788"), rgb("#3e5c3a")),
           root: rgb("#1b4332")),
  // Neon: loud, saturated colours.
  neon: (colors: (rgb("#ff2079"), rgb("#00e5ff"), rgb("#aaff00"), rgb("#ffe600"),
                  rgb("#ff6a00"), rgb("#b026ff"), rgb("#00ff9c"), rgb("#ff3cac")),
         root: rgb("#1a1a2e")),
)

// Every field a palette can have, with its default.
#let _palette-defaults = (
  colors: (), root: rgb("#7f9bff"),
  ink: auto, ink-dark: black, ink-light: white, ink-threshold: 0.55,
)

#let _palette(p) = {
  if type(p) == str {
    assert(p in palettes, message: "brainroot: unknown palette \"" + p + "\", expected one of " + palettes.keys().join(", "))
    _merge(_palette-defaults, palettes.at(p), "palette")
  } else if type(p) == array {
    _merge(_palette-defaults, (colors: p), "palette")
  } else if type(p) == dictionary {
    let base = _merge(_palette-defaults, palettes.at(p.at("base", default: "poster")), "palette")
    let over = p
    let _ = over.remove("base", default: none)
    _merge(base, over, "palette")
  } else {
    panic("brainroot: palette must be a name, an array of colours or a dictionary")
  }
}
