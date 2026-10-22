#import "../navigation.typ": get-navigation
#import "../title-layouts.typ": get-title-layout
#import "../ending-layouts.typ": get-ending-layout

// Coordinated composition and treatment defaults (docs/flavors.md). Navigation
// is a suggestion: an explicit choice owns and reserves its header/sidebar/footer region.
// All literal color values come from palettes.
#let flavor-defaults = (
  name: "custom",
  slide-level: 2,
  top-margin: 4.2em,
  title-renderer: auto,
  title-layout: "stacked",
  header-renderer: auto,
  footer-renderer: auto,
  ending-renderer: auto,
  ending-layout: "centered",
  title-width: 100%,
  title-background: self => self.colors.surface,
  title-text: self => self.colors.primary,
  title-shadow: true,
  block-shadow: true,
  block-style: "plain",
  watermark-slides: (),
  navigation: "none",
  navigation-primary: self => self.colors.primary,
  navigation-secondary: self => self.colors.muted,
  navigation-background: self => none,
  header-background: self => none,
  header-title: self => self.colors.primary,
  header-subtitle: self => self.colors.primary,
  header-title-inset-left: 1.5em,
  header-title-inset-right: 1.5em,
  header-banner: false,
  header-logo: false,
  header-logo-placement: "title",
  header-logo-fade: 0em,
  header-logo-style: "light",
  footer-logo: false,
  footer-style: "bar",
  ending-empty-header: false,
  ending-width: auto,
  ending-background: self => self.colors.primary-light,
  ending-text: self => self.colors.foreground,
  ending-shadow: false,
)

#let flavors = (
  simple: flavor-defaults + (
    watermark-slides: ("title", "outline", "section"),
    top-margin: 2.4em,
    title-background: self => none,
    title-shadow: false,
    header-logo: true,
    ending-background: self => none,
    ending-text: self => self.colors.primary,
  ),
  cambridge: flavor-defaults + (
    slide-level: 3,
    top-margin: 3.1em,
    navigation: "context",
    header-background: self => self.colors.surface-alt,
    footer-logo: true,
    ending-width: 100%,
    ending-background: self => self.colors.surface,
    ending-text: self => self.colors.primary,
    ending-shadow: true,
  ),
  darmstadt: flavor-defaults + (
    title-background: self => self.colors.accent-strong,
    title-text: self => self.colors.on-accent-strong,
    navigation: "dots",
    navigation-primary: self => self.colors.on-chrome,
    navigation-secondary: self => self.colors.chrome-muted,
    navigation-background: self => self.colors.chrome,
    header-background: self => gradient.linear(
      self.colors.chrome,
      self.colors.accent-strong.darken(25%),
      ..((self.colors.accent-strong,) * 5),
      angle: 90deg,
    ),
    header-title: self => self.colors.on-chrome,
    header-subtitle: self => self.colors.chrome-muted,
    header-logo-style: "original",
    footer-logo: true,
    ending-width: 100%,
    ending-background: self => self.colors.accent-strong,
    ending-text: self => self.colors.on-accent-strong,
    ending-shadow: true,
  ),
  dewdrop: flavor-defaults + (
    watermark-slides: ("title", "outline", "section"),
    navigation: "dots",
  ),
  stargazer: flavor-defaults + (
    title-width: auto,
    title-background: self => self.colors.accent-strong,
    title-text: self => self.colors.on-accent-strong,
    title-shadow: false,
    navigation: "tabs",
    navigation-primary: self => self.colors.on-chrome,
    navigation-secondary: self => self.colors.chrome-muted,
    navigation-background: self => self.colors.chrome,
    header-background: self => gradient.linear(
      self.colors.accent-strong,
      self.colors.accent-strong.darken(25%),
      self.colors.accent-strong.darken(50%),
      self.colors.chrome,
      angle: -45deg,
    ),
    header-title: self => self.colors.on-chrome,
    header-subtitle: self => self.colors.chrome-muted,
  ),
  portico: flavor-defaults + (
    top-margin: 3.5em,
    navigation: "sidebar",
    navigation-background: self => self.colors.chrome,
    navigation-primary: self => self.colors.on-chrome,
    navigation-secondary: self => self.colors.chrome-muted,
    header-banner: true,
    header-title-inset-left: 2.5em,
    title-shadow: false,
    block-shadow: false,
    footer-style: "minimal",
    header-subtitle: self => self.colors.muted,
    ending-background: self => self.colors.surface,
    ending-text: self => self.colors.primary,
  ),
  minimal: flavor-defaults + (
    watermark-slides: ("title", "outline", "section"),
    top-margin: 2.8em,
    title-background: self => self.colors.surface,
    title-text: self => self.colors.primary,
    title-shadow: false,
    block-shadow: false,
    footer-style: "minimal",
    header-logo: true,
    header-background: self => self.colors.surface,
    header-title: self => self.colors.primary,
    header-subtitle: self => self.colors.muted,
    ending-background: self => self.colors.surface,
    ending-text: self => self.colors.primary,
  ),
)

#let flavor-names = flavors.keys()

#let get-flavor(value) = {
  let definition = if type(value) == str {
    assert(value in flavors, message: "Flavor '" + value + "' is not supported. Choose: " + flavor-names.join(", ") + ".")
    flavors.at(value) + (name: value)
  } else {
    assert(type(value) == dictionary, message: "Flavor must be a built-in name or an ambrosia-flavor descriptor.")
    for key in value.keys() {
      assert(key in flavor-defaults, message: "Unknown flavor option: " + key)
    }
    flavor-defaults + value
  }
  assert(type(definition.name) == str, message: "Flavor name must be a string.")
  let _ = get-navigation(definition.navigation)
  let _ = get-title-layout(definition.title-layout)
  let _ = get-ending-layout(definition.ending-layout)
  assert(type(definition.header-logo-fade) == length, message: "Header logo fade must be a length, such as 1.5em.")
  assert(definition.header-logo-placement in ("title", "corner", "edge"), message: "Header logo placement must be title, corner, or edge.")
  assert(definition.footer-style in ("bar", "minimal"), message: "Unknown flavor footer style.")
  assert(type(definition.slide-level) == int and definition.slide-level > 0, message: "Flavor slide-level must be positive.")
  for key in ("title-renderer", "header-renderer", "footer-renderer", "ending-renderer") {
    assert(definition.at(key) == auto or definition.at(key) == none or type(definition.at(key)) == function,
      message: key + " must be auto, none, or a function.")
  }
  definition
}

/// Extend a built-in flavor or another descriptor without modifying a registry.
#let ambrosia-flavor(base: "minimal", name: "custom", ..options) = get-flavor(
  get-flavor(base) + options.named() + (name: name),
)

/// Renderers use the definition normalized once during theme setup.
#let current-flavor(self) = self.store.flavor-definition
