#import "../../lib.typ": *
#import "../../translators/translation.typ": simplify as v1-simplify, implicit-diff as v1-implicit-diff

#let assert(ok, msg) = {
  if not ok { panic("probe failed: " + msg) }
}

#let same-expr(a, b) = repr(cas.parse(a)) == repr(cas.parse(b))

// Identity expansion sample from examples/test.typ
#let id = cas.simplify("abs(x)/x + x/abs(x) + min(x,x)", allow-domain-sensitive: true, strict: false)
#assert(cas.ok(id), "identity sample simplify ok")
#assert(repr(id.expr) == repr(cas.parse("x + 2*sign(x)")), "identity sample expression")
#assert(id.restrictions.len() > 0, "identity sample has unresolved restrictions")

// Translation aliases
#let t1 = v1-simplify("sin(x)^2 + cos(x)^2")
#assert(repr(t1) == repr(cas.parse("1")), "v1 simplify alias result")

#let t2 = v1-implicit-diff("x*y - 3", "x", "y")
#let t2v = cas.eval(t2, bindings: (x: 2, y: 3))
#assert(cas.ok(t2v), "v1 implicit diff alias eval ok")
#assert(calc.abs(t2v.value + 1.5) < 1e-9, "v1 implicit diff alias numeric value")

// Guarded domain-sensitive identity should not apply without explicit opt-in
#let gated = cas.simplify("abs(x)/x")
#assert(cas.ok(gated), "gated simplify ok")
#assert(repr(gated.expr) != repr(cas.parse("sign(x)")), "gated identity blocked by default")

Probe 1 passed.
