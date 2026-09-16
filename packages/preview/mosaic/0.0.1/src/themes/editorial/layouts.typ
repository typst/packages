// Callable Editorial layout namespace: base layouts with Editorial defaults. The
// facade and the definition share these defaults, so an explicit
// `m.layouts.content()` call builds the same slide an automatic heading does.
#import "../../layout/api.typ" as _base
#import "../../author.typ": author

#let content = _base.content.with(variant: "header-body")
#let title = _base.title.with(variant: "kicker")
#let section = _base.section.with(variant: "numeral")
#let image = _base.image
