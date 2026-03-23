#import "../../lib.typ": *

#let assert(ok, msg) = {
  if not ok { panic("probe failed: " + msg) }
}

#let q = cas.expr("x + x + 1")

#let qp = cas.parsed(q)
#let qs = cas.simplify(q)
#let qd = cas.diff(q, "x")
#let qi = cas.integrate(q, "x")

#assert(cas.ok(qp), "query parsed ok")
#assert(cas.ok(qs), "query simplify ok")
#assert(cas.ok(qd), "query diff ok")
#assert(cas.ok(qi), "query integrate ok")

#assert(qi.expr.type != "integral", "query integrate should produce antiderivative, not unresolved integral node")

#let sv = cas.eval(qs.expr, bindings: (x: 3))
#let dv = cas.eval(qd.expr, bindings: (x: 3))
#let back = cas.diff(qi.expr, "x")
#let bv = cas.eval(back.expr, bindings: (x: 3))

#assert(cas.ok(sv), "simplify eval ok")
#assert(cas.ok(dv), "diff eval ok")
#assert(cas.ok(back), "diff(integral) ok")
#assert(cas.ok(bv), "diff(integral) eval ok")

#assert(calc.abs(sv.value - 7) < 1e-9, "simplify numeric value")
#assert(calc.abs(dv.value - 2) < 1e-9, "diff numeric value")
#assert(calc.abs(bv.value - 7) < 1e-9, "diff(integral) numeric value")

// Limit sanity check for the earlier bug
#let lim = cas.limit("sin(x)/x", "x", 0)
#let limv = cas.eval(lim.expr)
#assert(cas.ok(lim), "limit sin(x)/x ok")
#assert(cas.ok(limv), "limit result eval ok")
#assert(calc.abs(limv.value - 1) < 1e-9, "limit sin(x)/x == 1")

Probe 2 passed.
