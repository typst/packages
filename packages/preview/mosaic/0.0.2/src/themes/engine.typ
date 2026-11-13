// Private engine that consumes passive theme definitions.
#import "../shared.typ": fail, validate-keys
#import "../settings.typ": resolve-colors
#import "../setup-core.typ": setup-core, default-setup
#import "../layout/config.typ": standard-layouts, validate-layouts

#let identity(body, colors: (:), options: (:)) = body
#let default-definition = (
  name: "Custom",
  colors: none,
  defaults: (:),
  options: (:),
  layouts: standard-layouts,
  apply: identity,
)
// The theme-neutral option names are exactly what themed setup accepts:
// setup-core's own options plus `colors`, which the engine resolves against
// the theme palette before setup-core runs.
#let generic-options = default-setup.keys() + ("colors",)

#let validate-theme(theme) = {
  if type(theme) != dictionary {
    fail("theme must be a dictionary")
  }
  _ = validate-keys(theme, default-definition, "theme")
  let theme = default-definition + theme
  if type(theme.name) != str or theme.name.trim() == "" {
    fail("theme name must be a non-empty string")
  }
  if theme.colors == none {
    fail("theme requires a complete colors dictionary")
  }
  _ = resolve-colors(theme.colors, (:))
  if type(theme.defaults) != dictionary {
    fail("theme defaults must be a dictionary")
  }
  for reserved in ("layouts", "colors") {
    if reserved in theme.defaults {
      fail(
        "theme defaults must configure " + reserved + " through theme "
          + reserved,
      )
    }
  }
  if type(theme.options) != dictionary {
    fail("theme options must be a dictionary")
  }
  for key in theme.options.keys() {
    if type(key) != str or key.trim() == "" {
      fail("theme option names must be non-empty strings")
    }
    if key in generic-options {
      fail("theme option " + repr(key) + " conflicts with setup")
    }
  }
  if type(theme.layouts) not in (dictionary, function) {
    fail("theme layouts must be a dictionary or function")
  }
  if type(theme.apply) != function {
    fail("theme apply must be a function")
  }
  theme
}

#let resolve-theme-layouts(theme, options) = {
  let layouts = if type(theme.layouts) == function {
    (theme.layouts)(options)
  } else {
    theme.layouts
  }
  if type(layouts) != dictionary {
    fail("theme layouts must return a dictionary")
  }
  validate-layouts(layouts, name: "theme layouts")
}

// Receives a definition already normalized by `validate-theme`; the public
// extension validates at bind time so a malformed theme fails where it is
// bound, not where the deck applies it.
#let theme-setup(body, theme: none, ..options) = {
  if options.pos().len() > 0 {
    fail(theme.name + " setup accepts only its document body positionally")
  }
  let named = options.named()
  let theme-options = theme.options
  for key in theme.options.keys() {
    if key in named {
      theme-options.insert(key, named.remove(key))
    }
  }
  let layout-overrides = (:)
  if "layouts" in named {
    layout-overrides = validate-layouts(named.remove("layouts"), partial: true)
  }
  // The theme side is validated complete by `resolve-theme-layouts` and the
  // overrides partially just above, so the merge needs no third pass here;
  // `configure-deck` validates the final dictionary once, where it enters the
  // deck record.
  let layouts = resolve-theme-layouts(theme, theme-options) + layout-overrides
  let color-overrides = (:)
  if "colors" in named {
    color-overrides = named.remove("colors")
  }
  let colors = resolve-colors(theme.colors, color-overrides)
  show: setup-core.with(
    theme.defaults + named + (layouts: layouts),
    colors: colors,
  )
  show: (theme.apply).with(colors: colors, options: theme-options)
  body
}
