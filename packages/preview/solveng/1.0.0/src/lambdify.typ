// lambdify: an expression as a plain Typst function.
#import "api.typ": *

/// Turns an expression into a plain Typst function of numbers, for value tables,
/// other plotting packages (lilaq, cetz-plot, simple-plot) or your own calculations.
/// Defined variables and functions are used with their current values. Needs `context`.
///
/// ```typ
/// #import units: Ω, W, V
/// #worksheet($R := 50 #Ω$, hidden: true)
/// #context {
///   let P = lambdify($U^2/R$, "U", unit: $#W$, units: (U: $#V$))
///   table(columns: 2, ..range(1, 6).map(u => ([#u V], [#P(u) W])).flatten())
/// }
/// ```
///
/// The function takes one argument per parameter: a number (in the unit given in
/// `units`, else in the SI unit) or a math quantity like `$5 #V$`. It returns a float in
/// `unit` (else in the SI unit), or `none` where the expression isn't defined
/// (`sqrt(-1)`, division by zero).
///
/// Unlike the other functions, problems stop the compilation here, since the
/// result is a function and not content.
///
/// - expr (content): The expression, using defined variables and the parameters: `$U^2 / R$`.
/// - ..params (str): The parameters in order, e.g. `"U"` or `"U", "R"`. A defined variable as a parameter is replaced by the argument. Without any: the undefined variables of the expression, in the order they appear.
/// - unit (none, content): Unit of the result as math, e.g. `$#W$` or `$kW$`. Checked against the expression when all parameters have units.
/// - units (dictionary): Units of numeric arguments as math, e.g. `(U: $#V$, R: $kΩ$)`.
/// -> function
#let lambdify(expr, ..params, unit: none, units: (:)) = {
  let fail(m) = panic("solveng: lambdify: " + m)
  if params.named().len() > 0 { fail("unknown argument '" + params.named().keys().first() + "' (arguments: the parameters, unit, units)") }
  if type(expr) != content or expr.func() != std.math.equation { fail("the expression must be math, got " + _tn(expr)) }
  if type(units) != dictionary { fail("units: a dictionary like (U: \"V\"), got " + _tn(units)) }
  if unit != none and (type(unit) != content or unit.func() != math.equation) { fail("unit: a math expression containing unit values") }
  if units.values().any(u => type(u) != content or u.func() != math.equation) { fail("units: math expressions containing unit values") }
  let ps = params.pos()
  if ps.any(p => type(p) != str) { fail("the parameters must be names like \"U\", got " + repr(ps.find(p => type(p) != str))) }
  let cf = _cf.get()
  let src = _src(expr.body)
  if _E(src) { fail("can't read the expression") }
  let r = _call(_p.lambdify, _env(_st.get()), (
    cfg: _req-cfg(cf + (separator: ".")), src: src, params: ps,
    unit: if unit == none { none } else { _unit-src(unit.body) }, units: units.pairs().map(((k, v)) => (k, _unit-src(v.body))).to-dict(),
  ))
  if "err" in r { fail(r.err) }
  let lam = r.lam
  (..args) => {
    if args.named().len() > 0 { panic("solveng: lambdify: the function takes no named arguments") }
    let a = args.pos().map(v => if type(v) in (int, float) { float(v) } else if type(v) == content and v.func() == std.math.equation { _unit-src(v.body) } else { panic("solveng: lambdify: a number or a math quantity like $5 unit(\"V\")$, got " + _tn(v)) })
    let y = _call(_p.lam_eval, lam, a)
    if type(y) == dictionary { panic("solveng: lambdify: " + y.err) }
    y
  }
}
