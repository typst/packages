#import "../lib.typ": *

#set page(margin: 1.35cm)
#set text(font: "New Computer Modern", size: 10.5pt)

= typcas v2 Unified Surface Test

#cas.set-step-style((
  palette: (
    transform: rgb("#0A9AA4"),
    warn: rgb("#C27B00"),
    error: rgb("#B4372F"),
    meta: rgb("#2E6E77"),
  ),
  arrow: (main: "⇒", sub: "↦", meta: "⟹"),
  indent-size: 1.2em,
  branch: (
    mode: "inline",
    marker: "↳",
  ),
))

#let a-base = cas.assume("x", real: true)
#let a-pos = cas.assume-string("x", "(0")
#let a-guard = cas.assume-domain("x", "(-inf,1) ∪ (1,inf)")
#let a-xy = cas.merge-assumptions(
  cas.assume("x", real: true, nonzero: true),
  cas.assume("y", real: true, nonzero: true),
)

#let assert-ok(res, label) = {
  if not res.ok {
    let msg = if res.errors != none and res.errors.len() > 0 { res.errors.at(0).message } else { "unknown" }
    panic("regression failed (" + label + "): " + msg)
  }
}

#let assert-true(ok, label) = {
  if not ok { panic("regression failed: " + label) }
}

#let assert-expr-eq(lhs, rhs, label) = {
  let l = repr(cas.parse(lhs))
  let r = repr(cas.parse(rhs))
  if l != r {
    panic("regression failed (" + label + "): " + l + " != " + r)
  }
}

== 1. Strict Regression Gates
#let rg1 = cas.simplify("sin(x)^2 + cos(x)^2", assumptions: a-base)
#assert-ok(rg1, "simplify-identity")
#assert-expr-eq(rg1.expr, "1", "pythagorean")

#let rg2 = cas.simplify("(x^2-1)/(x-1)", assumptions: a-guard)
#assert-ok(rg2, "guarded-cancel")
#assert-expr-eq(rg2.expr, "x+1", "guarded-cancel-result")

#let rg3 = cas.diff("ln(x)", "x", assumptions: a-pos)
#assert-ok(rg3, "diff-smoke")

#let rg4 = cas.integrate("sec(x)^2 + csc(x)^2", "x", assumptions: a-base)
#assert-ok(rg4, "integrate-primitives")

#let rg5 = cas.solve("x^2 + 1", rhs: 0)
#assert-ok(rg5, "solve-complex")
#assert-true(rg5.roots != none and rg5.roots.len() == 2, "solve-complex-roots")

#let rg6 = cas.trace("(x^2+1)^3", "diff", var: "x", depth: 1, assumptions: a-base)
#assert-ok(rg6, "trace-smoke")
#let _render-smoke = cas.render-steps("(x^2+1)^3", rg6, operation: "diff", var: "x")

#let rg7 = cas.simplify("x^2 + 1", detail: 1, assumptions: a-base)
#assert-ok(rg7, "core-detail-steps")
#assert-true(rg7.steps != none and rg7.steps.len() > 0, "core-detail-produces-steps")

#let rg8 = cas.trace("x^2 + 1", "simplify", detail: 0, assumptions: a-base)
#assert-ok(rg8, "trace-detail-zero")
#assert-true(rg8.steps != none and rg8.steps.len() == 0, "trace-detail-zero-empty")

#let rg9 = cas.implicit-diff("x^2 + y^2 - 1", "x", "y", assumptions: a-xy)
#assert-ok(rg9, "implicit-diff-canonical")
#let rg9e1 = cas.eval(rg9.expr, bindings: (x: 2, y: 3))
#let rg9e2 = cas.eval("-x/y", bindings: (x: 2, y: 3))
#assert-ok(rg9e1, "implicit-diff-eval-left")
#assert-ok(rg9e2, "implicit-diff-eval-right")
#assert-true(calc.abs(rg9e1.value - rg9e2.value) < 1e-9, "implicit-diff-value")

#let rg10 = cas.diff("abs(x)", "x", strict: false)
#assert-ok(rg10, "nonsmooth-abs")
#assert-true(rg10.expr.type == "piecewise", "nonsmooth-abs-piecewise")
#assert-true(rg10.warnings.len() > 0, "nonsmooth-abs-warning")

#let rg11 = cas.diff("min(x, x^2)", "x", strict: false)
#assert-ok(rg11, "nonsmooth-min")
#assert-true(rg11.expr.type == "piecewise", "nonsmooth-min-piecewise")

#let rg12 = cas.limit("(1-cos(x))/x^2", "x", 0)
#let rg12v = cas.eval(rg12.expr)
#assert-ok(rg12, "limit-trig-standard")
#assert-ok(rg12v, "limit-trig-standard-eval")
#assert-true(calc.abs(rg12v.value - 0.5) < 1e-9, "limit-trig-standard-value")

