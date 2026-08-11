/// Get theme property otherwise fail helpfully
#let theme-prop(
  /// Theme dictionary to get property from
  /// -> dictionary
  theme,

  /// Property name to get
  /// -> string
  prop-name,
) = {
  if prop-name not in theme {
    panic("Theme does not have required property '" + prop-name + "'")
  }

  return theme.at(prop-name)
}

/// Creates a helper to access properties from the theme dictionary.
#let theme-helper(
  /// Theme dictionary to use
  /// -> dictionary
  theme,
) = {
  return (prop) => theme-prop(theme, prop)
}
