// title.typ - Title rendering primitive

#import "../theme.typ": *

#let draw-title(title, theme, subtitle: none) = {
  if title == none and subtitle == none { return }
  v(2pt)
  if title != none {
    align(center, text(size: theme.title-size, weight: theme.title-weight, fill: theme.text-color)[#title])
  }
  if subtitle != none {
    if title != none { v(1pt) }
    align(center, text(size: theme.at("subtitle-size", default: theme.axis-title-size), fill: theme.text-color-light)[#subtitle])
  }
  v(theme.title-gap)
}