#let rg13 = cas.limit("(3x^2+1)/(2x^2-5)", "x", "inf")
#let rg13v = cas.eval(rg13.expr)
#assert-ok(rg13, "limit-infinity-rational")
#assert-ok(rg13v, "limit-infinity-rational-eval")
#assert-true(calc.abs(rg13v.value - 1.5) < 1e-9, "limit-infinity-rational-value")

All strict gates passed.

== 2. UX-First Usage
#let cx = cas.with(assumptions: a-pos)
#let simplify-x = cx.simplify
#let diff-x = cx.diff
#let solve-x = cx.solve
#let trace-i = cx.trace-integrate

#let ux-s = simplify-x("sin(x)^2 + cos(x)^2")
#assert-true(cas.ok(ux-s), "ux-with-simplify-ok")
*context simplify (expr-of):*\
*Before:*\
$ #cas.display("sin(x)^2 + cos(x)^2") $
*After:*\
$ #cas.display(cas.expr-of(ux-s)) $

#let ux-d = diff-x("x^3 + ln(x)", "x")
#assert-true(cas.ok(ux-d), "ux-with-diff-ok")
*context diff (expr-of):*\
*Before:*\
$ #cas.display("x^3 + ln(x)") $
*After:*\
$ #cas.display(cas.expr-of(ux-d)) $

#let ux-z = solve-x("x^2 - 4", rhs: 0)
#assert-true(cas.ok(ux-z), "ux-with-solve-ok")
*context solve roots (roots-of):*\
*Before:*\
$ #cas.display("x^2 - 4") $
*After:*\
#let roots = cas.roots-of(ux-z)
*After (roots):*\
#for (i, r) in roots.enumerate() [
  $ r_(#(i + 1)) = #cas.display(r) $
]
*After (count):*\
$ #roots.len() $

*context error message helper (on success):*\
$ #cas.error-message(ux-s, default: "none") $

#let ux-t = trace-i("2x*cos(x^2)", var: "x", detail: 3)
#assert-true(cas.ok(ux-t), "ux-with-trace-ok")
#if cas.steps-of(ux-t).len() > 0 [
  *context trace-integrate:*
  #cas.render-steps("2x*cos(x^2)", ux-t, operation: "integrate", var: "x")
]

== 3. Canonical API Surface (`cas.*`)
#let raw = "log_2(x) + sin(x)^2 + cos(x)^2"
#let parsed = cas.parsed(raw, assumptions: a-base)
#let simp = cas.simplify(raw, assumptions: a-base)

*parse/display:* $ #cas.display(parsed.expr) $
*equation helper:*\
*Before:*\
$ #cas.display("x^2-1") $
*After:*\
$ #cas.display("(x-1)(x+1)") $
*simplify*:
*Before:*\
$ #cas.display(raw) $
*After:*\
$ #cas.display(simp.expr) $
#let simp-panel = simp.diagnostics.at("restriction-panel", default: none)
#if simp-panel != none [
  *restriction panel (simplify):*\
  #text(size: 0.92em)[active=#simp-panel.counts.active, satisfied=#simp-panel.counts.satisfied, conflicts=#simp-panel.counts.conflicts]
  #for row in simp-panel.rows [
    #text(size: 0.88em)[#row.status ":"]
    #h(0.35em)
    #row.math
  ]
]

#let ad-src = "(-inf,0)∪(0,inf)"
#let ad-assume = cas.assume-domain("x", ad-src)
*parse-domain input:* `(-inf,0)∪(0,inf)`
*parse-domain (normalized display):*\
$ #cas.display-domain("x", assumptions: ad-assume) $
*display-domain (`a-pos`):*\
$ #cas.display-domain("x", assumptions: a-pos) $

#let qdom = cas.domain("x^2 + 1", "x", assumptions: a-pos)
#assert-ok(qdom, "query-domain")
*query domain value:*\
$ #qdom.value $

#let d1 = cas.diff("x^3 + ln(x)", "x", order: 2, assumptions: a-pos)
#assert-ok(d1, "diff-order")
*diff(order=2)*\
*Before:*\
$ #cas.display("x^3 + ln(x)") $
*After:*\
$ #cas.display(d1.expr) $

#let i1 = cas.integrate("x^2 + 1", "x", assumptions: a-base)
#let i2 = cas.integrate("x", "x", definite: (0, 2), assumptions: a-base)
#assert-ok(i1, "integrate-indef")
#assert-ok(i2, "integrate-def")
*integrate*\
*Before:*\
$ #cas.display("x^2 + 1") $
*After:*\
$ #cas.display(i1.expr) $
*definite integrate [0,2]*\
*Before:*\
$ #cas.display("x") $
*After:*\
$ #cas.display(i2.expr) $

#let id1 = cas.implicit-diff("x*y - 3", "x", "y", assumptions: a-xy)
#assert-ok(id1, "implicit-diff-second")
*implicit diff*\
*Before:*\
$ #cas.display("x*y - 3") $
*After:*\
$ #cas.display(id1.expr) $

#let s1 = cas.solve("x^2 - 4", rhs: 0)
#assert-ok(s1, "solve-basic")
*solve roots count (distinct):*\
*Before:*\
$ #cas.display("x^2 - 4") $
*After:*\
$ #s1.roots.len() $

