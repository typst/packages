// Thin wrappers around elembic to enable deprecation warnings once native custom types land
#import "@preview/elembic:1.1.1" as e

#let set_(elem, ..fields) = {
	e.set_(elem, ..fields)
}

#let show_(filter, replacement, mode: auto) = {
	e.show_(filter, replacement, mode: mode)
}

#let cond-set(filter, ..fields) = {
	e.cond-set(filter, ..fields)
}

#let selector(elem, outline: false, outer: false, meta: false) = {
	e.selector(elem, outline: outline, outer: outer, meta: meta)
}

#let prepare(..args) = {
	e.prepare(..args)
}