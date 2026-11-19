#import "../constants.typ" as constants
#import "units.typ" as units


#let base(
  title: none,
  subtitle: none,
  meta-top: none,
  columns: 3,
  body
  ) = {
  meta-top

  heading(level: 1, title)
  if subtitle != none {
    set par(leading: 0.6em)
    text(
      size: units.font.lg,
      fill: constants.palette.grey.medium,
      subtitle
    )
  }
  v(units.space.md)

  grid(
    columns: 100%,
    column-gutter: units.space.base,
    std.columns(columns, gutter: units.space.base, body)
  )
}