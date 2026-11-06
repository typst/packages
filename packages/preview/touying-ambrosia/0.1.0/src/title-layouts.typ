// Title composition is independent of flavor, palette, and institutional roles.
#let title-layout-defaults = (
  name: "custom",
  composition: "centered",
  alignment: center,
  logos-placement: "above",
  logos-align: center,
  logos-distribution: auto,
  logo-height: auto,
  logo-columns: auto,
  logo-gap: 0.7em,
  featured-logo: false,
  featured-logo-height: 3em,
  header-background: self => self.colors.chrome,
  header-inset: 0.45em,
  title-background: auto,
  title-text: auto,
  title-shadow: auto,
  title-width: auto,
  title-size: 1.2em,
  subtitle-size: 1em,
  title-inset: 1em,
  title-radius: 0.5em,
  gap: 0.65em,
  side-width: 30%,
  side-background: self => self.colors.surface-alt,
  immersive: false,
  page-background: auto,
  foreground: auto,
  background-image: none,
  background-overlay: none,
)

#let title-layouts = (
  stacked: title-layout-defaults,
  header: title-layout-defaults + (logos-placement: "header", logos-align: right, logo-height: 1.8em),
  split: title-layout-defaults + (
    composition: "split", logos-placement: "side", alignment: left,
    title-background: none, title-shadow: false, title-inset: 0em, title-size: 1.55em,
    gap: 1em,
  ),
  plain: title-layout-defaults + (
    alignment: left, logos-align: left, title-background: none,
    title-shadow: false, title-inset: 0em, title-size: 1.55em,
    gap: 1em,
  ),
  featured: title-layout-defaults + (
    featured-logo: true, logos-placement: "below", logo-height: 1.4em,
  ),
  cover: title-layout-defaults + (
    immersive: true, page-background: self => self.colors.cover,
    foreground: self => self.colors.on-cover,
    title-background: none, title-text: self => self.colors.on-cover,
    title-shadow: false, title-inset: 0em, title-size: 1.7em, gap: 1em,
    background-overlay: self => self.colors.cover.transparentize(20%),
  ),
)
#let title-layout-names = title-layouts.keys()

#let get-title-layout(value) = {
  let definition = if type(value) == str {
    assert(value in title-layouts, message: "Title layout '" + value + "' is not supported. Choose: " + title-layout-names.join(", ") + ".")
    title-layouts.at(value) + (name: value)
  } else {
    assert(type(value) == dictionary, message: "Title layout must be a built-in name or an ambrosia-title-layout descriptor.")
    for key in value.keys() { assert(key in title-layout-defaults, message: "Unknown title layout option: " + key) }
    title-layout-defaults + value
  }
  assert(type(definition.name) == str, message: "Title layout name must be a string.")
  assert(definition.composition in ("centered", "split"), message: "Title composition must be centered or split.")
  assert(definition.alignment in (left, center, right) and definition.logos-align in (left, center, right),
    message: "Title and logo alignment must be left, center, or right.")
  assert(definition.logos-placement in ("above", "below", "header", "side", "none"), message: "Title logos-placement must be above, below, header, side, or none.")
  assert(definition.logos-distribution in (auto, "equal", "grouped"), message: "Title logos-distribution must be auto, equal, or grouped.")
  assert(definition.logos-placement != "side" or definition.composition == "split", message: "Side logos require the split title composition.")
  assert(definition.logo-height == auto or type(definition.logo-height) == length, message: "Title logo-height must be auto or a length.")
  assert(definition.logo-columns == auto or (type(definition.logo-columns) == int and definition.logo-columns > 0),
    message: "Title logo-columns must be auto or a positive integer.")
  assert(definition.title-shadow == auto or type(definition.title-shadow) == bool, message: "Title shadow must be auto, true, or false.")
  assert(type(definition.featured-logo) == bool and type(definition.immersive) == bool,
    message: "Title featured-logo and immersive must be true or false.")
  for key in ("logo-gap", "featured-logo-height", "header-inset", "title-size", "subtitle-size", "title-inset", "title-radius", "gap") {
    assert(type(definition.at(key)) == length, message: "Title " + key + " must be a length.")
  }
  assert(type(definition.side-width) == ratio and 0% < definition.side-width and definition.side-width < 70%,
    message: "Title side-width must be between 0% and 70%.")
  definition
}

/// Extend a native title layout without writing a custom slide renderer.
#let ambrosia-title-layout(base: "stacked", name: "custom", ..options) = get-title-layout(
  get-title-layout(base) + options.named() + (name: name),
)

#let resolve-title-layout(self, layout: auto) = {
  let definition = get-title-layout(
    if layout != auto { layout }
    else if self.store.title-layout != auto { self.store.title-layout }
    else { self.store.flavor-definition.title-layout })
  if definition.logos-distribution == auto { definition.logos-distribution = self.store.title-logo-distribution }
  definition
}
