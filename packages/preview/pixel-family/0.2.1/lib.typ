// Pixel Family — Inline pixel characters for Typst
//
// Usage:
//   #import "@preview/pixel-family:0.2.1": bob, alice, eve
//   Hello #bob() and #alice() and #eve()!

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

/// Render a 2D pixel array as native Typst content using one `curve()` per color.
/// Groups all pixels of the same color into a single multi-subpath curve element,
/// reducing ~200 draw calls to ~6 (one per distinct color).
///
/// - data (array): 2D array of color indices (0 = transparent)
/// - colors (array): color palette where colors.at(index) gives the fill color
/// - cell-size (length): size of each pixel cell
/// -> content (placed curve elements)
#let pixel-grid(data, colors, cell-size) = {
  let rows = data.len()
  // Group pixel positions by color index
  let groups = (:)
  for (row-idx, row) in data.enumerate() {
    for (col-idx, color-idx) in row.enumerate() {
      if color-idx > 0 and color-idx < colors.len() {
        let key = str(color-idx)
        if key not in groups { groups.insert(key, ()) }
        groups.at(key).push((col-idx, row-idx))
      }
    }
  }
  // Emit one curve() per color with all pixels as sub-paths
  for (key, positions) in groups {
    let color = colors.at(int(key))
    let commands = ()
    for (col, row) in positions {
      let x = col * cell-size
      let y = row * cell-size
      commands.push(curve.move((x, y)))
      commands.push(curve.line((x + cell-size, y)))
      commands.push(curve.line((x + cell-size, y + cell-size)))
      commands.push(curve.line((x, y + cell-size)))
      commands.push(curve.close(mode: "straight"))
    }
    place(curve(fill: color, stroke: none, ..commands))
  }
}

// === Character Box Helper ===
// Wraps pixel data into inline content with configurable baseline.
// baseline: auto = center-aligned with text, or pass a length (e.g. 0pt for bottom)
#let _char-box(size, baseline, data, colors) = box(
  baseline: if baseline == auto { (size - 1em) / 2 } else { baseline },
  width: size,
  height: size,
  pixel-grid(data, colors, size / 16),
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

// === Character Definitions (Batch 5 — Community, bust/portrait) ===

#import "characters/batch-5-community.typ": *

/// Alien: big brain dome, glowing green eyes (prototype GiggleLiu)
/// -> content (inline)
#let alien(
  size: 1em,
  baseline: auto,
  skin: rgb("#a8c8e8"),
  hair: rgb("#6a8cba"),
  shirt: rgb("#f0f0f0"),
  pants: pants-black,
) = _char-box(size, baseline, alien-data, alien-colors(skin, hair, shirt, pants))

/// Seraphim: fiery crown, eye-covered body, folded wings (prototype RJG)
/// -> content (inline)
#let seraphim(
  size: 1em,
  baseline: auto,
  skin: skin-light,
  hair: rgb("#fff3b0"),
  shirt: rgb("#c0392b"),
  pants: rgb("#8b0000"),
) = _char-box(size, baseline, seraphim-data, seraphim-colors(skin, hair, shirt, pants))

/// Shamir: vertically split in two halves (prototype ShawnAn)
/// -> content (inline)
#let shamir(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-brown,
  shirt: shirt-blue,
  pants: pants-black,
) = _char-box(size, baseline, shamir-data, shamir-colors(skin, hair, shirt, pants))

/// Steve: longer hair with glasses, teal shirt (prototype Zhongyi)
/// -> content (inline)
#let steve(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-brown,
  shirt: rgb("#008080"),
  pants: rgb("#6a0dad"),
) = _char-box(size, baseline, steve-data, steve-colors(skin, hair, shirt, pants))

/// Yui: brown hair with yellow hairclips, sailor collar (prototype Yui)
/// -> content (inline)
#let yui(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: rgb("#8b5a2b"),
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, yui-data, yui-colors(skin, hair, shirt, pants))

/// Logic: gate-shaped head, LED eyes, circuit-trace body (prototype Hongkuan)
/// -> content (inline)
#let logic(
  size: 1em,
  baseline: auto,
  skin: rgb("#b0b0b0"),
  hair: rgb("#555555"),
  shirt: rgb("#2c3e50"),
  pants: pants-black,
) = _char-box(size, baseline, logic-data, logic-colors(skin, hair, shirt, pants))

