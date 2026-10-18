#import "parse.typ": *

#let True = parse("/xy.x")
#let False = parse("/xy.y")
#let And = parse("/ab.aba")
#let And_(a, b) = apply(And, a, b)
#let Or = parse("/ab.aab")
#let Or_(a, b) = apply(Or, a, b)
#let Not = func("a", apply("a", False, True))
#let Not_(a) = apply(Not, a)
#let Xor = func("ab", apply("a", apply("b", False, True), "b"))
#let Xor_(a, b) = apply(Xor, a, b)

#let pair = parse("/mni.imn")
#let pair_(m, n) = apply(pair, m, n)
#let fst = parse("/p.p(/mn.m)")
#let fst_(p) = apply(fst, p)
#let snd = parse("/p.p(/mn.n)")
#let snd_(p) = apply(snd, p)

#let I = parse("/x.x")
#let K = parse("/xy.x")
#let S = parse("/xyz.(xz)(yz)")
#let Y = parse("/f.(/x.f(xx))(/x.f(xx))")
#let omega = parse("(/x.xx)(/x.xx)")

#let theta = parse("(/xy.y(xxy))(/xy.y(xxy))")

#let _0 = parse("/fx.x")
#let _1 = parse("/x.x")
#let _2 = parse("/fx.f(fx)")
#let _3 = parse("/fx.f(f(fx))")

#let Nat(n) = {
  assert(type(n) == int and n >= 0)
  parse("/fx." + "f(" * n + "x" + ")" * n)
}

#let succ = parse("/nfx.f(nfx)")
#let succ_(n) = apply(succ, n)
#let add = parse("/mnfx.mf(nfx)")
#let add_(m, n) = apply(add, m, n)
#let mul = parse("/mnf.m(nf)")
#let mul_(m, n) = apply(mul, m, n)
#let pow = parse("/mn.nm")
#let pow_(m, n) = apply(pow, m, n)

#let is-zero = parse("/nxy.n(/_.y)x")
#let is-zero_(n) = apply(is-zero, n)

#let pred = parse("/nfx.n(/gh.h(gf))(/_.x)(/i.i)")
#let pred_(n) = apply(pred, n)

#let fact = parse("(/nf.n(/fn.n(f(/fx.nf(fx))))(/_.f)(/x.x))")
#let fact_(n) = apply(fact, n)

#let fib = parse("/nf.n(/ca./b.cb(/x.a(bx)))(/xy.x)(/x.x)f")
#let fib_(n) = apply(fib, n)