#let f1 = cas.factor("x^2 - 4")
#assert-ok(f1, "factor-basic")
*factor*\
*Before:*\
$ #cas.display("x^2 - 4") $
*After:*\
$ #cas.display(f1.expr) $

#let t1 = cas.taylor("exp(x)", "x", 0, 4)
#assert-ok(t1, "taylor-basic")
*taylor*\
*Before:*\
$ #cas.display("exp(x)") $
*After:*\
$ #cas.display(t1.expr) $

#let l1 = cas.limit("sin(x)/x", "x", 0)
#let l1l = cas.limit("sin(x)/x", "x", "0-")
#let l1r = cas.limit("sin(x)/x", "x", "0+")
#let l2 = cas.limit("(1-cos(x))/x^2", "x", 0)
#let l3 = cas.limit("(3x^2+1)/(2x^2-5)", "x", "inf")
#assert-ok(l1, "limit-basic")
#assert-ok(l1l, "limit-left")
#assert-ok(l1r, "limit-right")
#assert-ok(l2, "limit-trig-std")
#assert-ok(l3, "limit-inf-rational")
#let l1v = cas.eval(l1.expr)
#let l1lv = cas.eval(l1l.expr)
#let l1rv = cas.eval(l1r.expr)
#let l2v = cas.eval(l2.expr)
#let l3v = cas.eval(l3.expr)
#assert-ok(l1v, "limit-basic-eval")
#assert-ok(l1lv, "limit-left-eval")
#assert-ok(l1rv, "limit-right-eval")
#assert-ok(l2v, "limit-trig-std-eval")
#assert-ok(l3v, "limit-inf-rational-eval")
#assert-true(calc.abs(l1v.value - 1) < 1e-9, "limit-sinc-value")
#assert-true(calc.abs(l1lv.value - 1) < 1e-9, "limit-sinc-left-value")
#assert-true(calc.abs(l1rv.value - 1) < 1e-9, "limit-sinc-right-value")
#assert-true(calc.abs(l2v.value - 0.5) < 1e-9, "limit-trig-std-value")
#assert-true(calc.abs(l3v.value - 1.5) < 1e-9, "limit-inf-rational-value")
*limit*\
*Before:*\
$ #cas.display("sin(x)/x") $
*After:*\
$ #cas.display(l1.expr) $
*limit (left-sided)*\
*Before:*\
$ #cas.display("sin(x)/x"), x arrow.r 0^- $
*After:*\
$ #cas.display(l1l.expr) $
*limit (right-sided)*\
*Before:*\
$ #cas.display("sin(x)/x"), x arrow.r 0^+ $
*After:*\
$ #cas.display(l1r.expr) $
*limit (trig standard)*\
*Before:*\
$ #cas.display("(1-cos(x))/x^2") $
*After:*\
$ #cas.display(l2.expr) $
*limit (x -> inf, rational degree)*\
*Before:*\
$ #cas.display("(3x^2+1)/(2x^2-5)"), x arrow.r infinity $
*After:*\
$ #cas.display(l3.expr) $

#let e1 = cas.eval("x^2 + 1", bindings: (x: 3))
#assert-ok(e1, "eval-basic")
*eval:*\
*Before:*\
$ #cas.display("x^2 + 1") $
*After:*\
$ #e1.value $

#let sub1 = cas.substitute("x^2 + y", "x", "z+1")
#assert-ok(sub1, "substitute-basic")
*substitute*\
*Before:*\
$ #cas.display("x^2 + y"), x arrow.r z + 1 $
*After:*\
$ #cas.display(sub1.expr) $

#let tr1 = cas.trace-integrate("2x*cos(x^2)", var: "x", detail: 2, assumptions: a-pos)
#assert-ok(tr1, "trace-canonical")
#if tr1.steps != none [#cas.render-steps("2x*cos(x^2)", tr1, operation: "integrate", var: "x")]

== 4. Query Input + Task API (No Field-Call Parens)
#let q-src = "x + x + 1"
#let q = cas.expr(q-src, assumptions: a-base)
#let q-impl = cas.expr("x^2 + y^2 - 1", assumptions: a-xy)
#let q2 = cas.expr(q.input, assumptions: a-base)

#let qp = cas.parsed(q)
#assert-ok(qp, "query-parsed")
*query parsed:* $ #cas.display(qp.expr) $

#let qs = cas.simplify(q, detail: 1)
#assert-ok(qs, "query-simplify")
*query simplify*\
*Before:*\
$ #cas.display(q-src) $
*After:*\
$ #cas.display(qs.expr) $

#let qd = cas.diff(q, "x", detail: 2)
#assert-ok(qd, "query-diff")
*query diff*\
*Before:*\
$ #cas.display(q-src) $
*After:*\
$ #cas.display(qd.expr) $

#let qi = cas.integrate(q, "x")
#assert-ok(qi, "query-integrate")
*query integrate*\
*Before:*\
$ #cas.display(q-src) $
*After:*\
$ #cas.display(qi.expr) $

