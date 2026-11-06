// "Areas of Focus", an altacv extension read from
// `custom.altacv.focusAreas` (the `read` hook in `layout.typ`'s
// `_sections`); JSON Resume's `interests` has the `{name, keywords}`
// shape that `skills` renders.

#import "../internal/primitives.typ": _section_frame

// One list, not an entry per item, so the bullets keep list spacing.
#let _focus_areas(items, (labels, ..)) = _section_frame(
  labels.focusAreas,
  items,
  list(..items),
)
