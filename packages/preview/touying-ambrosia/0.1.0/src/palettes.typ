#import "colors.typ"

#let _luminance(color) = {
  let linear(channel) = {
    let channel = channel / 100%
    if channel <= 0.04045 { channel / 12.92 } else { calc.pow((channel + 0.055) / 1.055, 2.4) }
  }
  let (r, g, b, _) = color.rgb().components()
  0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
}

#let contrast(a, b) = {
  let (a, b) = (_luminance(a), _luminance(b))
  (calc.max(a, b) + 0.05) / (calc.min(a, b) + 0.05)
}

#let readable-accent(primary, backgrounds, dark: false) = {
  let accent = primary
  for _ in range(40) {
    if backgrounds.all(background => contrast(accent, background) >= 4.5) { return accent }
    accent = if dark { accent.lighten(5%) } else { accent.darken(5%) }
  }
  accent
}

#let on-color(background) = {
  let light = colors.light-ink
  let dark = rgb("171b22")
  let chosen = if contrast(light, background) >= contrast(dark, background) { light } else { dark }
  if contrast(chosen, background) >= 4.5 { chosen }
  else if contrast(white, background) >= contrast(black, background) { white } else { black }
}

#let _light(accent, background: white, foreground: black, surface: white,
  surface-alt: auto, muted: colors.charcoal, border: colors.grey, chrome: black,
) = (dark: false, accent: accent, background: background, foreground: foreground,
  surface: surface, surface-alt: surface-alt, muted: muted, border: border, chrome: chrome)

#let _dark(accent, background, surface, surface-alt, chrome, foreground: colors.light-ink,
  muted: rgb("bbc4d2"), border: rgb("596273"),
) = (dark: true, accent: accent, background: background, foreground: foreground,
  surface: surface, surface-alt: surface-alt, chrome: chrome, muted: muted, border: border)

// Presets own all color choices; teams can override their accent independently.
#let palette-definitions = (
  light: _light(colors.accent),
  ocean: _light(rgb("0079c2"), background: rgb("f3f8fc"), foreground: rgb("153449"),
    surface-alt: rgb("e0edf6"), muted: rgb("4e6478"), border: rgb("a6bdd0"), chrome: rgb("14354a")),
  forest: _light(rgb("276749"), background: rgb("f4f8f2"), foreground: rgb("20392c"),
    surface-alt: rgb("e3eedf"), muted: rgb("536858"), border: rgb("aec2ae"), chrome: rgb("1d3728")),
  sand: _light(rgb("9c4c2b"), background: rgb("faf6ee"), foreground: rgb("42332a"), surface: rgb("fffdf8"),
    surface-alt: rgb("f0e6d7"), muted: rgb("75634f"), border: rgb("cabca8"), chrome: rgb("3d2e26")),
  rose: _light(rgb("a43870"), background: rgb("fcf5f8"), foreground: rgb("48273b"), surface: rgb("fffcfd"),
    surface-alt: rgb("f3e4ec"), muted: rgb("806374"), border: rgb("c9aebc"), chrome: rgb("432036")),
  slate: _light(rgb("415e87"), background: rgb("f2f4f7"), foreground: rgb("263341"),
    surface-alt: rgb("e1e6ee"), muted: rgb("596675"), border: rgb("acb7c5"), chrome: rgb("25303c")),
  nocturne: _dark(colors.accent, rgb("171b22"), rgb("242b36"), rgb("303948"), rgb("10141a")),
  nebula: _dark(rgb("9b4d88"), rgb("251422"), rgb("372036"), rgb("493047"), rgb("1c101b"), border: rgb("6e596e")),
  midnight: _dark(rgb("3498db"), rgb("111c30"), rgb("1b2c45"), rgb("263b57"), rgb("0c1526"),
    foreground: rgb("eef4ff"), muted: rgb("b2c2d8"), border: rgb("586f8c")),
  evergreen: _dark(rgb("62c294"), rgb("13271f"), rgb("203b2e"), rgb("2f4e3f"), rgb("0d1e16"),
    foreground: rgb("f0f8f1"), muted: rgb("b5ccbe"), border: rgb("5d8070")),
  ember: _dark(rgb("d77b3b"), rgb("281d19"), rgb("3b2b23"), rgb("50382d"), rgb("1d1411"),
    foreground: rgb("fff5eb"), muted: rgb("d6bdb0"), border: rgb("826253")),
  graphite: _dark(rgb("9ba4b3"), rgb("1e1e20"), rgb("2c2c30"), rgb("3a3a40"), rgb("121214"),
    foreground: rgb("f4f4f4"), muted: rgb("c4c4cb"), border: rgb("6d6d76")),
)

