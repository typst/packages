// SI prefixes
#let quecto = $q$
#let ronto = $r$
#let yocto = $y$
#let zepto = $z$
#let atto = $a$
#let femto = $f$
#let pico = $p$
#let nano = $n$
#let micro = $mu$
#let milli = $m$
#let centi = $c$
#let deci = $d$
#let deca = $d a$
#let deka = deca
#let hecto = $h$
#let kilo = $k$
#let mega = $M$
#let giga = $G$
#let tera = $T$
#let peta = $P$
#let exa = $E$
#let zetta = $Z$
#let yotta = $Y$
#let ronna = $R$
#let quetta = $Q$

// Binary prefixes
#let kibi = $K i$
#let mebi = $M i$
#let gibi = $G i$
#let tebi = $T i$
#let pebi = $P i$
#let exbi = $E i$
#let zebi = $Z i$
#let yobi = $Y i$

#{
  quecto = math.class("unary", quecto)
  ronto = math.class("unary", ronto)
  yocto = math.class("unary", yocto)
  zepto = math.class("unary", zepto)
  atto = math.class("unary", atto)
  femto = math.class("unary", femto)
  pico = math.class("unary", pico)
  nano = math.class("unary", nano)
  micro = math.class("unary", micro)
  milli = math.class("unary", milli)
  centi = math.class("unary", centi)
  deci = math.class("unary", deci)
  deca = math.class("unary", deca)
  deka = math.class("unary", deka)
  hecto = math.class("unary", hecto)
  kilo = math.class("unary", kilo)
  mega = math.class("unary", mega)
  giga = math.class("unary", giga)
  tera = math.class("unary", tera)
  peta = math.class("unary", peta)
  exa = math.class("unary", exa)
  zetta = math.class("unary", zetta)
  yotta = math.class("unary", yotta)
  ronna = math.class("unary", ronna)
  quetta = math.class("unary", quetta)

  kibi = math.class("unary", kibi)
  mebi = math.class("unary", mebi)
  gibi = math.class("unary", gibi)
  tebi = math.class("unary", tebi)
  pebi = math.class("unary", pebi)
  exbi = math.class("unary", exbi)
  zebi = math.class("unary", zebi)
  yobi = math.class("unary", yobi)
}
#let _dict = (
  quecto: quecto,
  ronto: ronto,
  yocto: yocto,
  zepto: zepto,
  atto: atto,
  femto: femto,
  pico: pico,
  nano: nano,
  micro: micro,
  milli: milli,
  centi: centi,
  deci: deci,
  deca: deca,
  deka: deka,
  hecto: hecto,
  kilo: kilo,
  mega: mega,
  giga: giga,
  tera: tera,
  peta: peta,
  exa: exa,
  zetta: zetta,
  yotta: yotta,
  ronna: ronna,
  quetta: quetta,
  
  kibi: kibi,
  mebi: mebi,
  gibi: gibi,
  tebi: tebi,
  pebi: pebi,
  exbi: exbi,
  zebi: zebi,
  yobi: yobi,
)

#let _power-tens = (
  quecto: -30,
  ronto: -27,
  yocto: -24,
  zepto: -21,
  atto: -18,
  femto: -15,
  pico: -12,
  nano: -9,
  micro: -6,
  milli: -3,
  centi: -2,
  deci: -1,
  deca: 1,
  deka: 1,
  hecto: 2,
  kilo: 3,
  mega: 6,
  giga: 9,
  tera: 12,
  peta: 15,
  exa: 18,
  zetta: 21,
  yotta: 24,
  ronna: 27,
  quetta: 30
)

// #let _dict = (
//   quecto: (quecto, -30),
//   ronto: (ronto, -27),
//   yocto: (yocto, -24),
//   zepto: (zepto, -21),
//   atto: (atto, -18),
//   femto: (femto, -15),
//   pico: (pico, -12),
//   nano: (nano, -9),
//   micro: (micro, -6),
//   milli: (milli, -3),
//   centi: (centi, -2),
//   deci: (deci, -1),
//   deca: (deca, 1),
//   deka: (deka, 1),
//   hecto: (hecto, 2),
//   kilo: (kilo, 3),
//   mega: (mega, 6),
//   giga: (giga, 9),
//   tera: (tera, 12),
//   peta: (peta, 15),
//   exa: (exa, 18),
//   zetta: (zetta, 21),
//   yotta: (yotta, 24),
//   ronna: (ronna, 27),
//   quetta: (quetta, 30)
// )
// #{
//   for (k, v) in _dict {
//     _dict.insert(k, (symbol: v.first(), power: v.last()))
//   }
// }


// #{
//   quecto += sym.zws
//   ronto += sym.zws
//   yocto += sym.zws
//   zepto += sym.zws
//   atto += sym.zws
//   femto += sym.zws
//   pico += sym.zws
//   nano += sym.zws
//   micro += sym.zws
//   milli += sym.zws
//   centi += sym.zws
//   deci += sym.zws
//   deca += sym.zws
//   deka = deca
//   hecto += sym.zws
//   kilo += sym.zws
//   // kilo = $k#sym.zws$
//   mega += sym.zws
//   giga += sym.zws
//   tera += sym.zws
//   peta += sym.zws
//   exa += sym.zws
//   zetta += sym.zws
//   yotta += sym.zws
//   ronna += sym.zws
//   quetta += sym.zws
// }

