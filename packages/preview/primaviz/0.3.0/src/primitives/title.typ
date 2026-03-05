// title.typ - Title rendering primitive

#import "../theme.typ": *

#let draw-title(title, theme) = {
  if title == none { return }
  v(2pt)
  align(center, text(size: theme.title-size, weight: theme.title-weight, fill: theme.text-color)[#title])
  v(theme.title-gap)
}
