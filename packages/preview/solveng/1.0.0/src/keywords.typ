// The type any, and what modifiers are made of: labelled metadata the worksheet reads, invisible elsewhere.

#let _key(name, ..args) = [#metadata((key: name, args: args.pos()))<solveng-key>]
/// The type of a parameter that takes every unit: `$f(x: any) := 2 x$`.
#let any = _key("any")
