// Render the grid of abbreviations defined via `abbr.make(...)` in
// main.typ. The chapter heading itself is added by the dissertation
// template's abbreviations-section helper.
//
// abbr.list() internally calls `heading(title)`, which inherits the global
// `set heading(numbering: "1.")` and would otherwise render as a numbered
// chapter ("Chapter 1") with the grid attached. We work around this by
// scoping the call so the heading is unnumbered, off-outline, and shown as
// nothing — leaving only the grid visible.
#import "@preview/abbr:0.3.1"

#[
  #set heading(numbering: none, outlined: false)
  #show heading.where(level: 1): none
  #abbr.list(title: none)
]
