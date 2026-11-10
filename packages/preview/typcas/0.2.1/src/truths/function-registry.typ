// =========================================================================
// typcas v2 Function Registry
// =========================================================================
// Single source for parse/display/eval/calculus metadata of named functions.
//
// Optional internal metadata (truth-driven analyzers):
// - analysis.always-positive: function output is > 0 (real domain)
// - analysis.nonnegative: function output is >= 0 (real domain)
// - hints.by-parts-x(v): antiderivative hint for ∫ x*f(x) dx
// - hints.direct-integral-var(v): direct antiderivative hint for ∫ f(v) dv
// =========================================================================

#import "../expr.typ": *

#let _restriction(lhs, rel, rhs, source, stage, note) = (
  lhs: lhs,
  rel: rel,
  rhs: rhs,
  source: source,
  stage: stage,
  note: note,
)

#let _render-args(args) = {
  if args.len() == 0 { return [] }
  let out = args.at(0)
  for i in range(1, args.len()) {
    out = $#out, #args.at(i)$
  }
  out
}

#let _render-op(name, args) = {
  if args.len() == 0 { return $op(#name)$ }
  $op(#name) lr((#_render-args(args)))$
}

#let _safe-softplus(a) = {
  if a > 35 { return a }
  if a < -35 { return calc.exp(a) }
  calc.ln(1.0 + calc.exp(a))
}

#let _safe-sigmoid(a) = {
  if a >= 0 {
    let z = calc.exp(-a)
    return 1.0 / (1.0 + z)
  }
  let z = calc.exp(a)
  z / (1.0 + z)
}

#let _eval-sinh(a) = (calc.exp(a) - calc.exp(-a)) / 2.0
#let _eval-cosh(a) = (calc.exp(a) + calc.exp(-a)) / 2.0
#let _eval-trunc(a) = if a >= 0 { calc.floor(a) } else { calc.ceil(a) }
#let _eval-tanh(a) = {
  let ep = calc.exp(a)
  let em = calc.exp(-a)
  let den = ep + em
  if den == 0 { return none }
  (ep - em) / den
}
#let _eval-min(args) = {
  if args.len() < 2 { return none }
  let best = args.at(0)
  for i in range(1, args.len()) {
    if args.at(i) < best { best = args.at(i) }
  }
  best
}
#let _eval-max(args) = {
  if args.len() < 2 { return none }
  let best = args.at(0)
  for i in range(1, args.len()) {
    if args.at(i) > best { best = args.at(i) }
  }
  best
}

