// touying-ufac-unofficial — constants: the color palette, the UFAC logo and the code-block language table.
// Everything derived from these values (tones, `config-colors`, the footer logo) lives in the other modules.

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
/// Official UFAC logo as an SVG string (yellow shield and blue lettering), rendered in the footer with
/// `image(bytes(ufac-logo), height: 0.64em)`. The title slide replaces the blue `#0c4da2` with white.
///
/// The logo belongs to the Universidade Federal do Acre and is not covered by the license of the package.
///
/// ```example
/// #image(bytes(ufac-logo), height: 2em)
/// ```
/// -> str
#let ufac-logo = read("../assets/ufac-logo.svg")
