// =========================================================================
// CAS Expression Constructors
// =========================================================================
// Every expression is a dictionary with a "type" key for dispatch.
// Constructor functions act as "classes" in this OOP-via-dict pattern.
// Raw int/float arguments are automatically wrapped in num().
//
// ## Expression Types (type tags):
//   "num"    — numeric literal         (val: number)
//   "var"    — named variable          (name: string)
//   "const"  — mathematical constant   (name: "e" | "pi")
//   "neg"    — negation −x             (arg: expr)
//   "add"    — addition x+y            (args: (expr, expr))
//   "mul"    — multiplication x·y      (args: (expr, expr))
//   "pow"    — exponentiation x^y      (base: expr, exp: expr)
//   "div"    — division x/y            (num: expr, den: expr)
//   "func"   — named function f(...)   (name: string, args: tuple<expr>)
//   "log"    — logarithm log_b(x)      (base: expr, arg: expr)
//   "matrix" — matrix                  (rows: array of arrays)
//   "piecewise" — piecewise function   (cases: array of (expr, condition))
//   "sum"    — summation Σ             (body, idx, from, to)
//   "prod"   — product Π               (body, idx, from, to)
// =========================================================================

// --- Type checking utility ---

/// Check if expr has the given type tag.
///
/// - expr: Any value (usually a CAS expression dict).
/// - t: Type tag string, e.g. "num", "var", "add".
/// - returns: true if expr is a CAS dict with matching type.
#let is-type(expr, t) = {
  type(expr) == dictionary and expr.at("type", default: none) == t
}

/// Check if expr is any CAS expression (has a type key).
///
/// - expr: Any value.
/// - returns: true if expr is a CAS expression dictionary.
#let is-expr(expr) = {
  type(expr) == dictionary and expr.at("type", default: none) != none
}

// --- Leaf nodes ---

/// Create a numeric literal expression.
///
/// - n: The numeric value (int or float).
/// - returns: (type: "num", val: n)
///
/// example
/// num(3)    // integer 3
/// num(0.5)  // float 0.5
///
#let num(n) = {
  (type: "num", val: n)
}

/// Create a variable expression.
///
/// - name: Variable name (string), e.g. "x", "theta".
/// - returns: (type: "var", name: name)
///
/// example
/// cvar("x")
/// cvar("theta")
///
#let cvar(name) = {
  (type: "var", name: name)
}

/// Create a mathematical constant expression (e or π).
///
/// - name: "e" for Euler's number, "pi" for π.
/// - returns: (type: "const", name: name)
#let const-expr(name) = {
  (type: "const", name: name)
}

/// Euler's number e.
#let const-e = const-expr("e")

/// π (pi).
#let const-pi = const-expr("pi")

// --- Auto-wrap helper ---
// Converts raw int/float to num() so users can write add(x, 3) instead of add(x, num(3))
/// Internal helper `_w`.
#let _w(arg) = {
  if type(arg) == int or type(arg) == float { return num(arg) }
  arg
}

// --- Binary / n-ary operators ---

/// Addition node: a + b.
///
/// - a: First operand (expr, int, or float).
/// - b: Second operand (expr, int, or float).
/// - returns: (type: "add", args: (a, b))
#let add(a, b) = {
  (type: "add", args: (_w(a), _w(b)))
}

/// Multiplication node: a · b.
///
/// - a: First factor (expr, int, or float).
/// - b: Second factor (expr, int, or float).
/// - returns: (type: "mul", args: (a, b))
#let mul(a, b) = {
  (type: "mul", args: (_w(a), _w(b)))
}

/// Exponentiation node: base^exp.
///
/// - base: Base expression (expr, int, or float).
/// - exp: Exponent expression (expr, int, or float).
/// - returns: (type: "pow", base: base, exp: exp)
#let pow(base, exp) = {
  (type: "pow", base: _w(base), exp: _w(exp))
}

/// Division node: numerator / denominator.
///
/// - numer: Numerator (expr, int, or float).
/// - denom: Denominator (expr, int, or float).
/// - returns: (type: "div", num: numer, den: denom)
#let cdiv(numer, denom) = {
  (type: "div", num: _w(numer), den: _w(denom))
}

// --- Unary operators ---

