// palette: the shared Okabe–Ito colour-blind-safe qualitative palette, lightened
// into highlight backgrounds that keep black text legible. One source of truth
// for field-highlight colour across all three diagrams — reach for a colour by
// name in an explicit `fill:`, e.g. `fill: palette.orange`. Timeline markers fill
// with these and rim them with a darker shade of the same hue (see render). Pure.

#let palette = (
  orange: rgb("#E69F00").lighten(45%),
  sky: rgb("#56B4E9").lighten(45%),
  green: rgb("#009E73").lighten(45%),
  yellow: rgb("#F0E442").lighten(45%),
  blue: rgb("#0072B2").lighten(45%),
  vermillion: rgb("#D55E00").lighten(45%),
  purple: rgb("#CC79A7").lighten(45%),
  grey: rgb("#000000").lighten(80%),
)
