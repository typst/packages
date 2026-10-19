// touying-ufac-unofficial — constants: the color palette, the UFAC logo (its SVG and `ufac-logo-image`, which draws it in
// the colours of the theme) and the code-block language table. Everything else derived from these values (tones,
// `config-colors`, the footer) lives in the other modules.

/// Seven-tone ramp of a base color, derived in RGB: `darkest`/`darker`/`dark` by `darken(75% / 55% / 30%)` and
/// `light`/`lighter`/`lightest` by `lighten(30% / 60% / 85%)`. The base tone itself is inserted by the caller.
///
/// #test(
///   `_ramp(red).keys() == ("darkest", "darker", "dark", "light", "lighter", "lightest")`,
///   `_ramp(red).dark == red.darken(30%)`,
///   `_ramp(red).lightest == red.lighten(85%)`,
/// )
/// -> dictionary
#let _ramp(
  /// Base color of the family. -> color
  c,
) = (
  darkest: c.darken(75%), darker: c.darken(55%), dark: c.darken(30%),
  light: c.lighten(30%), lighter: c.lighten(60%), lightest: c.lighten(85%),
)

/// Ramp of the neutral family, following Touying's default: `#808080` ± thirds, ending in pure black and white.
///
/// #test(
///   `_neutral-ramp(gray).darkest == rgb("#000000")`,
///   `_neutral-ramp(gray).lightest == rgb("#ffffff")`,
/// )
/// -> dictionary
#let _neutral-ramp(
  /// Base gray. -> color
  c,
) = (
  darkest: rgb("#000000"), darker: c.darken(66.667%), dark: c.darken(33.333%),
  light: c.lighten(33.333%), lighter: c.lighten(66.667%), lightest: rgb("#ffffff"),
)

/// The theme palette: the official UFAC colors plus a neutral gray, named after Touying's `config-colors` keys
/// (`primary`, `secondary`, `tertiary`, `neutral`) plus `quaternary`. Each family has 7 tones, `<family>-darkest`,
/// `-darker`, `-dark`, the base, `-light`, `-lighter` and `-lightest`, so `colors.primary-lighter`,
/// `colors.quaternary-dark` etc. exist. The whole dictionary is passed to `config-colors`, hence the same keys are
/// available as `self.colors.*`.
///
/// #table(
///   columns: 3,
///   table.header([Family], [Base], [Role]),
///   [`primary`], [`#0C4DA2`], [titles, `->` markers, tables, `#alert`/`#primary`, pills],
///   [`secondary`], [`#FFBF14`], [`-` markers, `#secondary`, quotes; `-lighter` is the highlight],
///   [`tertiary`], [`#BE1E2D`], [`#tertiary`, exercises],
///   [`quaternary`], [`#09B081`], [`#quaternary`, examples],
///   [`neutral`], [`#808080`], [`-darkest` is the bold/italic text, `-lightest` the background],
/// )
///
/// #test(
///   `colors.len() == 35`,
///   `colors.primary == rgb("#0C4DA2")`,
///   `colors.secondary-lighter == colors.secondary.lighten(60%)`,
///   `colors.neutral-darkest == rgb("#000000")`,
/// )
/// -> dictionary
#let colors = {
  let base = (
    primary: rgb("#0C4DA2"), secondary: rgb("#FFBF14"), tertiary: rgb("#BE1E2D"), quaternary: rgb("#09B081"),
    neutral: rgb("#808080"),
  )
  let d = base
  for (name, c) in base {
    for (tone, v) in (if name == "neutral" { _neutral-ramp(c) } else { _ramp(c) }) { d.insert(name + "-" + tone, v) }
  }
  d
}

/// Languages known to codly in code blocks. The `name` is what `#local(display-name: true)[…]` shows as a label;
/// `text` is labelled "saída" (output), in Portuguese like the other user-facing defaults of the theme.
/// -> dictionary
#let code-languages = (
  python: (name: "Python", color: rgb("#3776AB")),
  typst: (name: "Typst", color: rgb("#239DAD")),
  bash: (name: "Bash", color: rgb("#4EAA25")),
  text: (name: "saída", color: luma(120)),
)

// The logo lives in its own file, assets/ufac-logo.svg: it is copyrighted by the Universidade Federal do Acre (UFAC) and
// is not covered by the license of this package (see the License section of the README).
/// Official UFAC logo as an SVG string (yellow shield and blue lettering). @ufac-logo-image draws it, also in other
/// colours (the footer, blue; the cover, white with the yellow shield).
///
/// The logo belongs to the Universidade Federal do Acre and is not covered by the license of the package.
///
/// ```example
/// #image(bytes(ufac-logo), height: 2em)
/// ```
/// -> str
#let ufac-logo = read("../assets/ufac-logo.svg")

/// The UFAC logo as an image, in the colours the theme uses: blue lettering with the yellow shield, as in the footer
/// of the slides; the lettering in another colour, as on the cover (`color: white`, the shield still yellow); or all
/// in one colour (`color: white, shield: white`), on a background where the yellow would not stand out. For a
/// document that goes with the slides, such as a handout, or a logo next to it in `ufac-theme(logos:)`.
///
/// ```example
/// #ufac-logo-image(height: 2em)
/// #box(fill: colors.primary, inset: 0.4em,
///   ufac-logo-image(height: 2em, color: white))
/// #box(fill: colors.primary, inset: 0.4em,
///   ufac-logo-image(height: 2em, color: white, shield: white))
/// ```
/// -> content
#let ufac-logo-image(
  /// Height of the logo; `0.64em` is its height in the footer. -> length
  height: 0.64em,
  /// Colour of the lettering, the blue `#0c4da2` of the logo; `auto` keeps it. -> auto | color
  color: auto,
  /// Colour of the shield, the yellow `#fdb813` of the logo; `auto` keeps it. -> auto | color
  shield: auto,
) = {
  let svg = ufac-logo
  if color != auto { svg = svg.replace("#0c4da2", color.to-hex()) }
  if shield != auto { svg = svg.replace("#fdb813", shield.to-hex()) }
  image(bytes(svg), height: height)
}
