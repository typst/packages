// Closing composition follows the same override model as opening composition.
#let ending-layout-defaults = (
  name: "custom", composition: "centered", alignment: center,
  logos-placement: "none", logos-align: center,
  logo-height: 2em, logo-columns: auto, logo-gap: 0.7em,
  title-background: auto, title-text: auto, title-shadow: auto,
  title-width: auto, title-inset: 0.75em, title-radius: 0.5em, title-size: 1.5em,
  gap: 1em, side-width: 32%, side-background: self => self.colors.surface-alt,
  immersive: false, page-background: auto, foreground: auto,
  background-image: none, background-overlay: none,
)
#let ending-layouts = (
  centered: ending-layout-defaults,
  plain: ending-layout-defaults + (
    alignment: left, title-background: none, title-shadow: false,
    title-inset: 0em, title-size: 1.7em,
  ),
  split: ending-layout-defaults + (
    composition: "split", alignment: left, logos-placement: "side",
    title-background: none, title-shadow: false, title-inset: 0em,
  ),
  cover: ending-layout-defaults + (
    immersive: true, page-background: self => self.colors.cover,
    foreground: self => self.colors.on-cover, logos-placement: "above",
    title-background: none, title-text: self => self.colors.on-cover,
    title-shadow: false, title-inset: 0em, title-size: 2em,
    background-overlay: self => self.colors.cover.transparentize(20%),
  ),
)
#let ending-layout-names = ending-layouts.keys()
#let get-ending-layout(value) = {
  let definition = if type(value) == str {
    assert(value in ending-layouts, message: "Ending layout '" + value + "' is not supported. Choose: " + ending-layout-names.join(", ") + ".")
    ending-layouts.at(value) + (name: value)
  } else {
    assert(type(value) == dictionary, message: "Ending layout must be a built-in name or an ambrosia-ending-layout descriptor.")
    for key in value.keys() { assert(key in ending-layout-defaults, message: "Unknown ending layout option: " + key) }
    ending-layout-defaults + value
  }
  assert(type(definition.name) == str, message: "Ending layout name must be a string.")
  assert(definition.composition in ("centered", "split"), message: "Ending composition must be centered or split.")
  assert(definition.alignment in (left, center, right) and definition.logos-align in (left, center, right),
    message: "Ending and logo alignment must be left, center, or right.")
  assert(definition.logos-placement in ("none", "above", "below", "side"), message: "Ending logos-placement must be none, above, below, or side.")
  assert(definition.logos-placement != "side" or definition.composition == "split", message: "Side logos require the split ending composition.")
  assert(definition.logo-columns == auto or (type(definition.logo-columns) == int and definition.logo-columns > 0),
    message: "Ending logo-columns must be auto or a positive integer.")
  assert(definition.title-shadow == auto or type(definition.title-shadow) == bool, message: "Ending shadow must be auto, true, or false.")
  assert(type(definition.immersive) == bool, message: "Ending immersive must be true or false.")
  for key in ("logo-height", "logo-gap", "title-inset", "title-radius", "title-size", "gap") {
    assert(type(definition.at(key)) == length, message: "Ending " + key + " must be a length.")
  }
  assert(type(definition.side-width) == ratio and 0% < definition.side-width and definition.side-width < 70%,
    message: "Ending side-width must be between 0% and 70%.")
  definition
}

#let ambrosia-ending-layout(base: "centered", name: "custom", ..options) = get-ending-layout(
  get-ending-layout(base) + options.named() + (name: name),
)
#let resolve-ending-layout(self, layout: auto) = get-ending-layout(
  if layout != auto { layout }
  else if self.store.ending-layout != auto { self.store.ending-layout }
  else { self.store.flavor-definition.ending-layout },
)
