// Classical sets
#let NN = math.op($bb(N)$)
#let NN-star = math.op($attach(NN, tr: *)$)
#let RR = math.op($bb(R)$)
#let RR-plus = math.op($attach(RR, br: +)$)
#let RR-minus = math.op($attach(RR, br: -)$)
#let RR-star = math.op($attach(RR, tr: *)$)
#let RR-plus-star = math.op($attach(RR-plus, tr: *)$)
#let RR-minus-star = math.op($attach(RR-minus, tr: *)$)
#let ZZ = math.op($bb(Z)$)
#let ZZ-star = math.op($attach(ZZ, tr: *)$)
#let CC = math.op($bb(C)$)
#let CC-star = math.op($attach(CC, tr: *)$)
#let QQ = math.op($bb(Q)$)
#let QQ-star = math.op($attach(QQ, tr: *)$)
#let KK = math.op($bb(K)$)
#let KK-star = math.op($attach(KK, tr: *)$)

// Operators
#let argmax = math.op("argmax", limits: true)
#let argmin = math.op("argmin", limits: true)
#let indicator = math.op($bb(1)$, limits: true)

// Linear algebra
#let diag = math.op("diag")
#let tr = math.op("tr")
#let rank = math.op("rank")
#let Span = math.op("Span")
#let ker = math.op("Ker")
#let im = math.op("Im")

// Probability
#let filt = math.op($cal(F)$)
#let expec = math.op($bb(E)$)
#let econd(var, cond) = $#math.op($bb(E)$)lr([#var|#cond])$
#let proba = math.op($bb(P)$)
#let pcond(var, cond) = $#math.op($bb(P)$)lr([#var|#cond])$
#let variance = math.op("Var")  // named to avoid conflict with physica var operator
#let cov = math.op("Cov")
#let corr = math.op("Corr")
#let bias = math.op("Bias")
#let mse = math.op("MSE")
#let iid = math.op("i.i.d.")

// Usual probability distributions
#let gauss = math.op($cal(N)$)
#let uniform = math.op($cal(U)$)
#let bernoulli = math.op("Ber")
#let binomial = math.op("Bin")
#let poisson = math.op("Pois")
#let exponential = math.op("Exp")
#let gammadist = math.op("Gamma")
#let betadist = math.op("Beta")
#let chisq = math.op($chi^2$)
#let student = math.op($cal(T)$)

// Analysis / topology
#let interior = math.op("Int")
#let cl = math.op("cl")
#let fr = math.op("fr")
#let diam = math.op("diam")
#let conv = math.op("conv")