/// Tabby: chonky orange cat, half-closed happy eyes (prototype Patrick)
/// -> content (inline)
#let tabby(
  size: 1em,
  baseline: auto,
  skin: rgb("#e8932f"),
  hair: rgb("#c06a1a"),
  shirt: rgb("#ffe0b2"),
  pants: pants-black,
) = _char-box(size, baseline, tabby-data, tabby-colors(skin, hair, shirt, pants))

/// Schrodinger: half-solid half-ghostly cat (prototype GuoyiZhu)
/// -> content (inline)
#let schrodinger(
  size: 1em,
  baseline: auto,
  skin: rgb("#555577"),
  hair: rgb("#333355"),
  shirt: rgb("#7777aa"),
  pants: pants-black,
) = _char-box(size, baseline, schrodinger-data, schrodinger-colors(skin, hair, shirt, pants))

/// Enaga: maximum fluffball Shima Enaga bird (prototype hmyuuu)
/// -> content (inline)
#let enaga(
  size: 1em,
  baseline: auto,
  skin: rgb("#fafafa"),
  hair: rgb("#555555"),
  shirt: rgb("#e8e8e8"),
  pants: pants-black,
) = _char-box(size, baseline, enaga-data, enaga-colors(skin, hair, shirt, pants))

/// Noir: black cat with wind-blown red scarf (prototype xuanzhao)
/// -> content (inline)
#let noir(
  size: 1em,
  baseline: auto,
  skin: rgb("#1a1a1a"),
  hair: rgb("#333333"),
  shirt: rgb("#e74c3c"),
  pants: pants-black,
) = _char-box(size, baseline, noir-data, noir-colors(skin, hair, shirt, pants))

/// Milady: bob-cut hair, headphones, cyber glow (prototype Qingyun)
/// -> content (inline)
#let milady(
  size: 1em,
  baseline: auto,
  skin: skin-light,
  hair: rgb("#1a1a2e"),
  shirt: rgb("#1a1a2e"),
  pants: pants-black,
) = _char-box(size, baseline, milady-data, milady-colors(skin, hair, shirt, pants))

/// Tigris: white tiger, black stripes, blue eyes (prototype YushengZhao)
/// -> content (inline)
#let tigris(
  size: 1em,
  baseline: auto,
  skin: rgb("#f5f5f5"),
  hair: hair-black,
  shirt: rgb("#e8e8e8"),
  pants: rgb("#555555"),
) = _char-box(size, baseline, tigris-data, tigris-colors(skin, hair, shirt, pants))

/// Porcellum: royal piglet with gold crown and bowtie (prototype Han Wang)
/// -> content (inline)
#let porcellum(
  size: 1em,
  baseline: auto,
  skin: rgb("#ffb6c1"),
  hair: rgb("#e8909a"),
  shirt: rgb("#ffe4e1"),
  pants: pants-black,
) = _char-box(size, baseline, porcellum-data, porcellum-colors(skin, hair, shirt, pants))

/// Lain: bear-suit hoodie, antenna wire (prototype longli zheng)
/// -> content (inline)
#let lain(
  size: 1em,
  baseline: auto,
  skin: skin-light,
  hair: hair-brown,
  shirt: rgb("#8b7355"),
  pants: pants-black,
) = _char-box(size, baseline, lain-data, lain-colors(skin, hair, shirt, pants))

/// Dragon: eastern dragon head, curved horns, gold whiskers (prototype Yuqing)
/// -> content (inline)
#let dragon(
  size: 1em,
  baseline: auto,
  skin: rgb("#2e7d32"),
  hair: rgb("#1b5e20"),
  shirt: rgb("#a5d6a7"),
  pants: pants-black,
) = _char-box(size, baseline, dragon-data, dragon-colors(skin, hair, shirt, pants))

/// Paddler: brown bear with ping-pong paddle (prototype Guanhua)
/// -> content (inline)
#let paddler(
  size: 1em,
  baseline: auto,
  skin: rgb("#8b6914"),
  hair: rgb("#654321"),
  shirt: rgb("#d2b48c"),
  pants: pants-black,
) = _char-box(size, baseline, paddler-data, paddler-colors(skin, hair, shirt, pants))

/// Chaser: solar crown, sun-ray spikes, golden emblem (prototype zhaohui)
/// -> content (inline)
#let chaser(
  size: 1em,
  baseline: auto,
  skin: rgb("#c6865c"),
  hair: rgb("#c73e1d"),
  shirt: rgb("#e74c3c"),
  pants: pants-black,
) = _char-box(size, baseline, chaser-data, chaser-colors(skin, hair, shirt, pants))