#let fn-registry = (
  sin: (
    name: "sin", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $sin(#args.at(0))$),
    eval: args => calc.sin(args.at(0)),
    hints: (
      by-parts-x: v => add(neg(mul(cvar(v), cos-of(cvar(v)))), sin-of(cvar(v))),
      direct-integral-var: none,
    ),
    calculus: (diff: u => cos-of(u), integ: u => neg(cos-of(u)), diff-step: "d/dx sin(@) = cos(@)·@'", domain-note: none),
  ),
  cos: (
    name: "cos", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $cos(#args.at(0))$),
    eval: args => calc.cos(args.at(0)),
    hints: (
      by-parts-x: v => add(mul(cvar(v), sin-of(cvar(v))), cos-of(cvar(v))),
      direct-integral-var: none,
    ),
    calculus: (diff: u => neg(sin-of(u)), integ: u => sin-of(u), diff-step: "d/dx cos(@) = -sin(@)·@'", domain-note: none),
  ),
  tan: (
    name: "tan", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $tan(#args.at(0))$),
    eval: args => calc.tan(args.at(0)),
    restrictions: (
      defined: args => (_restriction(cos-of(args.at(0)), "!=", num(0), "fn:tan", "defined", "tan(u) undefined when cos(u)=0."),),
      diff: args => (_restriction(cos-of(args.at(0)), "!=", num(0), "fn:tan", "diff", "Derivative form assumes cos(u) != 0."),),
      integ: args => (_restriction(cos-of(args.at(0)), "!=", num(0), "fn:tan", "integ", "Antiderivative form assumes cos(u) != 0."),),
    ),
    calculus: (diff: u => cdiv(num(1), pow(cos-of(u), num(2))), integ: u => neg(ln-of(abs-of(cos-of(u)))), diff-step: "d/dx tan(@) = sec²(@)·@'", domain-note: none),
  ),
  csc: (
    name: "csc", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $csc(#args.at(0))$),
    eval: args => {
      let s = calc.sin(args.at(0))
      if s == 0 { return none }
      1.0 / s
    },
    restrictions: (
      defined: args => (_restriction(sin-of(args.at(0)), "!=", num(0), "fn:csc", "defined", "csc(u) undefined when sin(u)=0."),),
      diff: args => (_restriction(sin-of(args.at(0)), "!=", num(0), "fn:csc", "diff", "Derivative form assumes sin(u) != 0."),),
      integ: args => (_restriction(sin-of(args.at(0)), "!=", num(0), "fn:csc", "integ", "Antiderivative form assumes sin(u) != 0."),),
    ),
    calculus: (diff: u => neg(mul(csc-of(u), cot-of(u))), integ: u => neg(ln-of(abs-of(add(csc-of(u), cot-of(u))))), diff-step: "d/dx csc(@) = -csc(@)cot(@)·@'", domain-note: none),
  ),
  sec: (
    name: "sec", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $sec(#args.at(0))$),
    eval: args => {
      let c = calc.cos(args.at(0))
      if c == 0 { return none }
      1.0 / c
    },
    restrictions: (
      defined: args => (_restriction(cos-of(args.at(0)), "!=", num(0), "fn:sec", "defined", "sec(u) undefined when cos(u)=0."),),
      diff: args => (_restriction(cos-of(args.at(0)), "!=", num(0), "fn:sec", "diff", "Derivative form assumes cos(u) != 0."),),
      integ: args => (_restriction(cos-of(args.at(0)), "!=", num(0), "fn:sec", "integ", "Antiderivative form assumes cos(u) != 0."),),
    ),
    calculus: (diff: u => mul(sec-of(u), tan-of(u)), integ: u => ln-of(abs-of(add(sec-of(u), tan-of(u)))), diff-step: "d/dx sec(@)=sec(@)tan(@)·@'", domain-note: none),
  ),
  cot: (
    name: "cot", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $cot(#args.at(0))$),
    eval: args => {
      let s = calc.sin(args.at(0))
      if s == 0 { return none }
      calc.cos(args.at(0)) / s
    },
    restrictions: (
      defined: args => (_restriction(sin-of(args.at(0)), "!=", num(0), "fn:cot", "defined", "cot(u) undefined when sin(u)=0."),),
      diff: args => (_restriction(sin-of(args.at(0)), "!=", num(0), "fn:cot", "diff", "Derivative form assumes sin(u) != 0."),),
      integ: args => (_restriction(sin-of(args.at(0)), "!=", num(0), "fn:cot", "integ", "Antiderivative form assumes sin(u) != 0."),),
    ),
    calculus: (diff: u => neg(cdiv(num(1), pow(sin-of(u), num(2)))), integ: u => ln-of(abs-of(sin-of(u))), diff-step: "d/dx cot(@)=-csc²(@)·@'", domain-note: none),
  ),

  arcsin: (
    name: "arcsin", aliases: ("asin",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $arcsin(#args.at(0))$),
    eval: args => {
      let a = args.at(0)
      if a < -1 or a > 1 { return none }
      calc.asin(a)
    },
    restrictions: (
      defined: args => (
        _restriction(args.at(0), ">=", num(-1), "fn:arcsin", "defined", "arcsin real-domain: -1 <= u <= 1."),
        _restriction(args.at(0), "<=", num(1), "fn:arcsin", "defined", "arcsin real-domain: -1 <= u <= 1."),
      ),
      diff: args => (
        _restriction(args.at(0), ">", num(-1), "fn:arcsin", "diff", "Derivative real-domain: -1 < u < 1."),
        _restriction(args.at(0), "<", num(1), "fn:arcsin", "diff", "Derivative real-domain: -1 < u < 1."),
      ),
      integ: args => (),
    ),
    calculus: (diff: u => cdiv(num(1), sqrt-of(sub(num(1), pow(u, num(2))))), integ: none, diff-step: "d/dx arcsin(@)=@'/sqrt(1-@²)", domain-note: "Real-domain derivative requires -1 < @ < 1."),
  ),
  arccos: (
    name: "arccos", aliases: ("acos",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $arccos(#args.at(0))$),
    eval: args => {
      let a = args.at(0)
      if a < -1 or a > 1 { return none }
      calc.acos(a)
    },
    restrictions: (
      defined: args => (
        _restriction(args.at(0), ">=", num(-1), "fn:arccos", "defined", "arccos real-domain: -1 <= u <= 1."),
        _restriction(args.at(0), "<=", num(1), "fn:arccos", "defined", "arccos real-domain: -1 <= u <= 1."),
      ),
      diff: args => (
        _restriction(args.at(0), ">", num(-1), "fn:arccos", "diff", "Derivative real-domain: -1 < u < 1."),
        _restriction(args.at(0), "<", num(1), "fn:arccos", "diff", "Derivative real-domain: -1 < u < 1."),
      ),
      integ: args => (),
    ),
    calculus: (diff: u => neg(cdiv(num(1), sqrt-of(sub(num(1), pow(u, num(2)))))), integ: none, diff-step: "d/dx arccos(@)=-@'/sqrt(1-@²)", domain-note: "Real-domain derivative requires -1 < @ < 1."),
  ),
  arctan: (
    name: "arctan", aliases: ("atan",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $arctan(#args.at(0))$),
    eval: args => calc.atan(args.at(0)),
    calculus: (diff: u => cdiv(num(1), add(num(1), pow(u, num(2)))), integ: none, diff-step: "d/dx arctan(@)=@'/(1+@²)", domain-note: none),
  ),
  arccsc: (
    name: "arccsc", aliases: ("acsc",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arccsc", args)),
    eval: args => {
      let a = args.at(0)
      if a == 0 or calc.abs(a) < 1 { return none }
      calc.asin(1.0 / a)
    },
    restrictions: (
      defined: args => (_restriction(abs-of(args.at(0)), ">=", num(1), "fn:arccsc", "defined", "arccsc real-domain: |u|>=1."),),
      diff: args => (_restriction(abs-of(args.at(0)), ">", num(1), "fn:arccsc", "diff", "Derivative real-domain: |u|>1."),),
      integ: args => (),
    ),
    calculus: (diff: u => neg(cdiv(num(1), mul(abs-of(u), sqrt-of(sub(pow(u, num(2)), num(1)))))), integ: none, diff-step: "d/dx arccsc(@)=-@'/(|@|sqrt(@²-1))", domain-note: "Real-domain derivative requires |@| > 1."),
  ),
  arcsec: (
    name: "arcsec", aliases: ("asec",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arcsec", args)),
    eval: args => {
      let a = args.at(0)
      if a == 0 or calc.abs(a) < 1 { return none }
      calc.acos(1.0 / a)
    },
    restrictions: (
      defined: args => (_restriction(abs-of(args.at(0)), ">=", num(1), "fn:arcsec", "defined", "arcsec real-domain: |u|>=1."),),
      diff: args => (_restriction(abs-of(args.at(0)), ">", num(1), "fn:arcsec", "diff", "Derivative real-domain: |u|>1."),),
      integ: args => (),
    ),
    calculus: (diff: u => cdiv(num(1), mul(abs-of(u), sqrt-of(sub(pow(u, num(2)), num(1))))), integ: none, diff-step: "d/dx arcsec(@)=@'/(|@|sqrt(@²-1))", domain-note: "Real-domain derivative requires |@| > 1."),
  ),
  arccot: (
    name: "arccot", aliases: ("acot",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arccot", args)),
    eval: args => {
      let a = args.at(0)
      if a == 0 { return calc.pi / 2.0 }
      calc.atan(1.0 / a)
    },
    calculus: (diff: u => neg(cdiv(num(1), add(num(1), pow(u, num(2))))), integ: none, diff-step: "d/dx arccot(@)=-@'/(1+@²)", domain-note: none),
  ),

  sinh: (
    name: "sinh", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $sinh(#args.at(0))$),
    eval: args => _eval-sinh(args.at(0)),
    calculus: (diff: u => cosh-of(u), integ: u => cosh-of(u), diff-step: "d/dx sinh(@)=cosh(@)·@'", domain-note: none),
  ),
  cosh: (
    name: "cosh", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $cosh(#args.at(0))$),
    eval: args => _eval-cosh(args.at(0)),
    calculus: (diff: u => sinh-of(u), integ: u => sinh-of(u), diff-step: "d/dx cosh(@)=sinh(@)·@'", domain-note: none),
  ),
  tanh: (
    name: "tanh", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $tanh(#args.at(0))$),
    eval: args => _eval-tanh(args.at(0)),
    calculus: (diff: u => cdiv(num(1), pow(cosh-of(u), num(2))), integ: u => ln-of(cosh-of(u)), diff-step: "d/dx tanh(@)=sech²(@)·@'", domain-note: none),
  ),
  csch: (
    name: "csch", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("csch", args)),
    eval: args => {
      let den = calc.exp(args.at(0)) - calc.exp(-args.at(0))
      if den == 0 { return none }
      2.0 / den
    },
    restrictions: (
      defined: args => (_restriction(sinh-of(args.at(0)), "!=", num(0), "fn:csch", "defined", "csch(u) undefined when sinh(u)=0."),),
      diff: args => (_restriction(sinh-of(args.at(0)), "!=", num(0), "fn:csch", "diff", "Derivative form assumes sinh(u) != 0."),),
      integ: args => (_restriction(sinh-of(args.at(0)), "!=", num(0), "fn:csch", "integ", "Antiderivative form assumes sinh(u) != 0."),),
    ),
    calculus: (diff: u => neg(mul(csch-of(u), coth-of(u))), integ: u => ln-of(abs-of(tanh-of(cdiv(u, num(2))))), diff-step: "d/dx csch(@)=-csch(@)coth(@)·@'", domain-note: none),
  ),
  sech: (
    name: "sech", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("sech", args)),
    eval: args => {
      let den = calc.exp(args.at(0)) + calc.exp(-args.at(0))
      if den == 0 { return none }
      2.0 / den
    },
    calculus: (diff: u => neg(mul(sech-of(u), tanh-of(u))), integ: u => mul(num(2), arctan-of(tanh-of(cdiv(u, num(2))))), diff-step: "d/dx sech(@)=-sech(@)tanh(@)·@'", domain-note: none),
  ),
  coth: (
    name: "coth", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("coth", args)),
    eval: args => {
      let ep = calc.exp(args.at(0))
      let em = calc.exp(-args.at(0))
      let den = ep - em
      if den == 0 { return none }
      (ep + em) / den
    },
    restrictions: (
      defined: args => (_restriction(sinh-of(args.at(0)), "!=", num(0), "fn:coth", "defined", "coth(u) undefined when sinh(u)=0."),),
      diff: args => (_restriction(sinh-of(args.at(0)), "!=", num(0), "fn:coth", "diff", "Derivative form assumes sinh(u) != 0."),),
      integ: args => (_restriction(sinh-of(args.at(0)), "!=", num(0), "fn:coth", "integ", "Antiderivative form assumes sinh(u) != 0."),),
    ),
    calculus: (diff: u => neg(pow(csch-of(u), num(2))), integ: u => ln-of(abs-of(sinh-of(u))), diff-step: "d/dx coth(@)=-csch²(@)·@'", domain-note: none),
  ),

  arcsinh: (
    name: "arcsinh", aliases: ("asinh",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arcsinh", args)),
    eval: args => calc.ln(args.at(0) + calc.sqrt(args.at(0) * args.at(0) + 1.0)),
    calculus: (diff: u => cdiv(num(1), sqrt-of(add(pow(u, num(2)), num(1)))), integ: none, diff-step: "d/dx arcsinh(@)=@'/sqrt(@²+1)", domain-note: none),
  ),
  arccosh: (
    name: "arccosh", aliases: ("acosh",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arccosh", args)),
    eval: args => {
      let a = args.at(0)
      if a < 1 { return none }
      calc.ln(a + calc.sqrt(a * a - 1.0))
    },
    restrictions: (
      defined: args => (_restriction(args.at(0), ">=", num(1), "fn:arccosh", "defined", "arccosh real-domain: u>=1."),),
      diff: args => (_restriction(args.at(0), ">", num(1), "fn:arccosh", "diff", "Derivative real-domain: u>1."),),
      integ: args => (),
    ),
    calculus: (diff: u => cdiv(num(1), sqrt-of(sub(pow(u, num(2)), num(1)))), integ: none, diff-step: "d/dx arccosh(@)=@'/sqrt(@²-1)", domain-note: "Real-domain derivative requires @ > 1."),
  ),
  arctanh: (
    name: "arctanh", aliases: ("atanh",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arctanh", args)),
    eval: args => {
      let a = args.at(0)
      if a <= -1 or a >= 1 { return none }
      0.5 * calc.ln((1.0 + a) / (1.0 - a))
    },
    restrictions: (
      defined: args => (_restriction(abs-of(args.at(0)), "<", num(1), "fn:arctanh", "defined", "arctanh real-domain: |u|<1."),),
      diff: args => (_restriction(abs-of(args.at(0)), "<", num(1), "fn:arctanh", "diff", "Derivative real-domain: |u|<1."),),
      integ: args => (),
    ),
    calculus: (diff: u => cdiv(num(1), sub(num(1), pow(u, num(2)))), integ: none, diff-step: "d/dx arctanh(@)=@'/(1-@²)", domain-note: "Real-domain derivative requires |@| < 1."),
  ),
  arccsch: (
    name: "arccsch", aliases: ("acsch",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arccsch", args)),
    eval: args => {
      let a = args.at(0)
      if a == 0 { return none }
      calc.ln(1.0 / a + calc.sqrt(1.0 / (a * a) + 1.0))
    },
    restrictions: (
      defined: args => (_restriction(args.at(0), "!=", num(0), "fn:arccsch", "defined", "arccsch real-domain: u != 0."),),
      diff: args => (_restriction(args.at(0), "!=", num(0), "fn:arccsch", "diff", "Derivative form assumes u != 0."),),
      integ: args => (),
    ),
    calculus: (diff: u => neg(cdiv(num(1), mul(u, sqrt-of(add(pow(u, num(2)), num(1)))))), integ: none, diff-step: "d/dx arccsch(@)=-@'/(@sqrt(@²+1))", domain-note: none),
  ),
  arcsech: (
    name: "arcsech", aliases: ("asech",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arcsech", args)),
    eval: args => {
      let a = args.at(0)
      if a <= 0 or a > 1 { return none }
      calc.ln(1.0 / a + calc.sqrt(1.0 / (a * a) - 1.0))
    },
    restrictions: (
      defined: args => (
        _restriction(args.at(0), ">", num(0), "fn:arcsech", "defined", "arcsech real-domain: 0 < u <= 1."),
        _restriction(args.at(0), "<=", num(1), "fn:arcsech", "defined", "arcsech real-domain: 0 < u <= 1."),
      ),
      diff: args => (
        _restriction(args.at(0), ">", num(0), "fn:arcsech", "diff", "Derivative real-domain: 0 < u < 1."),
        _restriction(args.at(0), "<", num(1), "fn:arcsech", "diff", "Derivative real-domain: 0 < u < 1."),
      ),
      integ: args => (),
    ),
    calculus: (diff: u => neg(cdiv(num(1), mul(u, sqrt-of(sub(num(1), pow(u, num(2))))))), integ: none, diff-step: "d/dx arcsech(@)=-@'/(@sqrt(1-@²))", domain-note: none),
  ),
  arccoth: (
    name: "arccoth", aliases: ("acoth",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arccoth", args)),
    eval: args => {
      let a = args.at(0)
      if calc.abs(a) <= 1 { return none }
      0.5 * calc.ln((a + 1.0) / (a - 1.0))
    },
    restrictions: (
      defined: args => (_restriction(abs-of(args.at(0)), ">", num(1), "fn:arccoth", "defined", "arccoth real-domain: |u|>1."),),
      diff: args => (_restriction(abs-of(args.at(0)), ">", num(1), "fn:arccoth", "diff", "Derivative real-domain: |u|>1."),),
      integ: args => (),
    ),
    calculus: (diff: u => cdiv(num(1), sub(num(1), pow(u, num(2)))), integ: none, diff-step: "d/dx arccoth(@)=@'/(1-@²)", domain-note: "Real-domain derivative requires |@| > 1."),
  ),

  ln: (
    name: "ln", aliases: ("log",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $ln(#args.at(0))$),
    eval: args => {
      let a = args.at(0)
      if a <= 0 { return none }
      calc.ln(a)
    },
    restrictions: (
      defined: args => (_restriction(args.at(0), ">", num(0), "fn:ln", "defined", "ln(u) requires u > 0."),),
      diff: args => (_restriction(args.at(0), ">", num(0), "fn:ln", "diff", "Derivative form assumes u > 0."),),
      integ: args => (),
    ),
    hints: (
      by-parts-x: none,
      direct-integral-var: v => sub(mul(cvar(v), ln-of(cvar(v))), cvar(v)),
    ),
    calculus: (diff: u => cdiv(num(1), u), integ: none, diff-step: "d/dx ln(@)=@'/@", domain-note: "Real-domain derivative requires @ > 0."),
  ),
  exp: (
    name: "exp", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $e^(#args.at(0))$),
    eval: args => calc.exp(args.at(0)),
    analysis: (always-positive: true, nonnegative: true),
    hints: (
      by-parts-x: v => sub(mul(cvar(v), exp-of(cvar(v))), exp-of(cvar(v))),
      direct-integral-var: none,
    ),
    calculus: (diff: u => exp-of(u), integ: u => exp-of(u), diff-step: "d/dx e^@ = e^@·@'", domain-note: none),
  ),
  log2: (
    name: "log2", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $log_(2) lr((#args.at(0)))$),
    eval: args => {
      let a = args.at(0)
      if a <= 0 { return none }
      calc.ln(a) / calc.ln(2.0)
    },
    restrictions: (
      defined: args => (_restriction(args.at(0), ">", num(0), "fn:log2", "defined", "log2(u) requires u > 0."),),
      diff: args => (_restriction(args.at(0), ">", num(0), "fn:log2", "diff", "Derivative form assumes u > 0."),),
      integ: args => (),
    ),
    calculus: (diff: u => cdiv(num(1), mul(u, ln-of(num(2)))), integ: none, diff-step: "d/dx log2(@)=@'/( @ ln 2 )", domain-note: "Real-domain derivative requires @ > 0."),
  ),
  log10: (
    name: "log10", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $log_(10) lr((#args.at(0)))$),
    eval: args => {
      let a = args.at(0)
      if a <= 0 { return none }
      calc.ln(a) / calc.ln(10.0)
    },
    restrictions: (
      defined: args => (_restriction(args.at(0), ">", num(0), "fn:log10", "defined", "log10(u) requires u > 0."),),
      diff: args => (_restriction(args.at(0), ">", num(0), "fn:log10", "diff", "Derivative form assumes u > 0."),),
      integ: args => (),
    ),
    calculus: (diff: u => cdiv(num(1), mul(u, ln-of(num(10)))), integ: none, diff-step: "d/dx log10(@)=@'/( @ ln 10 )", domain-note: "Real-domain derivative requires @ > 0."),
  ),
  log1p: (
    name: "log1p", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("log1p", args)),
    eval: args => {
      let a = args.at(0)
      if a <= -1 { return none }
      calc.ln(1.0 + a)
    },
    restrictions: (
      defined: args => (_restriction(args.at(0), ">", num(-1), "fn:log1p", "defined", "log1p(u) requires u > -1."),),
      diff: args => (_restriction(args.at(0), ">", num(-1), "fn:log1p", "diff", "Derivative form assumes u > -1."),),
      integ: args => (),
    ),
    calculus: (diff: u => cdiv(num(1), add(num(1), u)), integ: none, diff-step: "d/dx log1p(@)=@'/(1+@)", domain-note: "Real-domain derivative requires @ > -1."),
  ),
  expm1: (
    name: "expm1", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("expm1", args)),
    eval: args => calc.exp(args.at(0)) - 1.0,
    calculus: (diff: u => exp-of(u), integ: u => sub(exp-of(u), u), diff-step: "d/dx expm1(@)=e^@·@'", domain-note: none),
  ),
  cbrt: (
    name: "cbrt", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $root(3, #args.at(0))$),
    eval: args => {
      let a = args.at(0)
      if a < 0 { return -calc.pow(-a, 1.0 / 3.0) }
      calc.pow(a, 1.0 / 3.0)
    },
    calculus: (diff: u => cdiv(num(1), mul(num(3), pow(func("cbrt", u), num(2)))), integ: none, diff-step: "d/dx cbrt(@)=@'/(3 cbrt(@)^2)", domain-note: none),
  ),
  sinc: (
    name: "sinc", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("sinc", args)),
    eval: args => {
      let a = args.at(0)
      if calc.abs(a) < 1e-12 { return 1.0 }
      calc.sin(a) / a
    },
    calculus: (diff: u => cdiv(sub(mul(u, cos-of(u)), sin-of(u)), pow(u, num(2))), integ: none, diff-step: "d/dx sinc(@)=((@cos(@)-sin(@))/@²)·@'", domain-note: "Symbolic form assumes @ != 0 (continuous extension at 0 is 1)."),
  ),
  softplus: (
    name: "softplus", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("softplus", args)),
    eval: args => _safe-softplus(args.at(0)),
    calculus: (diff: u => func("sigmoid", u), integ: none, diff-step: "d/dx softplus(@)=sigmoid(@)·@'", domain-note: none),
  ),
  sigmoid: (
    name: "sigmoid", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("sigmoid", args)),
    eval: args => _safe-sigmoid(args.at(0)),
    calculus: (diff: u => mul(func("sigmoid", u), sub(num(1), func("sigmoid", u))), integ: none, diff-step: "d/dx sigmoid(@)=sigmoid(@)(1-sigmoid(@))·@'", domain-note: none),
  ),
  abs: (
    name: "abs", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $lr(|#args.at(0)|)$),
    eval: args => calc.abs(args.at(0)),
    analysis: (always-positive: false, nonnegative: true),
    restrictions: (
      defined: args => (),
      diff: args => (_restriction(args.at(0), "!=", num(0), "fn:abs", "diff", "d|u|/dx undefined at u=0."),),
      integ: args => (),
    ),
    calculus: (diff: u => cdiv(u, abs-of(u)), integ: none, diff-step: "d/dx |@|=@/|@|·@'", domain-note: "Derivative undefined at @ = 0."),
  ),
  sign: (
    name: "sign", aliases: ("sgn",), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("sign", args)),
    eval: args => {
      let a = args.at(0)
      if a > 0 { return 1 }
      if a < 0 { return -1 }
      0
    },
    calculus: (diff: none, integ: none, diff-step: none, domain-note: none),
  ),
  floor: (
    name: "floor", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("floor", args)),
    eval: args => calc.floor(args.at(0)),
    calculus: (diff: none, integ: none, diff-step: none, domain-note: none),
  ),
  ceil: (
    name: "ceil", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("ceil", args)),
    eval: args => calc.ceil(args.at(0)),
    calculus: (diff: none, integ: none, diff-step: none, domain-note: none),
  ),
  round: (
    name: "round", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("round", args)),
    eval: args => calc.round(args.at(0)),
    calculus: (diff: none, integ: none, diff-step: none, domain-note: none),
  ),
  trunc: (
    name: "trunc", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("trunc", args)),
    eval: args => _eval-trunc(args.at(0)),
    calculus: (diff: none, integ: none, diff-step: none, domain-note: none),
  ),
  fracpart: (
    name: "fracpart", aliases: (), arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("fracpart", args)),
    eval: args => {
      let a = args.at(0)
      a - _eval-trunc(a)
    },
    calculus: (diff: none, integ: none, diff-step: none, domain-note: none),
  ),
  min: (
    name: "min", aliases: (), arity: "variadic", min-arity: 2,
    parse: (allow-implicit: false, allow-power-prefix: false),
    display: (render: args => _render-op("min", args)),
    eval: args => _eval-min(args),
    calculus: (diff: none, integ: none, diff-step: none, domain-note: none),
  ),
  max: (
    name: "max", aliases: (), arity: "variadic", min-arity: 2,
    parse: (allow-implicit: false, allow-power-prefix: false),
    display: (render: args => _render-op("max", args)),
    eval: args => _eval-max(args),
    calculus: (diff: none, integ: none, diff-step: none, domain-note: none),
  ),
  clamp: (
    name: "clamp", aliases: (), arity: 3,
    parse: (allow-implicit: false, allow-power-prefix: false),
    display: (render: args => _render-op("clamp", args)),
    eval: args => {
      let x = args.at(0)
      let lo = args.at(1)
      let hi = args.at(2)
      if lo > hi { return none }
      if x < lo { return lo }
      if x > hi { return hi }
      x
    },
    restrictions: (
      defined: args => (_restriction(args.at(1), "<=", args.at(2), "fn:clamp", "defined", "clamp(x, lo, hi) requires lo <= hi."),),
      diff: args => (),
      integ: args => (),
    ),
    calculus: (diff: none, integ: none, diff-step: none, domain-note: none),
  ),
  hypot2: (
    name: "hypot2", aliases: (), arity: 2,
    parse: (allow-implicit: false, allow-power-prefix: false),
    display: (render: args => _render-op("hypot2", args)),
    eval: args => calc.sqrt(args.at(0) * args.at(0) + args.at(1) * args.at(1)),
    calculus: (diff: none, integ: none, diff-step: none, domain-note: none),
  ),
)

#let fn-alias-map = {
  let out = (:)
  for name in fn-registry.keys() {
    let spec = fn-registry.at(name)
    out.insert(name, name)
    for a in spec.aliases {
      out.insert(a, name)
    }
  }
  out
}

#let fn-canonical(name) = fn-alias-map.at(name, default: none)

#let fn-spec(name) = {
  let c = fn-canonical(name)
  if c == none { return none }
  fn-registry.at(c, default: none)
}

#let fn-arity-min(spec) = {
  if spec == none { return none }
  if type(spec.arity) == int { return spec.arity }
  if type(spec.arity) == str and spec.arity == "variadic" {
    return spec.at("min-arity", default: 0)
  }
  none
}

#let fn-arity-ok(spec, argc) = {
  if spec == none { return false }
  if type(spec.arity) == int { return spec.arity == argc }
  if type(spec.arity) == str and spec.arity == "variadic" {
    let minc = fn-arity-min(spec)
    return argc >= minc
  }
  false
}

#let fn-known-names = {
  let out = ()
  for name in fn-alias-map.keys() { out.push(name) }
  out
}

#let fn-calc-rules = {
  let out = (:)
  for name in fn-registry.keys() {
    let spec = fn-registry.at(name)
    if spec.arity != 1 { continue }
    let c = spec.calculus
    if c == none or c.diff == none { continue }
    let rule = (diff: c.diff, integ: c.integ, diff-step: c.diff-step, domain-note: c.domain-note)
    out.insert(name, rule)
    for a in spec.aliases {
      out.insert(a, rule)
    }
  }
  out
}

#let fn-square-power-integral-rules = (
  sec: (antideriv: u => tan-of(u), rule: "∫sec²(u)dx = tan(u)/u'"),
  csc: (antideriv: u => neg(cot-of(u)), rule: "∫csc²(u)dx = -cot(u)/u'"),
  sech: (antideriv: u => tanh-of(u), rule: "∫sech²(u)dx = tanh(u)/u'"),
  csch: (antideriv: u => neg(coth-of(u)), rule: "∫csch²(u)dx = -coth(u)/u'"),
)

#let fn-square-power-integral-spec(name) = {
  let c = fn-canonical(name)
  if c == none { return none }
  fn-square-power-integral-rules.at(c, default: none)
}
