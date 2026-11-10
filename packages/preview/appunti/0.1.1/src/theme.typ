/// Default color scheme.
#let default-theme = (
  background: white,
  foreground: black,
  link: blue,
  rule: gray,
)

/// Resolve a theme dictionary into a complete color scheme, filling in missing keys with defaults.
///
/// - theme (dictionary): Colors to override. Missing keys keep their default.
/// -> dictionary
#let resolve-theme(theme) = default-theme + theme
