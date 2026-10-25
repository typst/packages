/// Theme object.
/// -> theme
#let theme(
  inset: 9pt,
  body-fill: rgb("#F5F3EE"),
  header-text-fill: rgb("#F5F3EE"),
  radius: 0pt,
  stroke: rgb("#1B1B1B"),
  header-fill: rgb("#1B1B1B"),
  line-color: rgb("#1B1B1B"),
  visibility-fill: rgb("#1B1B1B"),
  line-thickness: 0.6pt,
  mark-size: 0.8pt,
  body-text-fill: rgb("#1B1B1B"),
  line: "line",
) = {
  return (
    inset: inset,
    radius: radius,
    stroke: stroke,
    header-fill: header-fill,
    header-text-fill: header-text-fill,
    body-fill: body-fill,
    body-text-fill: body-text-fill,
    visibility-fill: visibility-fill,
    line-color: line-color,
    line-thickness: line-thickness,
    mark-size: mark-size,
    line: line,
  )
}

/// Create a theme
/// -> theme
#let _theme-builder(
  inset: 6pt,
  radius: 4pt,
  thickness: 1pt,
  mark-size: 1pt,
  primary-color: white,
  secondary-color: black,
  tertiary-color: gray,
) = {
  return theme(
    inset: inset,
    radius: radius,
    stroke: tertiary-color + thickness,
    line-color: tertiary-color,
    line-thickness: thickness,
    mark-size: mark-size,
    body-fill: primary-color,
    body-text-fill: secondary-color,
    header-fill: secondary-color,
    header-text-fill: primary-color,
    visibility-fill: tertiary-color,
  )
}

#let themes = (
  terminal: theme(
    inset: 7pt,
    body-fill: rgb("#101810"),
    radius: 8pt,
    stroke: rgb("#55FF77"),
    header-fill: rgb("#17351D"),
    header-text-fill: rgb("#7CFF91"),
    line-color: rgb("#55FF77"),
    line-thickness: 0.7pt,
    mark-size: 1pt,
    body-text-fill: rgb("#7CFF91"),
  ),

  bauhaus: _theme-builder(
    inset: 7pt,
    radius: 1pt,
    thickness: 1.5pt,
    mark-size: 1.2pt,
    primary-color: rgb("#FFEF3F"),
    secondary-color: rgb("#E21919"),
    tertiary-color: rgb("#111111"),
  ),

  blueprint: _theme-builder(
    inset: 7pt,
    radius: 1pt,
    thickness: 0.8pt,
    mark-size: 1.2pt,
    primary-color: rgb("#174A7E"),
    secondary-color: rgb("#D9EEFF"),
    tertiary-color: rgb("#A9D6F5"),
  ),

  desert: theme(
    inset: 8pt,
    body-fill: rgb("#E8C9A0"),
    radius: 7pt,
    stroke: rgb("#8A4B32"),
    header-fill: rgb("#B85C3D"),
    header-text-fill: rgb("#E8C9A0"),
    visibility-fill: rgb("#8A4B32"),
    line-color: rgb("#8A4B32"),
    line-thickness: 1.2pt,
    mark-size: 1.3pt,
    body-text-fill: rgb("#37251C"),
  ),

  arctic: theme(
    inset: 7pt,
    body-fill: rgb("#E8F5F8"),
    radius: 5pt,
    stroke: rgb("#75AAB8"),
    header-fill: rgb("#B9E4EA"),
    header-text-fill: rgb("#75AAB8"),
    line-color: rgb("#75AAB8"),
    visibility-fill: rgb("#75AAB8").saturate(30%),
    line-thickness: 0.8pt,
    mark-size: 1pt,
    body-text-fill: rgb("#183A44"),
  ),

  vaporwave: theme(
    inset: 8pt,
    body-fill: rgb("#4B0082"),
    body-text-fill: rgb("#F5F5F5"),
    header-fill: rgb("#4B0082"),
    header-text-fill: rgb("#FF77FF"),
    visibility-fill: rgb("#FFB200"),
    radius: 8pt,
    stroke: rgb("#FFB200"),
    line-color: rgb("#FFB200"),
    line-thickness: 1.5pt,
    mark-size: 1pt,
  ),

  botanical: theme(
    inset: 8pt,
    body-fill: rgb("#DCE5D2"),
    header-text-fill: rgb("#DCE5D2"),
    radius: 9pt,
    stroke: rgb("#4D6545"),
    visibility-fill: rgb("#4D6545"),
    header-fill: rgb("#708B61"),
    line-color: rgb("#71816A"),
    line-thickness: 1pt,
    mark-size: 1.2pt,
    body-text-fill: rgb("#263226"),
  ),

  editorial: theme(
    inset: 9pt,
    body-fill: rgb("#F5F3EE"),
    header-text-fill: rgb("#F5F3EE"),
    radius: 0pt,
    stroke: rgb("#1B1B1B"),
    header-fill: rgb("#1B1B1B"),
    line-color: rgb("#1B1B1B"),
    visibility-fill: rgb("#1B1B1B"),
    line-thickness: 0.6pt,
    mark-size: 0.8pt,
    body-text-fill: rgb("#1B1B1B"),
  ),

  deep-ocean: theme(
    inset: 8pt,
    body-fill: rgb("#082F3D"),
    header-text-fill: rgb("#E8FAF8").darken(20%),
    radius: 6pt,
    stroke: rgb("#23C7B8"),
    header-fill: rgb("#0D6E75"),
    visibility-fill: white,
    line-color: rgb("#42B7B0"),
    line-thickness: 1pt,
    mark-size: 1.3pt,
    body-text-fill: rgb("#E8FAF8"),
  ),

  // Dark
  pixies: theme(
    inset: 6pt,
    body-fill: gray.darken(40%),
    radius: 0pt,
    stroke: 3pt,
    header-fill: gray.darken(70%),
    header-text-fill: gray,
    visibility-fill: black,
    line-color: black,
    line-thickness: 1pt,
    body-text-fill: white.darken(10%),
  ),

  // Material Design 3 - Clean, modern, elevation-based
  material-design: theme(
    inset: 12pt,
    body-fill: rgb("#e8def8"),
    // header-text-fill: rgb("#e8def8").lighten(30%),
    header-text-fill: white,
    body-text-fill: rgb("#d0bcff").darken(40%),
    visibility-fill: rgb("#d0bcff").darken(40%),
    radius: 8pt,
    stroke: 0pt,
    header-fill: rgb("#d0bcff"),
    line-color: rgb("#d0bcff"),
    line-thickness: 2pt,
  ),

  // Modern/Clean - Minimal borders, generous spacing
  modern: theme(
    inset: 8pt,
    body-fill: rgb("#f5f5f5"),
    radius: 8pt,
    stroke: 0pt,
    header-fill: rgb("#e8e8e8"),
    header-text-fill: rgb("#e8e8e8").darken(50%),
    body-text-fill: rgb("#e8e8e8").darken(50%),
    visibility-fill: rgb("#e8e8e8").darken(50%),
  ),
)