/// Alchemist: spiky hair, goggles, lab coat, cyan chip (prototype Shiqinrui Xu)
/// -> content (inline)
#let alchemist(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-brown,
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, alchemist-data, alchemist-colors(skin, hair, shirt, pants))

/// Hong Yuan: short bob, dark blazer, coffee mug, crystal pin (prototype Hong Yuan)
/// -> content (inline)
#let hongyuan(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-black,
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, hongyuan-data, hongyuan-colors(skin, hair, shirt, pants))

/// Fox: orange trickster fox, pointed ears, bushy tail (prototype sqwu)
/// -> content (inline)
#let fox(
  size: 1em,
  baseline: auto,
  skin: rgb("#e8932f"),
  hair: rgb("#b5651d"),
  shirt: rgb("#ffe0b2"),
  pants: pants-black,
) = _char-box(size, baseline, fox-data, fox-colors(skin, hair, shirt, pants))

/// Tuxedo: split-face black and white cat (prototype jiahutang)
/// -> content (inline)
#let tuxedo(
  size: 1em,
  baseline: auto,
  skin: rgb("#222222"),
  hair: rgb("#1a1a1a"),
  shirt: rgb("#f0f0f0"),
  pants: pants-black,
) = _char-box(size, baseline, tuxedo-data, tuxedo-colors(skin, hair, shirt, pants))

/// Climber: beanie with pom-pom, climbing rope across chest (prototype M. J.)
/// -> content (inline)
#let climber(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-brown,
  shirt: shirt-red,
  pants: rgb("#2e7d32"),
) = _char-box(size, baseline, climber-data, climber-colors(skin, hair, shirt, pants))

/// Sleeper: nightcap with pom-pom, closed eyes, pajama buttons (prototype J.-T. Jin)
/// -> content (inline)
#let sleeper(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-brown,
  shirt: shirt-blue,
  pants: rgb("#1a237e"),
) = _char-box(size, baseline, sleeper-data, sleeper-colors(skin, hair, shirt, pants))

/// Astronaut: fishbowl helmet, gold visor, white suit, mission patch (prototype Shengwei)
/// -> content (inline)
#let astronaut(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: rgb("#e0e0e0"),
  shirt: rgb("#f5f5f5"),
  pants: pants-black,
) = _char-box(size, baseline, astronaut-data, astronaut-colors(skin, hair, shirt, pants))

/// ARPES: messy hair, UV goggles, lab coat, spectral pin (prototype keyuan)
/// -> content (inline)
#let arpes(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: rgb("#3e2723"),
  shirt: rgb("#ecf0f1"),
  pants: rgb("#2c3e50"),
) = _char-box(size, baseline, arpes-data, arpes-colors(skin, hair, shirt, pants))

/// Echo: star halo, constellation robe, starlight figure (prototype Qiushan)
/// -> content (inline)
#let echo(
  size: 1em,
  baseline: auto,
  skin: rgb("#d5c8d6"),
  hair: rgb("#1a1a3e"),
  shirt: rgb("#0d0d2b"),
  pants: pants-black,
) = _char-box(size, baseline, echo-data, echo-colors(skin, hair, shirt, pants))

/// Meteor Rex: side-view running dino fleeing a meteorite (prototype Huan-Hai Zhou)
/// -> content (inline)
#let meteor-rex(
  size: 1em,
  baseline: auto,
  skin: rgb("#fff176"),
  hair: rgb("#fdd835"),
  shirt: rgb("#fffde7"),
  pants: pants-black,
) = _char-box(size, baseline, meteor-rex-data, meteor-rex-colors(skin, hair, shirt, pants))

/// Dirac: flowing hair, lab coat, wave lines on chest (prototype Xi Dai)
/// -> content (inline)
#let dirac(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: hair-black,
  shirt: shirt-white,
  pants: pants-black,
) = _char-box(size, baseline, dirac-data, dirac-colors(skin, hair, shirt, pants))

/// Split-Phase: vertically split hair+shirt, golden domain wall line (prototype Shangqiang Ning)
/// -> content (inline)
#let split-phase(
  size: 1em,
  baseline: auto,
  skin: skin-default,
  hair: rgb("#2c1654"),
  shirt: rgb("#1a237e"),
  pants: pants-black,
) = _char-box(size, baseline, split-phase-data, split-phase-colors(skin, hair, shirt, pants))
