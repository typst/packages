#let fa-icon(
  /// The name of the icon.
  ///
  /// This can be used with the ligature feature or the unicode of the glyph.
  name,

  /// Whether the icon is solid or not.
  solid: false,

  ..args
) = {
  text(
    font: (
      "Font Awesome 6 Free" + if solid { " Solid" },
      "Font Awesome 6 Brands",
    ),
    weight: if solid { 900 } else { 400 },
    name,
    ..args
  )
}