#let qv = cas.implicit-diff(q-impl, "x", "y")
#assert-ok(qv, "query-implicit-diff")
*query implicit diff*\
*Before:*\
$ #cas.display("x^2 + y^2 - 1") $
*After:*\
$ #cas.display(qv.expr) $

#let qz = cas.solve(q, rhs: 0)
#assert-ok(qz, "query-solve")
*query solve roots (distinct):*\
*Before:*\
$ #cas.display(q-src) $
*After:*\
$ #cas.roots-of(qz).len() $
*query recreated context (`with` equivalent):*\
$ #q2.field " / strict=" #q2.strict $

#let qdm = cas.domain(q2, "x")
#assert-ok(qdm, "query-domain")
*query domain:*\
$ #qdm.value $

#let qchain = cas.simplify(cas.diff(q, "x"), detail: 1)
#assert-ok(qchain, "query-chain")
*task chain diff -> simplify*\
*Before:*\
$ #cas.display(qd.expr) $
*After:*\
$ #cas.display(qchain.expr) $

#let qtr = cas.trace(q, "diff", var: "x", detail: 3)
#assert-ok(qtr, "query-trace")
#if qtr.steps != none [#cas.render-steps(q, qtr, operation: "diff", var: "x")]

== 5. Matrix / Systems / Poly Task APIs
#let m-a = cas.matrix(((1, 2), (3, 4)))
#let m-b = cas.matrix(((5, 6), (7, 8)))
#let m-c = cas.matrix(((5, 7), (9, 11)))
#let m-d = cas.matrix(((2, 0), (1, 2)))
#let m-e = cas.matrix(((1, 2, 3), (4, 5, 6)))
#let m-f = cas.matrix(((1, 2), (3, 5)))
#let m-g = cas.matrix(((2, 1), (1, 3)))
#let m-h = cas.matrix(((2, 1), (1, 2)))

#let ma = cas.mat-add(m-a, m-b)
#assert-ok(ma, "matrix-add")
*matrix add*\
*Before:*\
$ #cas.display(m-a) + #cas.display(m-b) $
*After:*\
$ #cas.display(ma.expr) $

#let ms = cas.mat-sub(m-c, m-a)
#assert-ok(ms, "matrix-sub")
*matrix sub*\
*Before:*\
$ #cas.display(m-c) - #cas.display(m-a) $
*After:*\
$ #cas.display(ms.expr) $

#let msc = cas.mat-scale(2, m-a)
#assert-ok(msc, "matrix-scale")
*matrix scale*\
*Before:*\
$ 2 dot.op #cas.display(m-a) $
*After:*\
$ #cas.display(msc.expr) $

#let mm = cas.mat-mul(m-a, m-d)
#assert-ok(mm, "matrix-mul")
*matrix mul*\
*Before:*\
$ #cas.display(m-a) dot.op #cas.display(m-d) $
*After:*\
$ #cas.display(mm.expr) $

#let mt = cas.mat-transpose(m-e)
#assert-ok(mt, "matrix-transpose")
*matrix transpose*\
*Before:*\
$ #cas.display(m-e) $
*After:*\
$ #cas.display(mt.expr) $

#let md = cas.mat-det(m-a)
#assert-ok(md, "matrix-det")
*matrix det*\
*Before:*\
$ #cas.display(m-a) $
*After:*\
$ #cas.display(md.expr) $

#let mi = cas.mat-inv(m-f)
#assert-ok(mi, "matrix-inv")
*matrix inv*\
*Before:*\
$ #cas.display(m-f) $
*After:*\
$ #cas.display(mi.expr) $

#let msolve = cas.mat-solve(m-g, (5, 6))
#assert-ok(msolve, "matrix-solve")
*matrix solve*\
*Before (A):*\
$ #cas.display(m-g) $
*Before (b):*\
$ b = (5, 6) $
*After:*\
#for (i, s) in msolve.expr.enumerate() [
  $ x_(#(i + 1)) = #cas.display(s) $
]

#let mev = cas.mat-eigenvalues(m-h)
#assert-ok(mev, "matrix-eigs")
*matrix eigenvalues:*\
*Before:*\
$ #cas.display(m-h) $
*After:*\
#for (i, lam) in mev.value.enumerate() [
  $ lambda_(#(i + 1)) = #cas.display(lam) $
]

#let mevec = cas.mat-eigenvectors(m-h)
#assert-ok(mevec, "matrix-eigvecs")
*matrix eigenvectors:*\
*Before:*\
$ #cas.display(m-h) $
*After:*\
#for (i, pair) in mevec.value.enumerate() [
  #let lam = pair.at(0)
  #let vec = pair.at(1)
  $ lambda_(#(i + 1)) = #cas.display(lam), v_(#(i + 1)) = (#cas.display(vec.at(0)), #cas.display(vec.at(1))) $
]

#let lins = cas.solve-linear-system(("2x+y-5", "x-y-1"), ("x", "y"))
#assert-ok(lins, "systems-linear")
*linear system:*\
*Before:*\
$ #cas.display("2x+y-5"), #cas.display("x-y-1") $
*After:*\
$ x = #cas.display(lins.value.at("x")), y = #cas.display(lins.value.at("y")) $

