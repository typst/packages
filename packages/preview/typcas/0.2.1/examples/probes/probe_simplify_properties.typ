#import "../../lib.typ": *

#let assert(ok, msg) = {
  if not ok { panic("probe failed: " + msg) }
}

#let e = cas.parse("(sin(x)^2 + cos(x)^2 + (x^2-1)/(x-1))")
#let s1 = cas.simplify(e, strict: false)
#let s2 = cas.simplify(s1.expr, strict: false)
#assert(cas.ok(s1) and cas.ok(s2), "simplify results ok")
#assert(repr(s1.expr) == repr(s2.expr), "simplify idempotence")

#let ind = cas.simplify("0/0", strict: false)
#assert(cas.ok(ind), "indeterminate simplify ok")
#assert(ind.expr.type == "div", "0/0 preserved as division")

#let stress = cas.simplify("(sin(x)^2 + cos(x)^2) + (sin(x)^2 + cos(x)^2) + (sin(x)^2 + cos(x)^2)", strict: false)
#assert(cas.ok(stress), "stress simplify ok")
#assert(stress.diagnostics.at("identity-count", default: 0) >= 3, "identity telemetry present")

Probe simplify properties passed.
