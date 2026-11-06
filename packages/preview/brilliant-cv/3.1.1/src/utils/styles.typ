
#let h-bar() = [#h(5pt) | #h(5pt)]

#let _latin-font-list = (
  "Source Sans 3",
  "Linux Libertine",
  "Font Awesome 6 Brands",
  "Font Awesome 6 Free",
)

#let _latin-header-font = ("Roboto")

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

/// Overwrite the default fonts if the metadata has custom font values
/// 
/// - metadata (array): the metadata object
/// - latin-fonts (array): the default list of latin fonts
/// - latin-header-font (string): the default header font
/// -> array
#let overwrite-fonts(metadata, latin-fonts, latin-header-font) = {
  let user-defined-fonts = metadata.layout.at("fonts", default: [])
  let regular-fonts = latin-fonts
  let header-font = latin-header-font
  if user-defined-fonts.len() > 0 {
    regular-fonts = user-defined-fonts.at("regular_fonts")
    header-font = user-defined-fonts.at("header_font")
  }
  return (regular-fonts: regular-fonts, header-font: header-font)
}

// Backward compatibility aliases
#let hBar = h-bar
