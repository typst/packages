// Pixel Family — Inline pixel characters for Typst
//
// Usage:
//   #import "@preview/pixel-family:0.1.0": bob, alice, eve
//   Hello #bob() and #alice() and #eve()!

#import "@preview/cetz:0.4.2": canvas, draw

// === Color Palette ===

#let skin-default = rgb("#e8b8a0")
#let skin-light = rgb("#f5d5c2")
#let skin-medium = rgb("#c6865c")
#let skin-dark = rgb("#8d5524")

#let hair-brown = rgb("#5c4033")
#let hair-blonde = rgb("#e6c229")
#let hair-black = rgb("#1a1a1a")
#let hair-red = rgb("#c73e1d")
#let hair-green = rgb("#2d5016")

#let shirt-white = white
#let shirt-blue = rgb("#4a90e2")
#let shirt-pink = rgb("#ffb6c1")
#let shirt-red = rgb("#e74c3c")
#let shirt-green = rgb("#27ae60")
#let shirt-black = black

#let pants-black = black
#let pants-blue = rgb("#2c3e50")
#let pants-gray = rgb("#7f8c8d")

#let chassis-silver = rgb("#b0b0b0")
#let chassis-white = rgb("#f0f0f0")
#let chassis-orange = rgb("#e67e22")
#let chassis-navy = rgb("#1a237e")
#let chassis-gunmetal = rgb("#78909c")

#let palette = (
  skin: skin-default,
  skin-light: skin-light,
  skin-medium: skin-medium,
  skin-dark: skin-dark,
  hair-brown: hair-brown,
  hair-blonde: hair-blonde,
  hair-black: hair-black,
  hair-red: hair-red,
  hair-green: hair-green,
  shirt-white: shirt-white,
  shirt-blue: shirt-blue,
  shirt-pink: shirt-pink,
  shirt-red: shirt-red,
  shirt-green: shirt-green,
  shirt-black: shirt-black,
  pants-black: pants-black,
  pants-blue: pants-blue,
  pants-gray: pants-gray,
  chassis-silver: chassis-silver,
  chassis-white: chassis-white,
  chassis-orange: chassis-orange,
  chassis-navy: chassis-navy,
  chassis-gunmetal: chassis-gunmetal,
)

// === Pixel Grid Renderer ===

/// Render a 2D pixel array as CeTZ rectangles (draw commands, for use inside canvas).
/// Coordinates are unitless integers; use canvas `length` to control output size.
///
/// - data (array): 2D array of color indices (0 = transparent)
/// - colors (array): color palette where colors.at(index) gives the fill color
/// -> CeTZ draw commands
#let pixel-grid(data, colors) = {
  let rows = data.len()
  for (row-idx, row) in data.enumerate() {
    for (col-idx, color-idx) in row.enumerate() {
      if color-idx > 0 and color-idx < colors.len() {
        let x = col-idx
        let y = rows - row-idx - 1
        draw.rect(
          (x, y), (x + 1, y + 1),
          fill: colors.at(color-idx),
          stroke: none,
        )
      }
    }
  }
}

// === Character Box Helper ===
// Wraps pixel data into inline content with configurable baseline.
// baseline: auto = center-aligned with text, or pass a length (e.g. 0pt for bottom)
#let _char-box(size, baseline, data, colors) = box(
  baseline: if baseline == auto { (size - 1em) / 2 } else { baseline },
  canvas(length: size / 16, {
    pixel-grid(data, colors)
  })
)

// === Character Definitions (Batch 1) ===

#import "characters/batch-1-initial.typ": *

/// Bob: green hair, white shirt, black vest
/// -> content (inline)
#let bob(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-green,
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, bob-data, bob-colors(skin, hair, shirt, pants))

/// Alice: brown hair, white shirt, red pocket, mustache
/// -> content (inline)
#let alice(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-brown,
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, alice-data, alice-colors(skin, hair, shirt, pants))

/// Christina: purple hair with yellow clip, green tie
/// -> content (inline)
#let christina(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: rgb("#8b5a9f"),
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, christina-data, christina-colors(skin, hair, shirt, pants))

/// Mary: black hair with red ribbons, red bow
/// -> content (inline)
#let mary(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-black,
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, mary-data, mary-colors(skin, hair, shirt, pants))

