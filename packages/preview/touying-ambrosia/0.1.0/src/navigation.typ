#import "palettes.typ": readable-accent, prefer-light

// Structural navigation owns a region; buttons and progress are independent.
#let navigation-defaults = (
  name: "custom", kind: "none", placement: "none", height: 0em, width: 9em,
  gap: 0.8em, side: "right", depth: 2, renderer: auto,
)
#let navigations = (
  "none": navigation-defaults + (name: "none", kind: "none"),
  tabs: navigation-defaults + (name: "tabs", kind: "tabs", placement: "header", height: 1.8em),
  dots: navigation-defaults + (name: "dots", kind: "dots", placement: "header", height: 1.6em),
  "context": navigation-defaults + (name: "context", kind: "context", placement: "header", height: 0.75em),
  tree: navigation-defaults + (name: "tree", kind: "tree", placement: "header", height: auto),
  panes: navigation-defaults + (name: "panes", kind: "panes", placement: "header", height: 2.7em),
  segments: navigation-defaults + (name: "segments", kind: "segments", placement: "footer", height: 1.35em),
  breadcrumbs: navigation-defaults + (name: "breadcrumbs", kind: "breadcrumbs", placement: "title"),
  sidebar: navigation-defaults + (name: "sidebar", kind: "sidebar", placement: "sidebar"),
)
#let navigation-names = navigations.keys()

#let get-navigation(value) = {
  if value == none { value = "none" }
  let result = if type(value) == str {
    assert(value in navigations, message: "Unknown navigation: " + value + ". Choose: " + navigation-names.join(", ") + ".")
    navigations.at(value)
  } else {
    assert(type(value) == dictionary, message: "Navigation must be a name, none, auto, or an ambrosia-navigation descriptor.")
    for key in value.keys() { assert(key in navigation-defaults, message: "Unknown navigation option: " + key) }
    navigation-defaults + value
  }
  assert(type(result.name) == str, message: "Navigation name must be a string.")
  assert(result.placement in ("none", "header", "title", "sidebar", "footer"), message: "Navigation placement must be none, header, title, sidebar, or footer.")
  assert(result.side in ("left", "right"), message: "Navigation side must be left or right.")
  assert(type(result.depth) == int and result.depth > 0, message: "Navigation depth must be a positive integer.")
  for key in ("width", "height", "gap") {
    assert(type(result.at(key)) == length or (key == "height" and result.kind == "tree" and result.height == auto), message: "Navigation " + key + " must be a length, such as 9em.")
  }
  assert(result.renderer == auto or type(result.renderer) == function,
    message: "Navigation renderer must be auto or a self => content function.")
  if result.renderer == auto {
    assert(result.kind in navigation-names, message: "A custom navigation needs a renderer.")
    assert((result.kind == "segments" and result.placement in ("header", "footer")) or result.placement == navigations.at(result.kind).placement,
      message: "Changing a navigation's placement requires a custom renderer.")
  }
  result
}

/// Extend a navigation preset. A custom renderer receives the resolved self.
#let ambrosia-navigation(base: "sidebar", name: "custom", ..options) = {
  assert(options.pos().len() == 0, message: "Navigation options must be named.")
  let definition = get-navigation(base)
  get-navigation(definition + options.named() + (name: name))
}

// A tree has a talk-title row and one row per enclosing heading level. Keep
// the budget stable across slides even when a branch has no subsection yet.
#let resolve-navigation-height(self, definition) = {
  if definition.kind == "tree" and definition.height == auto {
    definition.height = (1 + calc.min(definition.depth, calc.max(0, self.slide-level - 1))) * 0.75em
  }
  definition
}

#let resolve-navigation(self) = {
  let choice = self.store.navigation
  let definition = get-navigation(if choice == auto { self.store.flavor-definition.navigation } else { choice })
  for key in ("side", "width", "depth") {
    let override = self.store.at("navigation-" + key, default: auto)
    if override != auto { definition.insert(key, override) }
  }
  resolve-navigation-height(self, get-navigation(definition))
}

// Global/per-slide paint overrides keep the flavor's reserved region and padding.
// A transparent panel uses page ink rather than retaining inverse panel colors.
#let resolve-sidebar-style(self) = {
  let flavor = self.store.flavor-definition
  let preset = (flavor.navigation-background)(self)
  let choice = self.store.at("sidebar-background", default: none)
  assert(choice == auto or choice == none or type(choice) == color,
    message: "Sidebar background must be auto, none, or a color.")
  let background = if choice == auto { preset } else { choice }
  let ink = if choice == auto { (flavor.navigation-primary)(self) } else { self.colors.primary }
  let muted = if choice == auto { (flavor.navigation-secondary)(self) } else { self.colors.muted }
  let surface = if background == none { self.page.fill } else { background }
  if type(surface) == color {
    ink = readable-accent(ink, (surface,), dark: prefer-light(surface))
    muted = readable-accent(muted, (surface,), dark: prefer-light(surface))
  }
  (background: background, surface: surface, ink: ink, muted: muted,
    padding: if preset == none and background == none { 0em } else { 0.7em })
}
