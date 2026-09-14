
/// Validate that a theme dictionary contains only valid fields
///
/// - theme (dictionary): Theme to validate
/// - reference (dictionary): Reference theme with all valid fields
/// - field-type (str): Type of fields being validated (e.g., "theme", "layout")
#let validate-theme(theme, reference, field-type: "theme") = {
  for field in theme.keys() {
    if field not in reference {
      panic(
        "Invalid "
          + field-type
          + " field: '"
          + field
          + "'. Valid fields are: "
          + reference.keys().join(", "),
      )
    }
  }
}

/// Validate layout dictionary contains only valid fields
///
/// - layout (dictionary): Layout to validate
/// - reference (dictionary): Reference layout with all valid fields
#let validate-layout(layout, reference) = {
  validate-theme(layout, reference, field-type: "layout")
}

/// Resolve a theme from a theme collection
///
/// This function takes a theme collection (dictionary of named themes) and a theme specifier,
/// and returns the resolved theme dictionary with fallback support.
///
/// - themes (dictionary): Collection of named themes
/// - theme (str, dictionary): Theme name or custom theme dictionary
/// - default (str): Default theme key to use as fallback if theme is invalid
/// - validate (bool): Whether to validate theme fields against the default theme
/// -> dictionary: The resolved theme
#let resolve-theme(themes, theme, default: none, validate: true) = {
  assert(default != none, message: "The default theme is required")
  let default-theme = themes.at(default)
  if theme == auto {
    theme = default
  }

  let resolved-theme = if type(theme) == str {
    // theme is a string - pick it from themes collection
    if theme in themes {
      themes.at(theme)
    } else if default != none and default in themes {
      default-theme
    } else {
      panic(
        "Theme '"
          + theme
          + "' not found in theme collection. Available themes: "
          + repr(themes.keys()),
      )
    }
  } else if type(theme) == dictionary {
    // theme is a dictionary - handle inheritance
    if "inherit" in theme {
      // Handle inheritance
      let inherit-from = theme.inherit
      let base-theme = if type(inherit-from) == str and inherit-from in themes {
        themes.at(inherit-from)
      } else {
        panic("Invalid inherit value '" + repr(inherit-from) + "' and no valid default provided")
      }
      let _ = theme.remove("inherit")
      base-theme + theme
    } else {
      // No inherit field. Inherit default theme.
      default-theme + theme
    }
  } else {
    panic(
      "Theme must be either a string (theme name) or dictionary (custom theme). Got: "
        + str(type(theme)),
    )
  }

  // Validate the resolved theme if requested
  if validate {
    validate-theme(resolved-theme, default-theme)
  }

  resolved-theme
}

/// Resolve and validate a layout dictionary
///
/// - layout (dictionary): Layout overrides to apply
/// - default-layout (dictionary): Default layout with all valid fields
/// - validate (bool): Whether to validate layout fields
/// -> dictionary: The resolved layout
#let resolve-layout(layout, default-layout, validate: true) = {
  let resolved-layout = default-layout + layout

  // Validate the layout if requested
  if validate {
    validate-layout(layout, default-layout)
  }

  resolved-layout
}

/// Stretch the item to cover its container.
///
/// - item (content):
/// -> content
#let stretch-cover(item) = {
  layout(size => {
    let item-size = measure(item)
    let s = if item-size.width == 0pt or item-size.height == 0pt {
      1
    } else {
      calc.max(size.width / item-size.width, size.height / item-size.height)
    }
    align(horizon + center, scale(s * 100%, item, reflow: true))
  })
}

/// Create a show rule for automatic mention styling.
///
/// This function creates a show rule that automatically styles `@username` mentions
/// using Typst's ref syntax. When enabled, references that don't resolve to actual
/// elements are treated as mentions and styled using the provided styler function.
///
/// - auto-mention (bool): Whether to enable automatic mention styling.
/// - styler (function): Function that takes a username string and returns styled content.
/// -> function: Show rule function to apply to content
#let auto-mention-rule(auto-mention, styler) = {
  if auto-mention {
    it => {
      show ref: it => if it.element != none {
        it
      } else {
        styler(repr(it.target).slice(1, -1))
      }
      it
    }
  } else {
    it => it
  }
}
