// Prose-style "Areas of Focus" — a top-level array of content items
// rendered as a bulleted list. This is an altacv extension; JSON
// Resume's `interests` carries the `{name, keywords}` shape that the
// `skills` section uses.

#let _focus_areas(items, labels) = if items.len() > 0 [
  == #labels.focusAreas

  #for item in items [- #item]
]
