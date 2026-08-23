#import "match.typ": slot, tight, loose

#let arithmetic = (
  sep: (infix: $,$, prec: -1, assoc: true),

  eq: (infix: $=$,  prec: 0),
  ne: (infix: $!=$, prec: 0),
  lt: (infix: $<$,  prec: 0),
  le: (infix: $<=$, prec: 0),
  gt: (infix: $>$,  prec: 0),
  ge: (infix: $>=$, prec: 0),

  add: (infix: $+$, prec: 1, assoc: true),
  sub: (infix: $-$, prec: 1),
  add-sub: (infix: $plus.minus$, prec: 1),
  plus: (prefix: $+$, prec: 2),
  neg: (prefix: $-$, prec: 2),
  plus-neg: (prefix: $plus.minus$, prec: 1),

  factorial: (postfix: $tight !$, prec: 3),

  times: (infix: $times$, prec: 2, assoc: true),
  dot: (infix: $dot$, prec: 2),
  mul: (infix: none, prec: 2.5, assoc: true),

  group: (match: $(slot("expr*"))$),
  frac: (match: math.frac),
  abs: (match: math.abs),
  binom: (match: $binom(slot("n"), slot("k"))$),

  pow: (
    match: math.attach,
    guard: slots => "t" in slots,
    rewrite: ((slots,)) => {
      let (base, t, ..rest) = slots
      let base = if rest.len() == 0 { base } else { math.attach(base, ..rest) }
      (head: "pow", args: (base, t), slots: (:))
    }
  ),

  root: (match: math.root(slot("index", guard: it => it != none), slot("radicand"))),
  sqrt: (match: $sqrt(slot("radicand"))$),

  call: (match: $slot("fn") tight (slot("args*"))$),
  
  pi: (match: $pi$),
  tau: (match: $tau$),
  ln: (match: $ln$),
  log: (match: $log$),
  sin: (match: $sin$),
  cos: (match: $cos$),
  tan: (match: $tan$),
  sinh: (match: $sinh$),
  cosh: (match: $cosh$),
  tanh: (match: $tanh$),
  arcsin: (match: $arcsin$),
  arccos: (match: $arccos$),
  arctan: (match: $arctan$),

)
