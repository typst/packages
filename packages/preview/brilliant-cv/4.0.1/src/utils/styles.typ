
#let h-bar() = [#h(5pt) | #h(5pt)]

#let _latin-font-list = (
  "Source Sans 3",
  "Linux Libertine",
  "Font Awesome 6 Brands",
  "Font Awesome 6 Free",
)

#let _latin-header-font = "Roboto"

#let _awesome-colors = (
  skyblue: rgb("#0395DE"),
  red: rgb("#DC3522"),
  nephritis: rgb("#27AE60"),
  concrete: rgb("#95A5A6"),
  darknight: rgb("#131A28"),
)

#let _regular-colors = (
  subtlegray: rgb("#ededee"),
  lightgray: rgb("#343a40"),
  darkgray: rgb("#212529"),
)

/// Set the accent color for the document
///
/// - awesome-colors (array): the awesome colors
/// - metadata (array): the metadata object
/// -> color
#let _set-accent-color(awesome-colors, metadata) = {
  let param = metadata.layout.awesome_color
  return if param in awesome-colors {
    awesome-colors.at(param)
  } else {
    rgb(param)
  }
}

/// Resolve the accent color used by a component, honoring an explicit
/// per-call `color:` override before falling back to the metadata-driven
/// default. Used at every cv-* component entry point that accepts a
/// `color: none` parameter.
///
/// - color (color | none): per-call override; takes precedence when non-none.
/// - awesome-colors (dictionary): the package's awesome-colors palette.
/// - metadata (dictionary): the metadata object (read for [layout] awesome_color).
/// -> color
#let _resolve-accent-color(color, awesome-colors, metadata) = {
  if color != none { color } else {
    _set-accent-color(awesome-colors, metadata)
  }
}

/// Overwrite the default fonts when the metadata supplies custom font values.
///
/// Each field in `[layout.fonts]` is independently optional: a profile that
/// only sets `regular_fonts` keeps the default `header_font`, and vice
/// versa. A profile with no `[layout.fonts]` block at all gets pure defaults.
///
/// - metadata (dictionary): the metadata object
/// - latin-fonts (array): the default list of latin fonts
/// - latin-header-font (string): the default header font
/// -> dictionary
#let overwrite-fonts(metadata, latin-fonts, latin-header-font) = {
  let user-defined-fonts = metadata.layout.at("fonts", default: (:))
  let regular-fonts = user-defined-fonts.at(
    "regular_fonts",
    default: latin-fonts,
  )
  let header-font = user-defined-fonts.at(
    "header_font",
    default: latin-header-font,
  )
  return (regular-fonts: regular-fonts, header-font: header-font)
}