/// Negation node: −arg.
///
/// - arg: Expression to negate (expr, int, or float).
/// - returns: (type: "neg", arg: arg)
#let neg(arg) = {
  (type: "neg", arg: _w(arg))
}

// --- Functions ---

/// Named function application: sin(x), cos(x), ln(x), exp(x), etc.
///
/// - name: Function name (string), e.g. "sin", "ln".
/// - args: One or more argument expressions (expr, int, or float).
/// - returns:
///   - unary: (type: "func", name: name, args: (arg,), arg: arg)
///   - n-ary: (type: "func", name: name, args: (...))
///
/// example
/// func("sin", cvar("x"))           // sin(x)
/// func("hypot2", cvar("x"), cvar("y"))  // hypot2(x, y)
///
#let func(name, ..args) = {
  let args = args.pos().map(_w)
  if args.len() == 1 {
    return (type: "func", name: name, args: args, arg: args.at(0))
  }
  (type: "func", name: name, args: args)
}

/// Return function arguments as a tuple for any func node.
/// Supports both modern `(args: (...))` and legacy `(arg: ...)` shapes.
#let func-args(expr) = {
  if not is-type(expr, "func") { return () }
  let args = expr.at("args", default: none)
  if args != none { return args }
  let arg = expr.at("arg", default: none)
  if arg != none { return (arg,) }
  ()
}

/// Return function arity for any func node.
#let func-arity(expr) = func-args(expr).len()

// --- Convenience constructors for trig/hyp/inverse functions ---
// Each creates a func() node with the appropriate name.

/// sin(arg)
#let sin-of(arg) = func("sin", arg)
/// cos(arg)
#let cos-of(arg) = func("cos", arg)
/// tan(arg)
#let tan-of(arg) = func("tan", arg)
/// csc(arg)
#let csc-of(arg) = func("csc", arg)
/// sec(arg)
#let sec-of(arg) = func("sec", arg)
/// cot(arg)
#let cot-of(arg) = func("cot", arg)

/// arcsin(arg)
#let arcsin-of(arg) = func("arcsin", arg)
/// arccos(arg)
#let arccos-of(arg) = func("arccos", arg)
/// arctan(arg)
#let arctan-of(arg) = func("arctan", arg)
/// arccsc(arg)
#let arccsc-of(arg) = func("arccsc", arg)
/// arcsec(arg)
#let arcsec-of(arg) = func("arcsec", arg)
/// arccot(arg)
#let arccot-of(arg) = func("arccot", arg)

/// sinh(arg)
#let sinh-of(arg) = func("sinh", arg)
/// cosh(arg)
#let cosh-of(arg) = func("cosh", arg)
/// tanh(arg)
#let tanh-of(arg) = func("tanh", arg)
/// csch(arg)
#let csch-of(arg) = func("csch", arg)
/// sech(arg)
#let sech-of(arg) = func("sech", arg)
/// coth(arg)
#let coth-of(arg) = func("coth", arg)

/// arcsinh(arg)
#let arcsinh-of(arg) = func("arcsinh", arg)
/// arccosh(arg)
#let arccosh-of(arg) = func("arccosh", arg)
/// arctanh(arg)
#let arctanh-of(arg) = func("arctanh", arg)
/// arccsch(arg)
#let arccsch-of(arg) = func("arccsch", arg)
/// arcsech(arg)
#let arcsech-of(arg) = func("arcsech", arg)
/// arccoth(arg)
#let arccoth-of(arg) = func("arccoth", arg)

/// Natural logarithm: ln(arg)
#let ln-of(arg) = func("ln", arg)

/// Exponential: exp(arg) = e^arg
#let exp-of(arg) = func("exp", arg)

/// Square root: sqrt(arg) = arg^(1/2)
///
/// - arg: Expression (expr, int, or float).
/// - returns: pow(arg, 1/2) — a power node, not a func node.
#let sqrt-of(arg) = pow(_w(arg), cdiv(1, 2))

// --- Subtraction sugar ---

/// Subtraction: a − b. Desugars to add(a, neg(b)).
///
/// - a: Minuend (expr, int, or float).
/// - b: Subtrahend (expr, int, or float).
/// - returns: add(a, neg(b))
#let sub(a, b) = {
  add(_w(a), neg(_w(b)))
}

// --- N-ary constructors ---

