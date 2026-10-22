// lambdify: an expression as a plain Typst function.
#import "core.typ": *

/// Turns an expression into a plain Typst function of numbers, for value tables,
/// other plotting packages (lilaq, cetz-plot, simple-plot) or your own calculations.
/// Defined variables and functions are used with their current values. Needs `context`.
///
/// ```typ
/// #def("R = 50 Ω")
/// #context {
///   let P = lambdify("U^2/R", "U", unit: "W", units: (U: "V"))
///   table(columns: 2, ..range(1, 6).map(u => ([#u V], [#P(u) W])).flatten())
/// }
/// ```
///
/// The function takes one argument per parameter: a number (in the unit given in
/// `units`, else in the SI unit) or a value like `"5 V"`. It returns a float in
/// `unit` (else in the SI unit), or `none` where the expression isn't defined
/// (`sqrt(-1)`, division by zero).
///
/// Unlike the other functions, problems stop the compilation here, since the
/// result is a function and not content.
///
/// - expr (str, content): The expression, using defined variables and the parameters: `"U^2/R"` or `$U^2 / R$`.
/// - ..params (str): The parameters in order, e.g. `"U"` or `"U", "R"`. A defined variable as a parameter is replaced by the argument. Without any: the undefined variables of the expression, in the order they appear.
/// - unit (none, str, content): Unit of the result, e.g. `"W"`. Checked against the expression when all parameters have units.
/// - units (dictionary): Units of numeric arguments, e.g. `(U: "V", R: "kΩ")`.
/// -> function
#let lambdify(expr, ..params, unit: none, units: (:)) = {
  let fail(m) = panic("solveng: lambdify: " + m)
  if params.named().len() > 0 { fail("unknown argument '" + params.named().keys().first() + "' (arguments: the parameters, unit, units)") }
  if type(expr) not in (str, content) { fail("the expression must be a string or math, got " + _tn(expr)) }
  if type(units) != dictionary { fail("units: a dictionary like (U: \"V\"), got " + _tn(units)) }
  let cf = _cf.get()
  let U = _UT(cf)
  let st = _st.get()
  let d = _vars-of(st)
  let fns = st.at("#fn", default: (:))
  let s = if type(expr) == content and expr.func() == math.equation {
    let m = _str(expr, q: true)
    if _E(m) { m } else { _math-src(m, d, cf) }
  } else { _str(expr) }
  if _E(s) { fail(s.err) }
  let e = _parse(s, d, f: fns, U: U)
  if _E(e) { fail(e.err) }
  let ps = params.pos()
  if ps.any(p => type(p) != str) { fail("the parameters must be names like \"U\", got " + repr(ps.find(p => type(p) != str))) }
  let ps = if ps.len() == 0 { _vars(e).dedup().filter(v => v not in d) } else { ps }
  let miss = _vars(e).dedup().filter(v => v not in d and v not in ps)
  if miss.len() > 0 { fail(miss.map(v => "'" + v + "'").join(", ") + " is neither defined nor a parameter") }
  // parameter name -> (factor, dims)
  let pu = (:)
  for (k, u) in units {
    if k not in ps { fail("units: '" + k + "' is not a parameter (parameters: " + ps.join(", ") + ")") }
    let r = _unit(_str(u), U: U)
    if _E(r) { fail("units: " + r.err) }
    pu.insert(k, r)
  }
  let yf = 1.0
  if unit != none {
    let r = _unit(_str(unit), U: U)
    if _E(r) { fail("unit: " + r.err) }
    yf = r.at(0)
    // with the units of all parameters known, the unit of the result can be checked now
    if ps.all(p => p in pu) {
      let dq = d + ps.map(p => (p, (v: pu.at(p).at(0), d: pu.at(p).at(1), raw: none, u: "", ex: none))).to-dict()
      let y = _dx(e, dq, _env(d), ())
      if _E(y) { fail(y.err) }
      let yd = if y.at(0) == none { r.at(1) } else { y.at(0).at(0).map(z => calc.round(z, digits: 6)) }
      if yd != r.at(1) { fail("the result has unit " + (if yd == _Z { "1 (no unit)" } else { _auto(yd, U: U) }) + ", not " + _str(unit)) }
    }
  }
  let env = _env(d)
  (..args) => {
    let a = args.pos()
    if args.named().len() > 0 { panic("solveng: lambdify: the function takes no named arguments") }
    if a.len() != ps.len() { panic("solveng: lambdify: the function takes " + str(ps.len()) + " argument(s) (" + ps.join(", ") + "), got " + str(a.len())) }
    let env = env
    for (p, v) in ps.zip(a) {
      let x = if type(v) in (int, float) { float(v) * pu.at(p, default: (1.0, none)).at(0) } else if type(v) in (str, content) {
        let q = _q(v, U: U)
        if _E(q) { panic("solveng: lambdify: " + p + ": " + q.err) }
        if p in pu and q.d != pu.at(p).at(1) { panic("solveng: lambdify: " + p + " = " + _str(v) + " doesn't have the unit of " + p) }
        q.v
      } else { panic("solveng: lambdify: " + p + ": a number or a value like \"5 V\", got " + _tn(v)) }
      env.insert(p, (x, none))
    }
    let r = _nd(e, env)
    if r == none { none } else { r.at(0) / yf }
  }
}
