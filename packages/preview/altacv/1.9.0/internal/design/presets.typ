// The colour themes and the deprecated accent palettes, re-exported
// from `lib.typ`. A theme is `_tokens` overrides (`theme.typ`), any
// subset of them; the built-in ones, one file each under `presets/`,
// set every colour role.

#import "presets/teal.typ"
#import "presets/navy.typ"
#import "presets/crimson.typ"
#import "presets/forest.typ"
#import "presets/plum.typ"
#import "presets/charcoal.typ"
#import "presets/altacv.typ"
#import "presets/rust.typ"
#import "presets/bauhaus.typ"
#import "presets/riso.typ"
#import "presets/phosphor.typ"
#import "presets/catppuccin.typ"

/// The built-in themes by name, for `altacv.with(theme: ..)`: `teal`
/// (the default), `navy`, `crimson`, `forest`, `plum`, `charcoal`,
/// `altacv`, `rust`, `bauhaus`, `riso`, `phosphor` and `catppuccin`.
/// Each is a dictionary of theme tokens; add to one to adjust it,
/// `themes.navy + (font: "Libertinus Serif")`.
/// -> dictionary
#let themes = (
  teal: teal.theme,
  navy: navy.theme,
  crimson: crimson.theme,
  forest: forest.theme,
  plum: plum.theme,
  charcoal: charcoal.theme,
  altacv: altacv.theme,
  rust: rust.theme,
  bauhaus: bauhaus.theme,
  riso: riso.theme,
  phosphor: phosphor.theme,
  catppuccin: catppuccin.theme,
)

/// The heading colours of the original six themes, `teal` to
/// `charcoal`, frozen when it was deprecated. Deprecated: use `themes`.
/// -> dictionary
#let palettes = (
  ("teal", "navy", "crimson", "forest", "plum", "charcoal")
    .map(k => (k, themes.at(k).colours.heading))
    .to-dict()
)
