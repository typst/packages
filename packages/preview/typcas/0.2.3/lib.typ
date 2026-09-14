// =========================================================================
// typcas v2 — Task-Centric CAS for Typst
// =========================================================================
// Public surface:
//   #import "@preview/typcas:0.2.1": *
//   #let q = cas.expr("sin(x)^2 + cos(x)^2")
//   #let r = q.simplify()
//   $ #cas.display(r.expr) $
// =========================================================================

#import "src/api/cas.typ" as cas

// Optional math operators for content parsing ergonomics.
#let arccsc = math.op("arccsc")
#let arcsec = math.op("arcsec")
#let arccot = math.op("arccot")
#let csch = math.op("csch")
#let sech = math.op("sech")
#let coth = math.op("coth")
#let arcsinh = math.op("arcsinh")
#let arccosh = math.op("arccosh")
#let arctanh = math.op("arctanh")
#let arccsch = math.op("arccsch")
#let arcsech = math.op("arcsech")
#let arccoth = math.op("arccoth")
