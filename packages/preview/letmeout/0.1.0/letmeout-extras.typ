// Optional helpers. Use `letmeout-extras.name` or `#import letmeout-extras: name`.
// Content, show rules, and page settings for one export target.
#import "src/target.typ": by-target, html-only, paged-only, for-target, for-html, for-paged, on-target, show-target
// Dark mode for parts of a document.
#import "src/scheme.typ": by-color-scheme, light-only, dark-only, for-scheme, on-scheme, theme
// Typst functions cannot inherit another function's associated definitions.
// These native element aliases also support set/show rules and .with().
#let grid-cell = std.grid.cell
#let grid-hline = std.grid.hline
#let grid-vline = std.grid.vline
#let grid-header = std.grid.header
#let grid-footer = std.grid.footer
// Typst's `page`, documented with what each setting does in HTML. Use it as
// `letmeout-extras.page`; `#import letmeout-extras: *` would shadow `page` and break `set page`.
#import "src/page-api.typ": page
