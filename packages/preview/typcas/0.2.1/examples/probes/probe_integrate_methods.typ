#import "../../lib.typ": *

#let assert(ok, msg) = {
  if not ok { panic("probe failed: " + msg) }
}

#let byparts = cas.integrate("x*exp(x)", "x")
#assert(cas.ok(byparts), "by-parts integrate ok")
#let d1 = cas.diff(byparts.expr, "x")
#let d1v = cas.eval(d1.expr, bindings: (x: 2))
#let src1v = cas.eval("x*exp(x)", bindings: (x: 2))
#assert(cas.ok(d1) and cas.ok(d1v) and cas.ok(src1v), "by-parts derivative check eval ok")
#assert(calc.abs(d1v.value - src1v.value) < 1e-6, "by-parts antiderivative derivative matches")

#let usub = cas.trace-integrate("2x*cos(x^2)", var: "x", detail: 3)
#assert(cas.ok(usub), "u-sub trace ok")
#let rendered = cas.render-steps(cas.parse("2x*cos(x^2)"), usub, operation: "integrate", var: "x")
#assert(rendered != none, "u-sub rendered")

#let pf = cas.integrate("1/(x^2-1)", "x")
#assert(cas.ok(pf), "partial-fraction integrate ok")

Probe integrate methods passed.
