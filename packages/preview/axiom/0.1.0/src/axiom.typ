// Operators
#let argmax = math.op("argmax", limits: true)
#let argmin = math.op("argmin", limits: true)
#let indicator = math.op($bb(1)$, limits: true)

// Linear algebra
#let diag = math.op("diag")
#let rank = math.op("rank") 
#let span = math.op("Span")

// Probability
#let filt = math.op($cal(F)$)
#let expec = math.op($bb(E)$)
#let econd(var, cond) = $#math.op($bb(E)$)lr([#var|#cond])$
#let proba = math.op($bb(P)$)
#let pcond(var, cond) = $#math.op($bb(P)$)lr([#var|#cond])$
#let variance = math.op("Var")  // named this way to avoid conflict with physica var operator
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
