// Native functions and types for code that shadows their names.
//
// A closure captures every name it references. Referencing `std.*` captures the
// whole standard-library module, and Typst hashes that capture (including the
// `sym` and `emoji` modules) whenever a newly created closure or context block
// is called or located. Runtime code therefore uses these plain bindings.
#let _std-alignment = std.alignment
#let _std-counter = std.counter
#let _std-footnote = std.footnote
#let _std-label = std.label
#let _std-link = std.link
#let _std-numbering = std.numbering
#let _std-stroke = std.stroke
#let _std-target = std.target
#let _std-underline = std.underline
