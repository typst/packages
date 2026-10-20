// def, solve and solve-block.
#import "core.typ": *

#let _STEPS = ("full", "formula", "result", "value")
// typed display arguments -> local options, or an error message
#let _disp(steps, layout, inline) = {
  if steps != auto and steps not in _STEPS { return _err("steps: use " + _STEPS.map(repr).join(", ")) }
  if layout != auto and layout not in ("row", "column") { return _err("layout: use \"row\" or \"column\"") }
  if type(inline) != bool { return _err("inline: true or false") }
  let o = (:)
  if inline { o.block = false }
  if steps != auto { o.steps = steps }
  if layout != auto { o.layout = layout }
  o
}

/// Defines values, functions or unknowns from equations, silently.
///
/// Every positional argument is an equation, as a string or as math. Several are
/// defined in order; equations that can't be defined one by one are solved together
/// as a system. `def` shows nothing (except problems) unless `output: true`; `solve`
/// is the same with the output on.
///
/// ```typ
/// #def("R = 7.2 kOhm", "I = 415 uA")     // values: a number with a unit
/// #def($Q_0 = 3450 "mAh"$)                // math works too
/// #def("U = R I")                          // computed from defined values
/// #def("f(x) = x^2 + 1")                   // a function, usable as f(3)
/// #def("Q_0/2 = I t", unit: "h")           // an equation: t is solved for
/// #def("x + y = 3", "x - y = 1")           // a system
/// ```
///
/// Inside an equation `[5 V]` is a value and `@R` inlines the formula of `R`.
///
/// - ..eqs (str, content): The equations. A single one without `=` (`"Q0/I"`) is evaluated (only useful with `output: true`).
/// - unit (none, str, content, dictionary): Unit of the result: `"mA"` (or math `$"mA"$`). For a system a dictionary per unknown: `(I: "mA", U: "V")`. Without it: the SI unit with an automatic prefix, or the non-SI unit of the inputs (h, mAh). If the result has another unit (`"x = f(1)"` gives volts, `unit: "A"`), that is an error.
/// - output (bool): Show the definition (like `solve` does).
/// - steps (auto, str): What is shown: `"full"`: equation ⇒ formula = numbers = result · `"formula"`: without the numbers · `"result"`: `t = 57.5 h` · `"value"`: just `57.5 h`. `auto`: the option `steps` (default `"full"`), or `inline-steps` with `inline: true`.
/// - layout (auto, str): `"row"`: all steps in one line · `"column"`: one step per line, aligned at `=`. `auto`: the option `layout` (default `"row"`).
/// - inline (bool): In the running text instead of a display block; `steps` default to `inline-steps` (`"result"`).
/// - unknown (none, str, array): What to solve for, `"t"` or `("x", "y")`. Only needed when it isn't clear; by default all variables that aren't defined yet are the unknowns (one per equation). If everything is defined, a lone variable on either side is recomputed.
/// - root (auto, int, function): Which solution is stored when there are several: `2` (1-based), or a test like `x => x > 0` (for systems it gets a dictionary). `auto`: the only all-positive one, else the first.
/// - guess (none, str, content, int, float, dictionary): Newton start value instead of the search: `"-1 A"`, or `(U: "5 V")` for systems.
/// - listed (bool): `false` hides it from `defined`.
/// - digits (auto, int): Significant digits of computed values, 1…15. Default `4`: `57.5 h`, `123500`.
/// - trailing-zeros (auto, bool): Keep trailing zeros up to `digits` (`2.500 V`). Default `false`.
/// - separator (auto, str): Decimal separator, any string like `","`. `auto` (default): from the document language, `,` for de, fr, it, … and `.` otherwise.
/// - grouping (auto, none, str, symbol, content): Digit grouping for integer parts with 5+ digits, e.g. `sym.space.thin` → `12 345`. Default `none`.
/// - scientific (auto, none, array): `(low, high)`: plain notation while the exponent `e` is in `low ≤ e < high`, else `2.5 · 10⁻⁷`. Default `(-3, 6)`; `none` never switches.
/// - engineering (auto, bool): Engineering notation, exponents in steps of 3. Default `false`.
/// - multiplication (auto, str): `"dot"` (default, `2 · 10⁶`) or `"times"` (`2 × 10⁶`).
/// - form (auto, str): How values are written. `"auto"` (default): as typed, results rounded · `"decimal"`: everything rounded to `digits` · `"fraction"`: exact fractions (`⅙ A`) · `"input"`: given values exactly as typed.
/// - max-denominator (auto, int): Largest denominator for `form: "fraction"`. Default `1000`.
/// - fractions (auto, str): How fractions are written: `"stacked"` (default) or `"slash"` (`1/2`).
/// - prefixes (auto, str, none, array): Prefixes picked for results: `"all"` (default: a f p n µ m k M G T; times from a minute on in min or h, not ks), `none` (base unit only) or an array like `("m", "k")` (`"u"` = µ).
/// - show-si (auto, bool): `defined` also shows the SI value (`Q₀ = 3450 mAh = 12420 C`). Default `false`.
/// - preferred-units (auto, str, array): Units for results of their dimension, `("bar", "kWh")`, before the unit of the inputs and the SI unit.
/// - strict (auto, bool): Unit names can't be variable names, and units in math must be quoted (`$5 "V"$`), see [Units and variables](#units-and-variables).
/// - inline-steps (auto, str): Steps for `inline: true` and inline code: `"full"`, `"formula"`, `"result"` (default) or `"value"`.
/// - implies (auto, content, symbol, str): What is written between steps, e.g. `sym.arrow.r.long` or `[and]`; ⇒ by default.
/// - approximate (auto, bool): Write `≈` when the shown result is rounded. Default `true`.
/// - block (auto, bool): Display equations (centred, default) or inline.
/// - max-solutions (auto, int): How many solutions are listed; all are found, `root` picks among all.
/// - defined-style (auto, str): How `defined` looks: `"grid"` (default: columns side by side, aligned at `=`), `"column"`, `"inline"` or `"list"`.
/// - errors (auto, str): `"document"` (default): problems are shown as red notes · `"panic"`: stop the compilation.
/// -> content
#let def(
  ..eqs,
  unit: none, output: false, steps: auto, layout: auto, inline: false,
  unknown: none, root: auto, guess: none, listed: true,
  digits: auto, trailing-zeros: auto, separator: auto, grouping: auto, scientific: auto, engineering: auto, multiplication: auto, form: auto, max-denominator: auto, fractions: auto,
  prefixes: auto, show-si: auto, preferred-units: auto, strict: auto, inline-steps: auto, implies: auto, approximate: auto, block: auto, max-solutions: auto,
  defined-style: auto, errors: auto,
) = {
  if eqs.named().len() > 0 {
    let k = eqs.named().keys().first()
    return _err-now("unknown argument '" + k + "' (arguments: unit, output, steps, layout, inline, unknown, root, guess, listed and the options " + _DEF.keys().filter(k => k not in ("steps", "layout", "units")).join(", ") + ")")
  }
  let lc = _check(_given((
    digits: digits, trailing-zeros: trailing-zeros, separator: separator, grouping: grouping, scientific: scientific, engineering: engineering, multiplication: multiplication, form: form, max-denominator: max-denominator, fractions: fractions,
    prefixes: prefixes, show-si: show-si, preferred-units: preferred-units, strict: strict, inline-steps: inline-steps, implies: implies, approximate: approximate, block: block, max-solutions: max-solutions,
    defined-style: defined-style, errors: errors,
  )))
  if _E(lc) { return _err-now(lc.err) }
  let dl = _disp(steps, layout, inline)
  if _E(dl) { return _err-now(dl.err) }
  for (n, v) in (output: output, listed: listed) { if type(v) != bool { return _err-now(n + ": true or false, got " + _tn(v)) } }
  if not (unknown == none or type(unknown) == str or (type(unknown) == array and unknown.len() > 0 and unknown.all(x => type(x) == str))) {
    return _err-now("unknown: a name like \"t\" or an array of names like (\"x\", \"y\")")
  }
  if type(root) not in (type(auto), int, function) { return _err-now("root: auto, a number (1, 2, …) or a function like x => x > 0, got " + _tn(root)) }
  let gok(g) = type(g) in (str, content, int, float)
  if not (guess == none or gok(guess) or (type(guess) == dictionary and guess.values().all(gok))) {
    return _err-now("guess: a value like \"-1 A\", or a dictionary like (U: \"5 V\")")
  }
  // unit: "mA", $"mA"$ or (I: "mA")
  let uok(u) = type(u) in (str, content)
  if not (unit == none or uok(unit) or (type(unit) == dictionary and unit.values().all(uok))) {
    return _err-now("unit: a unit like \"mA\", or for several unknowns a dictionary like (I: \"mA\"), got " + _tn(unit))
  }
  let un = if type(unit) == dictionary { unit.pairs().map(((k, u)) => (k, _str(u))).to-dict() } else if unit != none { _str(unit) }
  let b = if type(un) == dictionary { un.values().find(_E) } else if _E(un) { un }
  if b != none { return _err-now(b.err) }
  // the equations
  let pos = eqs.pos()
  if pos.len() == 0 { return _err-now("def needs something to define, e.g. def(\"I = 30 mA\")") }
  let bad = pos.find(x => type(x) not in (str, content))
  if bad != none { return _err-now("expected an equation as a string or math, got " + repr(bad) + " – e.g. def(\"I = 30 mA\")") }
  // math keeps its quotes, so "V" (a unit) and V (a variable) stay apart; it is read once the variables are known
  let strs = pos.map(x => if type(x) == content and x.func() == math.equation { let m = _str(x, q: true); if _E(m) { m } else { (math: m) } } else { _str(x) })
  let b = _first-err(strs)
  if b != none { return _err-now(b.err) }
  // a unit as the 2nd positional argument: solve("Q0/I", "h")
  for s in strs.slice(1).filter(s => type(s) == str).map(str.trim) {
    if s != "" and not s.contains("=") and _isu(s) { return _err-now("'" + s + "' looks like a unit – pass it as unit: \"" + s + "\"") }
  }
  // inline without explicit steps: the shorter inline-steps
  let lc = lc + (if inline and steps == auto { (steps: auto) } else { (:) }) + dl
  _def(strs, un, (unknown: unknown, root: root, guess: guess), lc, output, listed)
}
/// Solves equations and shows the way: equation ⇒ rearranged formula = numbers = result.
///
/// Solves for all unknowns, i.e. all variables that aren't defined yet (one unknown per
/// equation), and stores the results like `def`. The unknown can be on either side,
/// also inside a function call. If the unknown occurs once it is isolated symbolically;
/// polynomials give all real roots; anything else is solved numerically.
///
/// ```typ
/// #def("Q0 = 3450 mAh", "I = 30 mA")
/// #solve("Q0/2 = I t", unit: "h")          // Q₀/2 = I t ⇒ t = Q₀/(2I) = … = 57.5 h
/// #solve("I", unit: "A")                    // no '=': convert, I = 30 mA = 0.03 A
/// #solve("x^2 + 2x - 3 = 0")                // all real roots
/// #def("P1 = 2 W", "R1 = 50 Ω")
/// #solve("P1 = U1 I1", "U1 = R1 I1")        // a system
/// Runtime: #solve("Q0/I", unit: "h", inline: true, steps: "value")   // 115 h
/// #solve("Q0/4 = I t2", unit: "h", layout: "column", steps: "formula")
/// ```
///
/// - ..eqs (str, content): The equations (or a single expression without `=` to evaluate).
/// - unit (none, str, content, dictionary): Unit of the result: `"mA"` (or math `$"mA"$`). For a system a dictionary per unknown: `(I: "mA", U: "V")`. Without it: the SI unit with an automatic prefix, or the non-SI unit of the inputs (h, mAh). If the result has another unit (`"x = f(1)"` gives volts, `unit: "A"`), that is an error.
/// - output (bool): `false` defines silently, like `def`.
/// - steps (auto, str): What is shown: `"full"`: equation ⇒ formula = numbers = result · `"formula"`: without the numbers · `"result"`: `t = 57.5 h` · `"value"`: just `57.5 h`. `auto`: the option `steps` (default `"full"`), or `inline-steps` with `inline: true`.
/// - layout (auto, str): `"row"`: all steps in one line · `"column"`: one step per line, aligned at `=`. `auto`: the option `layout` (default `"row"`).
/// - inline (bool): In the running text instead of a display block; `steps` default to `inline-steps` (`"result"`).
/// - unknown (none, str, array): What to solve for, `"t"` or `("x", "y")`. Only needed when it isn't clear; by default all variables that aren't defined yet are the unknowns (one per equation). If everything is defined, a lone variable on either side is recomputed.
/// - root (auto, int, function): Which solution is stored when there are several: `2` (1-based), or a test like `x => x > 0` (for systems it gets a dictionary). `auto`: the only all-positive one, else the first.
/// - guess (none, str, content, int, float, dictionary): Newton start value instead of the search: `"-1 A"`, or `(U: "5 V")` for systems.
/// - listed (bool): `false` hides it from `defined`.
/// - digits (auto, int): Significant digits of computed values, 1…15. Default `4`: `57.5 h`, `123500`.
/// - trailing-zeros (auto, bool): Keep trailing zeros up to `digits` (`2.500 V`). Default `false`.
/// - separator (auto, str): Decimal separator, any string like `","`. `auto` (default): from the document language, `,` for de, fr, it, … and `.` otherwise.
/// - grouping (auto, none, str, symbol, content): Digit grouping for integer parts with 5+ digits, e.g. `sym.space.thin` → `12 345`. Default `none`.
/// - scientific (auto, none, array): `(low, high)`: plain notation while the exponent `e` is in `low ≤ e < high`, else `2.5 · 10⁻⁷`. Default `(-3, 6)`; `none` never switches.
/// - engineering (auto, bool): Engineering notation, exponents in steps of 3. Default `false`.
/// - multiplication (auto, str): `"dot"` (default, `2 · 10⁶`) or `"times"` (`2 × 10⁶`).
/// - form (auto, str): How values are written. `"auto"` (default): as typed, results rounded · `"decimal"`: everything rounded to `digits` · `"fraction"`: exact fractions (`⅙ A`) · `"input"`: given values exactly as typed.
/// - max-denominator (auto, int): Largest denominator for `form: "fraction"`. Default `1000`.
/// - fractions (auto, str): How fractions are written: `"stacked"` (default) or `"slash"` (`1/2`).
/// - prefixes (auto, str, none, array): Prefixes picked for results: `"all"` (default: a f p n µ m k M G T; times from a minute on in min or h, not ks), `none` (base unit only) or an array like `("m", "k")` (`"u"` = µ).
/// - show-si (auto, bool): `defined` also shows the SI value (`Q₀ = 3450 mAh = 12420 C`). Default `false`.
/// - preferred-units (auto, str, array): Units for results of their dimension, `("bar", "kWh")`, before the unit of the inputs and the SI unit.
/// - strict (auto, bool): Unit names can't be variable names, and units in math must be quoted (`$5 "V"$`), see [Units and variables](#units-and-variables).
/// - inline-steps (auto, str): Steps for `inline: true` and inline code: `"full"`, `"formula"`, `"result"` (default) or `"value"`.
/// - implies (auto, content, symbol, str): What is written between steps, e.g. `sym.arrow.r.long` or `[and]`; ⇒ by default.
/// - approximate (auto, bool): Write `≈` when the shown result is rounded. Default `true`.
/// - block (auto, bool): Display equations (centred, default) or inline.
/// - max-solutions (auto, int): How many solutions are listed; all are found, `root` picks among all.
/// - defined-style (auto, str): How `defined` looks: `"grid"` (default: columns side by side, aligned at `=`), `"column"`, `"inline"` or `"list"`.
/// - errors (auto, str): `"document"` (default): problems are shown as red notes · `"panic"`: stop the compilation.
/// -> content
#let solve(
  ..eqs,
  unit: none, output: true, steps: auto, layout: auto, inline: false,
  unknown: none, root: auto, guess: none, listed: true,
  digits: auto, trailing-zeros: auto, separator: auto, grouping: auto, scientific: auto, engineering: auto, multiplication: auto, form: auto, max-denominator: auto, fractions: auto,
  prefixes: auto, show-si: auto, preferred-units: auto, strict: auto, inline-steps: auto, implies: auto, approximate: auto, block: auto, max-solutions: auto,
  defined-style: auto, errors: auto,
) = def(
  ..eqs,
  unit: unit, output: output, steps: steps, layout: layout, inline: inline,
  unknown: unknown, root: root, guess: guess, listed: listed,
  digits: digits, trailing-zeros: trailing-zeros, separator: separator, grouping: grouping, scientific: scientific, engineering: engineering, multiplication: multiplication, form: form, max-denominator: max-denominator, fractions: fractions,
  prefixes: prefixes, show-si: show-si, preferred-units: preferred-units, strict: strict, inline-steps: inline-steps, implies: implies, approximate: approximate, block: block, max-solutions: max-solutions,
  defined-style: defined-style, errors: errors,
)