/// Sum of multiple expressions: sum-of(a, b, c, ...) = a + b + c + ...
///
/// - args: Any number of expressions (positional).
/// - returns: Left-folded addition tree, or num(0) if no args.
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

/// Product of multiple expressions: prod-of(a, b, c, ...) = a · b · c · ...
///
/// - args: Any number of expressions (positional).
/// - returns: Left-folded multiplication tree, or num(1) if no args.
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

/// Absolute value: |arg|
///
/// - arg: Expression (expr, int, or float).
/// - returns: func("abs", arg)
#let abs-of(arg) = func("abs", _w(arg))

// --- Logarithm with base ---

/// Logarithm with arbitrary base: log_base(arg).
///
/// - base: Base of the logarithm (expr, int, or float).
/// - arg: Argument of the logarithm (expr, int, or float).
/// - returns: (type: "log", base: base, arg: arg)
///
/// example
/// log-of(2, cvar("x"))  // log₂(x)
///
#let log-of(base, arg) = {
  let base = _w(base)
  let arg = _w(arg)
  (type: "log", base: base, arg: arg)
}

// --- Summation / Product notation ---

/// Symbolic summation: Σ_{idx=from}^{to} body.
///
/// - body: The expression being summed (CAS expression).
/// - idx: Index variable name (string).
/// - from: Lower bound (expr, int, or float).
/// - to: Upper bound (expr, int, or float).
/// - returns: (type: "sum", body, idx, from, to)
///
/// example
/// csum(pow(cvar("k"), 2), "k", 1, num(10))  // Σ_{k=1}^{10} k²
///
#let csum(body, idx, from, to) = {
  let from = _w(from)
  let to = _w(to)
  (type: "sum", body: body, idx: idx, from: from, to: to)
}

/// Symbolic product: Π_{idx=from}^{to} body.
///
/// - body: The expression being multiplied (CAS expression).
/// - idx: Index variable name (string).
/// - from: Lower bound (expr, int, or float).
/// - to: Upper bound (expr, int, or float).
/// - returns: (type: "prod", body, idx, from, to)
#let cprod(body, idx, from, to) = {
  let from = _w(from)
  let to = _w(to)
  (type: "prod", body: body, idx: idx, from: from, to: to)
}

// --- Matrix ---

/// Create a matrix from nested arrays.
///
/// - rows: Array of row arrays. Each element is an expr, int, or float.
/// - returns: (type: "matrix", rows: wrapped-rows)
///
/// example
/// cmat(((1, 2), (3, 4)))  // 2×2 matrix [[1,2],[3,4]]
/// cmat(((1, 0, 0), (0, 1, 0), (0, 0, 1)))  // 3×3 identity
///
#let cmat(rows) = {
  let wrapped = rows.map(row => row.map(_w))
  (type: "matrix", rows: wrapped)
}

/// Create an n×n identity matrix.
///
/// - n: Size of the matrix (integer).
/// - returns: n×n identity CAS matrix.
///
/// example
/// mat-id(3)  // 3×3 identity matrix
///
#let mat-id(n) = {
  let rows = range(n).map(i => range(n).map(j => if i == j { num(1) } else { num(0) }))
  cmat(rows)
}

// --- Piecewise ---

/// Create a piecewise function expression.
///
/// - cases: Array of (expression, condition) pairs.
///   Each condition is a string (e.g. "x > 0") or none for the default/otherwise case.
/// - returns: (type: "piecewise", cases: cases)
///
/// example
/// piecewise(((cvar("x"), "x > 0"), (neg(cvar("x")), none)))
/// // Defines |x|: x if x>0, −x otherwise
///
#let piecewise(cases) = {
  (type: "piecewise", cases: cases)
}

// --- Comparison / equality ---

/// Deep structural equality of two CAS expressions.
/// Compares the entire expression tree recursively.
///
/// - a: First expression.
/// - b: Second expression.
/// - returns: true if a and b are structurally identical.
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
  if t == "func" {
    if a.name != b.name { return false }
    let aa = func-args(a)
    let ba = func-args(b)
    if aa.len() != ba.len() { return false }
    for i in range(aa.len()) {
      if not expr-eq(aa.at(i), ba.at(i)) { return false }
    }
    return true
  }
  if t == "log" { return expr-eq(a.base, b.base) and expr-eq(a.arg, b.arg) }

  return false
}
