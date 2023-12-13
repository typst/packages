// === GENERIC ===

// A handy thing to slightly increase parentheses size. E.g.:
// `big((x - y) - (y - z))` will make the external parentheses a bit bigger
#let big(x) = math.lr(x, size: 150%)
#let bigp(x) = big($(#x)$)

// A wrapper to number a single equation
#let numbered(x) = {
  set math.equation(numbering: "(1)")
  x
}

// TODO: not implies, not implied by, not iff; generic "not" (like `\not` in LaTeX)?

// Handy cursive letters (only uppercase for now)
#let aa = $cal(A)$
#let bb = $cal(B)$
#let cc = $cal(C)$
#let dd = $cal(D)$
#let ee = $cal(E)$
#let ff = $cal(F)$
#let gg = $cal(G)$
#let hh = $cal(H)$
#let ii = $cal(I)$
#let jj = $cal(J)$
#let kk = $cal(K)$
#let ll = $cal(L)$
#let mm = $cal(M)$
#let nn = $cal(N)$
// #let oo = $cal(O)$
#let pp = $cal(P)$
#let qq = $cal(Q)$
#let rr = $cal(R)$
#let ss = $cal(S)$
#let tt = $cal(T)$
#let uu = $cal(U)$
#let vv = $cal(V)$
#let ww = $cal(W)$
#let xx = $cal(X)$
#let yy = $cal(Y)$
#let zz = $cal(Z)$

// === PROBABILITY THEORY ===

#let indep = $perp #h(-1em) perp$ // Independence relation
#let nindep = $cancel(indep)$ // Non-independence relation FIXME
#let Pr = math.op("Pr") // Alternative notation for probability
#let Ex = math.op("Ex") // Alternative notation for expectation
#let Var = math.op("Var") // Variance
#let Cov = math.op("Cov") // Covariance
#let ind = math.bb($1$) // Indicator
#let iid = math.upright("iid")

// === MISCELANEOUS IDENTITIES ===

#let sign = math.op("sign")
#let argmin = math.op("arg min", limits: true)
#let argmax = math.op("arg max", limits: true)

// === OPTIMIZATION, ANALYSIS and CALCULUS ===

#let dist = math.upright("d") // metric

#let deriv = math.upright("D") // general derivative operator

// Landau notation:
#let oh = $cal(o)$
#let Oh = $cal(O)$
#let ohmega = $cal(omega)$ // hmmm...
#let Ohmega = $cal(Omega)$ // hmmm...
#let Thetah = $cal(Theta)$ // hmmm...