// one line of a code block: "U = R I -> mV" (a system: equations separated by ';'; comments with //; "= expr" prints a value)
#let _line(s, block) = {
  let s = s.split("//").first().trim()
  if s == "" { return none }
  let (e, u) = if s.contains("->") { let p = s.split("->"); (p.at(0), p.at(1).trim()) } else { (s, none) }
  let lc = (block: block) + if not block { (steps: auto) } else { (:) }
  if e.trim().starts-with("=") { return _def((e.trim().slice(1),), u, (:), lc + (steps: "value"), true, false) }
  _def(e.split(";").map(str.trim).filter(x => x != ""), u, (:), lc, true, true)
}
// expression tree -> string _parse reads back the same
#let _src(e) = {
  let (k, ..a) = e
  let w(x) = "(" + _src(x) + ")"
  if k == "n" { repr(float(a.first())) }
  else if k in ("c", "v") { a.first() }
  else if k == "q" { let q = a.first(); if q.u == "" { repr(float(q.n)) } else { "[" + repr(float(q.n)) + " " + q.u + "]" } }
  else if k == "+" { a.map(w).join(" + ") }
  else if k == "*" { a.map(w).join(" * ") }
  else if k == "-" { "-" + w(a.first()) }
  else if k in ("/", "^") { w(a.first()) + " " + k + " " + w(a.last()) }
  else if k == "tuple" { a.map(_src).join(", ") }
  else { a.first() + w(a.last()) }
}
// where two steps of a chain differ only by a variable written out (l/A vs l/(b h)): (("A", tree of b h), …), or none
#let _diff(a, b) = {
  if a == b { return () }
  if a.at(0) == "v" and b.at(0) == "v" { return ((a.at(1), b), (b.at(1), a)) }
  if a.at(0) == "v" { return ((a.at(1), b),) }
  if b.at(0) == "v" { return ((b.at(1), a),) }
  if a.at(0) != b.at(0) or a.len() != b.len() { return none }
  let r = ()
  for (x, y) in a.slice(1).zip(b.slice(1)) {
    if type(x) != array or type(y) != array { if x != y { return none }; continue }
    let d = _diff(x, y)
    if d == none { return none }
    r += d
  }
  r
}
// a math equation in a solve-block: "I = 30 mA" is defined silently, the equation stays as written.
// Equations without '=', derivations (⇒, ≈, <, …) or content that isn't a formula (alignment, line breaks, calls) are left alone.
#let _math-def(it) = context {
  if _busy.get() > 0 { return it }
  let cf = _cf.get()
  let U = _UT(cf)
  let s = _str(it.body, q: true)
  if _E(s) or s.match(regex("[⇒⇔⟹⟺→←↔≈≠≡∼∝∈]")) != none { return it }
  let fail(e) = it + _errc(e.err, cf, wide: it.block)
  let rs = s.matches(regex("[<>≤≥]"))
  if rs.len() > 0 {
    // a bound R ≤ U/I: a definition only with exactly one unknown (0 < x < 1, a < b with known a, b stay prose)
    if rs.len() > 1 or s.contains("=") { return it }
    let rel = rs.first().text
    let vars = _vars-of(_st.get())
    let fns = _st.get().at("#fn", default: (:))
    let p = s.split(rel).map(x => _math-src(x, vars, cf))
    let b = _first-err(p)
    if b != none { return fail(b) }
    let p = p.map(str.trim)
    if p.any(x => x == "") { return it }
    let es = p.map(x => _parse(x, vars, f: fns, U: U))
    if es.any(_E) or es.map(_vars).flatten().dedup().filter(v => v not in vars).len() != 1 { return it }
    return it + _def((p.join(" " + rel + " "),), none, (:), (block: it.block), false, true)
  }
  let p = s.split("=")
  if p.len() < 2 or p.any(x => x.trim() == "") { return it }
  // a worked chain R = 7.2 kΩ = 7200 Ω: the first '=' defines, the rest are steps
  let vars = _vars-of(_st.get())
  let ms = p.map(x => _math-src(x, vars, cf))
  let b = _first-err(ms)
  if b != none { return fail(b) }
  let ms = ms.map(str.trim)
  let lhs = ms.at(0)
  let eq = lhs + " = " + ms.at(1)
  // steps that write an undefined variable out define it: R = ρ l/A = ρ l/(b h) gives A = b h
  let fns = _st.get().at("#fn", default: (:))
  let es = ms.slice(1).map(x => _parse(x, vars, f: fns, keep: true, U: U))
  let imp = ()
  let ds = range(es.len() - 1).map(i => if es.any(_E) { none } else { _diff(es.at(i), es.at(i + 1)) })
  if not es.any(_E) {
    let cs = ds.filter(c => c != none).fold((), (acc, c) => acc + c)
    // only variables that aren't defined, with one consistent expression of other variables
    let cs = cs.filter(((x, e)) => x not in vars and x not in _vars(e) and _vars(e).len() > 0)
    for (x, e) in cs {
      if cs.all(((y, f)) => y != x or f == e) and not cs.any(((y, f)) => f == ("v", x)) and x not in imp.map(c => c.at(0)) { imp.push((x, e)) }
    }
  }
  // implied definitions computable now go first; the main equation is the most written-out step with the fewest unknowns
  // (R = ρ l/(b h) for b), only among steps reached by substitutions (not = 0.2 Ω); the other implied ones follow
  let now = imp.filter(((x, e)) => _vars(e).all(v => v in vars))
  let known = vars.keys() + now.map(c => c.at(0))
  let le = _parse(lhs, vars, f: fns, U: U)
  let k = ds.position(c => c == none)
  let k = if k == none { ds.len() } else { k }
  if imp.len() > 0 and not _E(le) {
    let n(i) = (_vars(le) + _vars(es.at(i))).dedup().filter(v => v not in known).len()
    let best = range(k + 1).sorted(key: i => (n(i), -i)).first()
    eq = lhs + " = " + ms.at(best + 1)
  }
  let one(x, e) = _def((x + " = " + _src(e),), none, (:), (block: it.block), false, true)
  it + now.map(((x, e)) => one(x, e)).join() + _def((eq,), none, (:), (block: it.block), false, true) + imp.filter(c => c not in now).map(((x, e)) => one(x, e)).join()
}
/// A scope in which math and code are calculations.
///
/// `#show: solve-block` calculates the whole rest of the document; `#solve-block[…]` only its body, whose definitions are dropped at its end. How results look is set with `solve-config`, not here.
///
/// ```typ
/// #show: solve-block
/// The load draws $I = "30 mA"$ (#solve("I", unit: "A", steps: "value", inline: true)),
/// the battery holds $Q_0 = 3450 "mAh"$, so it lasts $t = Q_0 / I$, ```solveng = t -> h```.
/// ```
///
/// **Math.** Every math equation with a `=` is a definition, exactly like `def`: `$I = "30 mA"$`, `$P = U I$`, `$Q_0/2 = I t$`. The equation stays as you wrote it; problems are shown next to it.
///
/// - An inequality with exactly one unknown (`$R <= U/I$`) defines it like `#solve("R <= U/I")`; `$0 < x < 1$` and inequalities between known values stay prose.
/// - Equations without `=` (`$x^2$`), derivations with `⇒`, `≈`, … (`$ Q = I t => t = Q/I $`), equations with alignment or line breaks (`$ U &= R I \ &= 6 V $`) or with embedded calls are left alone.
/// - In a worked chain `$R = 7.2 "k"Omega = 7200 Omega$` the first `=` defines, the rest are steps.
/// - A step that writes an undefined variable out defines it: `$R = rho dot frac(l, A) = rho dot frac(l, b dot h)$` defines `A = b h`; with `R` given instead, `b` is solved from the most written-out step (`R = ρ l/(b h)`) and `A` follows.
/// - A number followed by units is a value (`frac(3450 "mAh", 30 "mA")`, `9.81 "m"/"s"^2`), `0,95` is a decimal number. Quoted units (`"h"`) are always units; a bare letter that is a defined variable is that variable (`$3 h$` with a variable `h` is 3 times h).
///
/// **Code.** Code tagged `solveng` is calculated:
///
/// - A code block ```` ```solveng ````: every line is a definition that shows itself, exactly like `#solve(line)`.
/// - Inline code ```` ```solveng t = Q0/I -> h``` ```` defines and shows inline with `inline-steps` (default `"result"`: t = 115 h).
/// - ```` ```solveng = Q0/I -> h``` ````: just the value (115 h), nothing is defined.
/// - Per line: `-> unit` for the result unit, `;` separates the equations of a system (`x + y = 3; x - y = 1`), `//` starts a comment.
///
/// Code without a language is left alone, so code samples stay code samples; `plain-code: true` calculates it as well. Code with another language (```` ```py ````) is always left alone. The output of `def`, `solve`, `defined` and `graph` is never read as a definition again.
///
/// **Starting over.** `reset` starts over at every match; `#reset` inside a solve-block does the same once: back to how the block started (with `inherit: true` the outer definitions stay). After the block the outer definitions come back.
///
/// ```typ
/// #show: solve-block.with(reset: heading)                    // every heading
/// #show: solve-block.with(reset: heading.where(level: 1))    // only top-level ones
/// #show: solve-block.with(reset: heading, inherit: true)     // keep the definitions made before the block
/// ```
///
/// - ..body (content): The content.
/// - inherit (bool): See the definitions made before the block (also after each `reset`).
/// - equations (bool): Read math equations as definitions. `false` leaves math alone.
/// - plain-code (bool): Also evaluate code without a language (```` ``` ```` blocks and `` `inline` `` code), not only code tagged `solveng`.
/// - reset (none, function, selector): Start over at every match, e.g. `heading` (every heading) or `heading.where(level: 1)`: the definitions made since are forgotten, like `#reset`.
/// -> content
#let solve-block(
  ..body,
  inherit: false, equations: true, plain-code: false, reset: none,
) = {
  let b = body.pos().at(0, default: [])
  if body.named().len() > 0 {
    let k = body.named().keys().first()
    return _err-now("unknown argument '" + k + "' for solve-block (arguments: inherit, equations, plain-code, reset)" + if k in _DEF { " – options go in solve-config(" + k + ": …)" } else { "" }) + b
  }
  if body.pos().len() > 1 { return _err-now("solve-block takes one body") + b }
  if type(b) != content { return _err-now("solve-block: the body must be content, got " + _tn(b)) }
  for (n, v) in (inherit: inherit, equations: equations, plain-code: plain-code) { if type(v) != bool { return _err-now(n + ": true or false, got " + _tn(v)) + b } }
  if type(reset) not in (type(none), function, selector, label) { return _err-now("reset: none or what to start over at, like heading or heading.where(level: 1), got " + _tn(reset)) + b }
  // "^": the state outside, restored at the end; "^0": the state at the start, for reset
  _st.update(d => { let n = if inherit { d } else { (:) }; n.insert("^", d); n.insert("^0", n); n })
  context {
    // raw text is set smaller, monospaced and in English; definitions use the surrounding text and language
    let (size, font, lang, region) = (text.size, text.font, text.lang, text.region)
    let out(it, sep) = text(size: size, font: font, lang: lang, region: region, it.text.split("\n").map(l => _line(l, it.block)).filter(x => x != none).join(sep))
    show raw.where(lang: "solveng"): it => out(it, if it.block { none } else { [, ] })
    show raw.where(lang: none): it => if plain-code { out(it, none) } else { it }
    show std.math.equation: it => if equations { _math-def(it) } else { it }
    // start over at each heading (or whatever reset selects): back to the state at the start of the block
    show selector(if reset == none { <solveng-never> } else { reset }): it => {
      if reset != none { _st.update(_restart) }
      it
    }
    b
  }
  _st.update(d => d.at("^"))
}
