#import "../../lib.typ": *

#let assert(ok, msg) = {
  if not ok { panic("probe failed: " + msg) }
}

#let dabs = cas.diff("abs(x)", "x", strict: false)
#assert(cas.ok(dabs), "diff abs ok")
#assert(dabs.expr.type == "piecewise", "diff abs returns piecewise")
#assert(dabs.warnings.len() > 0, "diff abs boundary warning")

#let dsign = cas.diff("sign(x)", "x", strict: false)
#assert(cas.ok(dsign), "diff sign ok")
#assert(dsign.expr.type == "piecewise", "diff sign returns piecewise")

#let dmin = cas.diff("min(x, x^2)", "x", strict: false)
#assert(cas.ok(dmin), "diff min ok")
#assert(dmin.expr.type == "piecewise", "diff min returns piecewise")

#let dclamp = cas.diff("clamp(x, 0, 1)", "x", strict: false)
#assert(cas.ok(dclamp), "diff clamp ok")
#assert(dclamp.expr.type == "piecewise", "diff clamp returns piecewise")

#let pos = cas.eval(dabs.expr, bindings: (x: 2))
#let neg = cas.eval(dabs.expr, bindings: (x: -2))
#assert(cas.ok(pos) and cas.ok(neg), "piecewise abs eval ok")
#assert(pos.value == 1, "abs' for x>0")
#assert(neg.value == -1, "abs' for x<0")

Probe nonsmooth diff passed.