#let nls = cas.solve-nonlinear-system(("x^2+y^2-5", "x-y-1"), ("x", "y"), (x: 2, y: 1))
#assert-ok(nls, "systems-nonlinear")
*nonlinear system:*\
*Before:*\
$ #cas.display("x^2+y^2-5"), #cas.display("x-y-1") $
*After:*\
$ upright("converged") = #nls.value.converged, upright("iterations") = #nls.value.iterations $
$ x approx #cas.display(nls.value.solution.at("x")), y approx #cas.display(nls.value.solution.at("y")) $

#let pd = cas.poly-div("x^3-1", "x-1", "x")
#let pd-q = cas.coeffs-to-expr(pd.value.at(0), "x")
#let pd-r = cas.coeffs-to-expr(pd.value.at(1), "x")
#assert-ok(pd, "poly-div")
#assert-ok(pd-q, "poly-div-quotient-expr")
#assert-ok(pd-r, "poly-div-remainder-expr")
*poly div:*\
*Before:*\
$ #cas.display("x^3-1") / #cas.display("x-1") $
*After:*\
$ q(x) = #cas.display(pd-q.expr), r(x) = #cas.display(pd-r.expr) $

#let ppf = cas.partial-fractions("(2x+3)/(x^2-1)", "x")
#let ppf-original = cas.parse("(2x+3)/(x^2-1)")
#assert-ok(ppf, "poly-pf")
#assert-true(repr(cas.expr-of(ppf)) != repr(ppf-original), "poly-pf-decomposed")
*partial fractions:*\
*Before:*\
$ #cas.display("(2x+3)/(x^2-1)") $
*After:*\
$ #cas.display(ppf.expr) $

== 6. Unified Demo Flow
#let master = "(x+1)/(x+1) + ln(exp(x)) + sin(x)^2 + cos(x)^2 + sqrt(x^2) + (2/5 + 7/15 - 13/15) + ((x+4)(x-4) - (x^2-16)) - (3 + abs(x))"
#let qdemo = cas.expr(master, assumptions: a-pos)

*Domain (x):*\
$ #cas.display-domain("x", assumptions: a-pos) $

#let rs = cas.simplify(qdemo, expand: true, allow-domain-sensitive: true, detail: 1)
#assert-ok(rs, "demo-simplify")
*demo simplify*\
*Before:*\
$ #cas.display(master) $
*After:*\
$ #cas.display(rs.expr) $

#let rd = cas.diff(qdemo, "x", detail: 1)
#let ri = cas.integrate(rd, "x")
#let rz = cas.solve(rs, rhs: 0, detail: 1)
#assert-ok(rd, "demo-diff")
#assert-ok(ri, "demo-integrate")
#assert-ok(rz, "demo-solve")

*demo derivative*\
*Before:*\
$ #cas.display(master) $
*After:*\
$ #cas.display(rd.expr) $
*demo integral of derivative*\
*Before:*\
$ #cas.display(rd.expr) $
*After:*\
$ #cas.display(ri.expr) $
*Roots found (distinct):*\
*Before:*\
$ #cas.display(rs.expr) = 0 $
*After:*\
$ #cas.roots-of(rz).len() $
*Restrictions summary:*\
$ "unresolved=" #rs.restrictions.len() ", satisfied=" #rs.satisfied.len() ", conflicts=" #rs.conflicts.len() $

== 7. Step Engine Showcase
#let st1 = cas.trace-simplify(qdemo, detail: 1, assumptions: a-pos)
#assert-ok(st1, "steps-simplify-d1")
*Simplify trace (detail 1):*\
#cas.render-steps(qdemo, st1, operation: "simplify")

#let st2 = cas.trace-simplify(qdemo, detail: 4, assumptions: a-pos)
#assert-ok(st2, "steps-simplify-d4")
*Simplify trace (detail 4):*\
#cas.render-steps(qdemo, st2, operation: "simplify")

#let st3 = cas.trace-diff("(x^2+1)^3", var: "x", detail: 3, assumptions: a-base)
#assert-ok(st3, "steps-diff")
*Diff trace:*\
#cas.render-steps("(x^2+1)^3", st3, operation: "diff", var: "x")

#let st4 = cas.trace-integrate("2x*cos(x^2)", var: "x", detail: 4, assumptions: a-pos)
#assert-ok(st4, "steps-integrate-usub")
*U-sub integrate trace:*\
#cas.render-steps("2x*cos(x^2)", st4, operation: "integrate", var: "x")

#let st7 = cas.trace-integrate("sec(x)^2 + csc(x)^2", var: "x", detail: 3, assumptions: a-base)
#assert-ok(st7, "steps-integrate-linearity")
*Additive integrate trace:*\
#cas.render-steps("sec(x)^2 + csc(x)^2", st7, operation: "integrate", var: "x")

