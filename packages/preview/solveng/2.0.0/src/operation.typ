#import "engine.typ": _p, _call, _src, _plain, _E, _binding-displays, _constant-display, _m, _req-cfg, _cf
#import "builtins.typ": _op-call

/// An operation under a name of your choice: `#let conv = operation("convolve")`, then `$conv(x, h)$`.
///
/// The name selects one of solveng's operations (see *Built-in operations*), whatever the binding is called;
/// quoted names in math never do. Unlike `math.op("tri")`, the result takes named arguments, as Typst only
/// parses them for functions: `$conv(x, h, step: 2)$`.
///
/// `display` is how the operation is shown, in the input and in results: a string (an operator name, as
/// `math.op` writes it), content, or a function returning content.
///
/// ```typ
/// #let triangle = operation("tri", display: "triangle")
/// #let step = operation("sgn", display: $op(sigma)$)
/// #show: worksheet
/// $triangle(1/2) =>$, $step(-2) =>$
/// ```
///
/// - name (str): The operation, e.g. `"tri"` or `"convolve"`.
/// - display (auto, str, content, function): How the operation is shown: an operator name, content, or a function
///   returning content; `auto`: its name.
/// -> function
#let operation(name, display: auto) = {
  assert(type(name) == str, message: "operation: expected an operation identity")
  assert(display == auto or type(display) in (function, content, str, symbol), message: "operation: display must be content or a function returning it")
  (..args) => _op-call(name, args, display: display)
}

#let _references(c) = {
  if type(c) != content { return (:) }
  if c.has("label") and c.label == <solveng-binding> {
    return c.children.find(x => x.func() == metadata).value.displays
  }
  if c.has("children") { return c.children.map(_references).fold((:), (a, b) => a + b) }
  if c.has("body") { return _references(c.body) }
  if c.func() == math.root { return _references(c.radicand) + _references(c.at("index", default: [])) }
  if c.func() == math.mat { return c.rows.flatten().map(_references).fold((:), (a, b) => a + b) }
  if c.func() == math.frac { return _references(c.num) + _references(c.denom) }
  if c.func() == math.attach { return _references(c.base) + _references(c.fields().at("t", default: [])) + _references(c.fields().at("b", default: [])) }
  (:)
}

// a display: content, or a function returning it
#let _display(kind, display) = {
  assert(display == auto or type(display) in (function, content, str, symbol), message: kind + ": display must be content or a function returning it")
  if type(display) == function { display() } else if type(display) == str { math.upright(display) } else { display }
}

#let _binding(kind, expression, identity, display) = {
  assert(identity == none or (type(identity) == str and identity.trim() != ""), message: kind + ": identity must be a nonempty string")
  let is-base = kind == "base-unit"
  let body = if is-base { [] } else {
    assert(type(expression) == content and expression.func() == math.equation, message: kind + ": expected a math expression")
    expression.body
  }
  let src = if is-base { "" } else { _src(body) }
  assert(not _E(src), message: kind + ": cannot read the expression")
  // a unit without a display shows its expression as solveng writes results: 2.54 cm, as in 1 · 2.54 cm =
  let written = kind == "unit" and display == auto
  // a constant is shown as the worksheet shows its identity, a unit as its display says
  let shown = if kind == "constant" { context _constant-display(identity, body) } else if written {
    context { let cf = _cf.get(); _m(_call(_p.written, (cfg: _req-cfg(cf), src: src)), cf) }
  } else if display != auto { _display(kind, display) } else { math.upright(identity) }
  let presentation = if kind == "constant" or written { "" } else { repr(shown) }
  let description = if kind == "constant" or written { "" } else { _plain(shown) }
  let binding = _call(_p.binding, (kind: kind, src: src, identity: identity, presentation: presentation, description: description, "auto": written))
  let displays = _references(body)
  if kind != "constant" { displays.insert(binding.id, shown) }
  // numeric: the display starts with a number; compound: it's more than one atom (how _restyle joins it)
  let meta = (token: binding.token, displays: displays, unit: kind != "constant", numeric: binding.at("numeric", default: false), compound: binding.at("compound", default: false))
  let body = [#_binding-displays.update(d => d + displays)#metadata(meta)#shown]
  [#body<solveng-binding>]
}

/// A unit of a new, independent dimension: `#let bit = base-unit("information")`.
///
/// The identity names the dimension: base units with the same identity are the same dimension, also when
/// they're declared in other files or worksheets. Results of the dimension are shown in the unit.
///
/// `display` is how the unit is shown, in the input and in results: a string (set upright), content, or a
/// function returning content.
///
/// ```typ
/// #let bit = base-unit("information", display: "bit")
/// #let byte = unit($8 bit$, display: $"B"$)
/// #show: worksheet
/// $d := 3 byte = bit$
/// ```
///
/// - identity (str): The dimension, the same in every file and worksheet.
/// - display (auto, str, content, function): How the unit is shown: a string (upright), content, or a function
///   returning content; `auto`: the identity, upright.
/// -> content
#let base-unit(identity, display: auto) = {
  assert(type(identity) == str and identity.trim() != "", message: "base-unit: expected a nonempty dimension identity")
  _binding("base-unit", none, identity, display)
}