#let palette-names = palette-definitions.keys()

#let _extra-roles = ("info", "success", "warning", "danger", "cover", "on-cover", "on-chrome",
  "on-accent", "accent-strong", "on-accent-strong", "chrome-muted", "primary-lightest", "secondary", "tertiary")

#let _definition(value) = {
  if type(value) == str {
    assert(value in palette-names, message: "Palette '" + value + "' is not supported. Choose: " + palette-names.join(", ") + ".")
    palette-definitions.at(value) + (name: value, kind: "ambrosia-palette")
  } else {
    assert(type(value) == dictionary and value.at("kind", default: none) == "ambrosia-palette",
      message: "Use a palette name or an ambrosia-palette descriptor.")
    value
  }
}

/// Compose a palette from a preset or descriptor. Hue rotation runs before
/// the explicit primary seed and named role overrides; semantic hues stay fixed.
/// -> dictionary
#let ambrosia-palette(
  /// Base preset name or another palette descriptor.
  /// -> str | dictionary
  base: "light",
  /// Display name; does not register a global preset.
  /// -> str
  name: "custom",
  /// Accent seed. Text accents are adjusted for contrast when resolved.
  /// -> auto | color
  primary: auto,
  /// Relative OKLCH hue rotation of the base colors.
  /// -> angle
  rotate: 0deg,
  /// Named color roles, such as `background` or `surface`; `dark` is a boolean.
  /// -> arguments
  ..roles,
) = {
  assert(type(name) == str and name != "", message: "Palette name must be a nonempty string.")
  assert(type(rotate) == angle, message: "Palette rotate must be an angle, such as 30deg.")
  assert(primary == auto or type(primary) == color, message: "Palette primary must be a color or auto.")
  assert(roles.pos().len() == 0, message: "Palette roles must be named arguments.")
  let definition = _definition(base)
  for key in ("accent", "background", "foreground", "surface", "surface-alt", "muted", "border", "chrome") {
    let value = definition.at(key)
    if type(value) == color and rotate != 0deg {
      definition.insert(key, value.oklch().rotate(rotate).rgb())
    }
  }
  if primary != auto { definition.accent = primary }
  for (key, value) in roles.named() {
    assert(key in palette-definitions.light or key in _extra-roles,
      message: "Unknown palette role: " + key)
    assert(if key == "dark" { type(value) == bool }
      else { type(value) == color or (key == "surface-alt" and value == auto) },
      message: "Palette role '" + key + "' must be " + if key == "dark" { "a boolean." } else { "a color." })
    definition.insert(key, value)
  }
  definition + (name: name)
}

// Select the logo variant from the surface it actually sits on.
#let prefer-light(background, light: colors.light-ink, dark: colors.dark-ink) = type(background) != color or contrast(light, background) > contrast(dark, background)

// Semantic surfaces/text roles keep colors independent of layout and branding.
#let resolve(name, primary: auto) = {
  let definition = _definition(name)
  let primary = if primary == auto { definition.accent } else { primary }
  let surface-alt = if definition.surface-alt == auto { primary.lighten(90%) } else { definition.surface-alt }
  let backgrounds = (definition.background, definition.surface, surface-alt)
  let accent = readable-accent(primary, backgrounds, dark: definition.dark)
  let strong = readable-accent(primary, (colors.light-ink,))
  let semantic = (:)
  for (name, base) in (info: rgb("2475b0"), success: rgb("278354"), warning: rgb("b47700"), danger: rgb("bd3450")) {
    semantic.insert(name, readable-accent(definition.at(name, default: base), backgrounds, dark: definition.dark))
  }
  let resolved = definition + semantic + (
    accent: accent, surface-alt: surface-alt,
    muted: readable-accent(definition.muted, backgrounds, dark: definition.dark),
    accent-strong: strong, on-accent-strong: colors.light-ink,
    cover: if definition.dark { definition.background } else { strong }, on-cover: colors.light-ink,
    on-chrome: colors.light-ink, chrome-muted: readable-accent(definition.muted, (definition.chrome,), dark: true),
    on-accent: on-color(accent),
  )
  for key in _extra-roles.filter(key => key not in semantic) {
    if key in definition { resolved.insert(key, definition.at(key)) }
  }
  resolved
}
