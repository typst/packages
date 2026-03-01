#import "match.typ": slot, tight, loose

#let arithmetic = (
  "=": (infix: $=$, prec: 0),
  "!=": (infix: $!=$, prec: 0),
  "<": (infix: $<$, prec: 0),
  ">": (infix: $>$, prec: 0),
  "<=": (infix: $<=$, prec: 0),
  ">=": (infix: $>=$, prec: 0),
  cmp: (infix: slot("op", any: ($=$, $!=$)), prec: 0),

  
  add: (infix: $+$, prec: 1, assoc: true),
  sub: (infix: $-$, prec: 1),
  plus: (prefix: $+$, prec: 2),
  neg: (prefix: $-$, prec: 2),

  times: (infix: $times$, prec: 2),
  dot: (infix: $dot$, prec: 2),
  factorial: (postfix: $tight !$, prec: 3),
  mul: (infix: none, prec: 2.5),

  group: (match: $(slot("expr*"))$),
  pow: (match: $slot("base")^slot("exp")$),

  union: (infix: $union$, prec: 1),
  inter: (infix: $inter$, prec: 1),

  frac: math.frac,
  abs: math.abs,
  norm: math.norm,
  root: math.root,

  op-call: (match: $op(slot("op"))(slot("args*"))$),
  op: math.op,
)