#let st5 = cas.trace-solve("x^2-4", rhs: 0, detail: 3)
#assert-ok(st5, "steps-solve")
*Solve trace:*\
#cas.render-steps("x^2-4", st5, operation: "solve", var: "x", rhs: 0)

#let st6 = cas.trace-diff("(x^2+1)^3", detail: 4, depth: 1, assumptions: a-base)
#assert-ok(st6, "steps-depth-override")
*Depth override demo (`detail:4` + `depth:1`):*\
#cas.render-steps("(x^2+1)^3", st6, operation: "diff", var: "x")

== 8. Additional Examples (Expanded)
#let ex-s1 = cas.simplify("((x^2-1)/(x-1)) + 1/sin(x)", assumptions: a-guard)
#assert-ok(ex-s1, "simplify-guarded")
*simplify (guarded cancel + reciprocal canonical):*\
*Before:*\
$ #cas.display("((x^2-1)/(x-1)) + 1/sin(x)") $
*After:*\
$ #cas.display(ex-s1.expr) $

#let ex-s2 = cas.simplify("sqrt(x^2) + abs(x)", assumptions: a-pos, allow-domain-sensitive: true)
#assert-ok(ex-s2, "simplify-domain-sensitive")
*simplify (domain-sensitive):*\
*Before:*\
$ #cas.display("sqrt(x^2) + abs(x)") $
*After:*\
$ #cas.display(ex-s2.expr) $

#let ex-d1 = cas.diff("exp(3x) + arctan(x^2)", "x", assumptions: a-base)
#assert-ok(ex-d1, "diff-1")
*diff (exp + inverse trig):*\
*Before:*\
$ #cas.display("exp(3x) + arctan(x^2)") $
*After:*\
$ #cas.display(ex-d1.expr) $

#let ex-d2 = cas.diff("x*ln(x)", "x", assumptions: a-pos)
#assert-ok(ex-d2, "diff-2")
*diff (product + log):*\
*Before:*\
$ #cas.display("x*ln(x)") $
*After:*\
$ #cas.display(ex-d2.expr) $

#let ex-nd1 = cas.diff("abs(x)", "x", strict: false)
#let ex-nd2 = cas.diff("min(x, x^2)", "x", strict: false)
#let ex-nd3 = cas.diff("clamp(x,0,1)", "x", strict: false)
#assert-ok(ex-nd1, "diff-nonsmooth-abs")
#assert-ok(ex-nd2, "diff-nonsmooth-min")
#assert-ok(ex-nd3, "diff-nonsmooth-clamp")
#assert-true(ex-nd1.expr.type == "piecewise", "diff-nonsmooth-abs-piecewise")
#assert-true(ex-nd2.expr.type == "piecewise", "diff-nonsmooth-min-piecewise")
#assert-true(ex-nd3.expr.type == "piecewise", "diff-nonsmooth-clamp-piecewise")
*diff (non-smooth abs, piecewise-aware):*\
*Before:*\
$ #cas.display("abs(x)") $
*After:*\
$ #cas.display(ex-nd1.expr) $
*warnings:*\
$ #ex-nd1.warnings.len() $

*diff (non-smooth min, piecewise-aware):*\
*Before:*\
$ #cas.display("min(x, x^2)") $
*After:*\
$ #cas.display(ex-nd2.expr) $

*diff (non-smooth clamp, piecewise-aware):*\
*Before:*\
$ #cas.display("clamp(x,0,1)") $
*After:*\
$ #cas.display(ex-nd3.expr) $

#let ex-i1 = cas.integrate("x*exp(x)", "x", assumptions: a-base)
#assert-ok(ex-i1, "integrate-1")
*integrate (by parts flavor):*\
*Before:*\
$ #cas.display("x*exp(x)") $
*After:*\
$ #cas.display(ex-i1.expr) $

#let ex-i2 = cas.integrate("sech(x)^2 + csch(x)^2", "x", assumptions: a-base)
#assert-ok(ex-i2, "integrate-2")
*integrate (hyperbolic square-family):*\
*Before:*\
$ #cas.display("sech(x)^2 + csch(x)^2") $
*After:*\
$ #cas.display(ex-i2.expr) $

#let ex-i3 = cas.integrate("1/(x^2-1)", "x", assumptions: a-guard)
#assert-ok(ex-i3, "integrate-3")
*integrate (rational / partial fractions):*\
*Before:*\
$ #cas.display("1/(x^2-1)") $
*After:*\
$ #cas.display(ex-i3.expr) $

#let ex-sol1 = cas.solve("x^3 - 6x^2 + 11x - 6", rhs: 0)
#assert-ok(ex-sol1, "solve-cubic")
*solve (cubic roots count):*\
*Before:*\
$ #cas.display("x^3 - 6x^2 + 11x - 6") $
*After:*\
$ #cas.roots-of(ex-sol1).len() $

#let ex-sol2 = cas.solve("x^4 + 1", rhs: 0)
#assert-ok(ex-sol2, "solve-quartic-complex")
*solve (quartic complex roots count):*\
*Before:*\
$ #cas.display("x^4 + 1") $
*After:*\
$ #cas.roots-of(ex-sol2).len() $

