// Colour theme: five accent colours with fixed roles.
//
//   primary     numbers of chapters, sections and parts, the margin table of
//               contents, the vertical rules, list markers, sidenote numbers
//               and the rules of code listings
//   link        years in citations, cross-references and URLs
//   challenge   Challenge boxes
//   objective   Objective boxes
//   definition  Definition, corollary, theorem, lemma, proposition, example
//               and remark boxes
//
// Without any setting the template looks exactly like the reference
// dissertation (black and grey, blue citation years).
#import "metrics.typ" as m

#let default = (
  primary: black,
  link: m.colors.cite,
  challenge: black,
  objective: black,
  definition: black,
)

// Example palettes; use them as `colors: "ocean"` or adapt them:
// `colors: palettes.ocean + (challenge: rgb("#b03a2e"))`.
#let palettes = (
  default: default,
  ocean: (
    primary: rgb("#1d4e89"),
    link: rgb("#1f78a8"),
    challenge: rgb("#b5403a"),
    objective: rgb("#2f7d5b"),
    definition: rgb("#1d4e89"),
  ),
  forest: (
    primary: rgb("#2f5d34"),
    link: rgb("#3c8031"),
    challenge: rgb("#a4532a"),
    objective: rgb("#2b6f74"),
    definition: rgb("#6b6a2a"),
  ),
  berry: (
    primary: rgb("#6a2c58"),
    link: rgb("#8e3a6b"),
    challenge: rgb("#b23a48"),
    objective: rgb("#3a5a8c"),
    definition: rgb("#6a2c58"),
  ),
)

// colors: none (default), the name of a palette, or a dictionary with any of
// the five roles (missing roles fall back to the default colours).
// box-style: "tinted", "bar" or "banner".
#let make-theme(colors: none, box-style: "tinted") = {
  assert(box-style in ("tinted", "bar", "banner"), message: "kaodiss: box-style must be \"tinted\", \"bar\" or \"banner\"")
  let custom = if colors == none or colors == "default" { (:) } else if type(colors) == str {
    assert(colors in palettes, message: "kaodiss: unknown palette " + colors + "; use one of " + palettes.keys().join(", "))
    palettes.at(colors)
  } else { colors }
  for key in custom.keys() {
    assert(key in default, message: "kaodiss: unknown colour role " + key + "; roles are " + default.keys().join(", "))
  }
  (
    ..default,
    ..custom,
    box-style: box-style,
    // By default only citation years are coloured; with an own palette,
    // cross-references and URLs take the link colour too.
    color-refs: "link" in custom,
    url: if "link" in custom { custom.link } else { m.colors.url },
  )
}

// Light background for boxes. Black gives the grey of the reference
// dissertation; colours are lightened a little less so that they stay visible.
#let tint(c, grey: 95%, colour: 90%) = if c == black { luma(grey) } else { c.lighten(colour) }

// The theme is also stored in a state, for functions that are called from the
// document (sidenotes). Colours do not influence the layout, so this does not
// cost extra layout iterations.
#let theme-state = state("kao-theme", make-theme())
