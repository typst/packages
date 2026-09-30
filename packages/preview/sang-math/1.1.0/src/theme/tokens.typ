// Internal semantic aliases for existing theme values. No palette is redesigned.
#let design-tokens(palette, font-body: "New Computer Modern", font-title: "New Computer Modern") = {
  let primary = palette.at("accent", default: rgb("#0057b8"))
  let secondary = palette.at("accent-2", default: primary)
  let text-color = palette.at("ink", default: black)
  (
    primary: primary,
    secondary: secondary,
    accent: primary,
    text: text-color,
    muted: text-color.lighten(40%),
    border: primary.lighten(55%),
    panel: palette.at("cover", default: white),
    radius-sm: 4pt,
    radius-md: 7pt,
    spacing-xs: 3pt,
    spacing-sm: 6pt,
    spacing-md: 12pt,
    spacing-lg: 20pt,
    font-body: font-body,
    font-title: font-title,
  )
}
