// Options, their checks, and the two states: definitions and options.

#let _st = state("solveng", (:))
// the export target; Typst 0.14 only knows target() with --features html, else it is paged
#let _target() = if "target" in dictionary(std) { std.target() } else { "paged" }
// ---------- configuration: #solve-config(..) globally, #solve-config(..)[..] / #show: solve-config.with(..) scoped, or per call ----------
#let _DEF = (
  // numbers
  digits: 4, trailing-zeros: false, separator: auto, grouping: none, scientific: (-3, 6), engineering: false, multiplication: "dot",
  form: "auto", max-denominator: 1000, fractions: "stacked",
  // units
  prefixes: "all", show-si: false, units: (:), preferred-units: (), strict: false,
  // output
  steps: "full", inline-steps: "result", layout: "row", implies: sym.arrow.r.double, approximate: true, block: true, max-solutions: 6,
  // output of defined
  defined-style: "grid",
  // problems: shown in the document, or stop the compilation
  errors: "document",
)
#let _CH = (
  form: ("auto", "decimal", "fraction", "input"), multiplication: ("dot", "times"), fractions: ("stacked", "slash"), steps: ("full", "formula", "result", "value", auto), inline-steps: ("full", "formula", "result", "value"),
  layout: ("row", "column"), errors: ("document", "panic"), defined-style: ("grid", "column", "inline", "list"),
)
// allowed types per option
#let _TY = (
  digits: (int,), trailing-zeros: (bool,), separator: (type(auto), str), grouping: (type(none), str, symbol, content), scientific: (type(none), array), engineering: (bool,),
  multiplication: (str,), form: (str,), max-denominator: (int,), fractions: (str,), prefixes: (str, type(none), array), show-si: (bool,),
  units: (dictionary,), preferred-units: (array, str), strict: (bool,),
  steps: (str, type(auto)), inline-steps: (str,), layout: (str,), implies: (content, symbol, str), approximate: (bool,), block: (bool,),
  max-solutions: (int,), defined-style: (str,), errors: (str,),
)
#let _tyname(ts) = ts.map(t => if t == type(none) { "none" } else if t == type(auto) { "auto" } else { str(t) }).join(" or ")
// global: units can only be set with solve-config (the unit table is built there)
#let _check(o, global: false) = {
  if type(o) != dictionary { return (err: "config: expected a dictionary of options like (digits: 3), got " + str(type(o))) }
  let o = o
  for (k, v) in o {
    if k not in _DEF { return (err: "unknown option '" + k + "' (options: " + _DEF.keys().join(", ") + ")") }
    if type(v) not in _TY.at(k) { return (err: k + ": expected " + _tyname(_TY.at(k)) + ", got " + repr(v)) }
    if k in _CH and v not in _CH.at(k) { return (err: k + ": " + repr(v) + " – use one of " + _CH.at(k).map(repr).join(", ")) }
  }
  if "digits" in o and (o.digits < 1 or o.digits > 15) { return (err: "digits must be 1…15") }
  if "max-denominator" in o and o.max-denominator < 1 { return (err: "max-denominator must be ≥ 1") }
  if "max-solutions" in o and o.max-solutions < 1 { return (err: "max-solutions must be ≥ 1") }
  if "scientific" in o and o.scientific != none and (o.scientific.len() != 2 or o.scientific.any(x => type(x) != int)) { return (err: "scientific must be (low, high) with integers, or none") }
  if "prefixes" in o and type(o.prefixes) == str and o.prefixes != "all" { return (err: "prefixes: \"all\", none or an array like (\"m\", \"k\")") }
  if "prefixes" in o and type(o.prefixes) == array and o.prefixes.any(p => type(p) != str) { return (err: "prefixes: the array must hold strings like \"m\"") }
  if "units" in o and not global { return (err: "units can only be set with solve-config, e.g. #solve-config(units: (bar: \"100 kPa\"))") }
  if "units" in o and o.units.values().any(v => type(v) not in (str, content, type(none))) { return (err: "units: a dictionary of definitions like (bar: \"100 kPa\", rpm: \"1/min\"), or none to remove a unit: (T: none)") }
  if "preferred-units" in o { if type(o.preferred-units) == str { o.preferred-units = (o.preferred-units,) }; if o.preferred-units.any(u => type(u) != str) { return (err: "preferred-units: units like (\"kWh\", \"mm\")") } }
  o
}
// named option arguments -> the ones actually given (auto = keep the current setting)
#let _given(o) = o.pairs().filter(((k, v)) => v != auto).to-dict()
#let _cf = state("solveng-cf", _DEF)
