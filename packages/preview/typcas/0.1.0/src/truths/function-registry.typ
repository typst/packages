// =========================================================================
// CAS Function Registry
// =========================================================================
// Canonical single source of truth for named function behavior.
//
// Each canonical entry includes:
//   - name: canonical function name
//   - aliases: accepted alias names
//   - arity: integer argument count or "variadic"
//   - parse: parser behavior flags
//       - allow-implicit: allow f x syntax
//       - allow-power-prefix: allow f^n x syntax
//   - display: rendering behavior
//       - render: closure args(content tuple) -> Typst math content
//   - eval: closure args(number tuple) -> number | none
//   - calculus: unary calculus metadata
//       - diff: closure u -> outer derivative
//       - integ: closure u -> antiderivative or none
//       - diff-step: step text
//       - domain-note: optional note text
// =========================================================================

#import "../expr.typ": *

/// Internal helper `_render-op`.
#let _render-op(name, args) = {
  if args.len() == 0 { return $op(#name)$ }
  if args.len() == 1 { return $op(#name) lr((#args.at(0)))$ }
  if args.len() == 2 { return $op(#name) lr((#args.at(0), #args.at(1)))$ }
  let body = args.at(0)
  let i = 1
  while i < args.len() {
    body = $#body, #args.at(i)$
    i += 1
  }
  $op(#name) lr((#body))$
}

/// Internal helper `_safe-softplus`.
#let _safe-softplus(a) = {
  if a > 35 { return a }
  if a < -35 { return calc.exp(a) }
  calc.ln(1.0 + calc.exp(a))
}

/// Internal helper `_safe-sigmoid`.
#let _safe-sigmoid(a) = {
  if a >= 0 {
    let z = calc.exp(-a)
    return 1.0 / (1.0 + z)
  }
  let z = calc.exp(a)
  z / (1.0 + z)
}

/// Internal helper `_eval-sinh`.
#let _eval-sinh(a) = (calc.exp(a) - calc.exp(-a)) / 2.0
/// Internal helper `_eval-cosh`.
#let _eval-cosh(a) = (calc.exp(a) + calc.exp(-a)) / 2.0
/// Internal helper `_eval-tanh`.
#let _eval-tanh(a) = {
  let ep = calc.exp(a)
  let em = calc.exp(-a)
  let den = ep + em
  if den == 0 { return none }
  (ep - em) / den
}

/// Public helper `fn-registry`.
#let fn-registry = (
  // --- Basic Trig ---
  sin: (
    name: "sin",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $sin(#args.at(0))$),
    eval: args => calc.sin(args.at(0)),
    calculus: (
      diff: u => cos-of(u),
      integ: u => neg(cos-of(u)),
      diff-step: "d/dx sin(@) = cos(@) · @'",
      domain-note: none,
    ),
  ),
  cos: (
    name: "cos",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $cos(#args.at(0))$),
    eval: args => calc.cos(args.at(0)),
    calculus: (
      diff: u => neg(sin-of(u)),
      integ: u => sin-of(u),
      diff-step: "d/dx cos(@) = -sin(@) · @'",
      domain-note: none,
    ),
  ),
  tan: (
    name: "tan",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $tan(#args.at(0))$),
    eval: args => calc.tan(args.at(0)),
    calculus: (
      diff: u => cdiv(num(1), pow(cos-of(u), num(2))),
      integ: u => neg(ln-of(abs-of(cos-of(u)))),
      diff-step: "d/dx tan(@) = sec²(@) · @'",
      domain-note: none,
    ),
  ),
  csc: (
    name: "csc",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $csc(#args.at(0))$),
    eval: args => {
      let a = args.at(0)
      let s = calc.sin(a)
      if s == 0 { return none }
      1.0 / s
    },
    calculus: (
      diff: u => neg(mul(csc-of(u), cot-of(u))),
      integ: u => neg(ln-of(abs-of(add(csc-of(u), cot-of(u))))),
      diff-step: "d/dx csc(@) = -csc(@)cot(@) · @'",
      domain-note: none,
    ),
  ),
  sec: (
    name: "sec",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $sec(#args.at(0))$),
    eval: args => {
      let a = args.at(0)
      let c = calc.cos(a)
      if c == 0 { return none }
      1.0 / c
    },
    calculus: (
      diff: u => mul(sec-of(u), tan-of(u)),
      integ: u => ln-of(abs-of(add(sec-of(u), tan-of(u)))),
      diff-step: "d/dx sec(@) = sec(@)tan(@) · @'",
      domain-note: none,
    ),
  ),
  cot: (
    name: "cot",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $cot(#args.at(0))$),
    eval: args => {
      let a = args.at(0)
      let s = calc.sin(a)
      if s == 0 { return none }
      calc.cos(a) / s
    },
    calculus: (
      diff: u => neg(cdiv(num(1), pow(sin-of(u), num(2)))),
      integ: u => ln-of(abs-of(sin-of(u))),
      diff-step: "d/dx cot(@) = -csc²(@) · @'",
      domain-note: none,
    ),
  ),
  // --- Inverse Trig ---
  arcsin: (
    name: "arcsin",
    aliases: ("asin",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $arcsin(#args.at(0))$),
    eval: args => {
      let a = args.at(0)
      if a < -1 or a > 1 { return none }
      calc.asin(a)
    },
    calculus: (
      diff: u => cdiv(num(1), sqrt-of(sub(num(1), pow(u, num(2))))),
      integ: none,
      diff-step: "d/dx arcsin(@) = @'/√(1-@²)",
      domain-note: "Real-domain derivative requires -1 < @ < 1.",
    ),
  ),
  arccos: (
    name: "arccos",
    aliases: ("acos",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $arccos(#args.at(0))$),
    eval: args => {
      let a = args.at(0)
      if a < -1 or a > 1 { return none }
      calc.acos(a)
    },
    calculus: (
      diff: u => neg(cdiv(num(1), sqrt-of(sub(num(1), pow(u, num(2)))))),
      integ: none,
      diff-step: "d/dx arccos(@) = -@'/√(1-@²)",
      domain-note: "Real-domain derivative requires -1 < @ < 1.",
    ),
  ),
  arctan: (
    name: "arctan",
    aliases: ("atan",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $arctan(#args.at(0))$),
    eval: args => calc.atan(args.at(0)),
    calculus: (
      diff: u => cdiv(num(1), add(num(1), pow(u, num(2)))),
      integ: none,
      diff-step: "d/dx arctan(@) = @'/(1+@²)",
      domain-note: none,
    ),
  ),
  arccsc: (
    name: "arccsc",
    aliases: ("acsc",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arccsc", args)),
    eval: args => {
      let a = args.at(0)
      if a == 0 or calc.abs(a) < 1 { return none }
      calc.asin(1.0 / a)
    },
    calculus: (
      diff: u => neg(cdiv(num(1), mul(abs-of(u), sqrt-of(sub(pow(u, num(2)), num(1)))))),
      integ: none,
      diff-step: "d/dx arccsc(@) = -@'/(|@|√(@²-1))",
      domain-note: "Real-domain derivative requires |@| > 1.",
    ),
  ),
  arcsec: (
    name: "arcsec",
    aliases: ("asec",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arcsec", args)),
    eval: args => {
      let a = args.at(0)
      if a == 0 or calc.abs(a) < 1 { return none }
      calc.acos(1.0 / a)
    },
    calculus: (
      diff: u => cdiv(num(1), mul(abs-of(u), sqrt-of(sub(pow(u, num(2)), num(1))))),
      integ: none,
      diff-step: "d/dx arcsec(@) = @'/(|@|√(@²-1))",
      domain-note: "Real-domain derivative requires |@| > 1.",
    ),
  ),
  arccot: (
    name: "arccot",
    aliases: ("acot",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arccot", args)),
    eval: args => {
      let a = args.at(0)
      if a == 0 { return calc.pi / 2.0 }
      calc.atan(1.0 / a)
    },
    calculus: (
      diff: u => neg(cdiv(num(1), add(num(1), pow(u, num(2))))),
      integ: none,
      diff-step: "d/dx arccot(@) = -@'/(1+@²)",
      domain-note: none,
    ),
  ),
  // --- Hyperbolic ---
  sinh: (
    name: "sinh",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $sinh(#args.at(0))$),
    eval: args => _eval-sinh(args.at(0)),
    calculus: (
      diff: u => cosh-of(u),
      integ: u => cosh-of(u),
      diff-step: "d/dx sinh(@) = cosh(@) · @'",
      domain-note: none,
    ),
  ),
  cosh: (
    name: "cosh",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $cosh(#args.at(0))$),
    eval: args => _eval-cosh(args.at(0)),
    calculus: (
      diff: u => sinh-of(u),
      integ: u => sinh-of(u),
      diff-step: "d/dx cosh(@) = sinh(@) · @'",
      domain-note: none,
    ),
  ),
  tanh: (
    name: "tanh",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $tanh(#args.at(0))$),
    eval: args => _eval-tanh(args.at(0)),
    calculus: (
      diff: u => cdiv(num(1), pow(cosh-of(u), num(2))),
      integ: u => ln-of(cosh-of(u)),
      diff-step: "d/dx tanh(@) = sech²(@) · @'",
      domain-note: none,
    ),
  ),
  csch: (
    name: "csch",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("csch", args)),
    eval: args => {
      let a = args.at(0)
      let den = calc.exp(a) - calc.exp(-a)
      if den == 0 { return none }
      2.0 / den
    },
    calculus: (
      diff: u => neg(mul(csch-of(u), coth-of(u))),
      integ: u => ln-of(abs-of(tanh-of(cdiv(u, num(2))))),
      diff-step: "d/dx csch(@) = -csch(@)coth(@) · @'",
      domain-note: none,
    ),
  ),
  sech: (
    name: "sech",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("sech", args)),
    eval: args => {
      let a = args.at(0)
      let den = calc.exp(a) + calc.exp(-a)
      if den == 0 { return none }
      2.0 / den
    },
    calculus: (
      diff: u => neg(mul(sech-of(u), tanh-of(u))),
      integ: u => mul(num(2), arctan-of(tanh-of(cdiv(u, num(2))))),
      diff-step: "d/dx sech(@) = -sech(@)tanh(@) · @'",
      domain-note: none,
    ),
  ),
  coth: (
    name: "coth",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("coth", args)),
    eval: args => {
      let a = args.at(0)
      let ep = calc.exp(a)
      let em = calc.exp(-a)
      let den = ep - em
      if den == 0 { return none }
      (ep + em) / den
    },
    calculus: (
      diff: u => neg(pow(csch-of(u), num(2))),
      integ: u => ln-of(abs-of(sinh-of(u))),
      diff-step: "d/dx coth(@) = -csch²(@) · @'",
      domain-note: none,
    ),
  ),
  // --- Inverse Hyperbolic ---
  arcsinh: (
    name: "arcsinh",
    aliases: ("asinh",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arcsinh", args)),
    eval: args => {
      let a = args.at(0)
      let val = a + calc.sqrt(a * a + 1.0)
      if val <= 0 { return none }
      calc.ln(val)
    },
    calculus: (
      diff: u => cdiv(num(1), sqrt-of(add(pow(u, num(2)), num(1)))),
      integ: none,
      diff-step: "d/dx arcsinh(@) = @'/√(@²+1)",
      domain-note: none,
    ),
  ),
  arccosh: (
    name: "arccosh",
    aliases: ("acosh",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arccosh", args)),
    eval: args => {
      let a = args.at(0)
      if a < 1 { return none }
      let val = a + calc.sqrt(a * a - 1.0)
      if val <= 0 { return none }
      calc.ln(val)
    },
    calculus: (
      diff: u => cdiv(num(1), sqrt-of(sub(pow(u, num(2)), num(1)))),
      integ: none,
      diff-step: "d/dx arccosh(@) = @'/√(@²-1)",
      domain-note: "Real-domain derivative requires @ > 1.",
    ),
  ),
  arctanh: (
    name: "arctanh",
    aliases: ("atanh",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arctanh", args)),
    eval: args => {
      let a = args.at(0)
      if a <= -1 or a >= 1 { return none }
      let arg = (1.0 + a) / (1.0 - a)
      if arg <= 0 { return none }
      0.5 * calc.ln(arg)
    },
    calculus: (
      diff: u => cdiv(num(1), sub(num(1), pow(u, num(2)))),
      integ: none,
      diff-step: "d/dx arctanh(@) = @'/(1-@²)",
      domain-note: "Real-domain derivative requires |@| < 1.",
    ),
  ),
  arccsch: (
    name: "arccsch",
    aliases: ("acsch",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arccsch", args)),
    eval: args => {
      let a = args.at(0)
      if a == 0 { return none }
      let val = 1.0 / a + calc.sqrt(1.0 / (a * a) + 1.0)
      if val <= 0 { return none }
      calc.ln(val)
    },
    calculus: (
      diff: u => neg(cdiv(num(1), mul(u, sqrt-of(add(pow(u, num(2)), num(1)))))),
      integ: none,
      diff-step: "d/dx arccsch(@) = -@'/(@√(@²+1))",
      domain-note: none,
    ),
  ),
  arcsech: (
    name: "arcsech",
    aliases: ("asech",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arcsech", args)),
    eval: args => {
      let a = args.at(0)
      if a <= 0 or a > 1 { return none }
      let val = 1.0 / a + calc.sqrt(1.0 / (a * a) - 1.0)
      if val <= 0 { return none }
      calc.ln(val)
    },
    calculus: (
      diff: u => neg(cdiv(num(1), mul(u, sqrt-of(sub(num(1), pow(u, num(2))))))),
      integ: none,
      diff-step: "d/dx arcsech(@) = -@'/(@√(1-@²))",
      domain-note: none,
    ),
  ),
  arccoth: (
    name: "arccoth",
    aliases: ("acoth",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("arccoth", args)),
    eval: args => {
      let a = args.at(0)
      if calc.abs(a) <= 1 { return none }
      let arg = (a + 1.0) / (a - 1.0)
      if arg <= 0 { return none }
      0.5 * calc.ln(arg)
    },
    calculus: (
      diff: u => cdiv(num(1), sub(num(1), pow(u, num(2)))),
      integ: none,
      diff-step: "d/dx arccoth(@) = @'/(1-@²)",
      domain-note: "Real-domain derivative requires |@| > 1.",
    ),
  ),
  // --- Logarithmic & Exponential ---
  ln: (
    name: "ln",
    aliases: ("log",),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $ln(#args.at(0))$),
    eval: args => {
      let a = args.at(0)
      if a <= 0 { return none }
      calc.ln(a)
    },
    calculus: (
      diff: u => cdiv(num(1), u),
      integ: none,
      diff-step: "d/dx ln(@) = @'/@",
      domain-note: "Real-domain derivative requires @ > 0.",
    ),
  ),
  exp: (
    name: "exp",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $e^(#args.at(0))$),
    eval: args => calc.exp(args.at(0)),
    calculus: (
      diff: u => func("exp", u),
      integ: u => func("exp", u),
      diff-step: "d/dx e^@ = e^@ · @'",
      domain-note: none,
    ),
  ),
  log2: (
    name: "log2",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $log_(2) lr((#args.at(0)))$),
    eval: args => {
      let a = args.at(0)
      if a <= 0 { return none }
      calc.ln(a) / calc.ln(2.0)
    },
    calculus: (
      diff: u => cdiv(num(1), mul(u, ln-of(num(2)))),
      integ: none,
      diff-step: "d/dx log₂(@) = @'/( @ ln 2 )",
      domain-note: "Real-domain derivative requires @ > 0.",
    ),
  ),
  log10: (
    name: "log10",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $log_(10) lr((#args.at(0)))$),
    eval: args => {
      let a = args.at(0)
      if a <= 0 { return none }
      calc.ln(a) / calc.ln(10.0)
    },
    calculus: (
      diff: u => cdiv(num(1), mul(u, ln-of(num(10)))),
      integ: none,
      diff-step: "d/dx log₁₀(@) = @'/( @ ln 10 )",
      domain-note: "Real-domain derivative requires @ > 0.",
    ),
  ),
  log1p: (
    name: "log1p",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("log1p", args)),
    eval: args => {
      let a = args.at(0)
      if a <= -1 { return none }
      calc.ln(1.0 + a)
    },
    calculus: (
      diff: u => cdiv(num(1), add(num(1), u)),
      integ: none,
      diff-step: "d/dx log1p(@) = @'/(1+@)",
      domain-note: "Real-domain derivative requires @ > -1.",
    ),
  ),
  expm1: (
    name: "expm1",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("expm1", args)),
    eval: args => calc.exp(args.at(0)) - 1.0,
    calculus: (
      diff: u => exp-of(u),
      integ: u => sub(exp-of(u), u),
      diff-step: "d/dx expm1(@) = e^@ · @'",
      domain-note: none,
    ),
  ),
  // --- Additional Base Functions ---
  cbrt: (
    name: "cbrt",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $root(3, #args.at(0))$),
    eval: args => {
      let a = args.at(0)
      if a < 0 { return -calc.pow(-a, 1.0 / 3.0) }
      calc.pow(a, 1.0 / 3.0)
    },
    calculus: (
      diff: u => cdiv(num(1), mul(num(3), pow(func("cbrt", u), num(2)))),
      integ: none,
      diff-step: "d/dx cbrt(@) = @'/(3 cbrt(@)^2)",
      domain-note: none,
    ),
  ),
  sinc: (
    name: "sinc",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("sinc", args)),
    eval: args => {
      let a = args.at(0)
      if calc.abs(a) < 1e-12 { return 1.0 }
      calc.sin(a) / a
    },
    calculus: (
      diff: u => cdiv(sub(mul(u, cos-of(u)), sin-of(u)), pow(u, num(2))),
      integ: none,
      diff-step: "d/dx sinc(@) = ((@cos(@) - sin(@))/@²) · @'",
      domain-note: "Symbolic form assumes @ != 0 (continuous extension at @ = 0 is 1).",
    ),
  ),
  softplus: (
    name: "softplus",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("softplus", args)),
    eval: args => _safe-softplus(args.at(0)),
    calculus: (
      diff: u => func("sigmoid", u),
      integ: none,
      diff-step: "d/dx softplus(@) = sigmoid(@) · @'",
      domain-note: none,
    ),
  ),
  sigmoid: (
    name: "sigmoid",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => _render-op("sigmoid", args)),
    eval: args => _safe-sigmoid(args.at(0)),
    calculus: (
      diff: u => mul(func("sigmoid", u), sub(num(1), func("sigmoid", u))),
      integ: none,
      diff-step: "d/dx sigmoid(@) = sigmoid(@)(1-sigmoid(@)) · @'",
      domain-note: none,
    ),
  ),
  abs: (
    name: "abs",
    aliases: (),
    arity: 1,
    parse: (allow-implicit: true, allow-power-prefix: true),
    display: (render: args => $lr(|#args.at(0)|)$),
    eval: args => calc.abs(args.at(0)),
    calculus: (
      diff: u => cdiv(u, abs-of(u)),
      integ: none,
      diff-step: "d/dx |@| = @/|@| · @'",
      domain-note: "Derivative is undefined when @ = 0.",
    ),
  ),
  // --- Multi-argument example for onboarding ---
  hypot2: (
    name: "hypot2",
    aliases: (),
    arity: 2,
    parse: (allow-implicit: false, allow-power-prefix: false),
    display: (render: args => _render-op("hypot2", args)),
    eval: args => {
      let a = args.at(0)
      let b = args.at(1)
      calc.sqrt(a * a + b * b)
    },
    calculus: (
      diff: none,
      integ: none,
      diff-step: none,
      domain-note: none,
    ),
  ),
)

/// Public helper `fn-alias-map`.
#let fn-alias-map = {
  let out = (:)
  for cname in fn-registry.keys() {
    let spec = fn-registry.at(cname)
    out.insert(cname, cname)
    for a in spec.aliases {
      out.insert(a, cname)
    }
  }
  out
}

/// Public helper `fn-canonical`.
#let fn-canonical(name) = fn-alias-map.at(name, default: none)

/// Public helper `fn-spec`.
#let fn-spec(name) = {
  let cname = fn-canonical(name)
  if cname == none { return none }
  fn-registry.at(cname, default: none)
}

/// Public helper `fn-arity-ok`.
#let fn-arity-ok(spec, argc) = {
  if spec == none { return false }
  let arity = spec.arity
  if type(arity) == str and arity == "variadic" { return true }
  if type(arity) == int { return arity == argc }
  false
}

/// Public helper `fn-known-names`.
#let fn-known-names = {
  let out = ()
  for name in fn-alias-map.keys() {
    out.push(name)
  }
  out
}

/// Public helper `fn-calc-rules`.
#let fn-calc-rules = {
  let out = (:)
  for cname in fn-registry.keys() {
    let spec = fn-registry.at(cname)
    if spec.arity != 1 { continue }
    let calc-spec = spec.calculus
    if calc-spec == none or calc-spec.diff == none { continue }

    let rule = (
      diff: calc-spec.diff,
      integ: calc-spec.integ,
      diff-step: calc-spec.diff-step,
      domain-note: calc-spec.domain-note,
    )

    out.insert(cname, rule)
    for a in spec.aliases {
      out.insert(a, rule)
    }
  }
  out
}

/// Public helper `fn-square-power-integral-rules`.
///
/// Canonical data for primitive patterns:
///   ∫f(u)^2 dx = F(u) / u'  (when u' is constant w.r.t. integration variable)
/// Used by both integration engine and step tracer to avoid hardcoded ladders.
#let fn-square-power-integral-rules = (
  sec: (
    antideriv: u => tan-of(u),
    rule: "Special rule: ∫sec²(u) dx = tan(u)/u'",
  ),
  csc: (
    antideriv: u => neg(cot-of(u)),
    rule: "Special rule: ∫csc²(u) dx = -cot(u)/u'",
  ),
  sech: (
    antideriv: u => tanh-of(u),
    rule: "Special rule: ∫sech²(u) dx = tanh(u)/u'",
  ),
  csch: (
    antideriv: u => neg(coth-of(u)),
    rule: "Special rule: ∫csch²(u) dx = -coth(u)/u'",
  ),
)

/// Public helper `fn-square-power-integral-spec`.
#let fn-square-power-integral-spec(name) = {
  let cname = fn-canonical(name)
  if cname == none { return none }
  fn-square-power-integral-rules.at(cname, default: none)
}
