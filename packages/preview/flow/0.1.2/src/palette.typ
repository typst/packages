#import "cfg.typ"

#let _key-on-theme(section) = {
  for (name, value) in section {
    if type(value) == dictionary {
      value = value.at(cfg.theme)
    }
    section.at(name) = value
  }
  section
}

#let duality = (
  fg: rgb("#B6B3B4"),
  bg: rgb("#212224"),

  blue: rgb("#00C7F7"),
  violet: rgb("#AAA9FF"),
  pink: rgb("#FA86CE"),

  orange: rgb("#FF9365"),
  yellow: rgb("#C7B700"),
  green: rgb("#11D396"),
)

#let print = (
  fg: luma(0%),
  bg: luma(100%),
)

#let fg = (duality: duality.fg, bow: print.fg, wob: print.bg).at(cfg.theme)
#let bg = (duality: duality.bg, bow: print.bg, wob: print.fg).at(cfg.theme)
#let gamut = gradient.linear(bg, fg, space: oklch)

/// Set the text to the given brightness.
/// 0% is merging with the background,
/// 100% is fully visible just like the foreground color.
#let fade(body, value: 60%) = text(fill: gamut.sample(value), body)

#let status = _key-on-theme((
  empty: gamut.sample(75%),
  urgent: (
    duality: duality.orange,
    bow: orange,
    wob: orange,
  ),
  progress: (
    duality: duality.violet,
    bow: purple,
    wob: purple,
  ),
  pause: (
    duality: duality.green,
    bow: green,
    wob: green,
  ),
  block: (
    duality: duality.blue,
    bow: teal,
    wob: teal,
  ),
  complete: fg,
  cancel: gamut.sample(40%),
  unknown: (
    duality: duality.yellow,
    bow: yellow,
    wob: yellow,
  ),

  remark: (
    duality: duality.green,
    bow: green,
    wob: green,
  ),
  hint: (
    duality: duality.violet,
    bow: purple,
    wob: purple,
  ),
  axiom: (
    duality: duality.yellow,
    bow: yellow,
    wob: yellow,
  ),
  define: (
    duality: duality.blue,
    bow: eastern,
    wob: aqua,
  ),
  theorem: (
    duality: duality.orange,
    bow: orange,
    wob: orange,
  ),
  propose: (
    duality: duality.violet,
    bow: purple,
    wob: purple,
  ),
  lemma: (
    duality: duality.pink,
    bow: fuchsia,
    wob: fuchsia,
  ),
  corollary: (
    duality: duality.green,
    bow: lime,
    wob: lime,
  ),
))

#let reference = _key-on-theme((
  external: (
    duality: duality.blue,
    bow: blue,
    wob: blue,
  ),
  other-file: (
    duality: duality.violet,
    bow: purple,
    wob: purple,
  ),
  same-file: (
    duality: duality.green,
    bow: purple.darken(10%),
    wob: purple,
  ),
))
