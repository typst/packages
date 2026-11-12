// "Areas of Focus", an altacv extension read from
// `custom.altacv.focusAreas` (the `read` hook in
// `data/sections.typ`); JSON Resume's `interests` has the `{name, keywords}`
// shape that `skills` renders.

#import "../internal/components/frame.typ": _section-frame

// One list, not an entry per item, so the bullets keep list spacing.
#let _focus-areas(items, (labels, ..)) = _section-frame(
  labels.focus-areas,
  items,
  list(..items),
)
