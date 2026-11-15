#import "core.typ" as core
#import core.palettes: *
#import "colors.typ"

// Institution presets are explicit; neutral names keep the core's colors.
#let greyc-light = core.ambrosia-palette(base: "light", name: "greyc-light", primary: colors.primary,
  primary-lightest: colors.tertiary, secondary: white, tertiary: colors.primary.lighten(80%))
#let greyc-ivory = core.ambrosia-palette(base: "light", name: "greyc-ivory", primary: colors.primary,
  background: rgb("faf7f2"), foreground: rgb("352b33"), surface: rgb("fffdf9"),
  surface-alt: rgb("f1e8ef"), muted: rgb("756571"), border: rgb("ccbfc9"), chrome: rgb("3d2339"))
#let greyc-nocturne = core.ambrosia-palette(base: "nocturne", name: "greyc-nocturne", primary: colors.primary)
#let greyc-charcoal = core.ambrosia-palette(base: "graphite", name: "greyc-charcoal", primary: colors.primary,
  background: rgb("242424"), surface: rgb("303030"), surface-alt: rgb("3c3a3c"),
  foreground: colors.logo-light, muted: rgb("c3b8c0"), border: rgb("666066"), chrome: rgb("181818"))

#let _greyc-palettes = (
  greyc-light: greyc-light,
  greyc-ivory: greyc-ivory,
  greyc-nocturne: greyc-nocturne,
  greyc-charcoal: greyc-charcoal,
)
#let palette-names = core.palettes.palette-names + _greyc-palettes.keys()
#let definition(value) = {
  if type(value) == str and value in _greyc-palettes { _greyc-palettes.at(value) } else { value }
}
#let ambrosia-palette(base: "light", ..args) = core.ambrosia-palette(base: definition(base), ..args)
#let resolve(name, primary: auto) = core.palettes.resolve(definition(name), primary: primary)
#let prefer-light(background) = core.palettes.prefer-light(background, light: colors.logo-light, dark: colors.logo)