#let ex-f1 = cas.factor("x^4 - 16")
#assert-ok(ex-f1, "factor")
*factor:*\
*Before:*\
$ #cas.display("x^4 - 16") $
*After:*\
$ #cas.display(ex-f1.expr) $

#let ex-t1 = cas.taylor("sin(x)", "x", 0, 7)
#assert-ok(ex-t1, "taylor")
*taylor:*\
*Before:*\
$ #cas.display("sin(x)") $
*After:*\
$ #cas.display(ex-t1.expr) $

#let ex-l1 = cas.limit("(cos(x)-1)/x", "x", 0)
#assert-ok(ex-l1, "limit")
*limit:*\
*Before:*\
$ #cas.display("(cos(x)-1)/x") $
*After:*\
$ #cas.display(ex-l1.expr) $

#let ex-e1 = cas.eval("sin(pi/2) + log10(100)")
#assert-ok(ex-e1, "eval")
*eval:*\
*Before:*\
$ #cas.display("sin(pi/2) + log10(100)") $
*After:*\
$ #ex-e1.value $

#let ex-sub1 = cas.substitute("x^2 + y^2", "y", "2x")
#assert-ok(ex-sub1, "substitute")
*substitute:*\
*Before:*\
$ #cas.display("x^2 + y^2"), y arrow.r 2x $
*After:*\
$ #cas.display(ex-sub1.expr) $

#let ex-pc = cas.poly-coeffs("x^4 - 3x + 2", "x")
#assert-ok(ex-pc, "poly-coeffs")
#let ex-pb = cas.coeffs-to-expr(ex-pc.value, "x")
#assert-ok(ex-pb, "poly-coeffs-roundtrip")
*poly coeffs roundtrip:*\
*Before:*\
$ #cas.display("x^4 - 3x + 2") $
*After:*\
$ #cas.display(ex-pb.expr) $

#let ex-lins = cas.solve-linear-system(("x+y-3", "2x-y"), ("x", "y"))
#assert-ok(ex-lins, "linear-system")
*linear system:*\
*Before:*\
$ #cas.display("x+y-3"), #cas.display("2x-y") $
*After:*\
$ x = #cas.display(ex-lins.value.at("x")), y = #cas.display(ex-lins.value.at("y")) $

#let ex-domain = cas.assume-domain("t", "(-inf,-2] ∪ (0,4) ∪ (4,inf)")
*domain display (`t`):*\
$ #cas.display-domain("t", assumptions: ex-domain) $

#let c-demo = cas.with(assumptions: a-guard)
#let ex-cx1 = (c-demo.simplify)("(x^2-1)/(x-1)")
#let ex-cx2 = (c-demo.integrate)("1/(x^2-1)", "x")
#assert-ok(ex-cx1, "context-simplify")
#assert-ok(ex-cx2, "context-integrate")
*context simplify:*\
*Before:*\
$ #cas.display("(x^2-1)/(x-1)") $
*After:*\
$ #cas.display(ex-cx1.expr) $
*context integrate:*\
*Before:*\
$ #cas.display("1/(x^2-1)") $
*After:*\
$ #cas.display(ex-cx2.expr) $

=== 8.1 Function + Identity Bundle
#let fx-sign-a = cas.eval("sign(-3)")
#let fx-sign-b = cas.eval("sign(0)")
#let fx-sign-c = cas.eval("sgn(5)")
#assert-ok(fx-sign-a, "fn-sign-neg")
#assert-ok(fx-sign-b, "fn-sign-zero")
#assert-ok(fx-sign-c, "fn-sign-pos")
#assert-true(fx-sign-a.value == -1 and fx-sign-b.value == 0 and fx-sign-c.value == 1, "fn-sign-values")
#assert-expr-eq(cas.parse("sgn(x)"), "sign(x)", "fn-sign-alias")
*sign / sgn:*\
*Before:*\
$ #cas.display("sign(-3)") ", " #cas.display("sign(0)") ", " #cas.display("sgn(5)") $
*After:*\
$ #fx-sign-a.value ", " #fx-sign-b.value ", " #fx-sign-c.value $

#let fx-rounding = cas.eval("floor(2.9) + ceil(2.1) + round(2.6)")
#assert-ok(fx-rounding, "fn-floor-ceil-round")
#assert-true(fx-rounding.value == 8, "fn-floor-ceil-round-values")
*floor + ceil + round:*\
*Before:*\
$ #cas.display("floor(2.9) + ceil(2.1) + round(2.6)") $
*After:*\
$ #fx-rounding.value $

#let fx-trunc = cas.eval("trunc(-2.9)")
#let fx-frac = cas.eval("fracpart(-2.9)")
#assert-ok(fx-trunc, "fn-trunc")
#assert-ok(fx-frac, "fn-fracpart")
#assert-true(fx-trunc.value == -2, "fn-trunc-value")
#assert-true(calc.abs(fx-frac.value - (-0.9)) < 1e-9, "fn-fracpart-value")
*trunc / fracpart:*\
*Before:*\
$ #cas.display("trunc(-2.9)") ", " #cas.display("fracpart(-2.9)") $
*After:*\
$ #fx-trunc.value ", " #fx-frac.value $