/// A unit defined by an expression of unit values: `#let minute = unit($60 #s$)`.
///
/// The expression is the unit's value: a positive number times units, from `units`, `base-unit` or other
/// `unit`s (`$100 kPa$`, `$1/min$`, `$#m / #s$`). Like every binding, the unit holds where the binding is
/// visible, in every worksheet.
///
/// `display` says how the unit is shown, in the input and in results, not what it means: a string (set upright),
/// content, or a function returning content. Binding names keep their spelling (a unit named `tau` isn't shown
/// as τ). Without a display the unit shows its expression, written as results are (numbers in the worksheet's
/// format, a thin space before units): `unit($2.54 #cm$)` is 2.54 cm. That display is one unit wherever it
/// appears: after a number or another factor it is joined by a dot, `$1 #inch$` is 1 · 2.54 cm, and under a
/// power or after a slash it is parenthesized, (2.54 cm)², m/(2.54 cm).
///
/// ```typ
/// #import units: kPa, min, cm
/// #let bar = unit($100 kPa$, display: "bar")
/// #let rpm = unit($1/min$, display: $"rpm"$)
/// #let inch = unit($2.54 #cm$)
/// #show: worksheet
/// $p := 3 bar$, $n := 3000 rpm$, $p => kPa$, $l := 2 #inch = inch$
/// ```
///
/// - expression (content): The unit's value as math.
/// - display (auto, str, content, function): How the unit is shown: a string (upright), content, or a function
///   returning content; `auto`: the expression, written as results are.
/// -> content
#let unit(expression, display: auto) = _binding("unit", expression, none, display)

/// Defines a constant: an identity and the math expression it stands for, which can carry units.
///
/// The identity says what the constant is and how it is shown: worksheets show it as their option `constants`
/// says, `#show: worksheet.with(constant-displays: (imaginary: $j$))`, with built-in displays for `"pi"`, `"euler"`,
/// `"imaginary"` and `"speed-of-light"`; an identity without a display is shown as its expression. The engine
/// calculates exactly with the identities it knows – `"pi"` (π), `"euler"` (e) and `"imaginary"` (i) – once the
/// expression has that value: `$#calc.pi$`, `$sqrt(-1)$`. Any other identity is kept by it in exact results
/// (`$E := m #c^2 ->$` is m c²) and calculated with its expression, which must have a value. `substitute` puts
/// the expression in: `$E := m #c^2 -> substitute(#c)$`, and a constant alone shows it as written,
/// `$#i -> substitute(#i)$` is √−1.
///
/// ```typ
/// #import units: m, s, kg
/// #let c0 = constant("speed-of-light", $299792458 #m / #s$)
/// #let g0 = constant("standard-gravity", $9.80665 #m / #s^2$)
/// #show: worksheet.with(constant-displays: ("standard-gravity": $g_0$))
/// $F := 2 kg #g0 =>$
/// ```
///
/// - identity (str): What the constant is, the same in every file and worksheet.
/// - expression (content): Its value as math: numbers, units and other constants.
/// -> content
#let constant(identity, expression) = {
  assert(type(identity) == str and identity.trim() != "", message: "constant: expected an identity, constant(\"imaginary\", $sqrt(-1)$)")
  _binding("constant", expression, identity, auto)
}
