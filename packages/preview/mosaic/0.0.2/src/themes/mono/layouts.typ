// Callable Mono layout namespace: base layouts with Mono defaults. The
// facade and the definition share these defaults, so an explicit
// `m.layouts.content()` call builds the same slide an automatic heading does.
//
// The section default is the toc variant: every section in the deck listed,
// the current one alive with its number, the others ghosted. On a terminal
// theme the divider doubles as the deck's process list.
#import "../../layout/api.typ" as _base
#import "../../author.typ": author

#let content = _base.content.with(variant: "header-body")
#let title = _base.title
#let section = _base.section.with(variant: "toc")
#let image = _base.image
