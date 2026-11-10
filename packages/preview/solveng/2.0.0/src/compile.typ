// compile: an expression as a plain Typst function.
#import "api.typ": *

/// Compiles a snapshot of an expression into a numeric Typst function. Needs context.
/// Parameters are an ordered dictionary; `auto` means arguments use SI units.
/// With no parameters, free names are inferred.
///
/// ```typ
/// #context {
///   let P = compile($U^2/R$, parameters: (U: $#V$), result-unit: $#W$)
///   [#P(12)]
/// }
/// ```
///
/// The function takes one argument per parameter: a number (in the unit given in
/// `parameters`, else in the SI unit) or a math quantity like `$5 #V$`. It returns
/// a float in `result-unit` (else in the SI unit), or `none` where the expression
/// isn't defined.
///
/// - expr (content): The expression, using defined variables and the parameters.
/// - parameters (dictionary): Names mapped to unit expressions or `auto`, in argument order.
/// - result-unit (none, content): Unit of the returned number as math; `none` means SI.
/// -> function
#let compile(expr, parameters: (:), result-unit: none) = {
  let fail(m) = panic("solveng: compile: " + m)
  if type(parameters) != dictionary { fail("parameters must be an ordered dictionary") }
  if type(expr) != content or expr.func() != std.math.equation { fail("the expression must be math") }
  if result-unit != none and (type(result-unit) != content or result-unit.func() != math.equation) { fail("result-unit must be a math expression containing unit values") }
  if parameters.values().any(u => u != auto and (type(u) != content or u.func() != std.math.equation)) { fail("parameters must map names to math unit expressions or auto") }
  let cf = _cf.get()
  let src = _src(expr.body)
  if _E(src) { fail("can't read the expression") }
  let units = parameters.pairs().filter(((name, unit)) => unit != auto).to-dict()
  let r = _call(_p.compile, _env(_st.get()), (
    cfg: _req-cfg(cf + (decimal-separator: ".")), src: src,
    params: parameters.keys(),
    unit: if result-unit == none { none } else { _unit-src(result-unit.body) },
    units: units.pairs().map(((k, v)) => (k, _unit-src(v.body))).to-dict(),
  ))
  if "err" in r { fail(r.err) }
  let compiled = r.compiled
  (..args) => {
    if args.named().len() > 0 { fail("the compiled function takes no named arguments") }
    let a = args.pos().map(v => if type(v) in (int, float) { float(v) } else if type(v) == content and v.func() == std.math.equation { _unit-src(v.body) } else { fail("an argument must be a number or a math quantity") })
    let y = _call(_p.compiled_eval, compiled, a)
    if type(y) == dictionary { fail(y.err) }
    y
  }
}