#let fx-min = cas.eval("min(3,4,1)")
#let fx-max = cas.eval("max(3,4,1)")
#let fx-clamp = cas.eval("clamp(10,0,5)")
#assert-ok(fx-min, "fn-min")
#assert-ok(fx-max, "fn-max")
#assert-ok(fx-clamp, "fn-clamp")
#assert-true(fx-min.value == 1 and fx-max.value == 4 and fx-clamp.value == 5, "fn-min-max-clamp-values")
*min / max / clamp:*\
*Before:*\
$ #cas.display("min(3,4,1)") ", " #cas.display("max(3,4,1)") ", " #cas.display("clamp(10,0,5)") $
*After:*\
$ #fx-min.value ", " #fx-max.value ", " #fx-clamp.value $

#let fx-clamp-ok = cas.simplify("clamp(x,0,5)")
#let fx-clamp-bad = cas.simplify("clamp(x,5,0)", strict: false)
#assert-ok(fx-clamp-ok, "fn-clamp-restriction-ok")
#assert-ok(fx-clamp-bad, "fn-clamp-restriction-conflict-result")
#assert-true(fx-clamp-ok.satisfied.len() > 0, "fn-clamp-restriction-satisfied")
#assert-true(fx-clamp-bad.conflicts.len() > 0, "fn-clamp-restriction-conflict")
*clamp restriction metadata:*\
*Before:*\
$ #cas.display("clamp(x,5,0)") $
*After:*\
$ "conflicts=" #fx-clamp-bad.conflicts.len() $

#let id-log1p = cas.simplify("log1p(expm1(x))")
#assert-ok(id-log1p, "id-log1p-expm1")
#assert-expr-eq(id-log1p.expr, "x", "id-log1p-expm1-result")

#let id-expm1 = cas.simplify("expm1(log1p(x))", allow-domain-sensitive: true)
#assert-ok(id-expm1, "id-expm1-log1p")
#assert-expr-eq(id-expm1.expr, "x", "id-expm1-log1p-result")

#let id-cbrt = cas.simplify("(cbrt(x))^3")
#assert-ok(id-cbrt, "id-cbrt-cube")
#assert-expr-eq(id-cbrt.expr, "x", "id-cbrt-cube-result")

#let id-sqrt = cas.simplify("(sqrt(x))^2", allow-domain-sensitive: true)
#assert-ok(id-sqrt, "id-sqrt-square")
#assert-expr-eq(id-sqrt.expr, "x", "id-sqrt-square-result")

#let id-min = cas.simplify("min(x,x)")
#let id-max = cas.simplify("max(x,x)")
#let id-clamp = cas.simplify("clamp(x,a,a)")
#assert-ok(id-min, "id-min-idempotent")
#assert-ok(id-max, "id-max-idempotent")
#assert-ok(id-clamp, "id-clamp-degenerate")
#assert-expr-eq(id-min.expr, "x", "id-min-idempotent-result")
#assert-expr-eq(id-max.expr, "x", "id-max-idempotent-result")
#assert-expr-eq(id-clamp.expr, "a", "id-clamp-degenerate-result")

#let id-signabs = cas.simplify("sign(x)*abs(x)")
#assert-ok(id-signabs, "id-sign-abs")
#assert-expr-eq(id-signabs.expr, "x", "id-sign-abs-result")

#let id-abs-self = cas.simplify("abs(x)/x", allow-domain-sensitive: true)
#let id-self-abs = cas.simplify("x/abs(x)", allow-domain-sensitive: true)
#assert-ok(id-abs-self, "id-abs-over-self")
#assert-ok(id-self-abs, "id-self-over-abs")
#assert-expr-eq(id-abs-self.expr, "sign(x)", "id-abs-over-self-result")
#assert-expr-eq(id-self-abs.expr, "sign(x)", "id-self-over-abs-result")

#let id-telemetry = cas.simplify("min(x,x)", detail: 1)
#assert-ok(id-telemetry, "id-telemetry")
#assert-true(id-telemetry.diagnostics.at("identity-count", default: 0) > 0, "id-telemetry-count")
*identity expansion sample:*\
*Before:*\
$ #cas.display("abs(x)/x + x/abs(x) + min(x,x)") $
*After:*\
$ #cas.display(cas.simplify("abs(x)/x + x/abs(x) + min(x,x)", allow-domain-sensitive: true).expr) $

== 9. Translation Layer Note (compact)
#import "../translators/translation.typ": simplify as v1-simplify, implicit-diff as v1-implicit-diff

#let t-s = v1-simplify("sin(x)^2 + cos(x)^2")
#let t-id = v1-implicit-diff("x*y - 3", "x", "y")

*v1 simplify alias:* $ #cas.display(t-s) $
*v1 implicit diff alias:* $ #cas.display(t-id) $

Canonical `cas.*` API is preferred for new documents.

== 10. Final Status
All unified checks passed.
