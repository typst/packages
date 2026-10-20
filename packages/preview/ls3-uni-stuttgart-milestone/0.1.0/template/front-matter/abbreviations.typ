// Render the grid of abbreviations defined via `abbr.make(...)` in
// main.typ. The chapter heading itself is added by the template's
// abbreviations-section helper.
//
// abbr.list() internally calls `heading(title)`. We scope the call so that
// internal heading is unnumbered, off-outline, and shown as nothing so only
// the grid is visible.
#import "@preview/abbr:0.3.1"

#[
  #set heading(numbering: none, outlined: false)
  #show heading.where(level: 1): none
  #abbr.list(title: none)
]
