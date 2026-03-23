#import "../../lib.typ": *

#let assert(ok, msg) = {
  if not ok { panic("probe failed: " + msg) }
}

#let l0 = cas.limit("sin(x)/x", "x", 0)
#let l0v = cas.eval(l0.expr)
#assert(cas.ok(l0), "two-sided sin(x)/x ok")
#assert(cas.ok(l0v), "two-sided sin(x)/x eval ok")
#assert(calc.abs(l0v.value - 1) < 1e-9, "two-sided sin(x)/x == 1")

#let lleft = cas.limit("sin(x)/x", "x", "0-")
#let lright = cas.limit("sin(x)/x", "x", "0+")
#let lleftv = cas.eval(lleft.expr)
#let lrightv = cas.eval(lright.expr)
#assert(cas.ok(lleft) and cas.ok(lright), "one-sided limits ok")
#assert(cas.ok(lleftv) and cas.ok(lrightv), "one-sided limits eval ok")
#assert(calc.abs(lleftv.value - 1) < 1e-9 and calc.abs(lrightv.value - 1) < 1e-9, "one-sided sin(x)/x == 1")

#let lstd = cas.limit("(1-cos(x))/x^2", "x", 0)
#let lstdv = cas.eval(lstd.expr)
#assert(cas.ok(lstd) and cas.ok(lstdv), "standard trig form ok")
#assert(calc.abs(lstdv.value - 0.5) < 1e-9, "(1-cos x)/x^2 == 1/2")

#let linf = cas.limit("(3x^2+1)/(2x^2-5)", "x", "inf")
#let linfv = cas.eval(linf.expr)
#assert(cas.ok(linf) and cas.ok(linfv), "infinity rational degree rule ok")
#assert(calc.abs(linfv.value - 1.5) < 1e-9, "leading coefficient ratio")

Probe limits passed.
