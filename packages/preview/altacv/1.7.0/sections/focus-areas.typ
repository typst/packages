// Prose-style "Areas of Focus" — a top-level array of content items
// rendered as a bulleted list. This is an altacv extension; JSON
// Resume's `interests` carries the `{name, keywords}` shape that the
// `skills` section uses. `prefs` is unused; it's accepted so every
// renderer shares the `(entries, labels, prefs)` dispatch signature.

#let _focus_areas(items, labels, prefs) = if items.len() > 0 [
  == #labels.focusAreas

  #for item in items [- #item]
]