/// Eve: red curly hair, green shirt
/// -> content (inline)
#let eve(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-red,
  shirt: shirt-green,
  pants: pants-black,
) = _char-box(size, baseline, eve-data, eve-colors(skin, hair, shirt, pants))

// === Character Definitions (Batch 2 — bust/portrait, no legs) ===

#import "characters/batch-2-top.typ": *

/// Frank: top hat, sideburns, mustache, bowtie
/// -> content (inline)
#let frank(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-black,
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, frank-data, frank-colors(skin, hair, shirt, pants))

/// Grace: elegant updo, gold necklace
/// -> content (inline)
#let grace(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-blonde,
  shirt: shirt-blue,
  pants: pants-black,
) = _char-box(size, baseline, grace-data, grace-colors(skin, hair, shirt, pants))

/// Trent: balding, beard, jacket over shirt
/// -> content (inline)
#let trent(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-brown,
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, trent-data, trent-colors(skin, hair, shirt, pants))

/// Mallory: hooded figure, kangaroo pocket
/// -> content (inline)
#let mallory(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-black,
  shirt: shirt-black,
  pants: pants-black,
) = _char-box(size, baseline, mallory-data, mallory-colors(skin, hair, shirt, pants))

/// Victor: peaked cap with badge, uniform
/// -> content (inline)
#let victor(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-black,
  shirt: shirt-blue,
  pants: pants-blue,
) = _char-box(size, baseline, victor-data, victor-colors(skin, hair, shirt, pants))

// === Character Definitions (Batch 3 — bust/portrait, no legs) ===

#import "characters/batch-3-top.typ": *

/// Ina: asymmetric purple hair covering one eye, teal pin
/// -> content (inline)
#let ina(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: rgb("#7b1fa2"),
  shirt: shirt-black,
  pants: pants-black,
) = _char-box(size, baseline, ina-data, ina-colors(skin, hair, shirt, pants))

/// Murphy: gray curly hair, glasses, lab coat
/// -> content (inline)
#let murphy(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: rgb("#9e9e9e"),
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, murphy-data, murphy-colors(skin, hair, shirt, pants))

/// Bella: side ponytail with flower, pendant necklace
/// -> content (inline)
#let bella(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-brown,
  shirt: shirt-pink,
  pants: pants-black,
) = _char-box(size, baseline, bella-data, bella-colors(skin, hair, shirt, pants))

// === Character Definitions (Batch 4 — Robots, bust/portrait) ===

#import "characters/batch-4-robots.typ": *

/// Bolt: retro robot, boxy head, antenna prongs
/// -> content (inline)
#let bolt(
  size: 1em,
  baseline: auto,
  skin: chassis-silver,
  hair: rgb("#666666"),
  shirt: shirt-blue,
  pants: pants-black,
) = _char-box(size, baseline, bolt-data, bolt-colors(skin, hair, shirt, pants))

/// Pixel: helper drone, dome head, single LED eye
/// -> content (inline)
#let pixel-char(
  size: 1em,
  baseline: auto,
  skin: chassis-white,
  hair: rgb("#00bcd4"),
  shirt: rgb("#e0e0e0"),
  pants: rgb("#555555"),
) = _char-box(size, baseline, pixel-char-data, pixel-char-colors(skin, hair, shirt, pants))

/// Crank: industrial bot, flat-top, wide shoulders
/// -> content (inline)
#let crank(
  size: 1em,
  baseline: auto,
  skin: chassis-orange,
  hair: rgb("#444444"),
  shirt: rgb("#d35400"),
  pants: pants-black,
) = _char-box(size, baseline, crank-data, crank-colors(skin, hair, shirt, pants))

/// Nova: sleek AI, tapered head, V-shaped visor
/// -> content (inline)
#let nova(
  size: 1em,
  baseline: auto,
  skin: chassis-navy,
  hair: rgb("#283593"),
  shirt: rgb("#1565c0"),
  pants: pants-black,
) = _char-box(size, baseline, nova-data, nova-colors(skin, hair, shirt, pants))

/// Sentinel: guardian, helmet head, red visor slit
/// -> content (inline)
#let sentinel(
  size: 1em,
  baseline: auto,
  skin: chassis-gunmetal,
  hair: rgb("#37474f"),
  shirt: rgb("#455a64"),
  pants: pants-black,
) = _char-box(size, baseline, sentinel-data, sentinel-colors(skin, hair, shirt, pants))
