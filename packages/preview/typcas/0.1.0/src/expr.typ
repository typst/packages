// =========================================================================
// CAS Expression Constructors
// =========================================================================
// Every expression is a dictionary with a "type" key for dispatch.
// Constructor functions act as "classes" in this OOP-via-dict pattern.
// Raw int/float arguments are automatically wrapped in num().
// =========================================================================

// --- Type checking utility ---

/// Check if an expression has the given type tag.
#let is-type(expr, t) = {
  type(expr) == dictionary and expr.at("type", default: none) == t
}

/// Check if an expression is a CAS expression (has a type key).
#let is-expr(expr) = {
  type(expr) == dictionary and expr.at("type", default: none) != none
}

// --- Leaf nodes ---

/// Numeric literal.
/// num(3) => (type: "num", val: 3)
#let num(n) = {
  (type: "num", val: n)
}

/// Variable / symbol.
/// cvar("x") => (type: "var", name: "x")
#let cvar(name) = {
  (type: "var", name: name)
}

/// Mathematical constant (e, pi).
#let const-expr(name) = {
  (type: "const", name: name)
}

#let const-e = const-expr("e")
#let const-pi = const-expr("pi")

// --- Auto-wrap helper ---
// Converts raw int/float to num() so users can write add(x, 3) instead of add(x, num(3))
#let _w(arg) = {
  if type(arg) == int or type(arg) == float { return num(arg) }
  arg
}

// --- Binary / n-ary operators ---

/// Addition of two expressions.
#let add(a, b) = {
  (type: "add", args: (_w(a), _w(b)))
}

/// Multiplication of two expressions.
#let mul(a, b) = {
  (type: "mul", args: (_w(a), _w(b)))
}

/// Exponentiation: base^exp.
#let pow(base, exp) = {
  (type: "pow", base: _w(base), exp: _w(exp))
}

/// Division: numerator / denominator.
#let cdiv(numer, denom) = {
  (type: "div", num: _w(numer), den: _w(denom))
}

// --- Unary operators ---

/// Negation: -arg.
#let neg(arg) = {
  (type: "neg", arg: _w(arg))
}

// --- Functions ---

/// Named function application: sin(x), cos(x), ln(x), exp(x), etc.
#let func(name, arg) = {
  (type: "func", name: name, arg: _w(arg))
}

// --- Convenience constructors ---

// Basic trig (6)
#let sin-of(arg) = func("sin", arg)
#let cos-of(arg) = func("cos", arg)
#let tan-of(arg) = func("tan", arg)
#let csc-of(arg) = func("csc", arg)
#let sec-of(arg) = func("sec", arg)
#let cot-of(arg) = func("cot", arg)

// Inverse trig (6)
#let arcsin-of(arg) = func("arcsin", arg)
#let arccos-of(arg) = func("arccos", arg)
#let arctan-of(arg) = func("arctan", arg)
#let arccsc-of(arg) = func("arccsc", arg)
#let arcsec-of(arg) = func("arcsec", arg)
#let arccot-of(arg) = func("arccot", arg)

// Hyperbolic (6)
#let sinh-of(arg) = func("sinh", arg)
#let cosh-of(arg) = func("cosh", arg)
#let tanh-of(arg) = func("tanh", arg)
#let csch-of(arg) = func("csch", arg)
#let sech-of(arg) = func("sech", arg)
#let coth-of(arg) = func("coth", arg)

// Inverse hyperbolic (6)
#let arcsinh-of(arg) = func("arcsinh", arg)
#let arccosh-of(arg) = func("arccosh", arg)
#let arctanh-of(arg) = func("arctanh", arg)
#let arccsch-of(arg) = func("arccsch", arg)
#let arcsech-of(arg) = func("arcsech", arg)
#let arccoth-of(arg) = func("arccoth", arg)

// Other
#let ln-of(arg) = func("ln", arg)
#let exp-of(arg) = func("exp", arg)
#let sqrt-of(arg) = pow(_w(arg), cdiv(1, 2))

// --- Subtraction sugar ---

/// Subtraction: a - b  =>  add(a, neg(b))
#let sub(a, b) = {
  add(_w(a), neg(_w(b)))
}

// --- N-ary constructors ---

/// Sum of multiple expressions.
#let sum-of(..args) = {
  let items = args.pos().map(_w)
  if items.len() == 0 { return num(0) }
  if items.len() == 1 { return items.at(0) }
  let result = items.at(0)
  for i in range(1, items.len()) {
    result = add(result, items.at(i))
  }
  result
}

/// Product of multiple expressions.
#let prod-of(..args) = {
  let items = args.pos().map(_w)
  if items.len() == 0 { return num(1) }
  if items.len() == 1 { return items.at(0) }
  let result = items.at(0)
  for i in range(1, items.len()) {
    result = mul(result, items.at(i))
  }
  result
}

// --- Absolute value ---

/// Absolute value: abs-of(x) => |x|
#let abs-of(arg) = func("abs", _w(arg))

// --- Logarithm with base ---

/// Logarithm: log-of(base, x) => log_base(x)
#let log-of(base, arg) = {
  let base = _w(base)
  let arg = _w(arg)
  (type: "log", base: base, arg: arg)
}



// --- Summation / Product notation ---

/// Symbolic sum: csum(body, idx, from, to)
/// e.g. csum(pow(cvar("k"), 2), "k", 1, num(10))
#let csum(body, idx, from, to) = {
  let from = _w(from)
  let to = _w(to)
  (type: "sum", body: body, idx: idx, from: from, to: to)
}

/// Symbolic product: cprod(body, idx, from, to)
#let cprod(body, idx, from, to) = {
  let from = _w(from)
  let to = _w(to)
  (type: "prod", body: body, idx: idx, from: from, to: to)
}

// --- Matrix ---

/// Matrix constructor from nested arrays.
/// cmat(((1, 2), (3, 4))) => 2x2 matrix
#let cmat(rows) = {
  let wrapped = rows.map(row => row.map(_w))
  (type: "matrix", rows: wrapped)
}

/// Identity matrix of size n
#let mat-id(n) = {
  let rows = range(n).map(i => range(n).map(j => if i == j { num(1) } else { num(0) }))
  cmat(rows)
}

// --- Comparison / equality ---

/// Deep structural equality of two expressions.
#let expr-eq(a, b) = {
  if type(a) != dictionary or type(b) != dictionary { return a == b }
  if a.at("type", default: none) != b.at("type", default: none) { return false }

  let t = a.type
  if t == "num" { return a.val == b.val }
  if t == "var" { return a.name == b.name }
  if t == "const" { return a.name == b.name }
  if t == "neg" { return expr-eq(a.arg, b.arg) }
  if t == "add" or t == "mul" {
    return expr-eq(a.args.at(0), b.args.at(0)) and expr-eq(a.args.at(1), b.args.at(1))
  }
  if t == "pow" { return expr-eq(a.base, b.base) and expr-eq(a.exp, b.exp) }
  if t == "div" { return expr-eq(a.num, b.num) and expr-eq(a.den, b.den) }
  if t == "func" { return a.name == b.name and expr-eq(a.arg, b.arg) }
  if t == "log" { return expr-eq(a.base, b.base) and expr-eq(a.arg, b.arg) }

  return false
}

